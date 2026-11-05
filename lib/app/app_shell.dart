import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers.dart';
import 'widgets/kitchen_format.dart';

class _Destination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _Destination(this.icon, this.selectedIcon, this.label);
}

const _destinations = [
  _Destination(Icons.menu_book_outlined, Icons.menu_book_rounded, 'Recipes'),
  _Destination(Icons.photo_camera_outlined, Icons.photo_camera_rounded, 'Scan'),
  _Destination(Icons.insights_outlined, Icons.insights_rounded, 'Food log'),
  _Destination(Icons.collections_bookmark_outlined, Icons.collections_bookmark_rounded, 'Collections'),
  _Destination(Icons.settings_outlined, Icons.settings_rounded, 'Settings'),
];

/// Adaptive navigation: bottom bar on phones, rail on tablets/desktop.
class AppShell extends StatelessWidget {
  final StatefulNavigationShell shell;
  const AppShell({super.key, required this.shell});

  static const compactBreakpoint = 720.0;

  void _select(int index) => shell.goBranch(index, initialLocation: index == shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final c = context.chefColors;
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < compactBreakpoint) {
        return Scaffold(
          body: shell,
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _RunningTimersBar(),
              Divider(height: 1, color: c.outlineSubtle),
              NavigationBar(
                selectedIndex: shell.currentIndex,
                onDestinationSelected: _select,
                destinations: [
                  for (final d in _destinations)
                    NavigationDestination(icon: Icon(d.icon), selectedIcon: Icon(d.selectedIcon), label: d.label),
                ],
              ),
            ],
          ),
        );
      }

      final extended = constraints.maxWidth >= 1200;
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: extended,
              selectedIndex: shell.currentIndex,
              onDestinationSelected: _select,
              labelType: extended ? NavigationRailLabelType.none : NavigationRailLabelType.all,
              minExtendedWidth: 220,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: ChefSpacing.space4),
                child: ChefBrandBadge(size: 40, showTitle: extended),
              ),
              trailing: const Expanded(
                child: Align(alignment: Alignment.bottomCenter, child: _RunningTimersRailIndicator()),
              ),
              destinations: [
                for (final d in _destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
            VerticalDivider(width: 1, color: c.outlineSubtle),
            Expanded(child: shell),
          ],
        ),
      );
    });
  }
}

/// Persistent strip showing the soonest running kitchen timer.
class _RunningTimersBar extends ConsumerWidget {
  const _RunningTimersBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timers = ref.watch(kitchenTimersProvider);
    final running = timers.running;
    if (running.isEmpty) return const SizedBox.shrink();
    final now = timers.now;
    running.sort((a, b) => a.remainingSeconds(now).compareTo(b.remainingSeconds(now)));
    final next = running.first;
    final c = context.chefColors;
    final t = context.chefText;

    return Material(
      color: c.tomatoSoft,
      child: InkWell(
        onTap: () => context.push('/recipe/${next.recipeId}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.timer_outlined, size: 18, color: c.contentPrimary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${next.label} · ${next.recipeTitle}${running.length > 1 ? '  +${running.length - 1} more' : ''}',
                  style: t.labelLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                KitchenFormat.clock(next.remainingSeconds(now)),
                style: ChefTypography.numeric(c.contentPrimary, size: 15, weight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RunningTimersRailIndicator extends ConsumerWidget {
  const _RunningTimersRailIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timers = ref.watch(kitchenTimersProvider);
    final running = timers.running;
    if (running.isEmpty) return const SizedBox(height: 16);
    final now = timers.now;
    running.sort((a, b) => a.remainingSeconds(now).compareTo(b.remainingSeconds(now)));
    final next = running.first;
    final c = context.chefColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Tooltip(
        message: '${next.label} · ${next.recipeTitle}',
        child: ActionChip(
          avatar: Icon(Icons.timer_outlined, size: 18, color: c.accentTomato),
          label: Text(
            KitchenFormat.clock(next.remainingSeconds(now)),
            style: ChefTypography.numeric(c.contentPrimary, size: 14, weight: FontWeight.w700),
          ),
          onPressed: () => context.push('/recipe/${next.recipeId}'),
        ),
      ),
    );
  }
}
