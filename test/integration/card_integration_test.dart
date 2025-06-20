import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test_config.dart';
import '../../lib/features/cards/models/card_info.dart';

void main() {
  group('Card Integration Tests', () {
    setUpAll(() async {
      // Initialize test environment
      await TestConfig.setupTestEnvironment();
    });

    tearDownAll(() async {
      // Clean up test environment
      await TestConfig.tearDownTestEnvironment();
    });

    test('CardInfo model should handle database conversion correctly', () {
      // Test CardInfo.fromDatabase factory
      final mockDatabaseData = TestConfig.getMockCardData();
      final cardInfo = CardInfo.fromDatabase(mockDatabaseData);

      expect(cardInfo.id, equals('test-card-id'));
      expect(cardInfo.bank, equals('Test Bank'));
      expect(cardInfo.cardType, equals('Test Credit Card'));
      expect(cardInfo.lastFourDigits, equals('1234'));
      expect(cardInfo.cardNetwork, equals('visa'));
      expect(cardInfo.creditLimit, equals(50000.0));
      expect(cardInfo.currentBalance, equals(10000.0));
      expect(cardInfo.rewardPoints, equals(1500.0));
      expect(cardInfo.cashbackEarned, equals(250.0));
      expect(cardInfo.status, equals('active'));
      expect(cardInfo.isPrimary, isTrue);
      expect(cardInfo.gradientColors.length, equals(2));
    });

    test('CardInfo should calculate available credit correctly', () {
      final cardInfo = CardInfo(
        id: 'test',
        bank: 'Test Bank',
        cardType: 'Test Card',
        gradientColors: [Colors.blue, Colors.indigo],
        creditLimit: 50000.0,
        currentBalance: 10000.0,
      );

      expect(cardInfo.availableCreditPercentage, equals(80.0));
      expect(cardInfo.isNearLimit, isFalse);

      final nearLimitCard = cardInfo.copyWith(currentBalance: 45000.0);
      expect(nearLimitCard.availableCreditPercentage, equals(10.0));
      expect(nearLimitCard.isNearLimit, isTrue);
    });

    test('CardInfo should format display strings correctly', () {
      final cardInfo = CardInfo(
        id: 'test',
        bank: 'Test Bank',
        cardType: 'Test Card',
        gradientColors: [Colors.blue, Colors.indigo],
        lastFourDigits: '1234',
        currentBalance: 10000.50,
        creditLimit: 50000.0,
      );

      expect(cardInfo.displayName, equals('Test Bank •••• 1234'));
      expect(cardInfo.formattedBalance, equals('₹10000.50'));
      expect(cardInfo.formattedCreditLimit, equals('₹50000'));
    });

    test('CardInfo should convert to database format correctly', () {
      final cardInfo = CardInfo(
        id: 'test',
        bank: 'Test Bank',
        cardType: 'Test Credit Card',
        gradientColors: [Colors.blue, Colors.indigo],
        lastFourDigits: '1234',
        cardNetwork: 'visa',
        creditLimit: 50000.0,
        currentBalance: 10000.0,
        rewardPoints: 1500.0,
        cashbackEarned: 250.0,
        isPrimary: true,
      );

      final databaseData = cardInfo.toDatabase();

      expect(databaseData['card_name'], equals('Test Credit Card'));
      expect(databaseData['card_type'], equals('credit'));
      expect(databaseData['last_four_digits'], equals('1234'));
      expect(databaseData['card_network'], equals('visa'));
      expect(databaseData['credit_limit'], equals(50000.0));
      expect(databaseData['current_balance'], equals(10000.0));
      expect(databaseData['reward_points'], equals(1500.0));
      expect(databaseData['cashback_earned'], equals(250.0));
      expect(databaseData['is_primary'], isTrue);
      expect(databaseData['status'], equals('active'));
    });

    test('CardInfo should handle gradient colors based on card network', () {
      // Test Visa colors
      final visaCard = CardInfo(
        id: 'visa-test',
        bank: 'Test Bank',
        cardType: 'Visa Card',
        gradientColors: [Colors.blue, Colors.indigo],
        cardNetwork: 'visa',
      );
      expect(visaCard.gradientColors.length, equals(2));

      // Test Mastercard colors
      final mastercardCard = CardInfo(
        id: 'mastercard-test',
        bank: 'Test Bank',
        cardType: 'Mastercard',
        gradientColors: [Colors.red, Colors.orange],
        cardNetwork: 'mastercard',
      );
      expect(mastercardCard.gradientColors.length, equals(2));

      // Test RuPay colors
      final rupayCard = CardInfo(
        id: 'rupay-test',
        bank: 'Test Bank',
        cardType: 'RuPay Card',
        gradientColors: [Colors.green, Colors.teal],
        cardNetwork: 'rupay',
      );
      expect(rupayCard.gradientColors.length, equals(2));
    });

    test('CardInfo should handle edge cases correctly', () {
      // Test zero balance
      final zeroBalanceCard = CardInfo(
        id: 'zero-balance',
        bank: 'Test Bank',
        cardType: 'Zero Balance Card',
        gradientColors: [Colors.blue, Colors.indigo],
        creditLimit: 50000.0,
        currentBalance: 0.0,
      );

      expect(zeroBalanceCard.availableCreditPercentage, equals(100.0));
      expect(zeroBalanceCard.isNearLimit, isFalse);

      // Test full limit usage
      final fullLimitCard = CardInfo(
        id: 'full-limit',
        bank: 'Test Bank',
        cardType: 'Full Limit Card',
        gradientColors: [Colors.red, Colors.deepOrange],
        creditLimit: 50000.0,
        currentBalance: 50000.0,
      );

      expect(fullLimitCard.availableCreditPercentage, equals(0.0));
      expect(fullLimitCard.isNearLimit, isTrue);

      // Test card without credit limit (debit card)
      final debitCard = CardInfo(
        id: 'debit-card',
        bank: 'Test Bank',
        cardType: 'Debit Card',
        gradientColors: [Colors.purple, Colors.deepPurple],
        creditLimit: null,
        currentBalance: null,
      );

      expect(debitCard.availableCreditPercentage, equals(0.0));
      expect(debitCard.isNearLimit,
          isTrue); // 0% available is considered near limit
    });

    test('Mock data should be properly structured', () {
      final mockData = TestConfig.getMockCardData();
      final mockUserData = TestConfig.getMockUserData();
      final mockTransactions = TestConfig.getMockTransactionData();
      final mockResponses = TestConfig.getMockSupabaseResponses();

      // Verify mock card data structure
      expect(mockData['id'], isNotNull);
      expect(mockData['card_name'], isNotNull);
      expect(mockData['card_type'], isNotNull);
      expect(mockData['card_issuers'], isNotNull);
      expect(mockData['card_categories'], isNotNull);

      // Verify mock user data structure
      expect(mockUserData['id'], isNotNull);
      expect(mockUserData['email'], isNotNull);
      expect(mockUserData['full_name'], isNotNull);

      // Verify mock transaction data structure
      expect(mockTransactions, isNotEmpty);
      expect(mockTransactions.first['id'], isNotNull);
      expect(mockTransactions.first['amount'], isNotNull);

      // Verify mock responses structure
      expect(mockResponses['user_cards'], isNotNull);
      expect(mockResponses['user_profiles'], isNotNull);
      expect(mockResponses['transactions'], isNotNull);
    });

    test('Test utilities should work correctly', () {
      // Test safe text finder
      final finder = TestUtils.findTextSafe('Test Text');
      expect(finder, isNotNull);

      // Test wait for condition
      bool testCondition = false;
      Timer(const Duration(milliseconds: 500), () {
        testCondition = true;
      });

      expect(
        TestUtils.waitForCondition(
          () => testCondition,
          timeout: const Duration(seconds: 1),
        ),
        completion(isTrue),
      );
    });

    test('Test matchers should work correctly', () {
      final mockCard1 = TestConfig.getMockCardData();
      final mockCard2 = TestConfig.getMockCardData();

      // Test card data matching
      expect(TestMatchers.cardDataMatches(mockCard1, mockCard2), isTrue);

      // Test modified card data
      final modifiedCard = Map<String, dynamic>.from(mockCard2);
      modifiedCard['card_name'] = 'Different Card';
      expect(TestMatchers.cardDataMatches(mockCard1, modifiedCard), isFalse);
    });
  });
}
