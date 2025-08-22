import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Reusable bottom navigation bar for CardSense app
class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final Function(int index, String route) onTap;

  static const List<NavigationItem> _items = [
    NavigationItem(
      icon: Icons.home,
      label: 'Home',
      route: '/',
    ),
    NavigationItem(
      icon: Icons.notifications_outlined,
      label: 'Alerts',
      route: '/alerts',
    ),
    NavigationItem(
      icon: Icons.credit_card_outlined,
      label: 'My Cards',
      route: '/cards',
    ),
    NavigationItem(
      icon: Icons.person_outline,
      label: 'Profile',
      route: '/profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: theme.shadows.bottomNav,
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isActive = index == currentIndex;
            
            return _NavItem(
              item: item,
              isActive: isActive,
              onTap: () => onTap(index, item.route),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final NavigationItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            item.icon,
            color: isActive 
                ? theme.colorScheme.primary 
                : theme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          SizedBox(height: theme.spacing.xs),
          Text(
            item.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isActive 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class NavigationItem {
  const NavigationItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;
}
