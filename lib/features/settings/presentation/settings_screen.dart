import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:design_tokens/design_tokens.dart';
import '../../../app/providers.dart';
import '../../backup/presentation/backup_export_dialog.dart';
import '../../backup/presentation/backup_restore_dialog.dart';
import '../../sync/presentation/cloud_sync_section.dart';
import '../../illustrations/presentation/illustration_approval_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.chefColors;
    final textTheme = context.chefText;

    final profileAsync = ref.watch(userProfileProvider);
    final capabilitiesAsync = ref.watch(capabilitiesProvider);

    return Scaffold(
      backgroundColor: colors.surfaceCanvas,
      appBar: AppBar(
        title: Text('Settings & Data', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(ChefSpacing.space4),
        children: [
          // 1. Preferences Card
          _buildCard(
            context,
            title: 'Cooking Preferences',
            children: [
              profileAsync.when(
                data: (profile) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Default Unit System'),
                    subtitle: Text(
                      profile.unitSystem == UnitSystem.metric
                          ? 'Metric (grams, ml, °C)'
                          : 'US Customary (cups, tbsp, oz, °F)',
                    ),
                    trailing: SegmentedButton<UnitSystem>(
                      segments: const [
                        ButtonSegment(value: UnitSystem.metric, label: Text('Metric')),
                        ButtonSegment(value: UnitSystem.usCustomary, label: Text('US')),
                      ],
                      selected: {profile.unitSystem},
                      onSelectionChanged: (selection) {
                        ref.read(settingsRepositoryProvider).updateProfile(
                              profile.copyWith(unitSystem: selection.first),
                            );
                      },
                    ),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: ChefSpacing.space4),

          // 2. Cloud Sync & Vault Section
          const CloudSyncSection(),
          const SizedBox(height: ChefSpacing.space4),

          // 3. Data & Local Backup Card
          _buildCard(
            context,
            title: 'Data & Backup',
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.download_outlined, color: colors.accentTomato),
                title: const Text('Export JSON Backup Package'),
                subtitle: const Text('Save a portable backup of all your recipes and collections.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => const BackupExportDialog(),
                  );
                },
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.restore_outlined, color: colors.accentHerb),
                title: const Text('Restore from Backup'),
                subtitle: const Text('Import recipes and collections from a JSON backup file.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => const BackupRestoreDialog(),
                  );
                },
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.restore_from_trash_outlined, color: colors.contentSecondary),
                title: const Text('Recently Deleted Recipes'),
                subtitle: const Text('View or restore soft-deleted recipes.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showRecentlyDeletedSheet(context, ref),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.palette_outlined, color: colors.accentTomato),
                title: const Text('Illustration Asset Governance'),
                subtitle: const Text('Review and moderate candidate artwork before library inclusion.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const IllustrationApprovalScreen()),
                  );
                },
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.delete_forever, color: colors.stateDanger),
                title: Text('Reset All Local Data', style: TextStyle(color: colors.stateDanger, fontWeight: FontWeight.w600)),
                subtitle: const Text('Permanently erase all local recipes, cooking history, and collections.'),
                onTap: () => _showResetAllDataDialog(context, ref),
              ),
            ],
          ),
          const SizedBox(height: ChefSpacing.space4),

          // 3. Privacy, Food Safety & Legal
          _buildCard(
            context,
            title: 'Privacy & Legal Readiness',
            children: [
              capabilitiesAsync.when(
                data: (caps) {
                  return Column(
                    children: [
                      _buildCapabilityRow('Local Notifications', caps.notifications.isGranted ? 'Active' : 'Optional'),
                      _buildCapabilityRow('Screen Keep-Awake', caps.screenAwake.isGranted ? 'Active in Cook Mode' : 'Disabled'),
                      _buildCapabilityRow('Speech & Voice Guide', caps.speechRecognition.isGranted ? 'Ready' : 'Manual / Push-to-talk'),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: ChefSpacing.space3),
              Container(
                padding: const EdgeInsets.all(ChefSpacing.space3),
                decoration: BoxDecoration(
                  color: colors.surfaceRaised,
                  borderRadius: BorderRadius.circular(ChefRadius.tile),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shield_outlined, color: colors.accentHerb, size: 20),
                        const SizedBox(width: ChefSpacing.space2),
                        Text('Local-First Privacy Guarantee', style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'All private recipes, photo scans, and cooking diaries stay on your device by default. No cloud account or external telemetry tracking required.',
                      style: textTheme.bodyMedium?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: ChefSpacing.space2),
              Container(
                padding: const EdgeInsets.all(ChefSpacing.space3),
                decoration: BoxDecoration(
                  color: colors.stateWarning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(ChefRadius.tile),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: colors.stateWarning, size: 20),
                        const SizedBox(width: ChefSpacing.space2),
                        Text('Food & Allergen Safety Disclaimer', style: textTheme.labelSmall?.copyWith(color: colors.stateWarning, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Recipe information, internal temperature guidelines, and allergen alerts are informational only. Always check ingredient labels and practice safe food handling.',
                      style: textTheme.bodyMedium?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: ChefSpacing.space2),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.info_outline),
                title: const Text('Open Source Licenses & Attributions'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: "Chef's Kiss",
                  applicationVersion: '1.0.0+1 (Phase 3 Production Launch)',
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required String title, required List<Widget> children}) {
    final colors = context.chefColors;
    final textTheme = context.chefText;

    return Container(
      padding: const EdgeInsets.all(ChefSpacing.space4),
      decoration: BoxDecoration(
        color: colors.surfacePaper,
        borderRadius: BorderRadius.circular(ChefRadius.card),
        border: Border.all(color: colors.outlineSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: ChefSpacing.space2),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCapabilityRow(String label, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(status, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }

  void _showRecentlyDeletedSheet(BuildContext context, WidgetRef ref) {
    final colors = context.chefColors;
    final textTheme = context.chefText;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surfacePaper,
      shape: const RoundedRectangleBorder(borderRadius: ChefRadius.sheetBorder),
      builder: (ctx) {
        return StreamBuilder<List<Recipe>>(
          stream: ref.watch(recipeRepositoryProvider).watchDeletedRecipes(),
          builder: (context, snapshot) {
            final deleted = snapshot.data ?? [];
            return Padding(
              padding: const EdgeInsets.all(ChefSpacing.space4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recently Deleted', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: ChefSpacing.space3),
                  if (deleted.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: ChefSpacing.space4),
                      child: Center(child: Text('Trash is empty.')),
                    )
                  else
                    ...deleted.map((r) => ListTile(
                          title: Text(r.title),
                          trailing: TextButton(
                            child: const Text('Restore'),
                            onPressed: () {
                              ref.read(recipeRepositoryProvider).restoreRecipe(r.id);
                              Navigator.pop(ctx);
                            },
                          ),
                        )),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showResetAllDataDialog(BuildContext context, WidgetRef ref) {
    final colors = context.chefColors;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reset All Local Data?', style: TextStyle(color: colors.stateDanger, fontWeight: FontWeight.w800)),
        content: const Text(
          'This action is irreversible. All recipes, collections, and cooking diaries stored on this device will be permanently erased. Please ensure you have exported a JSON backup first.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: colors.stateDanger),
            onPressed: () async {
              await ref.read(backupRepositoryProvider).resetAllData(profileId: 'default');
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              context.go('/');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All local data has been reset.')),
              );
            },
            child: const Text('Erase All Data'),
          ),
        ],
      ),
    );
  }
}
