import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth_provider.dart';
import '../services/profile_service.dart';
import '../widgets/user_avatar.dart';
import '../../../core/logging/app_logger.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () {
              // Handle menu action
            },
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) =>
            _buildProfileContent(context, ref, currentUser, profile),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading profile: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(currentUserProfileProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, WidgetRef ref, user,
      Map<String, dynamic>? profile) {
    final userName = profile?['full_name'] as String? ??
        user?.email?.split('@')[0] ??
        'User';
    final userEmail = user?.email ?? 'No email';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                const UserAvatar(
                  size: 80,
                  showBorder: false,
                ),
                const SizedBox(height: 16),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Latest Offers Section
          Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Latest Offers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // Premium Card Offer
                _buildOfferCard(
                  context,
                  'Premium Card Offer',
                  'Get 5% cashback on all purchases',
                  'View Details',
                  Colors.teal,
                  Icons.credit_card,
                ),

                const SizedBox(height: 12),

                // Travel Rewards Offer
                _buildOfferCard(
                  context,
                  'Travel Rewards',
                  'Earn 2x points on flights',
                  'View Details',
                  Colors.blue,
                  Icons.flight,
                ),

                const SizedBox(height: 12),

                // Shopping Bonus Offer
                _buildOfferCard(
                  context,
                  'Shopping Bonus',
                  'Extra 10% off at selected stores',
                  'View Details',
                  Colors.orange,
                  Icons.shopping_bag,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Profile Options
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildProfileOption(
                  context,
                  Icons.person_outline,
                  'My Profile',
                  () {
                    // Navigate to profile edit screen
                    AppLogger.info('User tapped My Profile');
                  },
                ),
                const Divider(height: 1, color: Colors.grey),
                _buildProfileOption(
                  context,
                  Icons.settings_outlined,
                  'Settings',
                  () {
                    // Navigate to settings screen
                    AppLogger.info('User tapped Settings');
                  },
                ),
                const Divider(height: 1, color: Colors.grey),
                _buildProfileOption(
                  context,
                  Icons.logout,
                  'Logout',
                  () async {
                    await _handleLogout(context, ref);
                  },
                  textColor: Colors.red,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildOfferCard(
    BuildContext context,
    String title,
    String description,
    String actionText,
    Color color,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  actionText,
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? Colors.black87,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor ?? Colors.black87,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    try {
      AppLogger.info('User initiated logout from profile screen');

      // Show confirmation dialog
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (shouldLogout == true) {
        await ref.read(authProvider.notifier).signOut();
        if (context.mounted) {
          context.go('/login');
        }
      }
    } catch (error) {
      AppLogger.error('Failed to logout from profile screen', error, null);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to logout: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
