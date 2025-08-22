import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Quick action chips for home screen actions
class QuickActionChips extends StatelessWidget {
  const QuickActionChips({
    super.key,
    required this.actions,
    required this.onActionTap,
  });

  final List<QuickAction> actions;
  final Function(String actionId) onActionTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: actions.asMap().entries.map((entry) {
        final index = entry.key;
        final action = entry.value;
        
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index < actions.length - 1 ? theme.spacing.md - theme.spacing.xs : 0,
            ),
            child: _ActionChip(
              action: action,
              onTap: () => onActionTap(action.id),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.action,
    required this.onTap,
  });

  final QuickAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: theme.spacing.md - theme.spacing.xs,
          horizontal: theme.spacing.md,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: theme.borderRadius.button,
        ),
        child: Text(
          action.title,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class QuickAction {
  const QuickAction({
    required this.id,
    required this.title,
    this.icon,
  });

  final String id;
  final String title;
  final IconData? icon;

  // Predefined actions
  static const QuickAction compareCards = QuickAction(
    id: 'compare_cards',
    title: 'Compare Cards',
    icon: Icons.compare_arrows,
  );

  static const QuickAction planPurchase = QuickAction(
    id: 'plan_purchase',
    title: 'Plan a Purchase',
    icon: Icons.shopping_cart,
  );

  static const QuickAction seeTravel = QuickAction(
    id: 'see_travel',
    title: 'See Travel',
    icon: Icons.flight,
  );

  static const QuickAction addCard = QuickAction(
    id: 'add_card',
    title: 'Add Card',
    icon: Icons.add_card,
  );

  static const List<QuickAction> defaultActions = [
    compareCards,
    planPurchase,
    seeTravel,
  ];
}
