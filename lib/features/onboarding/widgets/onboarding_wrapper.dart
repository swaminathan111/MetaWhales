import 'package:flutter/material.dart';
import '../screens/onboarding_screen.dart';
import '../../../services/onboarding_service.dart';

class OnboardingWrapper extends StatelessWidget {
  final Widget child;
  final OnboardingService onboardingService;

  const OnboardingWrapper({
    super.key,
    required this.child,
    required this.onboardingService,
  });

  @override
  Widget build(BuildContext context) {
    if (!onboardingService.isNewUser ||
        onboardingService.hasCompletedOnboarding) {
      return child;
    }

    return const OnboardingScreen();
  }
}
