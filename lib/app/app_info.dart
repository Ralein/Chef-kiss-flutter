import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'chef_toast_service.dart';

/// Who makes Chef's Kiss and how to reach them: shown in Settings, on the
/// developer's page and in the privacy policy and terms.
abstract final class AppInfo {
  static const appName = 'Chef’s Kiss';
  static const developerName = 'Ralein Nova';
  static const developerFirstName = 'Ralein';
  static const contactEmail = 'raleinnova@gmail.com';

  /// When the privacy policy and terms last changed.
  static const policyUpdated = 'November 8, 2026';
}

/// The installed version, e.g. "0.0.1 (1)"; null until it's read.
final appVersionProvider = FutureProvider<String?>((ref) async {
  try {
    final info = await PackageInfo.fromPlatform();
    final build = info.buildNumber.trim();
    return build.isEmpty || build == info.version ? info.version : '${info.version} ($build)';
  } catch (_) {
    return null;
  }
});

/// Opens a new email to the developer. Without a mail app, the address is
/// copied instead so it can be pasted anywhere.
Future<void> emailDeveloper(BuildContext context, {required String subject}) async {
  final uri = Uri.parse('mailto:${AppInfo.contactEmail}?subject=${Uri.encodeComponent(subject)}');
  var opened = false;
  try {
    opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    opened = false;
  }
  if (opened) return;
  await Clipboard.setData(const ClipboardData(text: AppInfo.contactEmail));
  ChefToastService.show(
    context: context.mounted ? context : null,
    title: 'Email address copied',
    description: AppInfo.contactEmail,
  );
}
