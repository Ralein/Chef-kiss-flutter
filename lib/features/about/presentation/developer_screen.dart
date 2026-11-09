import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/app_info.dart';
import '../../../app/widgets/common_widgets.dart';

/// "Meet the developer": a note from the person who makes the app and how to
/// reach them, laid out like Settings.
class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key});

  static const note = [
    '${AppInfo.appName} is made by one person: me. I wanted a calm, beautiful home for the recipes we love: '
        'the ones scribbled on cards, saved as screenshots, or passed down without ever being written down.',
    'There are no ads and no accounts, and your recipes stay on your phone.',
    'If something feels off, or you have an idea that would make your kitchen happier, I’d love to hear it.',
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.chefText;
    final c = context.chefColors;
    Widget link(IconData icon, String title, VoidCallback onTap, {String? subtitle}) => ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: const Icon(LucideIcons.chevronRight),
      onTap: onTap,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Meet the developer')),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              children: [
                ChefCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: c.tomatoSoft,
                            child: Text(
                              AppInfo.developerFirstName.characters.first,
                              style: t.titleLarge?.copyWith(color: c.accentTomato),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppInfo.developerName, style: t.titleMedium),
                                Text('Developer of ${AppInfo.appName}', style: t.bodySmall),
                              ],
                            ),
                          ),
                        ],
                      ),
                      for (final p in note) ...[
                        const SizedBox(height: 12),
                        Text(p, style: t.bodyMedium),
                      ],
                      const SizedBox(height: 12),
                      Text('— ${AppInfo.developerFirstName}', style: t.bodyMedium?.copyWith(color: c.contentSecondary)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ChefCard(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(
                    children: [
                      link(
                        LucideIcons.lightbulb,
                        'Share an idea',
                        () => emailDeveloper(context, subject: 'An idea for ${AppInfo.appName}'),
                      ),
                      link(
                        LucideIcons.mail,
                        'Say hello',
                        () => emailDeveloper(context, subject: 'Hello from a ${AppInfo.appName} cook'),
                        subtitle: AppInfo.contactEmail,
                      ),
                      link(LucideIcons.shieldCheck, 'Privacy Policy', () => context.push('/privacy')),
                      link(LucideIcons.scrollText, 'Terms of Use', () => context.push('/terms')),
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
