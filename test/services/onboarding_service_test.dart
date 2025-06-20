import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cardsense_ai/services/onboarding_service.dart';
import 'package:cardsense_ai/core/logging/app_logger.dart';

void main() {
  group('OnboardingService Tests', () {
    late OnboardingService onboardingService;
    late SharedPreferences prefs;

    setUpAll(() async {
      // Initialize test environment
      await AppLogger.initialize();

      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();

      onboardingService = OnboardingService(prefs);
    });

    group('Local Storage Tests', () {
      test('should set and get new user status', () async {
        // Test setting new user
        await onboardingService.setNewUser(false);
        expect(onboardingService.isNewUser, false);

        await onboardingService.setNewUser(true);
        expect(onboardingService.isNewUser, true);
      });

      test('should set and get onboarding completion status', () async {
        // Initially not completed
        expect(onboardingService.hasCompletedOnboarding, false);

        // Set as completed
        await onboardingService.setOnboardingComplete();
        expect(onboardingService.hasCompletedOnboarding, true);
        expect(onboardingService.isNewUser, false);
      });

      test('should reset onboarding status', () async {
        // Set some data
        await onboardingService.setOnboardingComplete();
        expect(onboardingService.hasCompletedOnboarding, true);

        // Reset
        await onboardingService.resetOnboarding();
        expect(onboardingService.hasCompletedOnboarding, false);
      });
    });

    group('Data Validation Tests', () {
      test('OnboardingData should create valid instance', () {
        final data = OnboardingData(
          monthlySpendingRange: '₹30-75k',
          selectedOptimizations: ['Rewards/Cashback', 'Travel perks'],
          selectedCategories: ['Groceries', 'Dining', 'Travel'],
          isOpenToNewCard: true,
          additionalInfo: 'Looking for better rewards',
          onboardingCompleted: true,
          onboardingCompletedAt: DateTime.now(),
        );

        expect(data.monthlySpendingRange, '₹30-75k');
        expect(data.selectedOptimizations.length, 2);
        expect(data.selectedCategories.length, 3);
        expect(data.isOpenToNewCard, true);
        expect(data.onboardingCompleted, true);
        expect(data.additionalInfo, 'Looking for better rewards');
      });

      test('OnboardingData should convert to JSON correctly', () {
        final data = OnboardingData(
          monthlySpendingRange: '₹30-75k',
          selectedOptimizations: ['Rewards/Cashback'],
          selectedCategories: ['Groceries'],
          isOpenToNewCard: true,
          onboardingCompleted: true,
        );

        final json = data.toJson();
        expect(json['monthlySpendingRange'], '₹30-75k');
        expect(json['selectedOptimizations'], ['Rewards/Cashback']);
        expect(json['selectedCategories'], ['Groceries']);
        expect(json['isOpenToNewCard'], true);
        expect(json['onboardingCompleted'], true);
      });
    });

    group('Database Integration Tests', () {
      // Note: These tests require a valid Supabase connection
      // In a real test environment, you would use a test database

      test('should handle saveOnboardingData with valid data', () async {
        // This test would normally require mocking Supabase or using a test database
        // For now, we'll test the method signature and validation logic

        expect(() async {
          await onboardingService.saveOnboardingData(
            monthlySpendingRange: '₹30-75k',
            selectedOptimizations: ['Rewards/Cashback', 'Travel perks'],
            selectedCategories: ['Groceries', 'Dining'],
            isOpenToNewCard: true,
            additionalInfo: 'Test info',
          );
        },
            throwsA(
                isA<Exception>())); // Will throw because no auth user in test
      });

      test('should handle getOnboardingData when no user is authenticated',
          () async {
        final data = await onboardingService.getOnboardingData();
        expect(
            data, isNull); // Should return null when no user is authenticated
      });

      test(
          'should handle checkOnboardingStatusInDB when no user is authenticated',
          () async {
        final status = await onboardingService.checkOnboardingStatusInDB();
        expect(
            status, false); // Should return false when no user is authenticated
      });
    });

    group('Legacy Method Tests', () {
      test('should handle deprecated methods gracefully', () async {
        // These methods are deprecated but should still work for backward compatibility
        await onboardingService.saveSelectedOptimizations(['Test']);
        await onboardingService.saveSelectedCategories(['Test']);
        await onboardingService.setHasAddedCard(true);

        // These should return empty/default values since they're deprecated
        expect(onboardingService.getSelectedOptimizations(), isEmpty);
        expect(onboardingService.getSelectedCategories(), isEmpty);
        expect(onboardingService.hasAddedCard, false);
      });
    });
  });

  group('Integration Tests', () {
    test('complete onboarding flow should work', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = OnboardingService(prefs);

      // Start as new user
      expect(service.isNewUser, true);
      expect(service.hasCompletedOnboarding, false);

      // Complete onboarding
      await service.setOnboardingComplete();
      expect(service.hasCompletedOnboarding, true);
      expect(service.isNewUser, false);

      // Reset onboarding
      await service.resetOnboarding();
      expect(service.hasCompletedOnboarding, false);
    });
  });
}
