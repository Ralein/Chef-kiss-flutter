import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/app_info.dart';
import '../../../app/widgets/common_widgets.dart';
import '../../library/presentation/widgets/library_books.dart' show kSerifFamily;

/// "Meet the developer": a note from the person who makes the app, and how
/// to reach them with an idea or a hello.
class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key});

  static const note = [
    '${AppInfo.appName} is made by one person: me. I wanted a calm, beautiful home for the recipes we love: '
        'the ones scribbled on cards, saved as screenshots, or passed down without ever being written down. '
        'Somewhere to keep them, cook from them and come back to them.',
    'There are no ads and no accounts, and your recipes stay on your phone.',
    'If something feels off, or you have an idea that would make your kitchen happier, I’d love to hear it. '
        'Every note helps shape what comes next.',
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.chefText;
    final c = context.chefColors;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: c.tomatoSoft,
                      child: Text(
                        AppInfo.developerFirstName.characters.first,
                        style: TextStyle(fontFamily: kSerifFamily, fontSize: 28, color: c.accentTomato),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(
                            header: true,
                            child: Text('Hi, I’m ${AppInfo.developerFirstName}', style: t.headlineMedium),
                          ),
                          Text('Developer of ${AppInfo.appName}', style: t.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ChefCard(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('A note from the developer', style: t.titleMedium?.copyWith(color: c.accentTomato)),
                      for (final p in note) ...[
                        const SizedBox(height: 12),
                        Text(p, style: t.bodyLarge),
                      ],
                      const SizedBox(height: 18),
                      Text(
                        'with love, ${AppInfo.developerFirstName}',
                        style: TextStyle(
                          fontFamily: kSerifFamily,
                          fontStyle: FontStyle.italic,
                          fontSize: 22,
                          color: c.contentSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => emailDeveloper(context, subject: 'An idea for ${AppInfo.appName}'),
                  icon: const Icon(LucideIcons.lightbulb),
                  label: const Text('Share an idea'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => emailDeveloper(context, subject: 'Hello from a ${AppInfo.appName} cook'),
                  icon: const Icon(LucideIcons.mail),
                  label: Text('Say hello to ${AppInfo.developerFirstName}'),
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    TextButton(onPressed: () => context.push('/privacy'), child: const Text('Privacy Policy')),
                    TextButton(onPressed: () => context.push('/terms'), child: const Text('Terms of Use')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
