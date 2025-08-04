class CreditCard {
  final String id;
  final String logoAsset;
  final String lastFourDigits;
  final String bestUseTag;
  final DateTime nextDueDate;
  final double nextDueAmount;
  final List<Map<String, String>> perks;

  CreditCard({
    required this.id,
    required this.logoAsset,
    required this.lastFourDigits,
    required this.bestUseTag,
    required this.nextDueDate,
    required this.nextDueAmount,
    required this.perks,
  });
}
