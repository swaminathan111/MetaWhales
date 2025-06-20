import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../cards/screens/add_card_screen.dart';
import '../../cards/providers/card_provider.dart';
import '../../cards/models/card_info.dart';
import '../../../core/logging/app_logger.dart';

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
  String? selectedCard;
  String? selectedCardType;
  bool _isLoading = false;

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
                      selectedCard = null; // Reset card when bank changes
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

  void _showCardSelection() {
    if (selectedBank == null) return;

    final bankCards = {
      'Axis Bank': [
        'ACE Credit Card',
        'Magnus Credit Card',
        'Flipkart Credit Card',
        'Neo Credit Card',
        'Select Credit Card'
      ],
      'HDFC Bank': [
        'Regalia Credit Card',
        'Millennia Credit Card',
        'MoneyBack Credit Card',
        'Diners Club Credit Card',
        'Times Credit Card'
      ],
      'ICICI Bank': [
        'Amazon Pay Credit Card',
        'Emeralde Credit Card',
        'Platinum Credit Card',
        'Sapphiro Credit Card',
        'Rubyx Credit Card'
      ],
      'SBI': [
        'SimplySAVE Credit Card',
        'PRIME Credit Card',
        'Elite Credit Card',
        'Cashback Credit Card',
        'Air India Credit Card'
      ],
    };

    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: (bankCards[selectedBank] ?? [])
            .map((card) => ListTile(
                  title: Text(card),
                  onTap: () {
                    setState(() {
                      selectedCard = card;
                      selectedCardType =
                          null; // Reset card type when card changes
                    });
                    Navigator.pop(context);
                  },
                ))
            .toList(),
      ),
    );
  }

  void _showCardTypeSelection() {
    if (selectedCard == null) return;

    final cardTypes = ['Credit', 'Debit'];

    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: cardTypes
            .map((type) => ListTile(
                  title: Text(type),
                  onTap: () {
                    setState(() {
                      selectedCardType = type;
                    });
                    Navigator.pop(context);
                  },
                ))
            .toList(),
      ),
    );
  }

  Future<void> _addCard() async {
    if (selectedBank == null ||
        selectedCard == null ||
        selectedCardType == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      AppLogger.info('Onboarding: User attempting to add card', null, null, {
        'bank': selectedBank,
        'card': selectedCard,
        'cardType': selectedCardType,
      });

      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Adding your card...'),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      // Add card using the new provider method
      final success = await ref.read(cardsProvider.notifier).addCard(
            cardName: selectedCard!,
            bankName: selectedBank!,
            cardType: selectedCardType!,
          );

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (success) {
        AppLogger.info('Onboarding: Card added successfully', null, null, {
          'bank': selectedBank,
          'card': selectedCard,
          'cardType': selectedCardType,
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('$selectedCard from $selectedBank added successfully!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        // Reset form
        setState(() {
          selectedBank = null;
          selectedCard = null;
          selectedCardType = null;
        });
      } else {
        AppLogger.error('Onboarding: Failed to add card', null, null, {
          'bank': selectedBank,
          'card': selectedCard,
          'cardType': selectedCardType,
        });

        // Show error message with retry option
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error Adding Card'),
              content: const Text(
                'We couldn\'t add your card right now. Please check your internet connection and try again.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _addCard(); // Retry
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
      }
    } catch (error, stackTrace) {
      AppLogger.error(
          'Onboarding: Exception while adding card', error, stackTrace);

      // Close loading dialog if still open
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(cardsProvider);
    final isProviderLoading = ref.read(cardsProvider.notifier).isLoading;

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
              onTap: _isLoading ? null : _showBankSelection,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isLoading ? Colors.grey[200] : Colors.grey[100],
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
                      color: _isLoading ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select Card',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: (_isLoading || selectedBank == null)
                  ? null
                  : _showCardSelection,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (_isLoading || selectedBank == null)
                      ? Colors.grey[200]
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedCard ?? 'Choose your card',
                      style: TextStyle(
                        fontSize: 16,
                        color: selectedCard != null
                            ? Colors.black
                            : Colors.grey[600],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: (_isLoading || selectedBank == null)
                          ? Colors.grey[400]
                          : Colors.grey[600],
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
              onTap: (_isLoading || selectedCard == null)
                  ? null
                  : _showCardTypeSelection,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (_isLoading || selectedCard == null)
                      ? Colors.grey[200]
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedCardType ?? 'Choose card type (Credit/Debit)',
                      style: TextStyle(
                        fontSize: 16,
                        color: selectedCardType != null
                            ? Colors.black
                            : Colors.grey[600],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: (_isLoading || selectedCard == null)
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (selectedBank != null &&
                        selectedCard != null &&
                        selectedCardType != null &&
                        !_isLoading &&
                        !isProviderLoading)
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
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Add Card',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),
            if (cards.isNotEmpty) ...[
              const Text(
                'Your Cards',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    return Container(
                      width: 300,
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: card.gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                card.icon,
                                color: Colors.white,
                                size: 32,
                              ),
                              const Spacer(),
                              if (card.isPrimary)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'PRIMARY',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
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
                          if (card.lastFourDigits != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              '•••• •••• •••• ${card.lastFourDigits}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 24),
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
