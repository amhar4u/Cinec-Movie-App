class AppConstants {
  // App Info
  static const String appName = 'Cinec';
  static const String appVersion = '1.0.0';
  
  // Animation Durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // Onboarding
  static const List<Map<String, String>> onboardingData = [
    {
      'title': 'Discover Movies',
      'description': 'Explore thousands of movies and find your next favorite film',
      'image': '🎬',
    },
    {
      'title': 'Book Tickets',
      'description': 'Reserve your seats with just a few taps and skip the lines',
      'image': '🎫',
    },
    {
      'title': 'Enjoy Experience',
      'description': 'Get the best cinema experience with premium sound and picture',
      'image': '🍿',
    },
  ];
  
  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
}
