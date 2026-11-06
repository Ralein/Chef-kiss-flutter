import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_tokens/design_tokens.dart';
import '../../../app/providers.dart';

class BackupExportDialog extends ConsumerStatefulWidget {
  const BackupExportDialog({super.key});

  @override
  ConsumerState<BackupExportDialog> createState() => _BackupExportDialogState();
}

class _BackupExportDialogState extends ConsumerState<BackupExportDialog> {
  String? _exportedJson;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generateExport();
  }

  void _generateExport() async {
    final res = await ref.read(backupRepositoryProvider).exportBackupJson(profileId: 'default');
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      res.when(
        ok: (json) => _exportedJson = json,
        err: (f) => _error = f.message,
      );
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
          Icon(Icons.download_outlined, color: colors.accentTomato, size: 24),
          const SizedBox(width: ChefSpacing.space2),
          Text('Export Recipe Backup', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: _isLoading
            ? const Center(heightFactor: 3, child: CircularProgressIndicator())
            : (_error != null
                ? Text('Export failed: $_error', style: TextStyle(color: colors.stateDanger))
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(ChefSpacing.space3),
                        decoration: BoxDecoration(
                          color: colors.surfaceRaised,
                          borderRadius: BorderRadius.circular(ChefRadius.tile),
                          border: Border.all(color: colors.outlineSubtle),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.lock_outline, size: 18, color: colors.contentSecondary),
                            const SizedBox(width: ChefSpacing.space2),
                            Expanded(
                              child: Text(
                                'Contains all recipes, cookbooks, and preferences in an open, portable JSON format.',
                                style: textTheme.bodyMedium?.copyWith(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: ChefSpacing.space3),
                      Text('JSON Package Preview:', style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: ChefSpacing.space1),
                      Container(
                        height: 180,
                        width: double.infinity,
                        padding: const EdgeInsets.all(ChefSpacing.space3),
                        decoration: BoxDecoration(
                          color: colors.surfaceCanvas,
                          borderRadius: BorderRadius.circular(ChefRadius.tile),
                          border: Border.all(color: colors.outlineSubtle),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            _exportedJson ?? '',
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                          ),
                        ),
                      ),
                    ],
                  )),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        if (_exportedJson != null)
          FilledButton.icon(
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Copy JSON to Clipboard'),
            style: FilledButton.styleFrom(backgroundColor: colors.accentTomato),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _exportedJson!));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Backup JSON copied to clipboard!')),
              );
            },
          ),
      ],
    );
  }
}
