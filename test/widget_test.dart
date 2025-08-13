import 'package:flutter_test/flutter_test.dart';

import 'package:cinec_movie_app/providers/theme_provider.dart';
import 'package:cinec_movie_app/models/user_model.dart';

void main() {
  group('Movie App Tests', () {
    testWidgets('Theme provider should toggle themes', (WidgetTester tester) async {
      final themeProvider = ThemeProvider();
      
      // Test initial theme (should be light mode)
      expect(themeProvider.isDarkMode, false);
      
      // Toggle to dark mode
      themeProvider.toggleTheme();
      expect(themeProvider.isDarkMode, true);
      
      // Toggle back to light mode
      themeProvider.toggleTheme();
      expect(themeProvider.isDarkMode, false);
    });

    test('UserModel should create correctly', () {
      final userModel = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        name: 'Test User',
        role: UserRole.user,
        createdAt: DateTime.now(),
        isActive: true,
      );

      expect(userModel.uid, 'test-uid');
      expect(userModel.email, 'test@example.com');
      expect(userModel.name, 'Test User');
      expect(userModel.role, UserRole.user);
      expect(userModel.isActive, true);
    });

    test('UserModel should copy with updated fields', () {
      final original = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        name: 'Test User',
        role: UserRole.user,
        createdAt: DateTime.now(),
        isActive: true,
      );

      final updated = original.copyWith(
        name: 'Updated User',
        role: UserRole.admin,
        isActive: false,
      );

      expect(updated.uid, original.uid);
      expect(updated.email, original.email);
      expect(updated.name, 'Updated User');
      expect(updated.role, UserRole.admin);
      expect(updated.isActive, false);
      expect(updated.createdAt, original.createdAt);
    });

    test('UserRole enum should have correct values', () {
      expect(UserRole.values.length, 2);
      expect(UserRole.values.contains(UserRole.user), true);
      expect(UserRole.values.contains(UserRole.admin), true);
    });
  });
}
