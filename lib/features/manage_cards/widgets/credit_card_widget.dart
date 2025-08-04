import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
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

class CreditCardWidget extends StatefulWidget {
  final CreditCard card;
  final bool isBest;

  const CreditCardWidget({super.key, required this.card, this.isBest = false});

  @override
  State<CreditCardWidget> createState() => _CreditCardWidgetState();
}

class _CreditCardWidgetState extends State<CreditCardWidget>
    with SingleTickerProviderStateMixin {
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
      width: 320,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Logo + masked number
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    widget.card.logoAsset,
                    height: 30,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.credit_card, color: Color(0xFF525E66));
                    },
                  ),
                  Text(
                    '...${widget.card.lastFourDigits}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF525E66),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Next due amount & date
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Color(0xFFA9BEE9)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Next Due: ₹${widget.card.nextDueAmount.toStringAsFixed(0)} on ${_formatDate(widget.card.nextDueDate)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF525E66),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              
              // Perks
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Chip icon + earn rate
                  Row(
                    children: [
                      const Icon(Icons.credit_card, size: 16, color: Color(0xFFA9BEE9)),
                      const SizedBox(width: 4),
                      const Text('1pt/₹100', style: TextStyle(fontSize: 12, color: Color(0xFF525E66))),
                    ],
                  ),
                  // Cashback icon + perk
                  Row(
                    children: [
                      const Icon(Icons.local_gas_station, size: 16, color: Color(0xFFA9BEE9)),
                      const SizedBox(width: 4),
                      const Text('2% fuel', style: TextStyle(fontSize: 12, color: Color(0xFF525E66))),
                    ],
                  ),
                ],
              ),
            ],
          ),
          
          // Best badge
          if (widget.isBest)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFFA8E6CD),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
                child: const Text(
                  'BEST',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      width: 320,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
