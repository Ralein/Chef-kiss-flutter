import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_tokens/design_tokens.dart';
import 'audio_chime_service.dart';
import 'chef_toast_service.dart';
import '../features/imports/presentation/ai_recipe_studio_modal.dart';

final isStudioEditModeProvider = StateProvider<bool>((ref) => false);
final lastViewedRecipeIdProvider = StateProvider<String>((ref) => 'pasta-pomodoro');

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  void _openAIStudio(BuildContext context) {
    audioChime.playTap();
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AIRecipeStudioModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.chefColors;
    final isEditMode = ref.watch(isStudioEditModeProvider);
    final lastRecipeId = ref.watch(lastViewedRecipeIdProvider);
    final location = GoRouterState.of(context).uri.toString();
    final isShelf = location == '/';
    final isJournal = location.startsWith('/recipe');

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 768;

        if (isCompact) {
          // 📱 Mobile View with Floating Glass Dock
          return Scaffold(
            backgroundColor: colors.surfaceCanvas,
            extendBody: true,
            body: SafeArea(
              bottom: false,
              child: child,
            ),
            bottomNavigationBar: SafeArea(
              top: false,
              bottom: true,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                height: 68,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Glass Pill Background & 4 Side Tabs
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            height: 60,
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF7F2).withValues(alpha: 0.94),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: const Color(0xFFE8E0D2), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Shelf Tab
                                Expanded(
                                  child: _buildMobileNavTab(
                                    icon: Icons.explore_outlined,
                                    activeIcon: Icons.explore,
                                    label: 'Shelf',
                                    isSelected: isShelf,
                                    activeColor: const Color(0xFFC85A32),
                                    activeBgColor: const Color(0xFFFBF0EB),
                                    onTap: () {
                                      audioChime.playTap();
                                      context.go('/');
                                    },
                                  ),
                                ),

                                // Journal Tab
                                Expanded(
                                  child: _buildMobileNavTab(
                                    icon: Icons.menu_book_outlined,
                                    activeIcon: Icons.menu_book,
                                    label: 'Journal',
                                    isSelected: isJournal,
                                    activeColor: const Color(0xFF4A6B53),
                                    activeBgColor: const Color(0xFFEEF4F0),
                                    onTap: () {
                                      audioChime.playTap();
                                      context.go('/recipe/$lastRecipeId');
                                    },
                                  ),
                                ),

                                // Empty Spacer for Raised Center Button
                                const SizedBox(width: 58),

                                // AI Studio Trigger
                                Expanded(
                                  child: _buildMobileNavTab(
                                    icon: Icons.auto_awesome_outlined,
                                    activeIcon: Icons.auto_awesome,
                                    label: 'AI Studio',
                                    isSelected: false,
                                    activeColor: const Color(0xFF4A6B53),
                                    activeBgColor: Colors.transparent,
                                    onTap: () => _openAIStudio(context),
                                  ),
                                ),

                                // Edit / View Mode Switch
                                Expanded(
                                  child: _buildMobileNavTab(
                                    icon: isEditMode ? Icons.edit : Icons.remove_red_eye_outlined,
                                    activeIcon: isEditMode ? Icons.edit : Icons.remove_red_eye,
                                    label: isEditMode ? 'Editing' : 'View',
                                    isSelected: isEditMode,
                                    activeColor: const Color(0xFFC85A32),
                                    activeBgColor: const Color(0xFFFBF0EB),
                                    onTap: () {
                                      audioChime.playTap();
                                      final next = !isEditMode;
                                      ref.read(isStudioEditModeProvider.notifier).state = next;
                                      if (isShelf) {
                                        context.go('/recipe/$lastRecipeId');
                                      }
                                      ChefToastService.show(
                                        context: context,
                                        title: next ? 'Edit Mode Activated' : 'View Mode Activated',
                                        description: next ? 'Tap elements to customize notes & stickers' : 'Clean reading view',
                                        type: ChefToastType.info,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Raised Protruding Center Cook Button
                    Positioned(
                      top: -4,
                      child: GestureDetector(
                        onTap: () {
                          audioChime.playTap();
                          context.push('/cook/$lastRecipeId');
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF1E1A18), Color(0xFF382E28)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(color: const Color(0xFFFAF7F2), width: 3.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFC85A32).withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(Icons.restaurant_menu, color: Color(0xFFD9822B), size: 24),
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Cook',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1E1A18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // 💻 Desktop / Tablet Layout with Top StudioNavbar
        return Scaffold(
          backgroundColor: colors.surfaceCanvas,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(58),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFAF7F2).withValues(alpha: 0.95),
                border: const Border(bottom: BorderSide(color: Color(0xFFE8E0D2))),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Brand Badge
                  const ChefBrandBadge(size: 34, showTitle: true),

                  // Center Nav Pill (Cookbook Shelf vs Recipe Journal)
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE6DC),
                      borderRadius: BorderRadius.circular(ChefRadius.pill),
                      border: Border.all(color: const Color(0xFFDFD6C9)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildDesktopNavPill(
                          label: 'Cookbook Shelf',
                          icon: Icons.explore_outlined,
                          isSelected: isShelf,
                          color: const Color(0xFFC85A32),
                          onTap: () {
                            audioChime.playTap();
                            context.go('/');
                          },
                        ),
                        const SizedBox(width: 4),
                        _buildDesktopNavPill(
                          label: 'Recipe Journal',
                          icon: Icons.menu_book_outlined,
                          isSelected: isJournal,
                          color: const Color(0xFF4A6B53),
                          onTap: () {
                            audioChime.playTap();
                            context.go('/recipe/$lastRecipeId');
                          },
                        ),
                      ],
                    ),
                  ),

                  // Right Side: AI Studio & View / Edit Switch
                  Row(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A6B53),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ChefRadius.pill)),
                        ),
                        icon: const Icon(Icons.auto_awesome, size: 14),
                        label: const Text('AI Studio', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        onPressed: () => _openAIStudio(context),
                      ),
                      const SizedBox(width: 10),

                      // View / Edit Toggle Pill
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE6DC),
                          borderRadius: BorderRadius.circular(ChefRadius.pill),
                          border: Border.all(color: const Color(0xFFDFD6C9)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                audioChime.playTap();
                                ref.read(isStudioEditModeProvider.notifier).state = false;
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: !isEditMode ? const Color(0xFF1E1A18) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(ChefRadius.pill),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.remove_red_eye_outlined, size: 13, color: !isEditMode ? Colors.white : const Color(0xFF6B625B)),
                                    const SizedBox(width: 4),
                                    Text('View', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: !isEditMode ? Colors.white : const Color(0xFF6B625B))),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                audioChime.playTap();
                                ref.read(isStudioEditModeProvider.notifier).state = true;
                                if (isShelf) context.go('/recipe/$lastRecipeId');
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isEditMode ? const Color(0xFFC85A32) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(ChefRadius.pill),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined, size: 13, color: isEditMode ? Colors.white : const Color(0xFF6B625B)),
                                    const SizedBox(width: 4),
                                    Text('Edit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isEditMode ? Colors.white : const Color(0xFF6B625B))),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          body: child,
        );
      },
    );
  }

  Widget _buildMobileNavTab({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
    required Color activeColor,
    required Color activeBgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? activeBgColor : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected ? Border.all(color: activeColor.withValues(alpha: 0.35), width: 1) : null,
            ),
            child: Icon(
              isSelected ? activeIcon : icon,
              size: 18,
              color: isSelected ? activeColor : const Color(0xFF6B625B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              color: isSelected ? activeColor : const Color(0xFF6B625B),
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopNavPill({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(ChefRadius.pill),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isSelected ? color : const Color(0xFF6B625B)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF1E1A18) : const Color(0xFF6B625B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
