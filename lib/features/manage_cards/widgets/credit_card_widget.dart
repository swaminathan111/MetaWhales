import 'package:flutter/material.dart';
import '../models/credit_card_model.dart';

String _formatCurrency(double amount) {
  if (amount >= 100000) {
    double result = amount / 100000;
    if (result % 1 == 0) {
      return '₹${result.toInt()}L';
    }
    return '₹${result.toStringAsFixed(1)}L';
  } else if (amount >= 1000) {
    double result = amount / 1000;
    if (result % 1 == 0) {
      return '₹${result.toInt()}K';
    }
    return '₹${result.toStringAsFixed(1)}K';
  }
  return '₹${amount.toInt()}';
}

class CreditCardWidget extends StatelessWidget {
  final CreditCard card;
  final bool isBest;

  const CreditCardWidget({super.key, required this.card, this.isBest = false});

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Top bar: Logo and masked digits
                Row(
                  children: [
                    Image.asset(card.logoAsset, height: 20), // Tiny logo
                    const SizedBox(width: 8),
                    Text('... ${card.lastFourDigits}', style: const TextStyle(fontSize: 12, color: Colors.black54)), // Smaller digits
                  ],
                ),
                const SizedBox(height: 24),

                // Middle: Next Due
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.black54),
                    const SizedBox(width: 8),
                    Text(
                      'Next Due: ₹${card.nextDueAmount.toStringAsFixed(0)} on ${_formatDate(card.nextDueDate)}',
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
                const Divider(height: 24.0, thickness: 1.0),

                // Bottom: Perks
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: card.perks.take(2).map((perk) {
                    return Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(perk['icon']!, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              perk['text']!,
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Badge
          if (isBest)
            Positioned(
              top: 12,
              right: 12,
              child: Chip(
                label: Text('★ ${card.bestUseTag}'),
                backgroundColor: Colors.green[100],
                labelStyle: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
        ],
      ),
    );
  }
}
