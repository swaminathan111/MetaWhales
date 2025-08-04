import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/credit_card_model.dart';
import '../widgets/credit_card_widget.dart';

class ManageCardsScreen extends ConsumerStatefulWidget {
  const ManageCardsScreen({super.key});

  @override
  ConsumerState<ManageCardsScreen> createState() => _ManageCardsScreenState();
}

class _ManageCardsScreenState extends ConsumerState<ManageCardsScreen> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Mock data for now

    final List<CreditCard> cards = [
      CreditCard(
        id: '1',
        logoAsset: 'assets/images/bank/logos/hdfc-bank.png',
        lastFourDigits: '1920',
        bestUseTag: 'Travel',
        nextDueDate: DateTime(2025, 8, 18),
        nextDueAmount: 3134.0,
        perks: [
          {'icon': '✈️', 'text': 'Lounge Access'},
          {'icon': '🏨', 'text': 'Hotel Vouchers'},
        ],
      ),
      CreditCard(
        id: '2',
        logoAsset: 'assets/images/bank/logos/icici-bank.png',
        lastFourDigits: '5678',
        bestUseTag: 'Shopping',
        nextDueDate: DateTime(2025, 8, 22),
        nextDueAmount: 1250.50,
        perks: [
          {'icon': '🛍️', 'text': '5% on Amazon'},
          {'icon': '🎁', 'text': '1% Rewards'},
        ],
      ),
      CreditCard(
        id: '3',
        logoAsset: 'assets/images/bank/logos/axis-bank.png',
        lastFourDigits: '9012',
        bestUseTag: 'Fuel',
        nextDueDate: DateTime(2025, 9, 5),
        nextDueAmount: 876.0,
        perks: [
          {'icon': '⛽', 'text': '4% Fuel Surcharge'},
          {'icon': '🎬', 'text': 'Movie Tickets'},
        ],
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
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _isExpanded ? cards.length : 2,
            itemBuilder: (context, index) {
              return CreditCardWidget(card: cards[index], isBest: index == 0);
            },
          ),
          const SizedBox(height: 16.0),
          if (cards.length > 2)
            TextButton(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Text(_isExpanded ? 'Show Less' : 'Show More'),
            ),
        ],
      ),
    );
  }
}
