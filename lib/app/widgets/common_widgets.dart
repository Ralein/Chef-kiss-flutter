import 'package:app_contracts/app_contracts.dart';
import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/ai/ai_connection.dart';

/// Centered progress with an optional message.
class LoadingView extends StatelessWidget {
  final String? message;
  const LoadingView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: context.chefText.bodyMedium, textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}

/// Friendly error state. Never shows raw exception text to users.
class ErrorView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final Widget? extraAction;

  const ErrorView({super.key, this.title = 'Something went wrong', required this.message, this.onRetry, this.extraAction});

  factory ErrorView.failure(AppFailure failure, {VoidCallback? onRetry, Widget? extraAction}) => ErrorView(
        message: [failure.message, if (failure.recoveryAction != null) failure.recoveryAction!].join('\n'),
        onRetry: onRetry,
        extraAction: extraAction,
      );

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    final t = context.chefText;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ChefSpacing.space5),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 44, color: c.stateDanger),
              const SizedBox(height: 12),
              Text(title, style: t.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text(message, style: t.bodyMedium?.copyWith(color: c.contentSecondary), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  if (onRetry != null)
                    FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded), label: const Text('Try again')),
                  ?extraAction,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Section title used across content screens.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  const SectionHeader(this.title, {super.key, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    final t = context.chefText;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(header: true, child: Text(title, style: t.titleLarge)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: t.bodySmall),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// Rounded content card with consistent padding.
class ChefCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final VoidCallback? onTap;

  const ChefCard({super.key, required this.child, this.padding = const EdgeInsets.all(ChefSpacing.space4), this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    return Material(
      color: color ?? c.surfacePaper,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ChefRadius.tile),
        side: BorderSide(color: c.outlineSubtle),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
    );
  }
}

/// Shown wherever an AI feature is unavailable. Explains why and links to
/// the one place it can be fixed, instead of pretending to work.
class AiSetupCard extends ConsumerWidget {
  final String feature;
  const AiSetupCard({super.key, required this.feature});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.chefColors;
    final t = context.chefText;
    final state = ref.watch(aiConnectionProvider).valueOrNull;
    final canFix = state?.canEditKey ?? true;

    return ChefCard(
      color: c.yolkSoft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome_rounded, color: c.contentPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Set up AI to use $feature', style: t.titleSmall),
                const SizedBox(height: 4),
                Text(
                  canFix
                      ? 'Chef’s Kiss uses Claude by Anthropic for photo recognition and recipe writing. '
                          'Add your Anthropic API key to turn it on — everything else works offline.'
                      : 'AI features are not available in this build.',
                  style: t.bodyMedium,
                ),
                if (canFix) ...[
                  const SizedBox(height: 10),
                  FilledButton.tonalIcon(
                    onPressed: () => context.go('/settings?section=ai'),
                    icon: const Icon(Icons.key_rounded, size: 18),
                    label: const Text('Add API key'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
