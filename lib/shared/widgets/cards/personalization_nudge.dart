import 'package:flutter/material.dart';
import 'dart:async';
import '../../theme/app_theme.dart';

/// Widget that displays rotating "Did you know?" cards with user's card perks
class PersonalizationNudge extends StatefulWidget {
  const PersonalizationNudge({
    super.key,
    required this.cardPerks,
    this.rotationDuration = const Duration(seconds: 8),
  });

  final List<CardPerk> cardPerks;
  final Duration rotationDuration;

  @override
  State<PersonalizationNudge> createState() => _PersonalizationNudgeState();
}

class _PersonalizationNudgeState extends State<PersonalizationNudge>
    with SingleTickerProviderStateMixin {
  late Timer _rotationTimer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.cardPerks.isNotEmpty) {
      _animationController.forward();
      _startRotation();
    }
  }

  void _startRotation() {
    _rotationTimer = Timer.periodic(widget.rotationDuration, (timer) {
      if (mounted && widget.cardPerks.isNotEmpty) {
        _animationController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _currentIndex = (_currentIndex + 1) % widget.cardPerks.length;
            });
            _animationController.forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _rotationTimer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cardPerks.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final currentPerk = widget.cardPerks[_currentIndex];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(theme.spacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFF8F9FF),
              const Color(0xFFF0F4FF),
            ],
          ),
          borderRadius: theme.borderRadius.card,
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  currentPerk.icon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            
            SizedBox(width: theme.spacing.md),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Did you know?',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: theme.spacing.xs),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: theme.spacing.xs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          currentPerk.cardName,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: theme.spacing.xs),
                  
                  Text(
                    currentPerk.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            
            // Rotation indicator
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Model for card perks used in personalization nudges
class CardPerk {
  final String icon;
  final String cardName;
  final String description;
  final String category;

  const CardPerk({
    required this.icon,
    required this.cardName,
    required this.description,
    required this.category,
  });
}

/// Sample card perks for demonstration
class SampleCardPerks {
  static const List<CardPerk> perks = [
    CardPerk(
      icon: '✈️',
      cardName: 'HDFC Infinia',
      description: 'Your card gives you complimentary lounge access at 1000+ airports worldwide',
      category: 'Travel',
    ),
    CardPerk(
      icon: '🛍️',
      cardName: 'ICICI Amazon Pay',
      description: 'You earn 5% cashback on Amazon purchases with no minimum spend limit',
      category: 'Shopping',
    ),
    CardPerk(
      icon: '⛽',
      cardName: 'HDFC Infinia',
      description: 'Get 3.3% reward points on fuel purchases at all petrol pumps',
      category: 'Fuel',
    ),
    CardPerk(
      icon: '🍽️',
      cardName: 'ICICI Amazon Pay',
      description: 'Enjoy 1+1 offers at premium restaurants and 20% off on food delivery',
      category: 'Dining',
    ),
    CardPerk(
      icon: '🏨',
      cardName: 'HDFC Infinia',
      description: 'Book hotels through SmartBuy and earn up to 10X reward points',
      category: 'Travel',
    ),
    CardPerk(
      icon: '🎬',
      cardName: 'ICICI Amazon Pay',
      description: 'Get buy-one-get-one movie tickets every month at BookMyShow',
      category: 'Entertainment',
    ),
  ];
}
