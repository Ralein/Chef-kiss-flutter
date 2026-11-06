import 'package:app_contracts/app_contracts.dart';
import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/foundation.dart';
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
import '../../../core/ai/ai_connection.dart';
import '../../../core/ai/ai_usage.dart';
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
  void initState() {
    super.initState();
    if (widget.initialSection == 'ai') {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final state = await ref.read(aiConnectionProvider.future);
        if (mounted && state.canEditKey && !state.isAvailable) showApiKeySheet(context);
      });
    }
  }

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
    final async = ref.watch(aiConnectionProvider);
    final state = async.valueOrNull;
    final mode = state?.mode;

    final (IconData icon, Color color, String status) = switch (mode) {
      AiConnectionMode.proxy => (LucideIcons.badgeCheck, c.stateSuccess, 'Connected · managed by Chef’s Kiss'),
      AiConnectionMode.gateway => (LucideIcons.badgeCheck, c.stateSuccess, 'Connected to your free-model gateway'),
      AiConnectionMode.userKey => (LucideIcons.badgeCheck, c.stateSuccess, 'Connected with your Claude key'),
      _ => (LucideIcons.cloudOff, c.contentSecondary, 'Not set up'),
    };
    final detail = switch (mode) {
      AiConnectionMode.gateway => '${state!.gateway!.model} · ${state.gateway!.baseUri.authority}',
      AiConnectionMode.userKey => '${state!.maskedKey} · ${state.config?.model ?? AiEnvironment.model}',
      AiConnectionMode.proxy => state!.model ?? '',
      _ => 'Powers food scanning, recipe photos, AI recipes, what-to-cook ideas and nutrition gap-filling.',
    };
    final ownConnection = mode == AiConnectionMode.gateway || mode == AiConnectionMode.userKey;

    return _Section(
      title: 'AI & Scanning',
      icon: LucideIcons.sparkles,
      children: [
        if (async.isLoading) const LinearProgressIndicator(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: color),
          title: Text(status),
          subtitle: Text(
            '$detail${state?.persistentStorage == false ? '\nCould not use the device keychain — the connection will be forgotten when the app closes.' : ''}',
          ),
        ),
        if (state?.isAvailable ?? false) const _RateLimitTile(),
        if (ownConnection)
          Wrap(
            spacing: 8,
            children: [
              TextButton.icon(
                onPressed: () async {
                  final res = await ref.read(aiConnectionProvider.notifier).testConnection();
                  ChefToastService.show(
                    title: res.isSuccess ? 'Connection works' : res.error!.message,
                    description: res.isSuccess ? null : res.error!.recoveryAction,
                    type: res.isSuccess ? ChefToastType.success : ChefToastType.error,
                  );
                },
                icon: const Icon(LucideIcons.activity),
                label: const Text('Test'),
              ),
              TextButton.icon(
                onPressed: () => mode == AiConnectionMode.gateway ? showGatewaySheet(context) : showApiKeySheet(context),
                icon: const Icon(LucideIcons.slidersHorizontal),
                label: const Text('Change'),
              ),
              TextButton.icon(
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Disconnect AI?'),
                      content: const Text('AI features stop working until you connect again.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Disconnect')),
                      ],
                    ),
                  );
                  if (ok != true) return;
                  final notifier = ref.read(aiConnectionProvider.notifier);
                  await (mode == AiConnectionMode.gateway ? notifier.removeGateway() : notifier.removeApiKey());
                },
                icon: const Icon(LucideIcons.unlink),
                label: const Text('Disconnect'),
              ),
            ],
          )
        else if (mode != AiConnectionMode.proxy) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: () => showGatewaySheet(context),
                icon: const Icon(LucideIcons.plug),
                label: const Text('Connect free models'),
              ),
              if (state?.canEditKey ?? false)
                TextButton(onPressed: () => showApiKeySheet(context), child: const Text('Use a Claude key instead')),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          child: Text(
            switch (mode) {
              AiConnectionMode.gateway =>
                'Photos and text you choose to analyze go to your gateway, which passes them to free models. '
                    'Free models may log what they are sent: leave personal details out. '
                    'Your recipes and food log stay on this device.',
              AiConnectionMode.userKey || AiConnectionMode.proxy =>
                'Photos and text you choose to analyze are sent to Anthropic’s Claude API. '
                    'Everything else — your recipes and food log — stays on this device.',
              _ => 'Use free models through a gateway you run, or your own Claude key. '
                  'Only what you choose to analyze leaves this device.',
            },
            style: t.bodySmall,
          ),
        ),
      ],
    );
  }
}

/// The AI service's rate limit as last reported, and this session's
/// requests: shown so a busy free model isn't a mystery.
class _RateLimitTile extends ConsumerWidget {
  const _RateLimitTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.chefColors;
    final usage = ref.watch(aiUsageProvider).usage;
    final now = DateTime.now();
    String at(DateTime time) => TimeOfDay.fromDateTime(time).format(context);
    final limited = usage.limitedAt(now);
    final requests = '${usage.requests} request${usage.requests == 1 ? '' : 's'} this session';
    final (String title, String? subtitle) = limited
        ? ('Rate limited — try again after ${at(usage.limitedUntil!)}', requests)
        : usage.limit != null && usage.remaining != null
        ? (
            '${usage.remaining} of ${usage.limit} requests left',
            [if (usage.resetsAt != null && usage.resetsAt!.isAfter(now)) 'resets at ${at(usage.resetsAt!)}', requests]
                .join(' · '),
          )
        : usage.requests > 0
        ? ('No rate limit reported', requests)
        : ('Rate limit: shown after the first request', null);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(LucideIcons.gauge, color: limited ? c.stateWarning : c.contentSecondary),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
    );
  }
}

Future<void> showGatewaySheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => const _GatewaySheet(),
  );
}

/// Connects to an OpenAI-compatible gateway — such as a free-model gateway
/// running on the user's computer — and picks which of its models to use.
class _GatewaySheet extends ConsumerStatefulWidget {
  const _GatewaySheet();

  @override
  ConsumerState<_GatewaySheet> createState() => _GatewaySheetState();
}

class _GatewaySheetState extends ConsumerState<_GatewaySheet> {
  late final _address = TextEditingController(
    text: ref.read(aiConnectionProvider).valueOrNull?.gateway?.baseUri.toString() ?? '',
  );
  final _key = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  String? _error;
  List<String>? _models;
  String? _model;

  @override
  void dispose() {
    _address.dispose();
    _key.dispose();
    super.dispose();
  }

  Future<void> _findModels() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final res = await ref.read(aiConnectionProvider.notifier).gatewayModels(_address.text, _key.text);
    if (!mounted) return;
    final current = ref.read(aiConnectionProvider).valueOrNull?.gateway?.model;
    setState(() {
      _busy = false;
      if (res.isSuccess) {
        final models = res.orNull!;
        _models = models;
        _model = models.contains(current) ? current : models.firstOrNull;
        if (models.isEmpty) _error = 'The gateway has no models to offer right now.';
      } else {
        _error = [res.error!.message, if (res.error!.recoveryAction != null) res.error!.recoveryAction!].join(' ');
      }
    });
  }

  Future<void> _connect() async {
    final model = _model;
    if (model == null) return;
    setState(() => _busy = true);
    final navigator = Navigator.of(context);
    final res = await ref
        .read(aiConnectionProvider.notifier)
        .saveGateway(address: _address.text, key: _key.text, model: model);
    if (!mounted) return;
    if (res.isSuccess) {
      navigator.pop();
      ChefToastService.show(title: 'AI is ready', description: 'Using $model.', type: ChefToastType.success);
    } else {
      setState(() {
        _busy = false;
        _error = res.error!.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.chefText;
    final c = context.chefColors;
    final models = _models;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Connect free models', style: t.headlineSmall),
            const SizedBox(height: 6),
            Text(
              'Run an OpenAI-compatible gateway, such as dsh-our-free-model, on your computer. With this phone on USB, '
              'run “adb reverse tcp:18899 tcp:18899” there and use http://127.0.0.1:18899. A gateway with an https '
              'address works from anywhere.',
              style: t.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _address,
              autofocus: _address.text.isEmpty,
              autocorrect: false,
              enableSuggestions: false,
              keyboardType: TextInputType.url,
              onChanged: (_) => setState(() => _models = null),
              decoration: const InputDecoration(labelText: 'Gateway address', hintText: 'http://127.0.0.1:18899'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _key,
              obscureText: _obscure,
              autocorrect: false,
              enableSuggestions: false,
              keyboardType: TextInputType.visiblePassword,
              onChanged: (_) => setState(() => _models = null),
              decoration: InputDecoration(
                labelText: 'Key, if the gateway asks for one',
                errorText: _error,
                errorMaxLines: 3,
                suffixIcon: IconButton(
                  tooltip: _obscure ? 'Show key' : 'Hide key',
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(_obscure ? LucideIcons.eye : LucideIcons.eyeOff),
                ),
              ),
            ),
            if (models != null && models.isNotEmpty) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _model,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Model'),
                items: [for (final m in models) DropdownMenuItem(value: m, child: Text(m, overflow: TextOverflow.ellipsis))],
                onChanged: (m) => setState(() => _model = m),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(LucideIcons.info, size: 16, color: c.stateWarning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Free models may log what they are sent. Leave personal details out.', style: t.bodySmall),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : (models == null || models.isEmpty ? _findModels : _connect),
              child: _busy
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(models == null || models.isEmpty ? 'Find models' : 'Connect'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showApiKeySheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => const _ApiKeySheet(),
  );
}

class _ApiKeySheet extends ConsumerStatefulWidget {
  const _ApiKeySheet();

  @override
  ConsumerState<_ApiKeySheet> createState() => _ApiKeySheetState();
}

class _ApiKeySheetState extends ConsumerState<_ApiKeySheet> {
  final _key = TextEditingController();
  final _workspace = TextEditingController();
  bool _obscure = true;
  bool _saving = false;
  bool _advanced = false;
  String? _error;

  @override
  void dispose() {
    _key.dispose();
    _workspace.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final navigator = Navigator.of(context);
    final res = await ref
        .read(aiConnectionProvider.notifier)
        .saveApiKey(_key.text, workspaceId: _workspace.text.trim().isEmpty ? null : _workspace.text);
    if (!mounted) return;
    if (res.isSuccess) {
      navigator.pop();
      ChefToastService.show(title: 'AI is ready', description: 'Scanning and AI recipes are now on.', type: ChefToastType.success);
    } else {
      setState(() {
        _saving = false;
        _error = [res.error!.message, if (res.error!.recoveryAction != null) res.error!.recoveryAction!].join(' ');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.chefText;
    final c = context.chefColors;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Use your Claude key', style: t.headlineSmall),
            const SizedBox(height: 6),
            Text(
              'Create an API key in the Claude Console (platform.claude.com → Settings → API keys) and paste it here. '
              'It is checked with Anthropic before it is saved.',
              style: t.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _key,
              autofocus: true,
              obscureText: _obscure,
              autocorrect: false,
              enableSuggestions: false,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                labelText: 'API key',
                hintText: 'sk-ant-…',
                errorText: _error,
                errorMaxLines: 3,
                suffixIcon: IconButton(
                  tooltip: _obscure ? 'Show key' : 'Hide key',
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(_obscure ? LucideIcons.eye : LucideIcons.eyeOff),
                ),
              ),
              onSubmitted: (_) => _saving ? null : _save(),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() => _advanced = !_advanced),
                child: Text(_advanced ? 'Hide advanced' : 'Advanced'),
              ),
            ),
            if (_advanced)
              TextField(
                controller: _workspace,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Workspace ID (optional)',
                  hintText: 'wrkspc_…',
                  helperText: 'Only needed for organization-level keys that are not tied to one workspace.',
                  helperMaxLines: 2,
                ),
              ),
            if (kIsWeb) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(LucideIcons.info, size: 16, color: c.stateWarning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'In a browser the key is stored in this browser’s storage. '
                      'For better protection use the mobile or desktop app.',
                      style: t.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(LucideIcons.badgeCheck),
              label: Text(_saving ? 'Checking…' : 'Save & verify'),
            ),
          ],
        ),
      ),
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
