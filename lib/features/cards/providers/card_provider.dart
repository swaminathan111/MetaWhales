import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/card_info.dart';

final cardsProvider =
    StateNotifierProvider<CardsNotifier, List<CardInfo>>((ref) {
  return CardsNotifier();
});

class CardsNotifier extends StateNotifier<List<CardInfo>> {
  CardsNotifier() : super([]);

  void addCard(CardInfo card) {
    state = [...state, card];
  }

  void removeCard(String id) {
    state = state.where((card) => card.id != id).toList();
  }

  void updateCard(CardInfo updatedCard) {
    state = state.map((card) {
      if (card.id == updatedCard.id) {
        return updatedCard;
      }
      return card;
    }).toList();
  }
}
