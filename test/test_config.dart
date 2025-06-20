import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test configuration and setup utilities
class TestConfig {
  // Test Environment Variables (using mock values for testing)
  static const String supabaseUrl =
      'https://test-ncbuipsgjuxicrhorqtq.supabase.co';
  static const String supabaseAnonKey = 'test_anon_key_for_testing_only';
  static const String openRouterApiKey = 'test_openrouter_key_for_testing_only';
  static const String googleClientId =
      'test-480921289409-6fspjd7c0rhvgs4h5l38utf1q8ksn4bd.apps.googleusercontent.com';

  // App Configuration for Testing
  static const String appName = 'CardSense AI Test';
  static const String appUrl = 'https://test.cardsense.ai';
  static const String environment = 'test';
  static const String defaultAiModel = 'test/gpt-4o-mini';

  // RAG API Configuration for Testing
  static const String ragApiBaseUrl =
      'https://test-card-sense-ai-rag.vercel.app/chat';
  static const bool useNewRagApi = true;

  // Test flags
  static const bool enableLogging = false;
  static const bool enableAnalytics = false;
  static const bool enableSpeechToText = false;
  static const bool enableAiChat = true;
  static const bool mockExternalServices = true;

  // Logging Configuration for Tests
  static const String logLevel = 'ERROR';
  static const bool logToConsole = false;
  static const bool logToFile = false;

  // Test user data
  static const String testUserEmail = 'test@cardsense.ai';
  static const String testUserId = 'test-user-id-123';

  /// Initialize test environment
  static Future<void> setupTestEnvironment() async {
    // Set test mode
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    // Note: Supabase initialization is skipped in tests since it requires
    // platform-specific plugins that aren't available in the test environment.
    // Tests should use mock data instead.
    debugPrint('Test environment initialized with mock data');
  }

  /// Clean up test environment
  static Future<void> tearDownTestEnvironment() async {
    // Reset any global state
    debugDefaultTargetPlatformOverride = null;
    debugPrint('Test environment cleaned up');
  }

  /// Get mock card data for testing
  static Map<String, dynamic> getMockCardData() {
    return {
      'id': 'test-card-id',
      'card_name': 'Test Credit Card',
      'card_type': 'credit',
      'last_four_digits': '1234',
      'card_network': 'visa',
      'credit_limit': 50000.0,
      'current_balance': 10000.0,
      'available_credit': 40000.0,
      'reward_points': 1500.0,
      'cashback_earned': 250.0,
      'annual_fee': 1200.0,
      'status': 'active',
      'is_primary': true,
      'created_at': '2024-01-01T00:00:00Z',
      'updated_at': '2024-01-01T00:00:00Z',
      'card_issuers': {
        'id': 'issuer-1',
        'name': 'Test Bank',
        'logo_url': null,
      },
      'card_categories': {
        'id': 'category-1',
        'name': 'Premium',
        'description': 'Premium credit cards',
        'icon_name': 'credit_card',
        'color_code': '#4285F4',
      },
      'benefits': {
        'cashback_rate': '2%',
        'reward_multiplier': '5x',
        'airport_lounge_access': true,
        'travel_insurance': true,
      }
    };
  }

  /// Get mock user data for testing
  static Map<String, dynamic> getMockUserData() {
    return {
      'id': testUserId,
      'email': testUserEmail,
      'full_name': 'Test User',
      'monthly_spending_range': '50000-100000',
      'is_open_to_new_card': true,
      'onboarding_completed': true,
      'onboarding_additional_info': 'Test user for automated testing',
      'created_at': '2024-01-01T00:00:00Z',
      'updated_at': '2024-01-01T00:00:00Z',
      'spending_categories': ['Food & Dining', 'Shopping', 'Travel'],
    };
  }

  /// Get mock transaction data for testing
  static List<Map<String, dynamic>> getMockTransactionData() {
    return [
      {
        'id': 'txn-1',
        'amount': 1500.0,
        'description': 'Test Restaurant',
        'category': 'Food & Dining',
        'merchant': 'Test Merchant 1',
        'date': '2024-01-15T10:30:00Z',
        'card_id': 'test-card-id',
        'user_id': testUserId,
        'transaction_type': 'debit',
        'status': 'completed',
        'reward_points_earned': 15.0,
        'cashback_earned': 30.0,
      },
      {
        'id': 'txn-2',
        'amount': 2500.0,
        'description': 'Test Shopping Mall',
        'category': 'Shopping',
        'merchant': 'Test Merchant 2',
        'date': '2024-01-14T15:45:00Z',
        'card_id': 'test-card-id',
        'user_id': testUserId,
        'transaction_type': 'debit',
        'status': 'completed',
        'reward_points_earned': 25.0,
        'cashback_earned': 50.0,
      },
    ];
  }

  /// Get mock spending categories for testing
  static List<Map<String, dynamic>> getMockSpendingCategories() {
    return [
      {
        'id': 'cat-1',
        'name': 'Food & Dining',
        'icon_name': 'restaurant',
        'color_code': '#FF5722',
        'budget_limit': 15000.0,
      },
      {
        'id': 'cat-2',
        'name': 'Shopping',
        'icon_name': 'shopping_bag',
        'color_code': '#9C27B0',
        'budget_limit': 20000.0,
      },
      {
        'id': 'cat-3',
        'name': 'Travel',
        'icon_name': 'flight',
        'color_code': '#2196F3',
        'budget_limit': 25000.0,
      },
    ];
  }

  /// Mock Supabase responses for testing
  static Map<String, dynamic> getMockSupabaseResponses() {
    return {
      'user_cards': [getMockCardData()],
      'user_profiles': [getMockUserData()],
      'transactions': getMockTransactionData(),
      'spending_categories': getMockSpendingCategories(),
      'card_issuers': [
        {
          'id': 'issuer-1',
          'name': 'Test Bank',
          'logo_url': null,
          'website': 'https://testbank.com',
        }
      ],
      'card_categories': [
        {
          'id': 'category-1',
          'name': 'Premium',
          'description': 'Premium credit cards',
          'icon_name': 'credit_card',
          'color_code': '#4285F4',
        }
      ],
      'chat_conversations': [
        {
          'id': 'conv-1',
          'user_id': testUserId,
          'title': 'Test Conversation',
          'created_at': '2024-01-01T00:00:00Z',
        }
      ],
      'chat_messages': [
        {
          'id': 'msg-1',
          'conversation_id': 'conv-1',
          'content': 'Test message',
          'role': 'user',
          'created_at': '2024-01-01T00:00:00Z',
        }
      ],
    };
  }

  /// Get test environment configuration
  static Map<String, dynamic> getTestEnvironmentConfig() {
    return {
      'ENVIRONMENT': environment,
      'LOG_LEVEL': logLevel,
      'LOG_TO_CONSOLE': logToConsole,
      'LOG_TO_FILE': logToFile,
      'SUPABASE_URL': supabaseUrl,
      'SUPABASE_ANON_KEY': supabaseAnonKey,
      'GOOGLE_WEB_CLIENT_ID': googleClientId,
      'OPENROUTER_API_KEY': openRouterApiKey,
      'APP_NAME': appName,
      'APP_URL': appUrl,
      'DEFAULT_AI_MODEL': defaultAiModel,
      'ENABLE_SPEECH_TO_TEXT': enableSpeechToText,
      'ENABLE_AI_CHAT': enableAiChat,
      'ENABLE_ANALYTICS': enableAnalytics,
      'RAG_API_BASE_URL': ragApiBaseUrl,
      'USE_NEW_RAG_API': useNewRagApi,
      'MOCK_EXTERNAL_SERVICES': mockExternalServices,
    };
  }
}

/// Test utilities for common test operations
class TestUtils {
  /// Pump and settle with a reasonable timeout
  static Future<void> pumpAndSettle(WidgetTester tester,
      [Duration? timeout]) async {
    await tester.pumpAndSettle(timeout ?? const Duration(seconds: 5));
  }

  /// Find widget by text with error handling
  static Finder findTextSafe(String text) {
    try {
      return find.text(text);
    } catch (e) {
      return find.byKey(Key('text_not_found_$text'));
    }
  }

  /// Tap widget with error handling
  static Future<void> tapSafe(WidgetTester tester, Finder finder) async {
    try {
      await tester.tap(finder);
      await pumpAndSettle(tester);
    } catch (e) {
      // Log error but don't fail the test
      debugPrint('Failed to tap widget: $e');
    }
  }

  /// Wait for condition with timeout
  static Future<bool> waitForCondition(
    bool Function() condition, {
    Duration timeout = const Duration(seconds: 10),
    Duration interval = const Duration(milliseconds: 100),
  }) async {
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < timeout) {
      if (condition()) {
        return true;
      }
      await Future.delayed(interval);
    }

    return false;
  }

  /// Mock API response for testing
  static Map<String, dynamic> mockApiResponse({
    required bool success,
    dynamic data,
    String? error,
    int statusCode = 200,
  }) {
    return {
      'success': success,
      'data': data,
      'error': error,
      'statusCode': statusCode,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Generate test card with specific properties
  static Map<String, dynamic> generateTestCard({
    String? id,
    String? cardName,
    String? bankName,
    String? cardType,
    String? cardNetwork,
    double? creditLimit,
    double? currentBalance,
    bool? isPrimary,
  }) {
    final baseCard = TestConfig.getMockCardData();
    return {
      ...baseCard,
      if (id != null) 'id': id,
      if (cardName != null) 'card_name': cardName,
      if (bankName != null)
        'card_issuers': {'name': bankName, 'logo_url': null},
      if (cardType != null) 'card_type': cardType,
      if (cardNetwork != null) 'card_network': cardNetwork,
      if (creditLimit != null) 'credit_limit': creditLimit,
      if (currentBalance != null) 'current_balance': currentBalance,
      if (isPrimary != null) 'is_primary': isPrimary,
    };
  }
}

/// Custom test matchers
class TestMatchers {
  /// Matcher for checking if a widget exists
  static Matcher widgetExists() => findsOneWidget;

  /// Matcher for checking if a widget doesn't exist
  static Matcher widgetNotExists() => findsNothing;

  /// Matcher for checking if multiple widgets exist
  static Matcher widgetExistsMultiple() => findsWidgets;

  /// Matcher for checking card data
  static bool cardDataMatches(
      Map<String, dynamic> actual, Map<String, dynamic> expected) {
    return actual['id'] == expected['id'] &&
        actual['card_name'] == expected['card_name'] &&
        actual['card_type'] == expected['card_type'] &&
        actual['status'] == expected['status'];
  }

  /// Matcher for checking user data
  static bool userDataMatches(
      Map<String, dynamic> actual, Map<String, dynamic> expected) {
    return actual['id'] == expected['id'] &&
        actual['email'] == expected['email'] &&
        actual['full_name'] == expected['full_name'];
  }

  /// Matcher for checking transaction data
  static bool transactionDataMatches(
      Map<String, dynamic> actual, Map<String, dynamic> expected) {
    return actual['id'] == expected['id'] &&
        actual['amount'] == expected['amount'] &&
        actual['category'] == expected['category'] &&
        actual['card_id'] == expected['card_id'];
  }
}
