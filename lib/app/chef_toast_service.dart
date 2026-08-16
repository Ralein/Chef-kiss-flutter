import 'package:flutter/material.dart';
import 'audio_chime_service.dart';

enum ChefToastType {
  info,
  success,
  alarm,
  error;
}

class ChefToastNotification {
  final String title;
  final String? description;
  final ChefToastType type;
  final Duration duration;

  const ChefToastNotification({
    required this.title,
    this.description,
    this.type = ChefToastType.info,
    this.duration = const Duration(seconds: 3),
  });
}

class ChefToastService {
  static final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

  static void show({
    required BuildContext context,
    required String title,
    String? description,
    ChefToastType type = ChefToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    audioChime.playTap();

    Color bgColor;
    Color borderColor;
    Color textColor;
    IconData icon;

    switch (type) {
      case ChefToastType.success:
        bgColor = const Color(0xFFEEF4F0);
        borderColor = const Color(0xFF4A6B53);
        textColor = const Color(0xFF283D2F);
        icon = Icons.check_circle_outline;
        break;
      case ChefToastType.alarm:
        bgColor = const Color(0xFFFBEFF1);
        borderColor = const Color(0xFFD94B34);
        textColor = const Color(0xFF8A2E14);
        icon = Icons.alarm_on;
        break;
      case ChefToastType.error:
        bgColor = const Color(0xFFFBEFF1);
        borderColor = const Color(0xFFC7382B);
        textColor = const Color(0xFF7A1C14);
        icon = Icons.error_outline;
        break;
      case ChefToastType.info:
        bgColor = const Color(0xFFFBF0EB);
        borderColor = const Color(0xFFC85A32);
        textColor = const Color(0xFF4A3219);
        icon = Icons.info_outline;
        break;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        content: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: borderColor, size: 20),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      if (description != null && description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          description,
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
