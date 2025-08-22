import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../models/credit_card_model.dart';
import '../../../core/theme/app_theme.dart';

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

class CreditCardWidget extends StatefulWidget {
  final CreditCard card;
  final bool isBest;

  const CreditCardWidget({
    super.key, 
    required this.card, 
    this.isBest = false, 
  });

  @override
  State<CreditCardWidget> createState() => _CreditCardWidgetState();
}

class _CreditCardWidgetState extends State<CreditCardWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_controller.status == AnimationStatus.completed) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }





  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  void _showSmartTip() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Icon(
                  Icons.drag_handle,
                  size: 30,
                  color: Color(0xFF525E66),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Smart Tip',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF525E66),
                ),
              ),
              const SizedBox(height: 20),
              // AI insight content - this would be dynamic in a real app
              const Text(
                'Save ₹32 on next ₹5 000 fuel spend',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF525E66),
                ),
              ),
              const SizedBox(height: 20),
              // Add more content as needed
              const Expanded(
                child: Text(
                  'Use your credit card at partnered fuel stations to maximize your savings. This offer is valid for the next 30 days.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF525E66),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_controller.value * pi),
            alignment: Alignment.center,
            child: Stack(
              children: [
                // Front side
                Opacity(
                  opacity: 1.0 - _controller.value,
                  child: _buildFront(),
                ),
                // Back side - rotated 180 degrees initially
                Transform(
                  transform: Matrix4.rotationY(pi),
                  alignment: Alignment.center,
                  child: Opacity(
                    opacity: _controller.value,
                    child: _buildBack(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: 180,
        maxHeight: 220,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo, Best tag, and Smart Tip bulb
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                widget.card.logoAsset,
                height: 30,
                width: 50,
                fit: BoxFit.contain,
              ),
              Row(
                children: [
                  if (widget.isBest)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: cardSenseTheme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Best',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (widget.isBest) const SizedBox(width: 8),
                  // Smart Tip bulb moved to top right
                  InkWell(
                    onTap: _showSmartTip,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amber.shade300, width: 1),
                      ),
                      child: Icon(
                        Icons.lightbulb,
                        color: Colors.amber.shade700,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Card number
          Text(
            '**** **** **** ${widget.card.lastFourDigits}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF525E66), // Using the specified dark slate color
            ),
          ),
          const SizedBox(height: 20),
          // Due amount and date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Next Due',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF525E66), // Using the specified dark slate color
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Color(0xFF525E66), // Using the specified dark slate color
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.card.nextDueDate.day}/${widget.card.nextDueDate.month}/${widget.card.nextDueDate.year}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF525E66), // Using the specified dark slate color
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Due Amount',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF525E66), // Using the specified dark slate color
                    ),
                  ),
                  Text(
                    _formatCurrency(widget.card.nextDueAmount),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF525E66), // Using the specified dark slate color
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Spacer to push content to bottom
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Perks section - stacked vertically in bottom left
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Display up to 2 perks, stacked vertically
                      if (widget.card.perks.isNotEmpty)
                        Container(
                          constraints: const BoxConstraints(maxWidth: 140),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.card.perks[0].containsKey('icon') ? widget.card.perks[0]['icon']! : '',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  widget.card.perks[0].containsKey('text') ? widget.card.perks[0]['text']! : '',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Color(0xFF525E66),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (widget.card.perks.isNotEmpty) const SizedBox(height: 2),
                      if (widget.card.perks.length > 1)
                        Container(
                          constraints: const BoxConstraints(maxWidth: 140),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.card.perks[1].containsKey('icon') ? widget.card.perks[1]['icon']! : '',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  widget.card.perks[1].containsKey('text') ? widget.card.perks[1]['text']! : '',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Color(0xFF525E66),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Pay Now button
                ElevatedButton(
                  onPressed: () {
                    // Handle pay now action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cardSenseTheme.colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    'Pay Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: 180,
        maxHeight: 220,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFA8E6CD), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Credit limit info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Credit Limit:',
                style: TextStyle(fontSize: 14, color: Color(0xFF525E66)),
              ),
              Text(
                _formatCurrency(500000), // Assuming ₹500,000 limit
                style: const TextStyle(fontSize: 14, color: Color(0xFF525E66)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Available:',
                style: TextStyle(fontSize: 14, color: Color(0xFF525E66)),
              ),
              Text(
                _formatCurrency(320000), // Assuming ₹320,000 available
                style: const TextStyle(fontSize: 14, color: Color(0xFF525E66)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Rewards info
          const Text(
            'Rewards:',
            style: TextStyle(fontSize: 14, color: Color(0xFF525E66)),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Points Balance:',
                style: TextStyle(fontSize: 12, color: Color(0xFF525E66)),
              ),
              const Text(
                '8,612', // Example points balance
                style: TextStyle(fontSize: 12, color: Color(0xFF525E66)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Earn Rate:',
                style: TextStyle(fontSize: 12, color: Color(0xFF525E66)),
              ),
              const Text(
                '1pt/₹120', // Example earn rate
                style: TextStyle(fontSize: 12, color: Color(0xFF525E66)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Perks Unlocked:',
                style: TextStyle(fontSize: 12, color: Color(0xFF525E66)),
              ),
              const Text(
                '3/10', // Example perks unlocked
                style: TextStyle(fontSize: 12, color: Color(0xFF525E66)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // AI Smart Tip
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFA8E6CD).withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'AI Tip: Save ₹32 on next ₹5,000 fuel spend',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF525E66),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


}
