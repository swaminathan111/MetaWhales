import 'package:flutter/material.dart';
import '../models/credit_card_model.dart';

class CreditCardWidget extends StatelessWidget {
  final CreditCard card;

  const CreditCardWidget({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(card.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        // Handle remove action here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${card.cardName} removed')),
        );
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete, color: Colors.white),
            Text('Remove', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Top Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(card.cardName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.credit_card, color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            Text('... ${card.lastFourDigits}', style: const TextStyle(fontSize: 16, color: Colors.black54)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Image.asset('assets/icons/card_chip.png', width: 40),
                      ],
                    ),
                  ),
                  // Bank Logo and More Icon
                  Row(
                    children: [
                      Image.asset(card.logoAsset, height: 24),
                      const SizedBox(width: 8),
                      const Icon(Icons.more_vert),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              // Bottom Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Next Bill Info
                  const Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.black54, size: 20),
                      SizedBox(width: 8),
                      Text('Next bill on 18 Aug'),
                    ],
                  ),
                  // Pay Now Button
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Column(
                      children: [
                        Text('PAY NOW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text('Earn 1.0%', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
