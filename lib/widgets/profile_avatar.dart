import 'package:flutter/material.dart';
import '../models/user_model.dart';

class ProfileAvatar extends StatelessWidget {
  final UserModel? userModel;
  final double radius;
  final bool showOnlineIndicator;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    this.userModel,
    this.radius = 24,
    this.showOnlineIndicator = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundColor: _getBackgroundColor(theme),
      child: userModel?.profilePictureUrl != null
          ? ClipOval(
              child: Image.network(
                userModel!.profilePictureUrl!,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildInitialAvatar(theme);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildInitialAvatar(theme);
                },
              ),
            )
          : _buildInitialAvatar(theme),
    );

    if (showOnlineIndicator) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: radius * 0.4,
              height: radius * 0.4,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.surface,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _buildInitialAvatar(ThemeData theme) {
    final initial = _getInitial();
    final colors = _getAvatarColors();
    
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontSize: radius * 0.6,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _getInitial() {
    if (userModel?.name.isNotEmpty == true) {
      return userModel!.name[0].toUpperCase();
    }
    return 'U';
  }

  Color _getBackgroundColor(ThemeData theme) {
    return theme.colorScheme.primary.withOpacity(0.1);
  }

  List<Color> _getAvatarColors() {
    // Generate colors based on the user's initial
    final initial = _getInitial();
    final colorIndex = initial.codeUnitAt(0) % _avatarColors.length;
    return _avatarColors[colorIndex];
  }

  static const List<List<Color>> _avatarColors = [
    [Color(0xFF6C5CE7), Color(0xFFA29BFE)], // Purple
    [Color(0xFF00B894), Color(0xFF00CEC9)], // Teal
    [Color(0xFFE17055), Color(0xFFE84393)], // Orange-Pink
    [Color(0xFF0984E3), Color(0xFF74B9FF)], // Blue
    [Color(0xFFE84393), Color(0xFFFD79A8)], // Pink
    [Color(0xFF00B894), Color(0xFF55EFC4)], // Green
    [Color(0xFFE17055), Color(0xFFFFAB91)], // Orange
    [Color(0xFF6C5CE7), Color(0xFF9980FA)], // Violet
    [Color(0xFF00CEC9), Color(0xFF81ECEC)], // Cyan
    [Color(0xFFFFB74D), Color(0xFFFFCC02)], // Yellow
  ];
}

// Utility widget for displaying user info with avatar
class UserInfoTile extends StatelessWidget {
  final UserModel userModel;
  final VoidCallback? onTap;
  final bool showRole;
  final bool showOnlineIndicator;

  const UserInfoTile({
    super.key,
    required this.userModel,
    this.onTap,
    this.showRole = true,
    this.showOnlineIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: ProfileAvatar(
        userModel: userModel,
        radius: 24,
        showOnlineIndicator: showOnlineIndicator,
      ),
      title: Text(
        userModel.name,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(userModel.email),
          if (showRole) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: userModel.role == UserRole.admin
                    ? theme.colorScheme.error.withOpacity(0.1)
                    : theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: userModel.role == UserRole.admin
                      ? theme.colorScheme.error.withOpacity(0.3)
                      : theme.colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Text(
                userModel.role.toString().split('.').last.toUpperCase(),
                style: TextStyle(
                  color: userModel.role == UserRole.admin
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }
}
