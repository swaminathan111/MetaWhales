import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../theme/app_theme.dart';
import '../../../features/chat/widgets/chat_overlay_helper.dart';

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
  
  static final Logger _logger = Logger();

  static const List<NavigationItem> _items = [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
      route: '/',
    ),
    NavigationItem(
      icon: Icons.credit_card_outlined,
      activeIcon: Icons.credit_card,
      label: 'My Cards',
      route: '/cards',
    ),
    NavigationItem(
      icon: Icons.notifications_outlined,
      activeIcon: Icons.notifications,
      label: 'Alerts',
      route: '/alerts',
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
    
    return SizedBox(
      height: 90,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Custom shaped bottom navigation bar with curved cutout
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 90),
            painter: BottomNavBarPainter(),
          ),
          // Navigation items
          Positioned.fill(
            child: SafeArea(
              child: Row(
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
            ),
          ),
          // Center CTA Button - positioned above the navigation bar
          Positioned(
            top: -30,
            left: MediaQuery.of(context).size.width / 2 - 40,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onCTATap ?? () async {
                  _logger.d('CTA button tapped - opening chat overlay');
                  try {
                    await ChatOverlayHelper.showFullScreenChat(context);
                    _logger.d('Chat overlay completed successfully');
                  } catch (e) {
                    _logger.e('Error opening chat overlay: $e');
                    // Show error dialog for debugging
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Debug Info'),
                        content: Text('Error: $e'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(40),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
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

/// Custom painter for bottom navigation bar with curved cutout
class BottomNavBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final path = Path();
    final shadowPath = Path();

    // Define the curved cutout dimensions
    const double cutoutRadius = 40.0;
    const double cutoutMargin = 20.0;
    final double centerX = size.width / 2;

    // Start from bottom left
    path.moveTo(0, size.height);
    shadowPath.moveTo(0, size.height);

    // Left side up to cutout
    path.lineTo(0, 0);
    path.lineTo(centerX - cutoutRadius - cutoutMargin, 0);
    shadowPath.lineTo(0, -2);
    shadowPath.lineTo(centerX - cutoutRadius - cutoutMargin, -2);

    // Create the curved cutout
    path.quadraticBezierTo(
      centerX - cutoutRadius, 0,
      centerX - cutoutRadius, cutoutRadius * 0.6,
    );
    path.arcToPoint(
      Offset(centerX + cutoutRadius, cutoutRadius * 0.6),
      radius: const Radius.circular(cutoutRadius),
      clockwise: false,
    );
    path.quadraticBezierTo(
      centerX + cutoutRadius, 0,
      centerX + cutoutRadius + cutoutMargin, 0,
    );

    // Shadow path for cutout
    shadowPath.quadraticBezierTo(
      centerX - cutoutRadius, -2,
      centerX - cutoutRadius, cutoutRadius * 0.6,
    );
    shadowPath.arcToPoint(
      Offset(centerX + cutoutRadius, cutoutRadius * 0.6),
      radius: const Radius.circular(cutoutRadius),
      clockwise: false,
    );
    shadowPath.quadraticBezierTo(
      centerX + cutoutRadius, -2,
      centerX + cutoutRadius + cutoutMargin, -2,
    );

    // Right side
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    shadowPath.lineTo(size.width, -2);
    shadowPath.lineTo(size.width, size.height);

    // Close the path
    path.close();
    shadowPath.close();

    // Draw shadow first
    canvas.drawPath(shadowPath, shadowPaint);
    
    // Draw the main navigation bar
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
