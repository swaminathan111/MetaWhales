import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Custom bottom navigation bar with elevated center CTA button
class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onCTATap,
  });

  final int currentIndex;
  final Function(int index, String route) onTap;
  final VoidCallback? onCTATap;

  static const List<NavigationItem> _items = [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
      route: '/',
    ),
    NavigationItem(
      icon: Icons.notifications_outlined,
      activeIcon: Icons.notifications,
      label: 'Alerts',
      route: '/alerts',
    ),
    NavigationItem(
      icon: Icons.credit_card_outlined,
      activeIcon: Icons.credit_card,
      label: 'My Cards',
      route: '/cards',
    ),
    NavigationItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
      route: '/profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Stack(
          children: [
            // Main navigation items
            Row(
              children: [
                // Left side items (Home, Alerts)
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _NavItem(
                        item: _items[0],
                        isActive: currentIndex == 0,
                        onTap: () => onTap(0, _items[0].route),
                      ),
                      _NavItem(
                        item: _items[1],
                        isActive: currentIndex == 1,
                        onTap: () => onTap(1, _items[1].route),
                      ),
                    ],
                  ),
                ),
                // Center space for CTA button
                const Expanded(flex: 1, child: SizedBox()),
                // Right side items (My Cards, Profile)
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _NavItem(
                        item: _items[2],
                        isActive: currentIndex == 2,
                        onTap: () => onTap(2, _items[2].route),
                      ),
                      _NavItem(
                        item: _items[3],
                        isActive: currentIndex == 3,
                        onTap: () => onTap(3, _items[3].route),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Center CTA Button
            Positioned(
              top: -15,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: onCTATap ?? () => onTap(4, '/chat'),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        // BoxShadow(
                        //   color: const Color(0xFF58D5D3).withOpacity(0.3),
                        //   blurRadius: 20,
                        //   offset: const Offset(0, 8),
                        //   spreadRadius: 0,
                        // ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/icons/cta_agent_circle.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
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
    const tealColor = Color(0xFF58D5D3);
    const grayColor = Color(0xFF9E9E9E);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? item.activeIcon : item.icon,
              color: isActive ? tealColor : grayColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? tealColor : grayColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationItem {
  const NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
}
