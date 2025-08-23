import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// CTA button row for AI response actions
class CTAButtonRow extends StatelessWidget {
  const CTAButtonRow({
    super.key,
    required this.actions,
    required this.onActionTap,
  });

  final List<CTAAction> actions;
  final Function(CTAAction action) onActionTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (actions.isEmpty) return const SizedBox.shrink();
    
    // Split actions into 2 rows
    final midPoint = (actions.length / 2).ceil();
    final firstRow = actions.take(midPoint).toList();
    final secondRow = actions.skip(midPoint).toList();
    
    return Padding(
      padding: EdgeInsets.only(top: theme.spacing.md),
      child: Column(
        children: [
          // First row - horizontally scrollable
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: firstRow.map((action) {
                return Padding(
                  padding: EdgeInsets.only(right: theme.spacing.sm),
                  child: _CTAButton(
                    action: action,
                    onTap: () => onActionTap(action),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Spacing between rows
          if (secondRow.isNotEmpty) SizedBox(height: theme.spacing.sm),
          
          // Second row - horizontally scrollable
          if (secondRow.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: secondRow.map((action) {
                  return Padding(
                    padding: EdgeInsets.only(right: theme.spacing.sm),
                    child: _CTAButton(
                      action: action,
                      onTap: () => onActionTap(action),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _CTAButton extends StatefulWidget {
  const _CTAButton({
    required this.action,
    required this.onTap,
  });

  final CTAAction action;
  final VoidCallback onTap;

  @override
  State<_CTAButton> createState() => _CTAButtonState();
}

class _CTAButtonState extends State<_CTAButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: theme.spacing.md,
                vertical: theme.spacing.sm,
              ),
              decoration: BoxDecoration(
                color: widget.action.isPrimary 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.surfaceContainerHigh,
                borderRadius: theme.borderRadius.medium,
                border: widget.action.isPrimary 
                    ? null 
                    : Border.all(
                        color: _isPressed 
                            ? theme.colorScheme.primary.withOpacity(0.5)
                            : theme.colorScheme.outline,
                        width: _isPressed ? 2 : 1,
                      ),
                boxShadow: [
                  if (widget.action.isPrimary || _isPressed)
                    BoxShadow(
                      color: (widget.action.isPrimary 
                          ? theme.colorScheme.primary 
                          : theme.colorScheme.outline).withOpacity(0.2),
                      blurRadius: _isPressed ? 12 : 8,
                      spreadRadius: _isPressed ? 2 : 0,
                      offset: Offset(0, _isPressed ? 4 : 2),
                    ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.action.icon != null) ...[
                    Icon(
                      widget.action.icon,
                      size: 16,
                      color: widget.action.isPrimary 
                          ? theme.colorScheme.onPrimary 
                          : theme.colorScheme.onSurface,
                    ),
                    SizedBox(width: theme.spacing.xs),
                  ],
                  Text(
                    widget.action.title,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: widget.action.isPrimary 
                          ? theme.colorScheme.onPrimary 
                          : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
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

class CTAAction {
  const CTAAction({
    required this.id,
    required this.title,
    this.icon,
    this.isPrimary = false,
    this.data,
  });

  final String id;
  final String title;
  final IconData? icon;
  final bool isPrimary;
  final Map<String, dynamic>? data;

  // Predefined CTA actions
  static const CTAAction compareCards = CTAAction(
    id: 'compare_cards',
    title: 'Compare Cards',
    icon: Icons.compare_arrows,
    isPrimary: true,
  );

  static const CTAAction applyNow = CTAAction(
    id: 'apply_now',
    title: 'Apply Now',
    icon: Icons.open_in_new,
    isPrimary: true,
  );

  static const CTAAction learnMore = CTAAction(
    id: 'learn_more',
    title: 'Learn More',
    icon: Icons.info_outline,
    isPrimary: false,
  );

  static const CTAAction viewDetails = CTAAction(
    id: 'view_details',
    title: 'View Details',
    icon: Icons.visibility,
    isPrimary: false,
  );

  static const CTAAction addToWallet = CTAAction(
    id: 'add_to_wallet',
    title: 'Add to Wallet',
    icon: Icons.account_balance_wallet,
    isPrimary: false,
  );
}
