import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';
  static const String _isUserLoggedInKey = 'is_user_logged_in';
  static const String _userEmailKey = 'user_email';
  static const String _rememberMeKey = 'remember_me';

  // Check if user has seen onboarding
  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenOnboardingKey) ?? false;
  }

  // Mark onboarding as seen
  static Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenOnboardingKey, true);
  }

  // Clear onboarding preference (for testing)
  static Future<void> clearOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasSeenOnboardingKey);
  }

  // Save login state
  static Future<void> saveLoginState({
    required bool isLoggedIn,
    required bool rememberMe,
    String? userEmail,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isUserLoggedInKey, isLoggedIn);
    await prefs.setBool(_rememberMeKey, rememberMe);
    if (userEmail != null) {
      await prefs.setString(_userEmailKey, userEmail);
    }
  }

  // Check if user should remain logged in
  static Future<bool> shouldStayLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isUserLoggedInKey) ?? false;
    final rememberMe = prefs.getBool(_rememberMeKey) ?? false;
    return isLoggedIn && rememberMe;
  }

  // Get saved email
  static Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // Check remember me preference
  static Future<bool> getRememberMePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  // Clear login state (for logout)
  static Future<void> clearLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isUserLoggedInKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_rememberMeKey);
  }

  // Clear all preferences (for app reset)
  static Future<void> clearAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
