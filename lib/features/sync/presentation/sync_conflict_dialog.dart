import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:design_tokens/design_tokens.dart';
import '../../../app/providers.dart';

class SyncConflictDialog extends ConsumerStatefulWidget {
  final SyncConflict conflict;

  const SyncConflictDialog({
    super.key,
    required this.conflict,
  });

  @override
  ConsumerState<SyncConflictDialog> createState() => _SyncConflictDialogState();
}

class _SyncConflictDialogState extends ConsumerState<SyncConflictDialog> {
  bool _isResolving = false;
  String? _errorMessage;

  Future<void> _applyResolution(SyncResolutionStrategy strategy, {Map<String, dynamic>? merged}) async {
    setState(() {
      _isResolving = true;
      _errorMessage = null;
    });

    final mediator = ref.read(syncMediatorProvider);
    final resolution = SyncResolution(
      strategy: strategy,
      mergedSnapshot: merged,
      resolvedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
    );

    final res = await mediator.resolveConflict(widget.conflict.conflictId, resolution);

    if (!mounted) return;

    if (res.isSuccess) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            strategy == SyncResolutionStrategy.keepLocal
                ? 'Resolved: Kept your local changes.'
                : strategy == SyncResolutionStrategy.keepRemote
                    ? 'Resolved: Applied cloud version.'
                    : 'Resolved: Merged changes.',
          ),
        ),
      );
    } else {
      setState(() {
        _isResolving = false;
        _errorMessage = res.error?.message ?? 'Failed to resolve conflict';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.chefColors;
    final textTheme = context.chefText;
    final conflict = widget.conflict;

    final localTitle = conflict.localSnapshot['title']?.toString() ?? conflict.localOperation.payload['title']?.toString() ?? 'Untitled';
    final remoteTitle = conflict.remoteSnapshot['title']?.toString() ?? conflict.remoteOperation.payload['title']?.toString() ?? 'Untitled';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ChefRadius.card)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(ChefSpacing.space6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(ChefSpacing.space2),
                    decoration: BoxDecoration(
                      color: colors.stateWarning.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.sync_problem, color: colors.stateWarning, size: 24),
                  ),
                  const SizedBox(width: ChefSpacing.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sync Conflict Detected', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        Text(
                          'Concurrent changes were made on another device.',
                          style: textTheme.bodySmall?.copyWith(color: colors.contentSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: ChefSpacing.space4),

              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(ChefSpacing.space3),
                  margin: const EdgeInsets.only(bottom: ChefSpacing.space3),
                  decoration: BoxDecoration(
                    color: colors.stateDanger.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(ChefRadius.tile),
                  ),
                  child: Text(_errorMessage!, style: TextStyle(color: colors.stateDanger, fontSize: 13)),
                ),

              // Conflicting Fields Summary
              Container(
                padding: const EdgeInsets.symmetric(horizontal: ChefSpacing.space3, vertical: ChefSpacing.space2),
                decoration: BoxDecoration(
                  color: colors.surfaceRaised,
                  borderRadius: BorderRadius.circular(ChefRadius.tile),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.compare_arrows, size: 16),
                    const SizedBox(width: ChefSpacing.space2),
                    Text(
                      'Conflicting field(s): ${conflict.conflictingFields.join(", ")}',
                      style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: ChefSpacing.space4),

              // Side-by-side comparison
              Flexible(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Local side
                    Expanded(
                      child: _buildVersionCard(
                        context,
                        title: 'This Device (Local)',
                        icon: Icons.phone_android,
                        badgeColor: colors.accentTomato,
                        snapshot: conflict.localSnapshot,
                        displayTitle: localTitle,
                        isConflicting: conflict.conflictingFields.contains('/title'),
                      ),
                    ),
                    const SizedBox(width: ChefSpacing.space3),
                    // Remote side
                    Expanded(
                      child: _buildVersionCard(
                        context,
                        title: 'Cloud Version (Remote)',
                        icon: Icons.cloud_outlined,
                        badgeColor: colors.accentHerb,
                        snapshot: conflict.remoteSnapshot,
                        displayTitle: remoteTitle,
                        isConflicting: conflict.conflictingFields.contains('/title'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: ChefSpacing.space6),

              // Action Buttons
              if (_isResolving)
                const Center(child: CircularProgressIndicator())
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.phone_android, size: 16),
                      label: const Text('Keep Local'),
                      onPressed: () => _applyResolution(SyncResolutionStrategy.keepLocal),
                    ),
                    const SizedBox(width: ChefSpacing.space3),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.cloud_download, size: 16),
                      label: const Text('Use Cloud'),
                      onPressed: () => _applyResolution(SyncResolutionStrategy.keepRemote),
                    ),
                    const SizedBox(width: ChefSpacing.space3),
                    FilledButton.icon(
                      icon: const Icon(Icons.merge_type, size: 16),
                      label: const Text('Smart Merge'),
                      onPressed: () {
                        // Merge local and remote snapshots
                        final merged = <String, dynamic>{
                          ...conflict.remoteSnapshot,
                          ...conflict.localSnapshot,
                        };
                        _applyResolution(SyncResolutionStrategy.fieldMerge, merged: merged);
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color badgeColor,
    required Map<String, dynamic> snapshot,
    required String displayTitle,
    required bool isConflicting,
  }) {
    final colors = context.chefColors;
    final textTheme = context.chefText;

    return Container(
      padding: const EdgeInsets.all(ChefSpacing.space4),
      decoration: BoxDecoration(
        color: colors.surfacePaper,
        borderRadius: BorderRadius.circular(ChefRadius.card),
        border: Border.all(
          color: isConflicting ? colors.stateWarning.withValues(alpha: 0.6) : colors.surfaceRaised,
          width: isConflicting ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: badgeColor),
              const SizedBox(width: ChefSpacing.space2),
              Expanded(
                child: Text(
                  title,
                  style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: badgeColor),
                ),
              ),
            ],
          ),
          const Divider(height: ChefSpacing.space4),
          Text('Title', style: textTheme.bodySmall?.copyWith(color: colors.contentSecondary, fontSize: 11)),
          Text(displayTitle, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: ChefSpacing.space2),
          if (snapshot.containsKey('difficulty')) ...[
            Text('Difficulty', style: textTheme.bodySmall?.copyWith(color: colors.contentSecondary, fontSize: 11)),
            Text(snapshot['difficulty']?.toString() ?? 'medium', style: textTheme.bodyMedium),
            const SizedBox(height: ChefSpacing.space2),
          ],
          if (snapshot.containsKey('totalMinutes')) ...[
            Text('Total Time', style: textTheme.bodySmall?.copyWith(color: colors.contentSecondary, fontSize: 11)),
            Text('${snapshot['totalMinutes']} minutes', style: textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
