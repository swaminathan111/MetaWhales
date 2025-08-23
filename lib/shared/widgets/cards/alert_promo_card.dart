import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Alert and promotional card widget with micro-interactions
class AlertPromoCard extends StatefulWidget {
  const AlertPromoCard({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    this.onTap,
    this.onDismiss,
    this.showDismiss = true,
  });

  final AlertType type;
  final String title;
  final String message;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final bool showDismiss;

  @override
  State<AlertPromoCard> createState() => _AlertPromoCardState();
}

class _AlertPromoCardState extends State<AlertPromoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isHovered = true);
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isHovered = false);
    _animationController.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    setState(() => _isHovered = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = _getTypeConfig(widget.type, theme);
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: widget.onTap != null ? _handleTapDown : null,
            onTapUp: widget.onTap != null ? _handleTapUp : null,
            onTapCancel: widget.onTap != null ? _handleTapCancel : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(theme.spacing.md + theme.spacing.xs),
              decoration: BoxDecoration(
                color: config.backgroundColor,
                borderRadius: theme.borderRadius.card,
                border: Border.all(
                  color: _isHovered 
                      ? config.borderColor.withOpacity(0.8)
                      : config.borderColor,
                  width: _isHovered ? 2 : 1,
                ),
                boxShadow: [
                  if (widget.type == AlertType.promoted || _isHovered) 
                    ...theme.shadows.card,
                  if (_isHovered)
                    BoxShadow(
                      color: config.iconColor.withOpacity(0.1),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                ],
              ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                config.icon,
                color: config.iconColor,
                size: 20,
              ),
              SizedBox(width: theme.spacing.md - theme.spacing.xs),
              Expanded(
                child: Text(
                  widget.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: config.titleColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (widget.type == AlertType.promoted) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: theme.spacing.sm,
                    vertical: theme.spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface,
                    borderRadius: theme.borderRadius.small,
                  ),
                  child: Text(
                    'PROMOTED',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.surface,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
              if (widget.showDismiss && widget.onDismiss != null) ...[
                SizedBox(width: theme.spacing.sm),
                GestureDetector(
                  onTap: widget.onDismiss,
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: config.iconColor,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: theme.spacing.sm),
          Text(
            widget.message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: config.messageColor,
              height: 1.4,
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

  _AlertConfig _getTypeConfig(AlertType type, ThemeData theme) {
    switch (type) {
      case AlertType.info:
        return _AlertConfig(
          backgroundColor: theme.colorScheme.secondaryContainer,
          borderColor: theme.colorScheme.secondary.withOpacity(0.3),
          icon: Icons.info_outline,
          iconColor: theme.colorScheme.secondary,
          titleColor: theme.colorScheme.onSecondaryContainer,
          messageColor: theme.colorScheme.onSecondaryContainer,
        );
      case AlertType.warning:
        return _AlertConfig(
          backgroundColor: Colors.orange.shade50,
          borderColor: Colors.orange.shade200,
          icon: Icons.warning_outlined,
          iconColor: Colors.orange.shade600,
          titleColor: Colors.orange.shade800,
          messageColor: Colors.orange.shade700,
        );
      case AlertType.success:
        return _AlertConfig(
          backgroundColor: Colors.green.shade50,
          borderColor: Colors.green.shade200,
          icon: Icons.check_circle_outline,
          iconColor: Colors.green.shade600,
          titleColor: Colors.green.shade800,
          messageColor: Colors.green.shade700,
        );
      case AlertType.error:
        return _AlertConfig(
          backgroundColor: theme.colorScheme.errorContainer,
          borderColor: theme.colorScheme.error.withOpacity(0.3),
          icon: Icons.error_outline,
          iconColor: theme.colorScheme.error,
          titleColor: theme.colorScheme.onErrorContainer,
          messageColor: theme.colorScheme.onErrorContainer,
        );
      case AlertType.notification:
        return _AlertConfig(
          backgroundColor: Colors.orange.shade50,
          borderColor: Colors.orange.shade200,
          icon: Icons.notifications,
          iconColor: Colors.orange.shade600,
          titleColor: theme.colorScheme.onSurface,
          messageColor: theme.colorScheme.onSurfaceVariant,
        );
      case AlertType.promoted:
        return _AlertConfig(
          backgroundColor: theme.colorScheme.surface,
          borderColor: theme.colorScheme.outlineVariant,
          icon: Icons.star_outline,
          iconColor: theme.colorScheme.primary,
          titleColor: theme.colorScheme.onSurface,
          messageColor: theme.colorScheme.onSurfaceVariant,
        );
    }
  }
}

class _AlertConfig {
  const _AlertConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.icon,
    required this.iconColor,
    required this.titleColor,
    required this.messageColor,
  });

  final Color backgroundColor;
  final Color borderColor;
  final IconData icon;
  final Color iconColor;
  final Color titleColor;
  final Color messageColor;
}

enum AlertType {
  info,
  warning,
  success,
  error,
  notification,
  promoted,
}

// Predefined alert configurations
class AlertConfig {
  static const AlertPromoCard newLoungeAccess = AlertPromoCard(
    type: AlertType.notification,
    title: 'New lounge access update for Regalia',
    message: 'Your card now has access to 3 additional airport lounges.',
  );

  static const AlertPromoCard promotedOffer = AlertPromoCard(
    type: AlertType.promoted,
    title: 'Get 5% back on Amazon',
    message: 'Use your ICICI Amazon Pay card for your next purchase to unlock this offer.',
  );

  static const AlertPromoCard paymentDue = AlertPromoCard(
    type: AlertType.warning,
    title: 'Payment Due Soon',
    message: 'Your HDFC Regalia payment of ₹15,000 is due in 3 days.',
  );

  static const AlertPromoCard rewardUpdate = AlertPromoCard(
    type: AlertType.success,
    title: 'Rewards Credited',
    message: 'You earned 2,500 reward points from your recent transactions.',
  );
}
