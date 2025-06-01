import 'package:flutter/material.dart';

class CardInfo {
  final String id;
  final String bank;
  final String cardType;
  final List<Color> gradientColors;
  final String? description;
  final int points;
  final IconData icon;

  CardInfo({
    required this.id,
    required this.bank,
    required this.cardType,
    required this.gradientColors,
    this.description,
    this.points = 0,
    this.icon = Icons.credit_card,
  });

  CardInfo copyWith({
    String? id,
    String? bank,
    String? cardType,
    List<Color>? gradientColors,
    String? description,
    int? points,
    IconData? icon,
  }) {
    return CardInfo(
      id: id ?? this.id,
      bank: bank ?? this.bank,
      cardType: cardType ?? this.cardType,
      gradientColors: gradientColors ?? this.gradientColors,
      description: description ?? this.description,
      points: points ?? this.points,
      icon: icon ?? this.icon,
    );
  }
}
