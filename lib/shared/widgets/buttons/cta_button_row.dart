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

class _CTAButton extends StatelessWidget {
  const _CTAButton({
    required this.action,
    required this.onTap,
  });

  final CTAAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.md,
          vertical: theme.spacing.sm,
        ),
        decoration: BoxDecoration(
          color: action.isPrimary 
              ? theme.colorScheme.primary 
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: theme.borderRadius.medium,
          border: action.isPrimary 
              ? null 
              : Border.all(
                  color: theme.colorScheme.outline,
                  width: 1,
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (action.icon != null) ...[
              Icon(
                action.icon,
                size: 16,
                color: action.isPrimary 
                    ? theme.colorScheme.onPrimary 
                    : theme.colorScheme.onSurface,
              ),
              SizedBox(width: theme.spacing.xs),
            ],
            Text(
              action.title,
              style: theme.textTheme.labelMedium?.copyWith(
                color: action.isPrimary 
                    ? theme.colorScheme.onPrimary 
                    : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
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
