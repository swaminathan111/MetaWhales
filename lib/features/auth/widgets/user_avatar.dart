import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/profile_service.dart';

class UserAvatar extends ConsumerWidget {
  final double size;
  final bool showBorder;
  final Color? borderColor;

  const UserAvatar({
    super.key,
    this.size = 40,
    this.showBorder = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return profileAsync.when(
      data: (profile) {
        final avatarUrl = profile?['avatar_url'] as String?;
        final fullName = profile?['full_name'] as String? ?? 'User';

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: showBorder
                ? Border.all(
                    color: borderColor ?? Theme.of(context).primaryColor,
                    width: 2,
                  )
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size / 2),
            child: avatarUrl != null && avatarUrl.isNotEmpty
                ? Image.network(
                    avatarUrl,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultAvatar(fullName);
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _buildLoadingAvatar();
                    },
                  )
                : _buildDefaultAvatar(fullName),
          ),
        );
      },
      loading: () => _buildLoadingAvatar(),
      error: (error, stackTrace) => _buildDefaultAvatar('User'),
    );
  }

  Widget _buildDefaultAvatar(String fullName) {
    final initials = _getInitials(fullName);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade300,
            Colors.blue.shade600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingAvatar() {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey,
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.5,
          height: size * 0.5,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }

  String _getInitials(String fullName) {
    final names = fullName.trim().split(' ');
    if (names.isEmpty) return 'U';

    if (names.length == 1) {
      return names[0].isNotEmpty ? names[0][0].toUpperCase() : 'U';
    }

    return (names[0][0] + names[names.length - 1][0]).toUpperCase();
  }
}
