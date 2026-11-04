import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

enum ChefToastType { info, success, alarm, error }

/// App-wide, theme-aware snackbar toasts.
///
/// Works with or without a [BuildContext]: when the caller's context is gone
/// (a modal just closed, a timer fired in the background) the global
/// [messengerKey] attached to `MaterialApp` is used instead.
class ChefToastService {
  ChefToastService._();

  static final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

  static void show({
    BuildContext? context,
    required String title,
    String? description,
    ChefToastType type = ChefToastType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final messenger = (context != null && context.mounted ? ScaffoldMessenger.maybeOf(context) : null) ??
        messengerKey.currentState;
    if (messenger == null) return;
    final themeContext = messengerKey.currentContext ?? (context != null && context.mounted ? context : null);
    final colors = themeContext?.chefColors ?? ChefColors.light;

    final (Color accent, IconData icon) = switch (type) {
      ChefToastType.success => (colors.stateSuccess, Icons.check_circle_rounded),
      ChefToastType.alarm => (colors.accentTomato, Icons.alarm_on_rounded),
      ChefToastType.error => (colors.stateDanger, Icons.error_rounded),
      ChefToastType.info => (colors.accentHerb, Icons.info_rounded),
    };

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          behavior: SnackBarBehavior.floating,
          backgroundColor: colors.surfacePaper,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: accent.withValues(alpha: 0.6), width: 1.2),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          action: actionLabel == null || onAction == null
              ? null
              : SnackBarAction(label: actionLabel, textColor: accent, onPressed: onAction),
          content: Semantics(
            liveRegion: true,
            child: Row(
              children: [
                Icon(icon, color: accent, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(color: colors.contentPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      if (description != null && description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(description, style: TextStyle(color: colors.contentSecondary, fontSize: 13)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}
