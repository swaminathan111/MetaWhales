import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/auth_provider.dart';
import '../../../services/onboarding_service.dart';
import '../../../core/logging/app_logger.dart';
import '../../../services/supabase_service.dart';

class LandingScreen extends ConsumerStatefulWidget {
  final OnboardingService onboardingService;

  const LandingScreen({
    super.key,
    required this.onboardingService,
  });

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  @override
  void initState() {
    super.initState();
    _handleAuthState();
  }

  void _handleAuthState() {
    // Listen for authentication state changes (OAuth callback handling)
    SupabaseService.client.auth.onAuthStateChange.listen((data) {
      if (data.session != null && mounted) {
        AppLogger.auth(
            'Authentication state changed - user signed in via OAuth');
        _navigateBasedOnUserStatus();
      }
    });

    // Also check current auth state immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      if (authState.hasValue && authState.value != null) {
        _navigateBasedOnUserStatus();
      }
    });
  }

  void _navigateBasedOnUserStatus() async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user != null) {
        // Check if user is marked as new in onboarding service
        final isNewUser = widget.onboardingService.isNewUser;
        final hasCompletedOnboarding =
            widget.onboardingService.hasCompletedOnboarding;

        AppLogger.auth('User authentication detected', null, null, {
          'userId': user.id,
          'isNewUser': isNewUser,
          'hasCompletedOnboarding': hasCompletedOnboarding,
        });

        if (isNewUser && !hasCompletedOnboarding) {
          AppLogger.auth('New user detected, navigating to onboarding');
          context.go('/onboarding');
        } else {
          AppLogger.auth('Existing user detected, navigating to home');
          context.go('/home');
        }
      }
    } catch (error) {
      AppLogger.error('Error handling post-OAuth navigation', error, null);
      // Fallback to login if there's an error
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2196F3),
              Color(0xFF1976D2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Logo/Icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.credit_card,
                          size: 60,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // App Name
                      const Text(
                        'CardSense',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Tagline
                      const Text(
                        'Smart Credit Card Management',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      // Get Started Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => context.go('/signup'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF1976D2),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () => context.go('/login'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side:
                                const BorderSide(color: Colors.white, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
