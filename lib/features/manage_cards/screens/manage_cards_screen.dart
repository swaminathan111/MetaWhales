import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/credit_card_model.dart';
import '../widgets/credit_card_widget.dart';

class ManageCardsScreen extends ConsumerWidget {
  const ManageCardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock data for now
    final List<CreditCard> cards = [
      CreditCard(
        id: '1',
        bankName: 'HDFC Bank',
        cardName: 'HDFC Infinia',
        lastFourDigits: '1920',
        cardType: 'Mastercard',
        logoAsset: 'assets/images/bank/logos/hdfc-bank.png',
      ),
      CreditCard(
        id: '2',
        bankName: 'HDFC Bank',
        cardName: 'HDFC Regalia',
        lastFourDigits: '1234',
        cardType: 'Visa',
        logoAsset: 'assets/images/bank/logos/hdfc-bank.png',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Chip(
              avatar: const CircleAvatar(
                backgroundColor: Colors.amber,
                child: Text('C'),
              ),
              label: const Text('2,546'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Gmail Link Banner
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, color: Colors.teal),
                const SizedBox(width: 12.0),
                const Expanded(
                  child: Text("Link Gmail or upload statement to spot hidden fees")
                ),
                const Icon(Icons.arrow_forward_ios, size: 16.0),
              ],
            ),
          ),
          // Cards Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('CARDS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              TextButton.icon(
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('ADD'),
                onPressed: () {},
              ),
            ],
          ),
          // Card List
          ...cards.map((card) => CreditCardWidget(card: card)).toList(),
        ],
      ),
    );
  }
}
