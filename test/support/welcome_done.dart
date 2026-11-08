import 'package:chefs_kiss/features/onboarding/application/onboarding.dart';

/// For tests of the app itself: the welcome tour is already behind the cook
/// and its card on the home screen closed.
final welcomeDone = [
  onboardingDoneProvider.overrideWith((ref) => Stream.value(true)),
  welcomeCardDismissedProvider.overrideWith((ref) => Stream.value(true)),
];
