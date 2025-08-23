import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../../features/cards/models/card_info.dart';

/// Horizontal scrollable card preview tiles
class CardPreviewTile extends StatelessWidget {
  const CardPreviewTile({
    super.key,
    required this.cards,
    required this.onCardTap,
    this.height = 200,
  });

  final List<CardInfo> cards;
  final Function(CardInfo card) onCardTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (cards.isEmpty) {
      return _EmptyCardState(height: height);
    }
    
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: theme.spacing.lg),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return Padding(
            padding: EdgeInsets.only(
              right: index < cards.length - 1 ? theme.spacing.md : 0,
            ),
            child: _CardTile(
              card: card,
              onTap: () => onCardTap(card),
            ),
          );
        },
      ),
    );
  }
}

class _CardTile extends StatefulWidget {
  const _CardTile({
    required this.card,
    required this.onTap,
  });

  final CardInfo card;
  final VoidCallback onTap;

  @override
  State<_CardTile> createState() => _CardTileState();
}

class _CardTileState extends State<_CardTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: Container(
              width: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.card.gradientColors,
                ),
                borderRadius: theme.borderRadius.card,
                boxShadow: [
                  ...theme.shadows.card,
                  if (_glowAnimation.value > 0)
                    BoxShadow(
                      color: widget.card.gradientColors.first.withOpacity(
                        0.3 * _glowAnimation.value,
                      ),
                      blurRadius: 20 * _glowAnimation.value,
                      spreadRadius: 2 * _glowAnimation.value,
                    ),
                ],
              ),
        child: Stack(
          children: [
            // Card content
            Padding(
              padding: EdgeInsets.all(theme.spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bank name and icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.card.bank,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        widget.card.icon,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                  SizedBox(height: theme.spacing.sm),
                  Text(
                    widget.card.cardType,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // Card number
                  Text(
                    '•••• 1234',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            // Card brand indicator
            Positioned(
              bottom: theme.spacing.md,
              right: theme.spacing.md,
              child: Container(
                width: 40,
                height: 25,
                decoration: BoxDecoration(
                  color: widget.card.bank.toLowerCase().contains('infinia') 
                      ? const Color(0xFF4A5568) 
                      : const Color(0xFF2563EB),
                  borderRadius: theme.borderRadius.small,
                ),
                child: Center(
                  child: Text(
                    widget.card.bank.toLowerCase().contains('infinia') ? 'INF' : 'REG',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 8,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyCardState extends StatelessWidget {
  const _EmptyCardState({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: height,
      margin: EdgeInsets.symmetric(horizontal: theme.spacing.lg),
      padding: EdgeInsets.all(theme.spacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: theme.borderRadius.card,
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: theme.spacing.md),
          Text(
            'No Cards Added',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: theme.spacing.sm),
          Text(
            'Add your first card to get started',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
