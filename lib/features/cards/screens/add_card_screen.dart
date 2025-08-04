import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/card_provider.dart';
import '../../../core/logging/app_logger.dart';
import '../../../services/card_data_service.dart';

class AddCardScreen extends ConsumerStatefulWidget {
  final VoidCallback? onNext;
  final bool isOnboarding;
  final VoidCallback? onCardAdded;

  const AddCardScreen({
    super.key,
    this.onNext,
    this.isOnboarding = false,
    this.onCardAdded,
  });

  @override
  ConsumerState<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends ConsumerState<AddCardScreen> {
  CardIssuer? selectedIssuer;
  CardProduct? selectedProduct;
  bool _isLoading = false;
  List<CardIssuer> _issuers = [];
  List<CardProduct> _products = [];
  bool _isLoadingIssuers = true;
  bool _isLoadingProducts = false;

  @override
  void initState() {
    super.initState();
    _loadIssuers();
  }

  Future<void> _loadIssuers() async {
    setState(() {
      _isLoadingIssuers = true;
    });

    try {
      final issuers = await CardDataService.getCardIssuers();
      setState(() {
        _issuers = issuers;
        _isLoadingIssuers = false;
      });
    } catch (error) {
      setState(() {
        _isLoadingIssuers = false;
      });
      AppLogger.error('Failed to load issuers', error, null);
    }
  }

  Future<void> _loadProducts(String issuerId) async {
    setState(() {
      _isLoadingProducts = true;
    });

    try {
      final products = await CardDataService.getCardProducts(issuerId);
      setState(() {
        _products = products;
        _isLoadingProducts = false;
      });
    } catch (error) {
      setState(() {
        _isLoadingProducts = false;
      });
      AppLogger.error('Failed to load products', error, null);
    }
  }

  void _showBankSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    'Select Bank',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoadingIssuers
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: _issuers.length,
                      itemBuilder: (context, index) {
                        final issuer = _issuers[index];
                        return ListTile(
                          title: Text(issuer.name),
                          subtitle: issuer.customerServicePhone != null
                              ? Text('📞 ${issuer.customerServicePhone}')
                              : null,
                          onTap: () {
                            setState(() {
                              selectedIssuer = issuer;
                              selectedProduct = null;
                            });
                            _loadProducts(issuer.id);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCardSelection() {
    if (selectedIssuer == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Select ${selectedIssuer!.name} Card',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoadingProducts
                  ? const Center(child: CircularProgressIndicator())
                  : _products.isEmpty
                      ? const Center(
                          child: Text(
                            'No cards available for this bank yet.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            return ListTile(
                              title: Text(product.productName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (product.annualFee != null)
                                    Text(
                                      'Annual Fee: ₹${product.annualFee!.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  if (product.rewardRate != null)
                                    Text(
                                      'Reward Rate: ${product.rewardRate!}%',
                                      style: TextStyle(
                                        color: Colors.green[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  if (product.keyBenefits.isNotEmpty)
                                    Text(
                                      product.keyBenefits.take(2).join(', '),
                                      style: TextStyle(
                                        color: Colors.blue[600],
                                        fontSize: 11,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                              onTap: () {
                                setState(() {
                                  selectedProduct = product;
                                });
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addCard() async {
    if (selectedIssuer == null || selectedProduct == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      AppLogger.info('User attempting to add card', null, null, {
        'issuer': selectedIssuer!.name,
        'product': selectedProduct!.productName,
        'isOnboarding': widget.isOnboarding,
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

      // Add card using the provider method
      final success = await ref.read(cardsProvider.notifier).addCard(
            cardName: selectedProduct!.productName,
            bankName: selectedIssuer!.name,
            cardType: 'credit', // Default to credit for now
          );

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (success) {
        AppLogger.info('Card added successfully', null, null, {
          'issuer': selectedIssuer!.name,
          'product': selectedProduct!.productName,
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${selectedProduct!.productName} from ${selectedIssuer!.name} added successfully!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }

        // Reset form
        setState(() {
          selectedIssuer = null;
          selectedProduct = null;
          _products = [];
        });

        // Handle navigation
        if (widget.isOnboarding && widget.onNext != null) {
          widget.onNext!();
        }

        widget.onCardAdded?.call();
      } else {
        AppLogger.error('Failed to add card', null, null, {
          'issuer': selectedIssuer!.name,
          'product': selectedProduct!.productName,
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
      AppLogger.error('Exception while adding card', error, stackTrace);

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add Card',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      selectedIssuer?.name ?? 'Choose your bank',
                      style: TextStyle(
                        fontSize: 16,
                        color: selectedIssuer != null
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
              onTap: (_isLoading || selectedIssuer == null)
                  ? null
                  : _showCardSelection,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (_isLoading || selectedIssuer == null)
                      ? Colors.grey[200]
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        selectedProduct?.productName ?? 'Choose your card',
                        style: TextStyle(
                          fontSize: 16,
                          color: selectedProduct != null
                              ? Colors.black
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: (_isLoading || selectedIssuer == null)
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),
            if (selectedProduct != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedProduct!.productName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (selectedProduct!.annualFee != null)
                      Text(
                        'Annual Fee: ₹${selectedProduct!.annualFee!.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    if (selectedProduct!.rewardRate != null)
                      Text(
                        'Reward Rate: ${selectedProduct!.rewardRate!}%',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    if (selectedProduct!.keyBenefits.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Key Benefits:',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...selectedProduct!.keyBenefits.take(3).map(
                            (benefit) => Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                '• $benefit',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                    ],
                  ],
                ),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (selectedIssuer != null &&
                        selectedProduct != null &&
                        !_isLoading)
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
          ],
        ),
      ),
    );
  }
}
