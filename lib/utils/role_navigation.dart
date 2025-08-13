import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../screens/user/main_user_screen.dart';
import '../screens/admin/admin_home_screen.dart';
import '../screens/auth/welcome_screen.dart';

class RoleBasedNavigation {
  /// Navigate to appropriate home screen based on user role
  static Widget getHomeScreenForRole(UserRole? role) {
    switch (role) {
      case UserRole.user:
        return const MainUserScreen();
      case UserRole.admin:
        return const AdminHomeScreen();
      default:
        return const WelcomeScreen(); // Fallback if role is null
    }
  }

  /// Navigate to home screen based on user role with replacement
  static void navigateToRoleBasedHome(BuildContext context, UserRole? role) {
    Widget homeScreen = getHomeScreenForRole(role);
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => homeScreen),
    );
  }

  /// Navigate to home screen and clear all previous routes
  static void navigateToRoleBasedHomeAndClearStack(BuildContext context, UserRole? role) {
    Widget homeScreen = getHomeScreenForRole(role);
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => homeScreen),
      (route) => false,
    );
  }

  /// Check if user has admin privileges
  static bool isAdmin(UserRole? role) {
    return role == UserRole.admin;
  }

  /// Check if user has user privileges
  static bool isUser(UserRole? role) {
    return role == UserRole.user;
  }
}
