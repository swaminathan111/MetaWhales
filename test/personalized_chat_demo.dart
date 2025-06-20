import 'dart:convert';
import 'package:flutter/material.dart';
import '../lib/services/user_context_service.dart';
import '../lib/features/chat/services/rag_chat_service.dart';
import '../lib/features/chat/services/openrouter_service.dart';

/// Demo file showing how the new personalized chat system works
///
/// This demonstrates:
/// 1. User context retrieval (cards, preferences, spending patterns)
/// 2. RAG API integration with user context
/// 3. Personalized vs generic responses
/// 4. Fallback mechanisms

void main() async {
  print('🎯 CardSense AI Personalization Demo\n');

  final demo = PersonalizedChatDemo();
  await demo.runDemo();
}

class PersonalizedChatDemo {
  final UserContextService _contextService = UserContextService();
  final RagChatService _ragService = RagChatService();

  Future<void> runDemo() async {
    try {
      print('1. 📊 Retrieving User Context...');
      await _demoUserContextRetrieval();

      print('\n2. 🤖 Testing Personalized RAG Responses...');
      await _demoPersonalizedResponses();

      print('\n3. 🔄 Testing Fallback Mechanisms...');
      await _demoFallbackMechanisms();

      print('\n4. 📈 Testing Different User Scenarios...');
      await _demoUserScenarios();

      print('\n✅ Demo Complete!');
    } catch (e) {
      print('❌ Demo failed: $e');
    }
  }

  /// Demo 1: Show how user context is retrieved and formatted
  Future<void> _demoUserContextRetrieval() async {
    print('  📋 Getting user context...');

    try {
      final userContext = await _contextService.getUserContext();

      print('  ✅ User Context Retrieved:');
      print('     - User ID: ${userContext.userId}');
      print('     - Has Cards: ${userContext.hasCards}');
      print('     - Complete Context: ${userContext.hasCompleteContext}');
      print('     - Cards Count: ${userContext.ownedCards.length}');
      print(
          '     - Spending Range: ${userContext.monthlySpendingRange ?? 'Not set'}');
      print(
          '     - Preferred Categories: ${userContext.preferredCategories.join(', ')}');

      if (userContext.hasCards) {
        print('  💳 User Cards:');
        for (final card in userContext.ownedCards) {
          print('     - ${card['card_name']} (${card['card_type']})');
        }
      }

      // Show formatted RAG context
      final ragContext = _contextService.formatContextForRAG(userContext);
      print(
          '  📤 RAG-Formatted Context Size: ${json.encode(ragContext).length} chars');

      // Show user summary
      final summary = _contextService.getUserSummary(userContext);
      print('  📝 User Summary: $summary');
    } catch (e) {
      print('  ❌ Failed to retrieve user context: $e');
    }
  }

  /// Demo 2: Show personalized vs generic responses
  Future<void> _demoPersonalizedResponses() async {
    final testQuestions = [
      'Which card should I use for grocery shopping?',
      'What are the best cashback cards for my spending?',
      'Should I get a new credit card?',
      'How can I optimize my credit card rewards?',
    ];

    for (final question in testQuestions) {
      print('\n  🔍 Question: "$question"');

      try {
        final response = await _ragService.sendMessage(
          message: question,
          conversationHistory: [],
        );

        print('  🎯 Personalized Response:');
        print('     ${_truncateResponse(response)}');
      } catch (e) {
        print('  ❌ Failed to get personalized response: $e');
      }
    }
  }

  /// Demo 3: Test fallback mechanisms
  Future<void> _demoFallbackMechanisms() async {
    print('  🔄 Testing Enhanced Chat Service Fallback...');

    try {
      final enhancedService = EnhancedChatService(
        _ragService,
        OpenRouterService(),
      );

      // Test service availability
      final availability = await enhancedService.checkServiceAvailability();
      print('  📊 Service Availability:');
      print('     - RAG API: ${(availability['rag'] ?? false) ? '✅' : '❌'}');
      print(
          '     - OpenRouter: ${(availability['openrouter'] ?? false) ? '✅' : '❌'}');

      // Test actual fallback
      final response = await enhancedService.sendMessage(
        message: 'Test fallback mechanism',
        conversationHistory: [],
      );

      print('  💬 Fallback Response: ${_truncateResponse(response)}');
    } catch (e) {
      print('  ❌ Fallback test failed: $e');
    }
  }

  /// Demo 4: Test different user scenarios
  Future<void> _demoUserScenarios() async {
    final scenarios = [
      {
        'name': 'New User (No Cards)',
        'description': 'User with no cards should get generic recommendations',
      },
      {
        'name': 'Single Card User',
        'description': 'User with one card should get optimization tips',
      },
      {
        'name': 'Multi-Card Power User',
        'description':
            'User with multiple cards should get advanced strategies',
      },
    ];

    for (final scenario in scenarios) {
      print('\n  🎭 Scenario: ${scenario['name']}');
      print('     ${scenario['description']}');

      try {
        // Simulate context for this scenario
        await _simulateUserScenario(scenario['name']!);
      } catch (e) {
        print('     ❌ Scenario simulation failed: $e');
      }
    }
  }

  /// Simulate different user scenarios
  Future<void> _simulateUserScenario(String scenarioName) async {
    switch (scenarioName) {
      case 'New User (No Cards)':
        print('     📝 This would show generic card recommendations');
        print('     💡 AI should suggest starter cards based on preferences');
        break;

      case 'Single Card User':
        print('     📝 This would show how to maximize existing card benefits');
        print('     💡 AI should suggest complementary cards if user is open');
        break;

      case 'Multi-Card Power User':
        print('     📝 This would show advanced optimization strategies');
        print(
            '     💡 AI should provide card stacking and category rotation tips');
        break;
    }
  }

  /// Helper to truncate long responses for demo
  String _truncateResponse(String response) {
    if (response.length <= 150) return response;
    return '${response.substring(0, 147)}...';
  }
}

/// Example RAG API Request Structure (for documentation)
class ExampleRAGRequest {
  static Map<String, dynamic> newApiFormat({
    required String question,
    required Map<String, dynamic> userContext,
  }) {
    return {
      'question': question,
      'user_context': userContext,
    };
  }

  static Map<String, dynamic> oldApiFormat({
    required List<Map<String, dynamic>> messages,
    required Map<String, dynamic> userContext,
  }) {
    return {
      'messages': messages,
      'user_context': userContext,
      'stream': false,
    };
  }

  /// Example user context structure
  static Map<String, dynamic> exampleUserContext() {
    return {
      'user_profile': {
        'monthly_spending_range': '₹30-75k',
        'preferred_optimizations': ['cashback', 'rewards', 'travel'],
        'preferred_categories': ['Groceries', 'Dining', 'Travel'],
        'is_open_to_new_card': true,
        'additional_info': 'Prefers no annual fee cards',
      },
      'owned_cards': [
        {
          'name': 'HDFC Regalia',
          'type': 'credit',
          'network': 'visa',
          'issuer': 'HDFC Bank',
          'category': 'Premium',
          'credit_limit': 200000.0,
          'annual_fee': 2500.0,
          'benefits': {
            'lounge_access': true,
            'reward_rate': '2%',
            'welcome_bonus': true,
          },
          'is_primary': true,
        },
        {
          'name': 'SBI SimplyCLICK',
          'type': 'credit',
          'network': 'visa',
          'issuer': 'State Bank of India',
          'category': 'Cashback',
          'credit_limit': 100000.0,
          'annual_fee': 499.0,
          'benefits': {
            'online_cashback': '5%',
            'offline_cashback': '1%',
          },
          'is_primary': false,
        },
      ],
      'spending_patterns': [
        {
          'category': 'Groceries',
          'amount': 15000.0,
          'transaction_count': 25,
          'percentage': 30.0,
        },
        {
          'category': 'Dining',
          'amount': 8000.0,
          'transaction_count': 15,
          'percentage': 16.0,
        },
      ],
      'recent_activity': {
        'has_recent_transactions': true,
        'transaction_count_last_10': 8,
      },
      'context_metadata': {
        'generated_at': DateTime.now().toIso8601String(),
        'cards_count': 2,
        'has_complete_profile': true,
      }
    };
  }
}

/// Expected Response Examples
class ExamplePersonalizedResponses {
  /// Response for user with HDFC Regalia asking about groceries
  static String groceryCardRecommendation() {
    return '''
Based on your HDFC Regalia card, I recommend using it for grocery shopping to earn 2 reward points per ₹150 spent. 

Since you spend ₹15,000 monthly on groceries (30% of your spending), you could earn approximately 200 reward points monthly from groceries alone.

However, considering your preference for cashback optimization, your SBI SimplyCLICK card might be better for online grocery platforms, offering 5% cashback up to ₹1,000 per month.

Strategy: Use SimplyCLICK for online groceries (BigBasket, Grofers) and Regalia for offline grocery stores.
''';
  }

  /// Response for new user asking about best cards
  static String newUserRecommendation() {
    return '''
Since you haven't added any cards yet, let me recommend some starter cards based on your ₹30-75k monthly spending range:

1. **HDFC MoneyBack** - Great for beginners, no annual fee, good cashback rates
2. **SBI SimplyCLICK** - Excellent for online spending with 5% cashback
3. **ICICI Amazon Pay** - Perfect if you shop on Amazon frequently

Based on your preference for Groceries, Dining, and Travel categories, I'd suggest starting with HDFC MoneyBack as your primary card, then adding SBI SimplyCLICK for online optimization.

Would you like me to help you compare the exact benefits of these cards?
''';
  }
}
