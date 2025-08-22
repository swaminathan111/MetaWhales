import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Reusable gradient header with greeting and insight card
class GradientHeader extends StatelessWidget {
  const GradientHeader({
    super.key,
    required this.userName,
    required this.insightText,
    this.onProfileTap,
    this.onActionTap,
    this.showActions = true,
  });

  final String userName;
  final String insightText;
  final VoidCallback? onProfileTap;
  final VoidCallback? onActionTap;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(theme.borderRadius.large.topLeft.x),
          bottomRight: Radius.circular(theme.borderRadius.large.topRight.x),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          theme.spacing.lg,
          theme.spacing.lg,
          theme.spacing.lg,
          theme.spacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row with profile and actions
            if (showActions) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: onProfileTap,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.onPrimary,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.person,
                        color: theme.colorScheme.onPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.credit_card,
                          color: theme.colorScheme.onPrimary,
                        ),
                        tooltip: 'Manage Cards',
                        onPressed: onActionTap,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.logout,
                          color: theme.colorScheme.onPrimary,
                        ),
                        onPressed: onActionTap,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: theme.spacing.xs),
            ],
            
            // Greeting
            Text(
              _getGreeting() + ', ${userName.split(' ')[0].split('.')[0]} 👋',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w400,
              ),
            ),
            
            SizedBox(height: theme.spacing.xs),
            
            // Insight card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(theme.spacing.md + theme.spacing.xs),
              decoration: BoxDecoration(
                color: theme.colorScheme.onPrimary.withOpacity(0.2),
                borderRadius: theme.borderRadius.card,
                border: Border.all(
                  color: theme.colorScheme.onPrimary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                insightText,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}
