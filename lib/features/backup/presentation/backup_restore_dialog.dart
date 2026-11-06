import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:design_tokens/design_tokens.dart';
import '../../../app/providers.dart';

class BackupRestoreDialog extends ConsumerStatefulWidget {
  const BackupRestoreDialog({super.key});

  @override
  ConsumerState<BackupRestoreDialog> createState() => _BackupRestoreDialogState();
}

class _BackupRestoreDialogState extends ConsumerState<BackupRestoreDialog> {
  final TextEditingController _jsonController = TextEditingController();
  BackupValidationResult? _validationResult;
  bool _isValidating = false;
  DuplicatePolicy _policy = DuplicatePolicy.keepBoth;

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  void _validatePackage() async {
    final text = _jsonController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isValidating = true);
    final res = await ref.read(backupRepositoryProvider).validateBackupJson(text);
    setState(() {
      _isValidating = false;
      _validationResult = res.orNull;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.chefColors;
    final textTheme = context.chefText;

    return AlertDialog(
      backgroundColor: colors.surfacePaper,
      title: Row(
        children: [
          Icon(Icons.restore_outlined, color: colors.accentTomato, size: 24),
          const SizedBox(width: ChefSpacing.space2),
          Text('Restore from Backup', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _jsonController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Paste Backup Package JSON',
                  hintText: '{\n  "manifest": ...\n  "recipes": [...]\n}',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                onChanged: (_) {
                  if (_validationResult != null) {
                    setState(() => _validationResult = null);
                  }
                },
              ),
              const SizedBox(height: ChefSpacing.space3),
              if (_validationResult == null)
                FilledButton.tonalIcon(
                  icon: _isValidating
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Validate Backup Schema'),
                  onPressed: _isValidating ? null : _validatePackage,
                ),
              if (_validationResult != null) ...[
                if (!_validationResult!.isValid) ...[
                  Container(
                    padding: const EdgeInsets.all(ChefSpacing.space3),
                    decoration: BoxDecoration(
                      color: colors.stateDanger.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(ChefRadius.tile),
                      border: Border.all(color: colors.stateDanger.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Invalid Backup Package', style: TextStyle(color: colors.stateDanger, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        ..._validationResult!.blockingErrors.map((e) => Text('• $e', style: const TextStyle(fontSize: 12))),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(ChefSpacing.space3),
                    decoration: BoxDecoration(
                      color: colors.accentHerb.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(ChefRadius.tile),
                      border: Border.all(color: colors.accentHerb.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.verified, color: colors.accentHerb, size: 18),
                            const SizedBox(width: ChefSpacing.space1),
                            Text('Valid Package Verified', style: TextStyle(color: colors.accentHerb, fontWeight: FontWeight.w800)),
                          ],
                        ),
                        const SizedBox(height: ChefSpacing.space1),
                        Text('• ${_validationResult!.recipeCount} recipes ready to restore'),
                        Text('• ${_validationResult!.collectionCount} cookbooks ready to restore'),
                        if (_validationResult!.duplicateRecipeTitles.isNotEmpty) ...[
                          const SizedBox(height: ChefSpacing.space1),
                          Text(
                            'Notice: ${_validationResult!.duplicateRecipeTitles.length} recipes match existing titles in your library.',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: ChefSpacing.space3),
                  Text('Duplicate Resolution Policy:', style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: ChefSpacing.space1),
                  SegmentedButton<DuplicatePolicy>(
                    segments: const [
                      ButtonSegment(value: DuplicatePolicy.keepBoth, label: Text('Keep Both')),
                      ButtonSegment(value: DuplicatePolicy.replace, label: Text('Replace Existing')),
                      ButtonSegment(value: DuplicatePolicy.skip, label: Text('Skip Duplicates')),
                    ],
                    selected: {_policy},
                    onSelectionChanged: (selection) {
                      setState(() => _policy = selection.first);
                    },
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        if (_validationResult != null && _validationResult!.isValid)
          FilledButton.icon(
            icon: const Icon(Icons.restore),
            label: const Text('Restore All Recipes'),
            style: FilledButton.styleFrom(backgroundColor: colors.accentTomato),
            onPressed: () async {
              final res = await ref.read(backupRepositoryProvider).restoreBackupJson(
                    jsonStr: _jsonController.text.trim(),
                    duplicatePolicy: _policy,
                    profileId: 'default',
                  );
              if (!context.mounted) return;
              Navigator.pop(context);
              res.when(
                ok: (count) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Successfully restored $count recipes!')),
                  );
                },
                err: (f) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Restore failed: ${f.message}')),
                  );
                },
              );
            },
          ),
      ],
    );
  }
}
