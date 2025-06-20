import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/logging/app_logger.dart';

class OnboardingService {
  final SharedPreferences _prefs;
  final SupabaseClient _supabase = Supabase.instance.client;

  // Keep local flags for immediate access
  static const String _hasCompletedOnboardingKey = 'has_completed_onboarding';
  static const String _isNewUserKey = 'is_new_user';
  static const String _selectedOptimizationsKey = 'selected_optimizations';
  static const String _selectedCategoriesKey = 'selected_categories';
  static const String _hasAddedCardKey = 'has_added_card';

  OnboardingService(this._prefs);

  // ============================================================================
  // LOCAL FLAGS (for immediate app flow control)
  // ============================================================================

  bool get isNewUser => _prefs.getBool(_isNewUserKey) ?? true;

  bool get hasCompletedOnboarding =>
      _prefs.getBool(_hasCompletedOnboardingKey) ?? false;

  Future<void> setNewUser(bool isNew) async {
    await _prefs.setBool(_isNewUserKey, isNew);
  }

  Future<void> setOnboardingComplete() async {
    await _prefs.setBool(_hasCompletedOnboardingKey, true);
    await setNewUser(false);

    // Also update database
    await _updateOnboardingCompletedInDB();
  }

  // ============================================================================
  // DATABASE OPERATIONS (persistent onboarding data)
  // ============================================================================

  /// Save complete onboarding data to database
  Future<void> saveOnboardingData({
    required String monthlySpendingRange,
    required List<String> selectedOptimizations,
    required List<String> selectedCategories,
    required bool isOpenToNewCard,
    String? additionalInfo,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      AppLogger.info('Saving onboarding data to database', null, null, {
        'userId': user.id,
        'monthlySpendingRange': monthlySpendingRange,
        'optimizationsCount': selectedOptimizations.length,
        'categoriesCount': selectedCategories.length,
        'isOpenToNewCard': isOpenToNewCard,
      });

      await _supabase.from('user_profiles').update({
        'monthly_spending_range': monthlySpendingRange,
        'selected_optimizations': selectedOptimizations,
        'selected_spending_categories': selectedCategories,
        'is_open_to_new_card': isOpenToNewCard,
        'onboarding_additional_info': additionalInfo,
        'onboarding_completed': true,
        'onboarding_completed_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);

      AppLogger.info('Onboarding data saved successfully');

      // Update local flags (without calling the method that updates DB again)
      await _prefs.setBool(_hasCompletedOnboardingKey, true);
      await setNewUser(false);
    } catch (error) {
      AppLogger.error('Failed to save onboarding data', error, null);
      rethrow;
    }
  }

  /// Get onboarding data from database
  Future<OnboardingData?> getOnboardingData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        AppLogger.warning(
            'No authenticated user found for getting onboarding data');
        return null;
      }

      final response = await _supabase.from('user_profiles').select('''
            monthly_spending_range,
            selected_optimizations,
            selected_spending_categories,
            is_open_to_new_card,
            onboarding_additional_info,
            onboarding_completed,
            onboarding_completed_at
          ''').eq('id', user.id).maybeSingle();

      if (response == null) {
        AppLogger.warning('No user profile found');
        return null;
      }

      return OnboardingData(
        monthlySpendingRange: response['monthly_spending_range'],
        selectedOptimizations:
            List<String>.from(response['selected_optimizations'] ?? []),
        selectedCategories:
            List<String>.from(response['selected_spending_categories'] ?? []),
        isOpenToNewCard: response['is_open_to_new_card'],
        additionalInfo: response['onboarding_additional_info'],
        onboardingCompleted: response['onboarding_completed'] ?? false,
        onboardingCompletedAt: response['onboarding_completed_at'] != null
            ? DateTime.parse(response['onboarding_completed_at'])
            : null,
      );
    } catch (error) {
      AppLogger.error('Failed to get onboarding data', error, null);
      return null;
    }
  }

  /// Check if user has completed onboarding in database
  Future<bool> checkOnboardingStatusInDB() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final response = await _supabase
          .from('user_profiles')
          .select('onboarding_completed')
          .eq('id', user.id)
          .maybeSingle();

      final dbCompleted = response?['onboarding_completed'] ?? false;

      // Sync local storage with database
      if (dbCompleted != hasCompletedOnboarding) {
        await _prefs.setBool(_hasCompletedOnboardingKey, dbCompleted);
      }

      return dbCompleted;
    } catch (error) {
      AppLogger.error('Failed to check onboarding status', error, null);
      return false;
    }
  }

  /// Update specific onboarding field
  Future<void> updateOnboardingField(String field, dynamic value) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      await _supabase.from('user_profiles').update({
        field: value,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);

      AppLogger.info('Updated onboarding field', null, null, {
        'field': field,
        'value': value.toString(),
      });
    } catch (error) {
      AppLogger.error('Failed to update onboarding field', error, null);
      rethrow;
    }
  }

  // ============================================================================
  // LEGACY METHODS (for backward compatibility - gradually remove these)
  // ============================================================================

  @Deprecated('Use saveOnboardingData instead')
  Future<void> saveSelectedOptimizations(List<String> optimizations) async {
    await updateOnboardingField('selected_optimizations', optimizations);
  }

  @Deprecated('Use getOnboardingData instead')
  List<String> getSelectedOptimizations() {
    // This will be empty until we implement local caching
    return [];
  }

  @Deprecated('Use saveOnboardingData instead')
  Future<void> saveSelectedCategories(List<String> categories) async {
    await updateOnboardingField('selected_spending_categories', categories);
  }

  @Deprecated('Use getOnboardingData instead')
  List<String> getSelectedCategories() {
    // This will be empty until we implement local caching
    return [];
  }

  @Deprecated('Use saveOnboardingData instead')
  Future<void> setHasAddedCard(bool value) async {
    // This could be a separate field if needed
    AppLogger.info('Card added status updated', null, null, {'hasCard': value});
  }

  @Deprecated('Use checkOnboardingStatusInDB instead')
  bool get hasAddedCard => false; // Placeholder

  // ============================================================================
  // PRIVATE HELPERS
  // ============================================================================

  Future<void> _updateOnboardingCompletedInDB() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('user_profiles').update({
        'onboarding_completed': true,
        'onboarding_completed_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);
    } catch (error) {
      AppLogger.error(
          'Failed to update onboarding completion status', error, null);
    }
  }

  /// Reset onboarding (for testing/development)
  Future<void> resetOnboarding() async {
    try {
      // Clear local storage
      await _prefs.remove(_hasCompletedOnboardingKey);
      await _prefs.remove(_isNewUserKey);

      // Reset database
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase.from('user_profiles').update({
          'onboarding_completed': false,
          'onboarding_completed_at': null,
          'monthly_spending_range': null,
          'selected_optimizations': [],
          'selected_spending_categories': [],
          'is_open_to_new_card': null,
          'onboarding_additional_info': null,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', user.id);
      }

      AppLogger.info('Onboarding reset completed');
    } catch (error) {
      AppLogger.error('Failed to reset onboarding', error, null);
      rethrow;
    }
  }
}

// ============================================================================
// DATA MODELS
// ============================================================================

class OnboardingData {
  final String? monthlySpendingRange;
  final List<String> selectedOptimizations;
  final List<String> selectedCategories;
  final bool? isOpenToNewCard;
  final String? additionalInfo;
  final bool onboardingCompleted;
  final DateTime? onboardingCompletedAt;

  OnboardingData({
    this.monthlySpendingRange,
    this.selectedOptimizations = const [],
    this.selectedCategories = const [],
    this.isOpenToNewCard,
    this.additionalInfo,
    this.onboardingCompleted = false,
    this.onboardingCompletedAt,
  });

  Map<String, dynamic> toJson() => {
        'monthlySpendingRange': monthlySpendingRange,
        'selectedOptimizations': selectedOptimizations,
        'selectedCategories': selectedCategories,
        'isOpenToNewCard': isOpenToNewCard,
        'additionalInfo': additionalInfo,
        'onboardingCompleted': onboardingCompleted,
        'onboardingCompletedAt': onboardingCompletedAt?.toIso8601String(),
      };

  @override
  String toString() => 'OnboardingData(${toJson()})';
}
