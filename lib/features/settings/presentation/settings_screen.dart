import 'package:app_contracts/app_contracts.dart';
import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/chef_toast_service.dart';
import '../../../app/providers.dart';
import '../../../app/widgets/common_widgets.dart';
import '../../../app/widgets/kitchen_format.dart';
import '../../../core/ai/ai_usage.dart';
import '../../../core/platform/tts_voices.dart';
import '../../../core/platform/flutter_tts_speech_service.dart';
import '../../backup/presentation/backup_export_dialog.dart';
import '../../backup/presentation/backup_restore_dialog.dart';
import '../../illustrations/presentation/illustration_approval_screen.dart';
import '../../sync/presentation/cloud_sync_section.dart';
import '../../voice/listen_button.dart';
import '../../voice/read_aloud_controller.dart';
import '../../voice/spoken_text.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  /// `ai` opens the API-key sheet directly (used by "Set up AI" prompts).
  final String? initialSection;
  const SettingsScreen({super.key, this.initialSection});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final t = context.chefText;
    final env = ref.watch(appEnvironmentProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              children: [
                Semantics(header: true, child: Text('Settings', style: t.headlineMedium)),
                const SizedBox(height: 16),
                const _AiSection(),
                const SizedBox(height: 16),
                const _AppearanceSection(),
                const SizedBox(height: 16),
                const _VoiceSection(),
                const SizedBox(height: 16),
                const _GoalsSection(),
                const SizedBox(height: 16),
                const _DataSection(),
                if (env.flags.cloudSyncPreviewEnabled || env.flags.illustrationGovernanceEnabled) ...[
                  const SizedBox(height: 16),
                  _DeveloperSection(env: env),
                ],
                const SizedBox(height: 16),
                _AboutSection(env: env),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _Section({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    return ChefCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: c.accentTomato),
              const SizedBox(width: 10),
              Expanded(child: Semantics(header: true, child: Text(title, style: context.chefText.titleMedium))),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

// --- AI -----------------------------------------------------------------------

class _AiSection extends ConsumerWidget {
  const _AiSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.chefColors;
    final t = context.chefText;
    return _Section(
      title: 'AI & Scanning',
      icon: LucideIcons.chefHat,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(LucideIcons.badgeCheck, color: c.stateSuccess),
          title: const Text('Chef’s Kiss AI · free'),
          subtitle: const Text(
            'Scans food, reads recipe photos, writes recipes, suggests what to cook and fills in nutrition. '
            'Nothing to set up.',
          ),
        ),
        const _RateLimitTile(),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          child: Text(
            'Runs on free, shared AI models. What you choose to analyze is sent to them '
            'and may be logged, so leave personal details out. Your recipes and food log stay on this device.',
            style: t.bodySmall,
          ),
        ),
      ],
    );
  }
}

/// How busy Chef's Kiss AI is: requests this session, and when it's free
/// again after every model was busy.
class _RateLimitTile extends ConsumerWidget {
  const _RateLimitTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.chefColors;
    final t = context.chefText;
    final meter = ref.watch(aiUsageProvider);
    final usage = meter.usage;
    final limited = usage.limitedAt(DateTime.now());
    final left = limited ? 0 : meter.leftThisHour;
    const limit = AiUsageMeter.hourlyLimit;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Free requests this hour', style: t.bodyMedium)),
              Text('$left of $limit left', style: t.labelLarge),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: left / limit,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
            color: limited || left < limit * 0.1 ? c.stateWarning : c.accentHerb,
            backgroundColor: c.meterTrack(c.accentHerb),
          ),
          const SizedBox(height: 6),
          Text(
            limited
                ? 'Busy — free again after ${TimeOfDay.fromDateTime(usage.limitedUntil!).format(context)}'
                : 'Counted on this phone; phones on the same Wi-Fi share the allowance.',
            style: t.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// The reading voice: automatic (the most natural American English voice on
/// this phone) or any English voice it has, each with a sample to hear.
class _VoiceTile extends ConsumerWidget {
  const _VoiceTile();

  static const sample = 'Toast the brioche until golden, then pile on the smashed avocado.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voices = ref.watch(ttsVoicesProvider).valueOrNull ?? const <TtsVoice>[];
    if (voices.isEmpty) return const SizedBox.shrink();
    final chosen = ref.watch(voiceSettingsProvider).valueOrNull?.voice;
    final labels = voiceLabels(voices);
    final current = voices.where((v) => v.name == chosen).firstOrNull;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Voice'),
      subtitle: Text(current == null ? 'Automatic · American English' : labels[current]!),
      trailing: const Icon(LucideIcons.chevronRight),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (ctx) => _VoicePicker(voices: voices, labels: labels),
      ),
    );
  }
}

class _VoicePicker extends ConsumerWidget {
  final List<TtsVoice> voices;
  final Map<TtsVoice, String> labels;
  const _VoicePicker({required this.voices, required this.labels});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(voiceSettingsProvider).valueOrNull ?? const VoiceSettings();
    final service = ref.read(speechOutputServiceProvider);
    void choose(String? name) {
      saveVoiceSettings(ref, name == null ? settings.copyWith(automaticVoice: true) : settings.copyWith(voice: name));
      Navigator.pop(context);
    }

    Widget hear(TtsVoice voice) => IconButton(
      tooltip: 'Hear it',
      icon: const Icon(LucideIcons.play),
      onPressed: service is FlutterTtsSpeechService ? () => service.preview(voice, _VoiceTile.sample) : null,
    );

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
        child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text('Voice', style: context.chefText.titleLarge),
            ),
            ListTile(
              leading: Icon(settings.voice == null ? LucideIcons.circleCheck : LucideIcons.circle),
              title: const Text('Automatic'),
              subtitle: const Text('The most natural American English voice'),
              onTap: () => choose(null),
            ),
            for (final v in voices)
              ListTile(
                leading: Icon(settings.voice == v.name ? LucideIcons.circleCheck : LucideIcons.circle),
                title: Text(labels[v]!),
                trailing: hear(v),
                onTap: () => choose(v.name),
              ),
          ],
        ),
        ),
      ),
    );
  }
}

/// Light, dark, or following the phone.
class _AppearanceSection extends ConsumerWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appearanceProvider).valueOrNull ?? ThemeMode.system;
    return _Section(
      title: 'Appearance',
      icon: LucideIcons.sunMoon,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('System')),
                ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
              ],
              selected: {mode},
              onSelectionChanged: (s) =>
                  ref.read(preferencesRepositoryProvider).writeJson(appearanceKey, s.first.name),
            ),
          ),
        ),
      ],
    );
  }
}

// --- Nutrition goals -------------------------------------------------------------

// --- Read aloud -----------------------------------------------------------------

class _VoiceSection extends ConsumerWidget {
  const _VoiceSection();

  static const _sample = 'Step 1 of 4. Bring a large pot of salted water to a boil, '
      'then add 200 g of spaghetti and cook for 10–12 min, until al dente.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(voiceSettingsProvider).valueOrNull ?? const VoiceSettings();
    final t = context.chefText;
    Future<void> save(VoiceSettings next) => saveVoiceSettings(ref, next);

    return _Section(
      title: 'Read aloud',
      icon: LucideIcons.speech,
      children: [
        Text(
          'Hear recipes and Cook Mode steps read out loud, so your hands can stay in the dough. '
          'Uses your device’s built-in voice — nothing is sent online.',
          style: t.bodySmall,
        ),
        const SizedBox(height: 12),
        Text('Speaking speed', style: t.labelLarge),
        const SizedBox(height: 8),
        SegmentedButton<SpeechPace>(
          showSelectedIcon: false,
          segments: [
            for (final pace in SpeechPace.values) ButtonSegment(value: pace, label: Text(pace.label)),
          ],
          selected: {settings.pace},
          onSelectionChanged: (s) => save(settings.copyWith(pace: s.first)),
        ),
        const SizedBox(height: 4),
        const _VoiceTile(),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Read steps in Cook Mode'),
          subtitle: const Text('Each step is read when you turn to it'),
          value: settings.readStepsInCookMode,
          onChanged: (v) => save(settings.copyWith(readStepsInCookMode: v)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Announce finished timers'),
          subtitle: const Text('“Your pasta timer is done”'),
          value: settings.announceTimers,
          onChanged: (v) => save(settings.copyWith(announceTimers: v)),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ListenButton(
              sessionId: 'settings:sample',
              label: 'Play a sample',
              script: () => [SpokenSegment('sample', SpokenText.normalize(_sample))],
            ),
          ),
        ),
      ],
    );
  }
}

class _GoalsSection extends ConsumerWidget {
  const _GoalsSection();

  Future<void> _edit(BuildContext context, WidgetRef ref, NutritionGoals goals, String label, double current, String unit,
      NutritionGoals Function(double) apply) async {
    final value = await showDialog<double>(
      context: context,
      builder: (_) => _NumberDialog(title: label, initial: current, unit: unit),
    );
    if (value == null) return;
    await ref.read(preferencesRepositoryProvider).writeJson(nutritionGoalsKey, apply(value).toJson());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(nutritionGoalsProvider).valueOrNull ?? NutritionGoals.standard;
    Widget row(String label, double value, String unit, NutritionGoals Function(double) apply) => ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(label),
          trailing: Text('${KitchenFormat.kcal(value)} $unit', style: context.chefText.labelLarge),
          onTap: () => _edit(context, ref, goals, label, value, unit, apply),
        );

    return _Section(
      title: 'Daily nutrition goals',
      icon: LucideIcons.flag,
      children: [
        row('Calories', goals.calories, 'kcal', (v) => goals.copyWith(calories: v)),
        row('Protein', goals.proteinG, 'g', (v) => goals.copyWith(proteinG: v)),
        row('Carbohydrates', goals.carbsG, 'g', (v) => goals.copyWith(carbsG: v)),
        row('Fat', goals.fatG, 'g', (v) => goals.copyWith(fatG: v)),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Defaults follow the FDA Daily Values for a 2,000 kcal diet. Adjust them to your needs.',
                  style: context.chefText.bodySmall,
                ),
              ),
              TextButton(
                onPressed: () => ref.read(preferencesRepositoryProvider).writeJson(nutritionGoalsKey, NutritionGoals.standard.toJson()),
                child: const Text('Reset'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NumberDialog extends StatefulWidget {
  final String title;
  final double initial;
  final String unit;
  const _NumberDialog({required this.title, required this.initial, required this.unit});

  @override
  State<_NumberDialog> createState() => _NumberDialogState();
}

class _NumberDialogState extends State<_NumberDialog> {
  late final _controller = TextEditingController(text: widget.initial.round().toString());
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final v = double.tryParse(_controller.text.trim());
    if (v == null || v <= 0 || v > 20000) {
      setState(() => _error = 'Enter a number between 1 and 20,000');
      return;
    }
    Navigator.pop(context, v);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.title),
        content: TextField(
          controller: _controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(suffixText: widget.unit, errorText: _error),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: _submit, child: const Text('Save')),
        ],
      );
}

// --- Data -----------------------------------------------------------------------

class _DataSection extends ConsumerWidget {
  const _DataSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.chefColors;
    return _Section(
      title: 'Your data',
      icon: LucideIcons.database,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(LucideIcons.upload),
          title: const Text('Export backup'),
          subtitle: const Text('Copy all recipes and cookbooks as a JSON backup'),
          onTap: () => showDialog<void>(context: context, builder: (_) => const BackupExportDialog()),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(LucideIcons.archiveRestore),
          title: const Text('Restore from backup'),
          subtitle: const Text('Import recipes from a JSON backup'),
          onTap: () => showDialog<void>(context: context, builder: (_) => const BackupRestoreDialog()),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(LucideIcons.trash),
          title: const Text('Recently deleted'),
          subtitle: const Text('Restore or permanently remove deleted recipes'),
          onTap: () => _showTrash(context),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(LucideIcons.triangleAlert, color: c.stateDanger),
          title: Text('Erase all data', style: TextStyle(color: c.stateDanger)),
          subtitle: const Text('Permanently delete recipes, cookbooks and your food log'),
          onTap: () => _confirmReset(context, ref),
        ),
      ],
    );
  }

  void _showTrash(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (_) => const _TrashSheet(),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final backup = ref.read(backupRepositoryProvider);
    final router = GoRouter.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Erase all data?'),
        content: const Text(
          'This permanently deletes every recipe, cookbook, cooking session and food log entry on this device. '
          'Export a backup first if you might want them back.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: ctx.chefColors.stateDanger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Erase everything'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final res = await backup.resetAllData(profileId: 'default');
    router.go('/');
    ChefToastService.show(
      title: res.isSuccess ? 'All data erased' : 'Could not erase data',
      type: res.isSuccess ? ChefToastType.info : ChefToastType.error,
    );
  }
}

class _TrashSheet extends ConsumerWidget {
  const _TrashSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.chefText;
    final repo = ref.read(recipeRepositoryProvider);
    return StreamBuilder<List<Recipe>>(
      stream: repo.watchDeletedRecipes(),
      builder: (context, snapshot) {
        final deleted = snapshot.data ?? const <Recipe>[];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('Recently deleted', style: t.headlineSmall),
                ),
                const SizedBox(height: 8),
                if (deleted.isEmpty)
                  const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Nothing here.')))
                else
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        for (final r in deleted)
                          ListTile(
                            title: Text(r.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(onPressed: () => repo.restoreRecipe(r.id), child: const Text('Restore')),
                                IconButton(
                                  tooltip: 'Delete forever',
                                  icon: const Icon(LucideIcons.trash2),
                                  onPressed: () => repo.purgeRecipe(r.id),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// --- Developer preview -------------------------------------------------------------

class _DeveloperSection extends StatelessWidget {
  final AppEnvironment env;
  const _DeveloperSection({required this.env});

  @override
  Widget build(BuildContext context) {
    final t = context.chefText;
    return _Section(
      title: 'Developer preview',
      icon: LucideIcons.flaskConical,
      children: [
        Text(
          'Visible in ${env.flavor.name} builds only. Cloud sync runs against an in-memory demo server — '
          'nothing here is persisted or backed up.',
          style: t.bodySmall,
        ),
        const SizedBox(height: 8),
        if (env.flags.cloudSyncPreviewEnabled) const CloudSyncSection(),
        if (env.flags.illustrationGovernanceEnabled)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(LucideIcons.palette),
            title: const Text('Illustration moderation'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const IllustrationApprovalScreen())),
          ),
      ],
    );
  }
}

// --- About ------------------------------------------------------------------------

class _AboutSection extends StatelessWidget {
  final AppEnvironment env;
  const _AboutSection({required this.env});

  @override
  Widget build(BuildContext context) {
    final t = context.chefText;
    return _Section(
      title: 'About',
      icon: LucideIcons.info,
      children: [
        Text(
          'Your recipes, cookbooks and food log are stored only on this device. Chef’s Kiss has no account, '
          'ads or tracking. AI requests you start are processed by Anthropic under its commercial terms.',
          style: t.bodyMedium,
        ),
        const SizedBox(height: 10),
        Text(
          'Nutrition, allergen and food-safety information is approximate and for general guidance only — '
          'always check labels, and follow safe cooking temperatures.',
          style: t.bodySmall,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(LucideIcons.fileText),
          title: const Text('Open-source licenses'),
          onTap: () => showLicensePage(
            context: context,
            applicationName: 'Chef’s Kiss',
            applicationVersion: '${env.version}${env.flavor.isProduction ? '' : ' (${env.flavor.name})'}',
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Version ${env.version}', style: t.bodySmall),
        ),
      ],
    );
  }
}
