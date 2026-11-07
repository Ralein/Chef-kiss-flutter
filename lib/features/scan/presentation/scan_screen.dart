import 'dart:typed_data';

import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../../app/chef_toast_service.dart';
import '../../../app/providers.dart';
import '../../../app/widgets/common_widgets.dart';
import '../../../app/widgets/food_art.dart';
import '../../../app/widgets/kitchen_format.dart';
import '../../../core/ai/ai_connection.dart';
import '../../../core/media/photo_picker.dart';
import '../../imports/presentation/import_flows.dart';
import '../../recipe_detail/presentation/widgets/recipe_sheets.dart' show showTextPromptDialog;

/// What the analysis screen needs: the photo, what it shows, and any note.
class ScanRequest {
  final ScanMode mode;

  /// The photo; null when the food was described in [note] instead.
  final Uint8List? bytes;
  final String? note;
  const ScanRequest({required this.mode, this.bytes, this.note});
}

extension ScanModeCopy on ScanMode {
  String get label => switch (this) {
        ScanMode.meal => 'Meal',
        ScanMode.ingredients => 'Ingredients',
        ScanMode.recipeCard => 'Recipe',
      };

  IconData get icon => switch (this) {
        ScanMode.meal => LucideIcons.utensils,
        ScanMode.ingredients => LucideIcons.refrigerator,
        ScanMode.recipeCard => LucideIcons.scrollText,
      };

  String get headline => switch (this) {
        ScanMode.meal => 'Snap your plate',
        ScanMode.ingredients => 'Snap your fridge or groceries',
        ScanMode.recipeCard => 'Snap a recipe',
      };

  String get explainer => switch (this) {
        ScanMode.meal => 'Get calories, macros and allergens for a meal, then log it.',
        ScanMode.ingredients => 'Snap or type what you have, and Chef’s Kiss AI suggests what to cook.',
        ScanMode.recipeCard => 'Turn a cookbook page or handwritten card into a saved recipe.',
      };
}

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  ScanMode _mode = ScanMode.meal;
  final _note = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _capture(ImageSource source) async {
    if (_busy) return;
    setState(() => _busy = true);
    final picked = await PhotoPicker.pick(source, maxEdge: _mode == ScanMode.recipeCard ? 2048 : 1568);
    if (!mounted) return;
    setState(() => _busy = false);
    if (picked.isFailure) {
      ChefToastService.show(
        context: context,
        title: picked.error!.message,
        description: picked.error!.recoveryAction,
        type: ChefToastType.error,
      );
      return;
    }
    final bytes = picked.orNull;
    if (bytes == null) return;

    if (_mode == ScanMode.recipeCard) {
      await startImport(context, ref, buildSource(ImportSourceKind.image, bytes: bytes));
    } else {
      await context.push('/analyze', extra: ScanRequest(mode: _mode, bytes: bytes, note: _note.text.trim()));
    }
  }

  /// Typing instead of a photo: a meal is described, ingredients listed,
  /// a recipe pasted.
  Future<void> _type() async {
    switch (_mode) {
      case ScanMode.ingredients:
        await context.push('/ideas');
      case ScanMode.recipeCard:
        await showPasteTextSheet(context, ref);
      case ScanMode.meal:
        final text = await showTextPromptDialog(
          context,
          title: 'What did you eat?',
          hint: 'e.g. A bowl of chicken chow mein and a glass of orange juice',
          confirmLabel: 'Analyze',
          maxLines: 4,
        );
        if (text == null || text.trim().isEmpty || !mounted) return;
        final detail = _note.text.trim();
        await context.push(
          '/analyze',
          extra: ScanRequest(mode: ScanMode.meal, note: detail.isEmpty ? text.trim() : '${text.trim()}. $detail'),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final t = context.chefText;
    final ai = ref.watch(aiConnectionProvider);
    final aiReady = ai.valueOrNull?.isAvailable == true;
    final today = ref.watch(foodLogDayProvider(dayKeyFor(DateTime.now()))).valueOrNull ?? const [];
    final recentScans = today.where((e) => e.source == FoodLogSource.scan).toList().reversed.take(8).toList();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                Semantics(header: true, child: Text('Scan', style: t.headlineMedium)),
                const SizedBox(height: 4),
                Text('Point your camera at food — Chef’s Kiss does the rest.', style: t.bodyMedium?.copyWith(color: c.contentSecondary)),
                const SizedBox(height: 20),
                SegmentedButton<ScanMode>(
                  segments: [
                    for (final m in ScanMode.values)
                      ButtonSegment(value: m, label: Text(m.label)),
                  ],
                  selected: {_mode},
                  showSelectedIcon: false,
                  onSelectionChanged: (s) => setState(() => _mode = s.first),
                ),
                const SizedBox(height: 10),
                Text(_mode.explainer, style: t.bodySmall),
                const SizedBox(height: 16),
                if (ai.isLoading)
                  const LinearProgressIndicator()
                else if (!aiReady) ...[
                  const AiSetupCard(feature: 'food scanning'),
                  const SizedBox(height: 16),
                ],
                _CaptureCard(
                  mode: _mode,
                  enabled: aiReady && !_busy,
                  busy: _busy,
                  onCamera: PhotoPicker.cameraAvailable ? () => _capture(ImageSource.camera) : null,
                  onGallery: () => _capture(ImageSource.gallery),
                  // No photo needed: every mode can be typed instead.
                  typeLabel: switch (_mode) {
                    ScanMode.meal => 'Describe it instead',
                    ScanMode.ingredients => 'Type them instead',
                    ScanMode.recipeCard => 'Type or paste it instead',
                  },
                  onType: aiReady && !_busy ? _type : null,
                ),
                if (_mode != ScanMode.recipeCard) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _note,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Add a detail (optional)',
                      hintText: 'e.g. “I ate half”, “dressing on the side”, “oat milk”',
                      prefixIcon: Icon(LucideIcons.notebookPen),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                _TipsCard(mode: _mode),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(LucideIcons.lock, size: 16, color: c.contentSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Photos go to Chef’s Kiss AI, which runs on free shared models that may keep what they '
                        'see. Nutrition values are estimates, not medical advice.',
                        style: t.bodySmall,
                      ),
                    ),
                  ],
                ),
                if (recentScans.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  SectionHeader(
                    'Scanned today',
                    trailing: TextButton(onPressed: () => context.go('/log'), child: const Text('Food log')),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 148,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: recentScans.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final e = recentScans[i];
                        return SizedBox(
                          width: 132,
                          child: ChefCard(
                            padding: EdgeInsets.zero,
                            onTap: () => context.go('/log'),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(height: 84, child: FoodPicture(imagePath: e.imagePath, title: e.title, radius: 0)),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(e.title, style: t.labelMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                                      Text('${KitchenFormat.kcal(e.nutrition.calories)} kcal', style: t.bodySmall),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CaptureCard extends StatelessWidget {
  final ScanMode mode;
  final bool enabled;
  final bool busy;
  final VoidCallback? onCamera;
  final VoidCallback onGallery;

  /// Typing instead of a photo, and what the button says.
  final VoidCallback? onType;
  final String typeLabel;

  const _CaptureCard({
    required this.mode,
    required this.enabled,
    required this.busy,
    required this.onCamera,
    required this.onGallery,
    this.onType,
    this.typeLabel = 'Type it instead',
  });

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final t = context.chefText;
    return ChefCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(color: c.tomatoSoft, shape: BoxShape.circle),
            child: busy
                ? const Padding(padding: EdgeInsets.all(28), child: CircularProgressIndicator(strokeWidth: 3))
                : Icon(mode.icon, size: 40, color: c.accentTomato),
          ),
          const SizedBox(height: 16),
          Text(mode.headline, style: t.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          // Side by side, each half the card: one row however long the labels.
          Row(
            children: [
              if (onCamera != null) ...[
                Expanded(
                  child: FilledButton.icon(
                    onPressed: enabled ? onCamera : null,
                    icon: const Icon(LucideIcons.camera, size: 18),
                    label: const FittedBox(child: Text('Take photo')),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: enabled ? onGallery : null,
                    icon: const Icon(LucideIcons.image, size: 18),
                    label: const FittedBox(child: Text('Choose photo')),
                  ),
                ),
              ] else
                Expanded(
                  child: FilledButton.icon(
                    onPressed: enabled ? onGallery : null,
                    icon: const Icon(LucideIcons.image, size: 18),
                    label: const Text('Choose photo'),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onType,
            icon: const Icon(LucideIcons.keyboard, size: 18),
            label: Text(typeLabel),
          ),
        ],
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  final ScanMode mode;
  const _TipsCard({required this.mode});

  @override
  Widget build(BuildContext context) {
    final t = context.chefText;
    final c = context.chefColors;
    final tips = switch (mode) {
      ScanMode.meal => [
          'Shoot from above in good light with the whole plate in frame.',
          'Include a fork, hand or the plate rim so portion size can be judged.',
          'One meal per photo — scan drinks separately.',
        ],
      ScanMode.ingredients => [
          'Open the fridge door wide or lay groceries out on the counter.',
          'Turn labels toward the camera when you can.',
        ],
      ScanMode.recipeCard => [
          'Lay the page flat and fill the frame with the text.',
          'Avoid glare — tilt the page away from overhead lights.',
        ],
    };
    return ChefCard(
      color: c.surfaceRaised,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('For best results', style: t.labelLarge),
          const SizedBox(height: 8),
          for (final tip in tips)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_rounded, size: 16, color: c.accentHerb),
                  const SizedBox(width: 8),
                  Expanded(child: Text(tip, style: t.bodyMedium)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
