import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/landing/screens/landing_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/screens/add_card_screen.dart';
import '../services/onboarding_service.dart';

class AppRouter {
  static GoRouter getRouter(OnboardingService onboardingService) {
    return GoRouter(
      initialLocation: '/splash',
      routes: [
        // Splash Screen
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),

        // Landing Screen
        GoRoute(
          path: '/',
          name: 'landing',
          builder: (context, state) => const LandingScreen(),
        ),

        // Login Screen
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) =>
              LoginScreen(onboardingService: onboardingService),
        ),

        // Signup Screen
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) =>
              SignupScreen(onboardingService: onboardingService),
        ),

        // Onboarding Screen
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          builder: (context, state) => const AddCardScreen(),
        ),

        // Home Screen
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'The page you are looking for does not exist.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
