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
  final ScrollController _scrollController = ScrollController();
  int _visibleCardCount = 2;
  final int _increment = 2;

  final List<CreditCard> _cards = [
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
    CreditCard(
      id: '4',
      logoAsset: 'assets/images/bank/logos/hdfc-bank.png',
      lastFourDigits: '1921',
      bestUseTag: 'Dining',
      nextDueDate: DateTime(2025, 9, 10),
      nextDueAmount: 4500.0,
      perks: [
        {'icon': '🍽️', 'text': 'Dining Offers'},
        {'icon': '🎉', 'text': 'Event Access'},
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (_visibleCardCount < _cards.length) {
        setState(() {
          _visibleCardCount = (_visibleCardCount + _increment > _cards.length) ? _cards.length : _visibleCardCount + _increment;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Gmail Link Banner
            Container(
              margin: const EdgeInsets.only(top: 16.0, bottom: 16.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: Colors.teal),
                  SizedBox(width: 12.0),
                  Expanded(
                      child: Text(
                          "Link Gmail or upload statement to spot hidden fees")),
                  Icon(Icons.arrow_forward_ios, size: 16.0),
                ],
              ),
            ),
            // Cards Header
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('CARDS',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  TextButton.icon(
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('ADD'),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            // Card List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _visibleCardCount,
                itemBuilder: (context, index) {
                  return CreditCardWidget(
                      card: _cards[index], isBest: index == 0);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
