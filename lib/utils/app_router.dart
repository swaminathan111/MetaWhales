import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/landing/screens/landing_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/auth/auth_provider.dart';
import '../services/onboarding_service.dart';
import '../services/supabase_service.dart';
import '../core/logging/app_logger.dart';

// Auth state notifier for router refresh
class _AuthStateNotifier extends ChangeNotifier {
  final WidgetRef _ref;

  _AuthStateNotifier(this._ref) {
    // Listen to auth state changes and notify router to refresh
    _ref.listen(authProvider, (previous, next) {
      notifyListeners();
    });
  }
}

class AppRouter {
  static GoRouter getRouter(
      OnboardingService onboardingService, WidgetRef ref) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: _AuthStateNotifier(ref),
      redirect: (context, state) {
        // Get current auth state
        final authState = ref.read(authProvider);
        final isAuthenticated = authState.hasValue && authState.value != null;
        final currentLocation = state.matchedLocation;

        AppLogger.debug('Router redirect check', null, null, {
          'currentLocation': currentLocation,
          'isAuthenticated': isAuthenticated,
          'userId': isAuthenticated ? authState.value!.id : null,
        });

        // Skip redirects for splash screen - let it handle its own navigation
        if (currentLocation == '/splash') {
          return null;
        }

        // If user is authenticated and trying to access login/signup/landing, redirect to home
        if (isAuthenticated &&
            (currentLocation == '/login' ||
                currentLocation == '/signup' ||
                currentLocation == '/')) {
          AppLogger.info('Redirecting authenticated user to home', null, null, {
            'fromLocation': currentLocation,
            'userId': authState.value!.id,
          });
          return '/home';
        }

        // If user is not authenticated and trying to access protected routes, redirect to login
        if (!isAuthenticated &&
            (currentLocation == '/home' || currentLocation == '/onboarding')) {
          AppLogger.info(
              'Redirecting unauthenticated user to login', null, null, {
            'fromLocation': currentLocation,
          });
          return '/login';
        }

        // No redirect needed
        return null;
      },
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
          builder: (context, state) =>
              LandingScreen(onboardingService: onboardingService),
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
          builder: (context, state) => const OnboardingScreen(),
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
