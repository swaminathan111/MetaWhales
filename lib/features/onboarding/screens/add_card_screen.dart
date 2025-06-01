import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../cards/screens/add_card_screen.dart';
import '../../cards/providers/card_provider.dart';
import '../../cards/models/card_info.dart';

class OnboardingAddCardScreen extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const OnboardingAddCardScreen({
    super.key,
    required this.onNext,
  });

  @override
  ConsumerState<OnboardingAddCardScreen> createState() =>
      _OnboardingAddCardScreenState();
}

class _OnboardingAddCardScreenState
    extends ConsumerState<OnboardingAddCardScreen> {
  String? selectedBank;
  String? selectedCardType;

  void _showBankSelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          'Axis Bank',
          'HDFC Bank',
          'ICICI Bank',
          'SBI',
        ]
            .map((bank) => ListTile(
                  title: Text(bank),
                  onTap: () {
                    setState(() {
                      selectedBank = bank;
                      selectedCardType =
                          null; // Reset card type when bank changes
                    });
                    Navigator.pop(context);
                  },
                ))
            .toList(),
      ),
    );
  }

  void _showCardTypeSelection() {
    if (selectedBank == null) return;

    final cardTypes = {
      'Axis Bank': [
        'ACE Credit Card',
        'Magnus Credit Card',
        'Flipkart Credit Card'
      ],
      'HDFC Bank': [
        'Regalia Credit Card',
        'Millennia Credit Card',
        'MoneyBack Credit Card'
      ],
      'ICICI Bank': [
        'Amazon Pay Credit Card',
        'Emeralde Credit Card',
        'Platinum Credit Card'
      ],
      'SBI': [
        'SimplySAVE Credit Card',
        'PRIME Credit Card',
        'Elite Credit Card'
      ],
    };

    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: (cardTypes[selectedBank] ?? [])
            .map((card) => ListTile(
                  title: Text(card),
                  onTap: () {
                    setState(() {
                      selectedCardType = card;
                    });
                    Navigator.pop(context);
                  },
                ))
            .toList(),
      ),
    );
  }

  void _addCard() {
    if (selectedBank != null && selectedCardType != null) {
      final newCard = CardInfo(
        id: DateTime.now().toString(),
        bank: selectedBank!,
        cardType: selectedCardType!,
        icon: Icons.credit_card,
        gradientColors: [Colors.blue[700]!, Colors.blue[900]!],
      );
      ref.read(cardsProvider.notifier).addCard(newCard);
      setState(() {
        selectedBank = null;
        selectedCardType = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(cardsProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Your Card',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose how you\'d like to add your card',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Select Bank',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _showBankSelection,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedBank ?? 'Choose your bank',
                      style: TextStyle(
                        fontSize: 16,
                        color: selectedBank != null
                            ? Colors.black
                            : Colors.grey[600],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select Card Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: selectedBank != null ? _showCardTypeSelection : null,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedCardType ?? 'Choose card type',
                      style: TextStyle(
                        fontSize: 16,
                        color: selectedCardType != null
                            ? Colors.black
                            : Colors.grey[600],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedBank != null && selectedCardType != null
                    ? _addCard
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4285F4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: const Text(
                  'Add Card',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Your cards',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            if (cards.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey[300]!,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.credit_card_outlined,
                      size: 32,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No cards added yet',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: cards.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    return Container(
                      width: MediaQuery.of(context).size.width - 64,
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: card.gradientColors,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            card.icon,
                            color: Colors.white,
                            size: 32,
                          ),
                          const Spacer(),
                          Text(
                            card.bank,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            card.cardType,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Your card details are encrypted and secure',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
