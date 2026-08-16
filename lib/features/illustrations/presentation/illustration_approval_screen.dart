import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_tokens/design_tokens.dart';
import '../../../app/providers.dart';
import '../data/illustration_governance_service.dart';

class IllustrationApprovalScreen extends ConsumerStatefulWidget {
  const IllustrationApprovalScreen({super.key});

  @override
  ConsumerState<IllustrationApprovalScreen> createState() => _IllustrationApprovalScreenState();
}

class _IllustrationApprovalScreenState extends ConsumerState<IllustrationApprovalScreen> {
  AssetApprovalStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final colors = context.chefColors;
    final textTheme = context.chefText;

    final candidatesAsync = ref.watch(illustrationCandidatesStreamProvider);

    return Scaffold(
      backgroundColor: colors.surfaceCanvas,
      appBar: AppBar(
        title: Text('Illustration Asset Governance', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // Filter Chips Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: ChefSpacing.space4, vertical: ChefSpacing.space2),
            color: colors.surfacePaper,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All Assets'),
                    selected: _statusFilter == null,
                    onSelected: (_) => setState(() => _statusFilter = null),
                  ),
                  const SizedBox(width: ChefSpacing.space2),
                  ChoiceChip(
                    label: const Text('Pending Review'),
                    selected: _statusFilter == AssetApprovalStatus.pending,
                    onSelected: (_) => setState(() => _statusFilter = AssetApprovalStatus.pending),
                  ),
                  const SizedBox(width: ChefSpacing.space2),
                  ChoiceChip(
                    label: const Text('Approved'),
                    selected: _statusFilter == AssetApprovalStatus.approved,
                    onSelected: (_) => setState(() => _statusFilter = AssetApprovalStatus.approved),
                  ),
                  const SizedBox(width: ChefSpacing.space2),
                  ChoiceChip(
                    label: const Text('Rejected'),
                    selected: _statusFilter == AssetApprovalStatus.rejected,
                    onSelected: (_) => setState(() => _statusFilter = AssetApprovalStatus.rejected),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Candidate List
          Expanded(
            child: candidatesAsync.when(
              data: (candidates) {
                final filtered = _statusFilter == null
                    ? candidates
                    : candidates.where((c) => c.status == _statusFilter).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No asset candidates in this category.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(ChefSpacing.space4),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: ChefSpacing.space3),
                  itemBuilder: (context, idx) {
                    final candidate = filtered[idx];
                    return Container(
                      padding: const EdgeInsets.all(ChefSpacing.space4),
                      decoration: BoxDecoration(
                        color: colors.surfacePaper,
                        borderRadius: BorderRadius.circular(ChefRadius.card),
                        border: Border.all(color: colors.surfaceRaised),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: ChefSpacing.space2, vertical: ChefSpacing.space1),
                                decoration: BoxDecoration(
                                  color: candidate.status == AssetApprovalStatus.approved
                                      ? colors.accentHerb.withValues(alpha: 0.15)
                                      : candidate.status == AssetApprovalStatus.rejected
                                          ? colors.stateDanger.withValues(alpha: 0.15)
                                          : colors.stateWarning.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(ChefRadius.pill),
                                ),
                                child: Text(
                                  candidate.status.name.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: candidate.status == AssetApprovalStatus.approved
                                        ? colors.accentHerb
                                        : candidate.status == AssetApprovalStatus.rejected
                                            ? colors.stateDanger
                                            : colors.stateWarning,
                                  ),
                                ),
                              ),
                              const SizedBox(width: ChefSpacing.space2),
                              Text(candidate.styleVersion, style: textTheme.bodySmall?.copyWith(color: colors.contentSecondary, fontSize: 11)),
                              const Spacer(),
                              Text(
                                DateTime.fromMillisecondsSinceEpoch(candidate.createdAt).toLocal().toString().substring(0, 10),
                                style: textTheme.bodySmall?.copyWith(color: colors.contentSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                          const SizedBox(height: ChefSpacing.space2),
                          Text(candidate.subjectKey, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                          if (candidate.promptTemplate != null) ...[
                            const SizedBox(height: ChefSpacing.space1),
                            Text(
                              'Prompt: "${candidate.promptTemplate}"',
                              style: textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: colors.contentSecondary),
                            ),
                          ],
                          const SizedBox(height: ChefSpacing.space3),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (candidate.status != AssetApprovalStatus.approved)
                                FilledButton.tonal(
                                  onPressed: () {
                                    ref.read(illustrationGovernanceServiceProvider).approveCandidate(candidate.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Approved ${candidate.subjectKey}')),
                                    );
                                  },
                                  child: const Text('Approve'),
                                ),
                              if (candidate.status != AssetApprovalStatus.rejected) ...[
                                const SizedBox(width: ChefSpacing.space2),
                                OutlinedButton(
                                  onPressed: () {
                                    ref.read(illustrationGovernanceServiceProvider).rejectCandidate(candidate.id);
                                  },
                                  child: const Text('Reject'),
                                ),
                              ],
                              const SizedBox(width: ChefSpacing.space2),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20),
                                onPressed: () {
                                  ref.read(illustrationGovernanceServiceProvider).deleteCandidate(candidate.id);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error loading assets: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
