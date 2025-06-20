import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_card_screen.dart';
import 'optimization_screen.dart';
import 'spending_categories_screen.dart';
import 'spending_screen.dart';
import 'preferences_screen.dart';
import '../models/user_preferences.dart';
import '../../../core/logging/app_logger.dart';
import '../../../services/onboarding_service.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 5;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Save onboarding data to database
      _saveOnboardingData();
    }
  }

  void _saveOnboardingData() async {
    try {
      final preferences = ref.read(userPreferencesProvider);

      // Validate that we have all required data
      if (preferences.monthlySpending == null) {
        throw Exception('Monthly spending range is required');
      }
      if (preferences.selectedOptimizations.isEmpty) {
        throw Exception('At least one optimization preference is required');
      }
      if (preferences.selectedCategories.isEmpty) {
        throw Exception('At least one spending category is required');
      }
      if (preferences.isOpenToNewCard == null) {
        throw Exception('New card preference is required');
      }

      AppLogger.info('Saving onboarding data', null, null, {
        'monthlySpending': preferences.monthlySpending,
        'optimizationsCount': preferences.selectedOptimizations.length,
        'categoriesCount': preferences.selectedCategories.length,
        'isOpenToNewCard': preferences.isOpenToNewCard,
      });

      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Saving your preferences...'),
              ],
            ),
          ),
        );
      }

      // Get OnboardingService instance
      final prefs = await SharedPreferences.getInstance();
      final onboardingService = OnboardingService(prefs);

      // Save to database
      await onboardingService.saveOnboardingData(
        monthlySpendingRange: preferences.monthlySpending!,
        selectedOptimizations: preferences.selectedOptimizations,
        selectedCategories: preferences.selectedCategories,
        isOpenToNewCard: preferences.isOpenToNewCard!,
        additionalInfo: preferences.additionalInfo,
      );

      AppLogger.info('Onboarding data saved successfully to database');

      // Clear local state
      ref.read(userPreferencesProvider.notifier).clearPreferences();

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Onboarding completed successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Navigate to home after a short delay
      if (mounted) {
        await Future.delayed(const Duration(seconds: 1));
        context.go('/home');
      }
    } catch (error) {
      AppLogger.error('Failed to save onboarding data', error, null);

      // Close loading dialog if open
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save onboarding data: $error'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _saveOnboardingData(),
            ),
          ),
        );
      }
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    ref.read(userPreferencesProvider.notifier).clearPreferences();
    context.go('/home');
  }

  String get _getButtonText {
    if (_currentPage == _totalPages - 1) return 'Finish';
    if (_currentPage == 0) return 'Get Started';
    return 'Next';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: List.generate(
                  _totalPages,
                  (index) => Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Step indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Text(
                    'Step ${_currentPage + 1} of $_totalPages',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  OnboardingAddCardScreen(onNext: _nextPage),
                  OptimizationScreen(onNext: _nextPage),
                  SpendingScreen(onNext: _nextPage),
                  SpendingCategoriesScreen(onNext: _nextPage),
                  PreferencesScreen(onNext: _nextPage),
                ],
              ),
            ),
            // Bottom navigation
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Next and Back buttons side by side
                  Row(
                    children: [
                      if (_currentPage > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _previousPage,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            child: const Text('Back'),
                          ),
                        ),
                      if (_currentPage > 0) const SizedBox(width: 12),
                      Expanded(
                        flex: _currentPage > 0 ? 2 : 1,
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(_getButtonText),
                        ),
                      ),
                    ],
                  ),
                  // Skip button at bottom
                  if (_currentPage < _totalPages - 1) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _skipOnboarding,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                      ),
                      child: const Text(
                        'Skip for now',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
