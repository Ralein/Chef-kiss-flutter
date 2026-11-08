import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

import '../../../app/app_info.dart';

/// A section of a legal document: a heading and its paragraphs.
typedef LegalSection = ({String heading, List<String> paragraphs});

/// The privacy policy and terms of use, written for this app as it is: no
/// account, everything on the device, AI only when you ask for it.
enum LegalDocument {
  privacy('Privacy Policy'),
  terms('Terms of Use');

  final String title;
  const LegalDocument(this.title);

  String get intro => switch (this) {
    LegalDocument.privacy =>
      '${AppInfo.appName} is a recipe book and cooking companion made by ${AppInfo.developerName}. '
          'This policy explains what the app does with your information. The short version: '
          'your kitchen stays on your phone.',
    LegalDocument.terms =>
      'These terms cover your use of ${AppInfo.appName}, made by ${AppInfo.developerName}. '
          'By using the app you agree to them. If you don’t, please don’t use the app.',
  };

  List<LegalSection> get sections => switch (this) {
    LegalDocument.privacy => const [
      (
        heading: 'What stays on your device',
        paragraphs: [
          'Your recipes, cookbooks, photos, food log, cooking goal, the name you give the app and your settings '
              'are stored only on this device. There is no ${AppInfo.appName} account, and no server of mine '
              'receives them.',
        ],
      ),
      (
        heading: 'Chef’s Kiss AI',
        paragraphs: [
          'Some features use AI: scanning food, reading a recipe from a photo, page or text, creating a recipe '
              'from an idea, suggesting dishes from your ingredients and estimating nutrition. Only when you use '
              'one of them, what that feature needs is sent over an encrypted connection: the photo you scan, the '
              'recipe you import, your idea or ingredient list, or a recipe’s ingredients.',
          'It goes to free, shared AI models run by third-party providers, reached through an AI gateway. Those '
              'providers may log what they receive, so please leave personal details out of what you send.',
        ],
      ),
      (
        heading: 'Links and images',
        paragraphs: [
          'When you import a recipe from a link, the app downloads that page straight from the website, as a '
              'browser would. Images you add by link are loaded from where they’re hosted.',
        ],
      ),
      (
        heading: 'Read aloud, camera and photos',
        paragraphs: [
          'Read aloud uses your device’s built-in text-to-speech; the app doesn’t send the text anywhere itself. '
              'Photos you take or choose are kept in the app’s own storage on your device.',
        ],
      ),
      (
        heading: 'No ads, no tracking',
        paragraphs: [
          '${AppInfo.appName} has no ads, analytics or tracking, and your information is never sold or shared '
              'for marketing.',
        ],
      ),
      (
        heading: 'Your choices',
        paragraphs: [
          'You can export a backup, delete any recipe, or erase everything from Settings → Your data. '
              'Uninstalling the app removes everything it stored on this device.',
        ],
      ),
      (
        heading: 'Children',
        paragraphs: [
          '${AppInfo.appName} isn’t directed at children under 13 and doesn’t knowingly collect information '
              'from them.',
        ],
      ),
      (
        heading: 'Changes',
        paragraphs: [
          'If this policy changes, the new version will appear here with a new date.',
        ],
      ),
    ],
    LegalDocument.terms => const [
      (
        heading: 'Using the app',
        paragraphs: [
          '${AppInfo.appName} is for your personal, non-commercial use. Please don’t misuse it, for example by '
              'trying to disrupt the services it relies on.',
        ],
      ),
      (
        heading: 'Your recipes',
        paragraphs: [
          'Recipes, photos and notes you add are yours. Because they live only on your device, keeping a backup '
              'is up to you: use Export backup in Settings.',
          'Respect other people’s work when you import or copy recipes, photos and text, and keep them for your '
              'own use unless you have permission.',
        ],
      ),
      (
        heading: 'AI features',
        paragraphs: [
          'AI can be wrong. Recipes, food scans and nutrition estimates it produces may be inaccurate or '
              'incomplete, so check them before relying on them. The free AI service can be busy or unavailable '
              'at times.',
        ],
      ),
      (
        heading: 'Food, health and safety',
        paragraphs: [
          'Nutrition, allergen and food-safety information in the app is approximate and for general guidance '
              'only. It isn’t medical or dietary advice. Always check labels for allergens, follow safe cooking '
              'temperatures and food handling, and ask a professional about specific dietary needs.',
          'Cooking involves heat, sharp tools and hot surfaces. Use your own judgement and take care.',
        ],
      ),
      (
        heading: 'No warranty',
        paragraphs: [
          'The app is provided “as is”, without warranties of any kind. Features may change or be removed. To '
              'the extent the law allows, the developer isn’t liable for any loss arising from use of the app, '
              'including lost data.',
        ],
      ),
      (
        heading: 'Changes',
        paragraphs: [
          'These terms may be updated; the new version will appear here with a new date. Continuing to use the '
              'app means you accept them.',
        ],
      ),
    ],
  };
}

/// One legal document, readable at any width.
class LegalScreen extends StatelessWidget {
  final LegalDocument document;
  const LegalScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    final t = context.chefText;
    final c = context.chefColors;
    return Scaffold(
      appBar: AppBar(title: Text(document.title)),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                Text('Last updated ${AppInfo.policyUpdated}', style: t.bodySmall),
                const SizedBox(height: 12),
                Text(document.intro, style: t.bodyLarge),
                for (final section in document.sections) ...[
                  const SizedBox(height: 24),
                  Semantics(header: true, child: Text(section.heading, style: t.titleMedium)),
                  for (final p in section.paragraphs) ...[
                    const SizedBox(height: 8),
                    Text(p, style: t.bodyMedium?.copyWith(color: c.contentPrimary)),
                  ],
                ],
                const SizedBox(height: 24),
                Semantics(header: true, child: Text('Contact', style: t.titleMedium)),
                const SizedBox(height: 8),
                Text('Questions or requests: ${AppInfo.contactEmail}', style: t.bodyMedium),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => emailDeveloper(context, subject: '${AppInfo.appName}: ${document.title}'),
                    child: const Text('Email the developer'),
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
