import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_preferences.dart';
import '../../../services/onboarding_service.dart';
import '../../../core/logging/app_logger.dart';

// Provider for OnboardingService integration
final onboardingDataProvider = FutureProvider<OnboardingData?>((ref) async {
  // This would need access to OnboardingService instance
  // For now, return null - will be implemented when service is properly injected
  return null;
});

// Enhanced UserPreferences provider with database integration
class OnboardingPreferencesNotifier extends StateNotifier<UserPreferences> {
  OnboardingPreferencesNotifier() : super(UserPreferences());

  void setMonthlySpending(String spending) {
    state = state.copyWith(monthlySpending: spending);
  }

  void setIsOpenToNewCard(bool isOpen) {
    state = state.copyWith(isOpenToNewCard: isOpen);
  }

  void setAdditionalInfo(String info) {
    state = state.copyWith(additionalInfo: info);
  }

  void toggleOptimization(String optimization) {
    final currentOptimizations = List<String>.from(state.selectedOptimizations);
    if (currentOptimizations.contains(optimization)) {
      currentOptimizations.remove(optimization);
    } else {
      currentOptimizations.add(optimization);
    }
    state = state.copyWith(selectedOptimizations: currentOptimizations);
  }

  void setSelectedCategories(List<String> categories) {
    // Add this method to handle spending categories
    state = state.copyWith(selectedCategories: categories);
  }

  void clearPreferences() {
    state = UserPreferences();
  }

  // New method to save to database via OnboardingService
  Future<bool> saveToDatabase(OnboardingService onboardingService) async {
    try {
      if (state.monthlySpending == null) {
        throw Exception('Monthly spending range is required');
      }

      await onboardingService.saveOnboardingData(
        monthlySpendingRange: state.monthlySpending!,
        selectedOptimizations: state.selectedOptimizations,
        selectedCategories: state.selectedCategories,
        isOpenToNewCard: state.isOpenToNewCard ?? false,
        additionalInfo: state.additionalInfo,
      );

      AppLogger.info('Onboarding preferences saved to database successfully');
      return true;
    } catch (error) {
      AppLogger.error('Failed to save onboarding preferences', error, null);
      return false;
    }
  }

  // Load preferences from database
  Future<void> loadFromDatabase(OnboardingService onboardingService) async {
    try {
      final data = await onboardingService.getOnboardingData();
      if (data != null) {
        state = UserPreferences(
          monthlySpending: data.monthlySpendingRange,
          isOpenToNewCard: data.isOpenToNewCard,
          additionalInfo: data.additionalInfo,
          selectedOptimizations: data.selectedOptimizations,
          selectedCategories: data.selectedCategories,
        );

        AppLogger.info('Onboarding preferences loaded from database');
      }
    } catch (error) {
      AppLogger.error('Failed to load onboarding preferences', error, null);
    }
  }
}

final onboardingPreferencesProvider =
    StateNotifierProvider<OnboardingPreferencesNotifier, UserPreferences>(
        (ref) {
  return OnboardingPreferencesNotifier();
});

// Helper to validate onboarding completion
class OnboardingValidator {
  static bool isValid(UserPreferences preferences) {
    return preferences.monthlySpending != null &&
        preferences.selectedOptimizations.isNotEmpty &&
        preferences.selectedCategories.isNotEmpty &&
        preferences.isOpenToNewCard != null;
  }

  static List<String> getMissingFields(UserPreferences preferences) {
    List<String> missing = [];

    if (preferences.monthlySpending == null) {
      missing.add('Monthly spending range');
    }
    if (preferences.selectedOptimizations.isEmpty) {
      missing.add('Optimization preferences');
    }
    if (preferences.selectedCategories.isEmpty) {
      missing.add('Spending categories');
    }
    if (preferences.isOpenToNewCard == null) {
      missing.add('New card preference');
    }

    return missing;
  }
}
