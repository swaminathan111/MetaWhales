import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/logging/app_logger.dart';
import 'card_service.dart';
import 'onboarding_service.dart';

/// Service to gather and format user context for personalized AI responses
class UserContextService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final CardService _cardService = CardService();

  /// Get comprehensive user context for personalized AI responses
  Future<UserContext> getUserContext() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      AppLogger.info(
          'Building user context for personalized AI response', null, null, {
        'userId': user.id,
      });

      // Get user profile and preferences in parallel
      final Future<Map<String, dynamic>?> profileFuture =
          _getUserProfile(user.id);
      final Future<List<Map<String, dynamic>>> cardsFuture =
          _cardService.loadUserCards();
      final Future<Map<String, dynamic>> spendingFuture =
          _getSpendingInsights(user.id);
      final Future<List<Map<String, dynamic>>> transactionsFuture =
          _getRecentTransactions(user.id);

      // Wait for all data to load
      final results = await Future.wait([
        profileFuture,
        cardsFuture,
        spendingFuture,
        transactionsFuture,
      ]);

      final profile = results[0] as Map<String, dynamic>?;
      final cards = results[1] as List<Map<String, dynamic>>;
      final spendingInsights = results[2] as Map<String, dynamic>;
      final recentTransactions = results[3] as List<Map<String, dynamic>>;

      final context = UserContext(
        userId: user.id,
        userProfile: profile,
        ownedCards: cards,
        spendingInsights: spendingInsights,
        recentTransactions: recentTransactions,
        contextGeneratedAt: DateTime.now(),
      );

      AppLogger.info('User context built successfully', null, null, {
        'cardsCount': cards.length,
        'hasProfile': profile != null,
        'recentTransactionsCount': recentTransactions.length,
      });

      return context;
    } catch (error, stackTrace) {
      AppLogger.error('Failed to build user context', error, stackTrace);
      // Return minimal context on error
      return UserContext(
        userId: _supabase.auth.currentUser?.id ?? '',
        userProfile: null,
        ownedCards: [],
        spendingInsights: {},
        recentTransactions: [],
        contextGeneratedAt: DateTime.now(),
      );
    }
  }

  /// Get user profile with preferences
  Future<Map<String, dynamic>?> _getUserProfile(String userId) async {
    try {
      final response = await _supabase.from('user_profiles').select('''
            full_name,
            monthly_spending_range,
            selected_optimizations,
            selected_spending_categories,
            is_open_to_new_card,
            onboarding_additional_info,
            notification_preferences,
            ai_chat_enabled
          ''').eq('id', userId).maybeSingle();

      return response;
    } catch (error) {
      AppLogger.warning('Failed to get user profile for context', null, null, {
        'error': error.toString(),
      });
      return null;
    }
  }

  /// Get user spending insights
  Future<Map<String, dynamic>> _getSpendingInsights(String userId) async {
    try {
      // Get spending summaries for last 3 months
      final summariesResponse = await _supabase
          .from('spending_summaries')
          .select('*')
          .eq('user_id', userId)
          .gte('year', DateTime.now().year)
          .gte('month', DateTime.now().month - 2)
          .order('year', ascending: false)
          .order('month', ascending: false)
          .limit(3);

      // Get top spending categories from last 30 days
      final categoriesResponse =
          await _supabase.rpc('get_top_categories', params: {
        'user_uuid': userId,
        'time_period': '30 days',
        'limit_count': 5,
      });

      return {
        'monthly_summaries': summariesResponse,
        'top_categories': categoriesResponse,
        'analysis_period': '30 days',
      };
    } catch (error) {
      AppLogger.warning('Failed to get spending insights', null, null, {
        'error': error.toString(),
      });
      return {};
    }
  }

  /// Get recent transactions for context
  Future<List<Map<String, dynamic>>> _getRecentTransactions(
      String userId) async {
    try {
      final response = await _supabase
          .from('transactions')
          .select('''
            *,
            spending_categories(name, icon_name),
            user_cards(card_name, card_type)
          ''')
          .eq('user_id', userId)
          .order('transaction_date', ascending: false)
          .limit(10);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      AppLogger.warning('Failed to get recent transactions', null, null, {
        'error': error.toString(),
      });
      return [];
    }
  }

  /// Format user context for RAG API consumption
  Map<String, dynamic> formatContextForRAG(UserContext context) {
    try {
      // Format owned cards for AI consumption
      final formattedCards = context.ownedCards.map((card) {
        return {
          'name': card['card_name'],
          'type': card['card_type'],
          'network': card['card_network'],
          'issuer': card['card_issuers']?['name'],
          'category': card['card_categories']?['name'],
          'credit_limit': card['credit_limit'],
          'annual_fee': card['annual_fee'],
          'benefits': card['benefits'],
          'is_primary': card['is_primary'],
        };
      }).toList();

      // Format spending preferences
      final profile = context.userProfile;
      final spendingCategories =
          profile?['selected_spending_categories'] as List<dynamic>? ?? [];
      final optimizations =
          profile?['selected_optimizations'] as List<dynamic>? ?? [];

      // Format recent spending patterns
      final topCategories =
          context.spendingInsights['top_categories'] as List<dynamic>? ?? [];
      final spendingPatterns = topCategories
          .map((cat) => {
                'category': cat['category_name'],
                'amount': cat['total_amount'],
                'transaction_count': cat['transaction_count'],
                'percentage': cat['percentage_of_total'],
              })
          .toList();

      // Create comprehensive context
      final ragContext = {
        'user_profile': {
          'monthly_spending_range': profile?['monthly_spending_range'],
          'preferred_optimizations': optimizations,
          'preferred_categories': spendingCategories,
          'is_open_to_new_card': profile?['is_open_to_new_card'],
          'additional_info': profile?['onboarding_additional_info'],
        },
        'owned_cards': formattedCards,
        'spending_patterns': spendingPatterns,
        'recent_activity': {
          'has_recent_transactions': context.recentTransactions.isNotEmpty,
          'transaction_count_last_10': context.recentTransactions.length,
        },
        'context_metadata': {
          'generated_at': context.contextGeneratedAt.toIso8601String(),
          'cards_count': formattedCards.length,
          'has_complete_profile': profile != null,
        }
      };

      AppLogger.debug('RAG context formatted successfully', null, null, {
        'cardsCount': formattedCards.length,
        'spendingPatternsCount': spendingPatterns.length,
        'hasProfile': profile != null,
      });

      return ragContext;
    } catch (error, stackTrace) {
      AppLogger.error('Failed to format context for RAG', error, stackTrace);
      return {
        'user_profile': {},
        'owned_cards': [],
        'spending_patterns': [],
        'recent_activity': {},
        'context_metadata': {
          'generated_at': DateTime.now().toIso8601String(),
          'error': 'Failed to format context',
        }
      };
    }
  }

  /// Get quick user summary for chat display
  String getUserSummary(UserContext context) {
    final cardsCount = context.ownedCards.length;
    final profile = context.userProfile;
    final spendingRange = profile?['monthly_spending_range'] ?? 'Unknown';

    if (cardsCount == 0) {
      return 'New user (no cards added yet)';
    }

    final primaryCard = context.ownedCards.firstWhere(
      (card) => card['is_primary'] == true,
      orElse: () => context.ownedCards.first,
    );

    return '$cardsCount card${cardsCount > 1 ? 's' : ''} • Primary: ${primaryCard['card_name']} • Spending: $spendingRange';
  }
}

/// Data class to hold user context information
class UserContext {
  final String userId;
  final Map<String, dynamic>? userProfile;
  final List<Map<String, dynamic>> ownedCards;
  final Map<String, dynamic> spendingInsights;
  final List<Map<String, dynamic>> recentTransactions;
  final DateTime contextGeneratedAt;

  UserContext({
    required this.userId,
    required this.userProfile,
    required this.ownedCards,
    required this.spendingInsights,
    required this.recentTransactions,
    required this.contextGeneratedAt,
  });

  /// Check if user has complete context for personalization
  bool get hasCompleteContext {
    return userProfile != null && ownedCards.isNotEmpty;
  }

  /// Check if user has any cards
  bool get hasCards {
    return ownedCards.isNotEmpty;
  }

  /// Get primary card if available
  Map<String, dynamic>? get primaryCard {
    try {
      return ownedCards.firstWhere(
        (card) => card['is_primary'] == true,
        orElse: () => ownedCards.isNotEmpty ? ownedCards.first : {},
      );
    } catch (e) {
      return null;
    }
  }

  /// Get user's monthly spending range
  String? get monthlySpendingRange {
    return userProfile?['monthly_spending_range'];
  }

  /// Get user's preferred spending categories
  List<String> get preferredCategories {
    final categories =
        userProfile?['selected_spending_categories'] as List<dynamic>?;
    return categories?.cast<String>() ?? [];
  }

  /// Get user's optimization preferences
  List<String> get optimizationPreferences {
    final optimizations =
        userProfile?['selected_optimizations'] as List<dynamic>?;
    return optimizations?.cast<String>() ?? [];
  }
}
