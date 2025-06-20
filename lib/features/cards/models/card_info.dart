import 'package:flutter/material.dart';

class CardInfo {
  final String id;
  final String bank;
  final String cardType;
  final List<Color> gradientColors;
  final String? description;
  final int points;
  final IconData icon;

  // Additional database fields
  final String? lastFourDigits;
  final String? cardNetwork;
  final double? creditLimit;
  final double? currentBalance;
  final double? availableCredit;
  final double? annualFee;
  final double? rewardPoints;
  final double? cashbackEarned;
  final Map<String, dynamic>? benefits;
  final String status;
  final bool isPrimary;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CardInfo({
    required this.id,
    required this.bank,
    required this.cardType,
    required this.gradientColors,
    this.description,
    this.points = 0,
    this.icon = Icons.credit_card,
    this.lastFourDigits,
    this.cardNetwork,
    this.creditLimit,
    this.currentBalance,
    this.availableCredit,
    this.annualFee,
    this.rewardPoints,
    this.cashbackEarned,
    this.benefits,
    this.status = 'active',
    this.isPrimary = false,
    this.createdAt,
    this.updatedAt,
  });

  CardInfo copyWith({
    String? id,
    String? bank,
    String? cardType,
    List<Color>? gradientColors,
    String? description,
    int? points,
    IconData? icon,
    String? lastFourDigits,
    String? cardNetwork,
    double? creditLimit,
    double? currentBalance,
    double? availableCredit,
    double? annualFee,
    double? rewardPoints,
    double? cashbackEarned,
    Map<String, dynamic>? benefits,
    String? status,
    bool? isPrimary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CardInfo(
      id: id ?? this.id,
      bank: bank ?? this.bank,
      cardType: cardType ?? this.cardType,
      gradientColors: gradientColors ?? this.gradientColors,
      description: description ?? this.description,
      points: points ?? this.points,
      icon: icon ?? this.icon,
      lastFourDigits: lastFourDigits ?? this.lastFourDigits,
      cardNetwork: cardNetwork ?? this.cardNetwork,
      creditLimit: creditLimit ?? this.creditLimit,
      currentBalance: currentBalance ?? this.currentBalance,
      availableCredit: availableCredit ?? this.availableCredit,
      annualFee: annualFee ?? this.annualFee,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      cashbackEarned: cashbackEarned ?? this.cashbackEarned,
      benefits: benefits ?? this.benefits,
      status: status ?? this.status,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create CardInfo from database response
  factory CardInfo.fromDatabase(Map<String, dynamic> data) {
    // Extract issuer and category data
    final issuer = data['card_issuers'] as Map<String, dynamic>?;
    final category = data['card_categories'] as Map<String, dynamic>?;

    // Determine gradient colors based on card network or use default
    List<Color> gradientColors = _getGradientColors(
      data['card_network'] as String?,
      category?['color_code'] as String?,
    );

    return CardInfo(
      id: data['id'] as String,
      bank: issuer?['name'] as String? ?? 'Unknown Bank',
      cardType: data['card_name'] as String? ?? 'Unknown Card',
      gradientColors: gradientColors,
      description: category?['description'] as String?,
      points: (data['reward_points'] as num?)?.toInt() ?? 0,
      icon: _getIconFromName(category?['icon_name'] as String?),
      lastFourDigits: data['last_four_digits'] as String?,
      cardNetwork: data['card_network'] as String?,
      creditLimit: (data['credit_limit'] as num?)?.toDouble(),
      currentBalance: (data['current_balance'] as num?)?.toDouble(),
      availableCredit: (data['available_credit'] as num?)?.toDouble(),
      annualFee: (data['annual_fee'] as num?)?.toDouble(),
      rewardPoints: (data['reward_points'] as num?)?.toDouble(),
      cashbackEarned: (data['cashback_earned'] as num?)?.toDouble(),
      benefits: data['benefits'] as Map<String, dynamic>?,
      status: data['status'] as String? ?? 'active',
      isPrimary: data['is_primary'] as bool? ?? false,
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'] as String)
          : null,
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'] as String)
          : null,
    );
  }

  /// Convert to database format for saving
  Map<String, dynamic> toDatabase() {
    return {
      'card_name': cardType,
      'card_type': _inferCardType(),
      'last_four_digits': lastFourDigits,
      'card_network': cardNetwork,
      'credit_limit': creditLimit,
      'current_balance': currentBalance,
      'available_credit': availableCredit,
      'annual_fee': annualFee,
      'reward_points': rewardPoints,
      'cashback_earned': cashbackEarned,
      'benefits': benefits ?? {},
      'status': status,
      'is_primary': isPrimary,
    };
  }

  /// Get display name for the card (e.g., "HDFC •••• 1234")
  String get displayName {
    if (lastFourDigits != null) {
      return '$bank •••• $lastFourDigits';
    }
    return '$bank $cardType';
  }

  /// Get formatted balance string
  String get formattedBalance {
    if (currentBalance != null) {
      return '₹${currentBalance!.toStringAsFixed(2)}';
    }
    return '₹0.00';
  }

  /// Get formatted credit limit string
  String get formattedCreditLimit {
    if (creditLimit != null) {
      return '₹${creditLimit!.toStringAsFixed(0)}';
    }
    return 'N/A';
  }

  /// Get available credit percentage
  double get availableCreditPercentage {
    if (creditLimit != null && creditLimit! > 0 && currentBalance != null) {
      return ((creditLimit! - currentBalance!) / creditLimit!) * 100;
    }
    return 0.0;
  }

  /// Check if card is near limit (>80% utilized)
  bool get isNearLimit {
    return availableCreditPercentage < 20.0;
  }

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  /// Get gradient colors based on card network or category
  static List<Color> _getGradientColors(
      String? cardNetwork, String? colorCode) {
    // First try to use category color
    if (colorCode != null && colorCode.isNotEmpty) {
      try {
        final color = Color(int.parse(colorCode.replaceFirst('#', '0xFF')));
        return [color, color.withOpacity(0.8)];
      } catch (e) {
        // Fall through to network colors
      }
    }

    // Use card network specific colors
    switch (cardNetwork?.toLowerCase()) {
      case 'visa':
        return [const Color(0xFF1A1F71), const Color(0xFF2E3A8C)];
      case 'mastercard':
        return [const Color(0xFFEB001B), const Color(0xFFF79E1B)];
      case 'rupay':
        return [const Color(0xFF067F39), const Color(0xFF0A9F4C)];
      case 'amex':
        return [const Color(0xFF006FCF), const Color(0xFF0085C3)];
      case 'diners':
        return [const Color(0xFF0079BE), const Color(0xFF009CDE)];
      default:
        return [const Color(0xFF4285F4), const Color(0xFF2962FF)];
    }
  }

  /// Get icon from icon name string
  static IconData _getIconFromName(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'credit_card':
        return Icons.credit_card;
      case 'payment':
        return Icons.payment;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'card_membership':
        return Icons.card_membership;
      default:
        return Icons.credit_card;
    }
  }

  /// Infer card type from card name
  String _inferCardType() {
    final cardTypeLower = cardType.toLowerCase();
    if (cardTypeLower.contains('debit')) {
      return 'debit';
    } else if (cardTypeLower.contains('prepaid')) {
      return 'prepaid';
    } else {
      return 'credit'; // Default to credit card
    }
  }
}
