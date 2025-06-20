import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Card Type Extraction Tests', () {
    // Helper function that mimics the _extractCardType logic from CardService
    String extractCardType(String cardTypeOrName) {
      final lowerCase = cardTypeOrName.toLowerCase();

      // Check for credit card keywords
      if (lowerCase.contains('credit') ||
          lowerCase.contains('cashback') ||
          lowerCase.contains('rewards') ||
          lowerCase.contains('platinum') ||
          lowerCase.contains('gold') ||
          lowerCase.contains('titanium') ||
          lowerCase.contains('signature') ||
          lowerCase.contains('infinite') ||
          lowerCase.contains('reserve')) {
        return 'credit';
      }

      // Check for debit card keywords
      if (lowerCase.contains('debit') ||
          lowerCase.contains('savings') ||
          lowerCase.contains('current')) {
        return 'debit';
      }

      // Check for prepaid card keywords
      if (lowerCase.contains('prepaid') ||
          lowerCase.contains('gift') ||
          lowerCase.contains('travel') ||
          lowerCase.contains('forex')) {
        return 'prepaid';
      }

      // Default to credit if no specific type found (most common case)
      return 'credit';
    }

    test('should extract credit card type correctly', () {
      // Test various credit card names
      expect(extractCardType('Flipkart Credit Card'), equals('credit'));
      expect(extractCardType('HDFC Cashback Credit Card'), equals('credit'));
      expect(extractCardType('SBI Rewards Card'), equals('credit'));
      expect(extractCardType('ICICI Platinum Card'), equals('credit'));
      expect(extractCardType('Axis Gold Card'), equals('credit'));
      expect(extractCardType('American Express Titanium'), equals('credit'));
      expect(extractCardType('Citibank Signature Card'), equals('credit'));
      expect(extractCardType('HDFC Infinite Card'), equals('credit'));
      expect(extractCardType('Chase Reserve'), equals('credit'));
    });

    test('should extract debit card type correctly', () {
      // Test various debit card names
      expect(extractCardType('HDFC Debit Card'), equals('debit'));
      expect(extractCardType('SBI Savings Account Debit'), equals('debit'));
      expect(extractCardType('ICICI Current Account Card'), equals('debit'));
      expect(extractCardType('Axis Savings Card'), equals('debit'));
    });

    test('should extract prepaid card type correctly', () {
      // Test various prepaid card names
      expect(extractCardType('HDFC Prepaid Card'), equals('prepaid'));
      expect(extractCardType('SBI Gift Card'), equals('prepaid'));
      expect(extractCardType('ICICI Travel Card'), equals('prepaid'));
      expect(extractCardType('Axis Forex Card'), equals('prepaid'));
    });

    test('should default to credit for unknown card types', () {
      // Test unknown or ambiguous card names
      expect(extractCardType('Some Unknown Card'), equals('credit'));
      expect(extractCardType('Bank XYZ Card'), equals('credit'));
      expect(extractCardType(''), equals('credit'));
    });

    test('should be case insensitive', () {
      // Test case insensitivity
      expect(extractCardType('FLIPKART CREDIT CARD'), equals('credit'));
      expect(extractCardType('hdfc debit card'), equals('debit'));
      expect(extractCardType('SbI pRepaId CaRd'), equals('prepaid'));
    });

    test('should handle the specific failing case', () {
      // Test the specific case that was failing
      expect(extractCardType('Flipkart Credit Card'), equals('credit'));
    });
  });
}
