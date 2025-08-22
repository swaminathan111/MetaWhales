import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Alert and promotional card widget for in-feed notifications
class AlertPromoCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = _getTypeConfig(type, theme);
    
    return Container(
      padding: EdgeInsets.all(theme.spacing.md + theme.spacing.xs),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: theme.borderRadius.card,
        border: Border.all(
          color: config.borderColor,
          width: 1,
        ),
        boxShadow: type == AlertType.promoted ? theme.shadows.card : null,
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
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: config.titleColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (type == AlertType.promoted) ...[
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
              if (showDismiss && onDismiss != null) ...[
                SizedBox(width: theme.spacing.sm),
                GestureDetector(
                  onTap: onDismiss,
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
          GestureDetector(
            onTap: onTap,
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: config.messageColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
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
