import 'package:app_contracts/app_contracts.dart';
import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_domain/recipe_domain.dart';

import '../../../app/chef_toast_service.dart';
import '../../../app/providers.dart';
import '../../../app/widgets/common_widgets.dart';
import '../../../app/widgets/kitchen_format.dart';
import '../../../core/ai/ai_connection.dart';
import '../../backup/presentation/backup_export_dialog.dart';
import '../../backup/presentation/backup_restore_dialog.dart';
import '../../illustrations/presentation/illustration_approval_screen.dart';
import '../../sync/presentation/cloud_sync_section.dart';

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

    final (IconData icon, Color color, String status) = switch (state?.mode) {
      AiConnectionMode.proxy => (Icons.verified_rounded, c.stateSuccess, 'Connected · managed by Chef’s Kiss'),
      AiConnectionMode.userKey => (Icons.verified_rounded, c.stateSuccess, 'Connected with your API key'),
      _ => (Icons.cloud_off_rounded, c.contentSecondary, 'Not set up'),
    };

    return _Section(
      title: 'AI & Scanning',
      icon: Icons.auto_awesome_rounded,
      children: [
        if (async.isLoading) const LinearProgressIndicator(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: color),
          title: Text(status),
          subtitle: Text(
            state?.mode == AiConnectionMode.userKey
                ? '${state!.maskedKey} · ${state.config?.model ?? AiEnvironment.model}'
                    '${state.persistentStorage ? '' : '\nCould not use the device keychain — the key will be forgotten when the app closes.'}'
                : 'Powers food scanning, recipe photos, AI recipe creation and nutrition gap-filling.',
          ),
        ),
        if (state?.mode == AiConnectionMode.userKey) ...[
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
                icon: const Icon(Icons.network_check_rounded),
                label: const Text('Test'),
              ),
              TextButton.icon(
                onPressed: () => showApiKeySheet(context),
                icon: const Icon(Icons.key_rounded),
                label: const Text('Replace key'),
              ),
              TextButton.icon(
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Remove API key?'),
                      content: const Text('AI features will stop working until you add a key again.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remove')),
                      ],
                    ),
                  );
                  if (ok == true) await ref.read(aiConnectionProvider.notifier).removeApiKey();
                },
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Remove'),
              ),
            ],
          ),
        ] else if (state?.canEditKey ?? false) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: () => showApiKeySheet(context),
              icon: const Icon(Icons.key_rounded),
              label: const Text('Add Anthropic API key'),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          child: Text(
            'Photos and text you choose to analyze are sent to Anthropic’s Claude API. '
            'Everything else — your recipes and food log — stays on this device.',
            style: t.bodySmall,
          ),
        ),
      ],
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
            Text('Connect Claude', style: t.headlineSmall),
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
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
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
                  Icon(Icons.info_outline_rounded, size: 16, color: c.stateWarning),
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
                  : const Icon(Icons.verified_outlined),
              label: Text(_saving ? 'Checking…' : 'Save & verify'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Nutrition goals -------------------------------------------------------------

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
      icon: Icons.flag_outlined,
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
      icon: Icons.storage_rounded,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.upload_rounded),
          title: const Text('Export backup'),
          subtitle: const Text('Copy all recipes and collections as a JSON backup'),
          onTap: () => showDialog<void>(context: context, builder: (_) => const BackupExportDialog()),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.restore_rounded),
          title: const Text('Restore from backup'),
          subtitle: const Text('Import recipes from a JSON backup'),
          onTap: () => showDialog<void>(context: context, builder: (_) => const BackupRestoreDialog()),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.delete_sweep_outlined),
          title: const Text('Recently deleted'),
          subtitle: const Text('Restore or permanently remove deleted recipes'),
          onTap: () => _showTrash(context),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.warning_amber_rounded, color: c.stateDanger),
          title: Text('Erase all data', style: TextStyle(color: c.stateDanger)),
          subtitle: const Text('Permanently delete recipes, collections and your food log'),
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
          'This permanently deletes every recipe, collection, cooking session and food log entry on this device. '
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
                                  icon: const Icon(Icons.delete_forever_outlined),
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
      icon: Icons.science_outlined,
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
            leading: const Icon(Icons.palette_outlined),
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
      icon: Icons.info_outline_rounded,
      children: [
        Text(
          'Your recipes, collections and food log are stored only on this device. Chef’s Kiss has no account, '
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
          leading: const Icon(Icons.description_outlined),
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
