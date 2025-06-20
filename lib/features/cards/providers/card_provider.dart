import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/card_info.dart';
import '../../../services/card_service.dart';
import '../../../core/logging/app_logger.dart';

final cardServiceProvider = Provider<CardService>((ref) => CardService());

final cardsProvider =
    StateNotifierProvider<CardsNotifier, List<CardInfo>>((ref) {
  return CardsNotifier(ref.read(cardServiceProvider));
});

class CardsNotifier extends StateNotifier<List<CardInfo>> {
  final CardService _cardService;
  bool _isLoading = false;

  CardsNotifier(this._cardService) : super([]) {
    loadCards();
  }

  bool get isLoading => _isLoading;

  /// Load cards from database
  Future<void> loadCards() async {
    if (_isLoading) return;

    _isLoading = true;
    try {
      AppLogger.info('Loading cards from database');

      final cardData = await _cardService.loadUserCards();
      final cards =
          cardData.map((data) => CardInfo.fromDatabase(data)).toList();

      state = cards;

      AppLogger.info('Cards loaded successfully', null, null, {
        'cardCount': cards.length,
      });
    } catch (error, stackTrace) {
      AppLogger.error('Failed to load cards', error, stackTrace);
    } finally {
      _isLoading = false;
    }
  }

  /// Add a new card (save to database and update local state)
  Future<bool> addCard({
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
      AppLogger.info('Adding new card', null, null, {
        'cardName': cardName,
        'bankName': bankName,
        'cardType': cardType,
      });

      // Save to database first
      final success = await _cardService.saveCard(
        cardName: cardName,
        bankName: bankName,
        cardType: cardType,
        lastFourDigits: lastFourDigits,
        cardNetwork: cardNetwork,
        creditLimit: creditLimit,
        annualFee: annualFee,
        benefits: benefits,
      );

      if (success) {
        // Reload cards from database to get the latest data
        await loadCards();
        AppLogger.info('Card added successfully', null, null, {
          'cardName': cardName,
          'bankName': bankName,
        });
        return true;
      } else {
        AppLogger.error('Failed to save card to database', null, null, {
          'cardName': cardName,
          'bankName': bankName,
          'cardType': cardType,
        });
        return false;
      }
    } catch (error, stackTrace) {
      AppLogger.error('Failed to add card', error, stackTrace, {
        'cardName': cardName,
        'bankName': bankName,
        'cardType': cardType,
      });
      return false;
    }
  }

  /// Add card from CardInfo object (for backward compatibility)
  Future<bool> addCardFromInfo(CardInfo card) async {
    return await addCard(
      cardName: card.cardType,
      bankName: card.bank,
      cardType: card.cardType,
      lastFourDigits: card.lastFourDigits,
      cardNetwork: card.cardNetwork,
      creditLimit: card.creditLimit,
      annualFee: card.annualFee,
      benefits: card.benefits,
    );
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
      AppLogger.info('Updating card', null, null, {
        'cardId': cardId,
      });

      final success = await _cardService.updateCard(
        cardId: cardId,
        cardName: cardName,
        creditLimit: creditLimit,
        currentBalance: currentBalance,
        availableCredit: availableCredit,
        status: status,
        isPrimary: isPrimary,
        benefits: benefits,
      );

      if (success) {
        // Reload cards to reflect changes
        await loadCards();
        AppLogger.info('Card updated successfully');
        return true;
      } else {
        AppLogger.error('Failed to update card in database');
        return false;
      }
    } catch (error, stackTrace) {
      AppLogger.error('Failed to update card', error, stackTrace);
      return false;
    }
  }

  /// Remove a card (soft delete)
  Future<bool> removeCard(String cardId) async {
    try {
      AppLogger.info('Removing card', null, null, {
        'cardId': cardId,
      });

      final success = await _cardService.deleteCard(cardId);

      if (success) {
        // Remove from local state
        state = state.where((card) => card.id != cardId).toList();
        AppLogger.info('Card removed successfully');
        return true;
      } else {
        AppLogger.error('Failed to remove card from database');
        return false;
      }
    } catch (error, stackTrace) {
      AppLogger.error('Failed to remove card', error, stackTrace);
      return false;
    }
  }

  /// Set a card as primary
  Future<bool> setPrimaryCard(String cardId) async {
    try {
      AppLogger.info('Setting primary card', null, null, {
        'cardId': cardId,
      });

      final success = await _cardService.setPrimaryCard(cardId);

      if (success) {
        // Reload cards to reflect primary status changes
        await loadCards();
        AppLogger.info('Primary card set successfully');
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

  /// Get card statistics
  Future<Map<String, dynamic>> getCardStatistics() async {
    try {
      return await _cardService.getCardStatistics();
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

  /// Refresh cards (reload from database)
  Future<void> refresh() async {
    await loadCards();
  }

  // ============================================================================
  // DEPRECATED METHODS (for backward compatibility)
  // ============================================================================

  @Deprecated('Use addCard or addCardFromInfo instead')
  void addCardOld(CardInfo card) {
    // This method is deprecated but kept for backward compatibility
    // It only updates local state without database persistence
    state = [...state, card];
    AppLogger.warning(
        'Using deprecated addCardOld method - card not saved to database');
  }

  @Deprecated('Use removeCard instead')
  void removeCardOld(String id) {
    // This method is deprecated but kept for backward compatibility
    // It only updates local state without database persistence
    state = state.where((card) => card.id != id).toList();
    AppLogger.warning(
        'Using deprecated removeCardOld method - card not removed from database');
  }

  @Deprecated('Use updateCard instead')
  void updateCardOld(CardInfo updatedCard) {
    // This method is deprecated but kept for backward compatibility
    // It only updates local state without database persistence
    state = state.map((card) {
      if (card.id == updatedCard.id) {
        return updatedCard;
      }
      return card;
    }).toList();
    AppLogger.warning(
        'Using deprecated updateCardOld method - card not updated in database');
  }
}
