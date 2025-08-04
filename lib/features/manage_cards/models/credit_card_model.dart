class CreditCard {
  final String id;
  final String bankName;
  final String cardName;
  final String lastFourDigits;
  final String cardType; // e.g., 'Mastercard', 'Visa'
  final String logoAsset;

  CreditCard({
    required this.id,
    required this.bankName,
    required this.cardName,
    required this.lastFourDigits,
    required this.cardType,
    required this.logoAsset,
  });
}
