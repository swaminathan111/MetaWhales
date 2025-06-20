import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/logging/app_logger.dart';
import '../features/cards/models/card_info.dart';

class CardService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Save a new card to the database
  Future<bool> saveCard({
    required String cardName,
    required String bankName,
    required String cardType,
    String? lastFourDigits,
    String? cardNetwork,
    double? creditLimit,
    double? annualFee,
    Map<String, dynamic>? benefits,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        AppLogger.error('No authenticated user found for saving card');
        return false;
      }

      AppLogger.info('Saving card to database', null, null, {
        'userId': user.id,
        'cardName': cardName,
        'bankName': bankName,
        'cardType': cardType,
      });

      // First, get or create the card issuer
      String? issuerId = await _getOrCreateIssuer(bankName);
      if (issuerId == null) {
        AppLogger.error('Failed to get or create card issuer');
        return false;
      }

      // Get default category (we can enhance this later)
      String? categoryId = await _getDefaultCategory();

      // Convert card type to lowercase for database
      String actualCardType = cardType.toLowerCase();

      AppLogger.debug('Processing card type for database', null, null, {
        'originalCardType': cardType,
        'processedCardType': actualCardType,
      });

      // Insert the card
      final response = await _supabase.from('user_cards').insert({
        'user_id': user.id,
        'issuer_id': issuerId,
        'category_id': categoryId,
        'card_name': cardName,
        'card_type': actualCardType,
        'last_four_digits': lastFourDigits,
        'card_network': cardNetwork?.toLowerCase(),
        'credit_limit': creditLimit,
        'annual_fee': annualFee,
        'benefits': benefits ?? {},
        'status': 'active',
        'is_primary': false, // User can set primary later
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).select();

      if (response.isNotEmpty) {
        AppLogger.info('Card saved successfully', null, null, {
          'cardId': response.first['id'],
          'cardName': cardName,
        });
        return true;
      } else {
        AppLogger.error('No response received when saving card');
        return false;
      }
    } catch (error, stackTrace) {
      AppLogger.error('Failed to save card', error, stackTrace, {
        'cardName': cardName,
        'bankName': bankName,
        'cardType': cardType,
        'errorDetails': error.toString(),
      });
      return false;
    }
  }

  /// Load all cards for the current user
  Future<List<Map<String, dynamic>>> loadUserCards() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        AppLogger.warning('No authenticated user found for loading cards');
        return [];
      }

      AppLogger.debug('Loading user cards from database', null, null, {
        'userId': user.id,
      });

      final response = await _supabase
          .from('user_cards')
          .select('''
            *,
            card_issuers(name, logo_url),
            card_categories(name, description, icon_name, color_code)
          ''')
          .eq('user_id', user.id)
          .eq('status', 'active')
          .order('created_at', ascending: true);

      AppLogger.info('Loaded user cards successfully', null, null, {
        'cardCount': response.length,
      });

      return List<Map<String, dynamic>>.from(response);
    } catch (error, stackTrace) {
      AppLogger.error('Failed to load user cards', error, stackTrace);
      return [];
    }
  }

  /// Update an existing card
  Future<bool> updateCard({
    required String cardId,
    String? cardName,
    double? creditLimit,
    double? currentBalance,
    double? availableCredit,
    String? status,
    bool? isPrimary,
    Map<String, dynamic>? benefits,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        AppLogger.error('No authenticated user found for updating card');
        return false;
      }

      AppLogger.info('Updating card in database', null, null, {
        'userId': user.id,
        'cardId': cardId,
      });

      Map<String, dynamic> updateData = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (cardName != null) updateData['card_name'] = cardName;
      if (creditLimit != null) updateData['credit_limit'] = creditLimit;
      if (currentBalance != null)
        updateData['current_balance'] = currentBalance;
      if (availableCredit != null)
        updateData['available_credit'] = availableCredit;
      if (status != null) updateData['status'] = status;
      if (isPrimary != null) updateData['is_primary'] = isPrimary;
      if (benefits != null) updateData['benefits'] = benefits;

      final response = await _supabase
          .from('user_cards')
          .update(updateData)
          .eq('id', cardId)
          .eq('user_id', user.id)
          .select();

      if (response.isNotEmpty) {
        AppLogger.info('Card updated successfully', null, null, {
          'cardId': cardId,
        });
        return true;
      } else {
        AppLogger.error('No card found to update or no changes made');
        return false;
      }
    } catch (error, stackTrace) {
      AppLogger.error('Failed to update card', error, stackTrace);
      return false;
    }
  }

  /// Delete a card (soft delete by setting status to inactive)
  Future<bool> deleteCard(String cardId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        AppLogger.error('No authenticated user found for deleting card');
        return false;
      }

      AppLogger.info('Deleting card from database', null, null, {
        'userId': user.id,
        'cardId': cardId,
      });

      final response = await _supabase
          .from('user_cards')
          .update({
            'status': 'inactive',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', cardId)
          .eq('user_id', user.id)
          .select();

      if (response.isNotEmpty) {
        AppLogger.info('Card deleted successfully', null, null, {
          'cardId': cardId,
        });
        return true;
      } else {
        AppLogger.error('No card found to delete');
        return false;
      }
    } catch (error, stackTrace) {
      AppLogger.error('Failed to delete card', error, stackTrace);
      return false;
    }
  }

  /// Set a card as primary (and unset others)
  Future<bool> setPrimaryCard(String cardId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        AppLogger.error('No authenticated user found for setting primary card');
        return false;
      }

      AppLogger.info('Setting primary card', null, null, {
        'userId': user.id,
        'cardId': cardId,
      });

      // First, unset all other cards as primary
      await _supabase
          .from('user_cards')
          .update({
            'is_primary': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', user.id)
          .neq('id', cardId);

      // Then set the selected card as primary
      final response = await _supabase
          .from('user_cards')
          .update({
            'is_primary': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', cardId)
          .eq('user_id', user.id)
          .select();

      if (response.isNotEmpty) {
        AppLogger.info('Primary card set successfully', null, null, {
          'cardId': cardId,
        });
        return true;
      } else {
        AppLogger.error('Failed to set primary card');
        return false;
      }
    } catch (error, stackTrace) {
      AppLogger.error('Failed to set primary card', error, stackTrace);
      return false;
    }
  }

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  /// Get or create a card issuer (bank)
  Future<String?> _getOrCreateIssuer(String bankName) async {
    try {
      // First, try to find existing issuer
      final existingResponse = await _supabase
          .from('card_issuers')
          .select('id')
          .eq('name', bankName)
          .eq('is_active', true)
          .maybeSingle();

      if (existingResponse != null) {
        return existingResponse['id'] as String;
      }

      // If not found, create new issuer
      final newResponse = await _supabase
          .from('card_issuers')
          .insert({
            'name': bankName,
            'country': 'India',
            'is_active': true,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select('id')
          .single();

      AppLogger.info('Created new card issuer', null, null, {
        'bankName': bankName,
        'issuerId': newResponse['id'],
      });

      return newResponse['id'] as String;
    } catch (error, stackTrace) {
      AppLogger.error('Failed to get or create issuer', error, stackTrace, {
        'bankName': bankName,
      });
      return null;
    }
  }

  /// Get default category for cards
  Future<String?> _getDefaultCategory() async {
    try {
      final response = await _supabase
          .from('card_categories')
          .select('id')
          .eq('is_active', true)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        return response['id'] as String;
      }

      // If no categories exist, create a default one
      final newResponse = await _supabase
          .from('card_categories')
          .insert({
            'name': 'General',
            'description': 'General purpose credit cards',
            'icon_name': 'credit_card',
            'color_code': '#4285F4',
            'is_active': true,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select('id')
          .single();

      AppLogger.info('Created default card category', null, null, {
        'categoryId': newResponse['id'],
      });

      return newResponse['id'] as String;
    } catch (error, stackTrace) {
      AppLogger.error('Failed to get default category', error, stackTrace);
      return null;
    }
  }

  /// Get card statistics for analytics
  Future<Map<String, dynamic>> getCardStatistics() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return {
          'totalCards': 0,
          'activeCards': 0,
          'totalCreditLimit': 0.0,
          'totalBalance': 0.0,
          'totalRewardPoints': 0.0,
          'totalCashback': 0.0,
        };
      }

      final response = await _supabase
          .from('user_cards')
          .select(
              'credit_limit, current_balance, reward_points, cashback_earned, status')
          .eq('user_id', user.id);

      int totalCards = response.length;
      int activeCards =
          response.where((card) => card['status'] == 'active').length;
      double totalCreditLimit = 0.0;
      double totalBalance = 0.0;
      double totalRewardPoints = 0.0;
      double totalCashback = 0.0;

      for (final card in response) {
        if (card['status'] == 'active') {
          totalCreditLimit += (card['credit_limit'] as num?)?.toDouble() ?? 0.0;
          totalBalance += (card['current_balance'] as num?)?.toDouble() ?? 0.0;
          totalRewardPoints +=
              (card['reward_points'] as num?)?.toDouble() ?? 0.0;
          totalCashback += (card['cashback_earned'] as num?)?.toDouble() ?? 0.0;
        }
      }

      return {
        'totalCards': totalCards,
        'activeCards': activeCards,
        'totalCreditLimit': totalCreditLimit,
        'totalBalance': totalBalance,
        'totalRewardPoints': totalRewardPoints,
        'totalCashback': totalCashback,
      };
    } catch (error, stackTrace) {
      AppLogger.error('Failed to get card statistics', error, stackTrace);
      return {
        'totalCards': 0,
        'activeCards': 0,
        'totalCreditLimit': 0.0,
        'totalBalance': 0.0,
        'totalRewardPoints': 0.0,
        'totalCashback': 0.0,
      };
    }
  }
}
