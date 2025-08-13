# Cinec - Movie Booking App

A beautiful and modern Flutter movie booking application with attractive UI, OAuth authentication, and dark/light mode support.

## Features

- 🎬 **Attractive Onboarding**: Smooth animated onboarding experience
- 🔐 **Authentication**: Login and Sign Up with OAuth support (Google, Apple)
- 🌓 **Theme Support**: Toggle between dark and light modes
- 📱 **Responsive Design**: Works on mobile, tablet, and desktop
- 🎨 **Modern UI**: Beautiful, consistent design with smooth animations
- 🔧 **Reusable Components**: Well-structured, modular widget architecture
- 👤 **User Profile Management**: Complete edit profile functionality with image upload
- 🔑 **Password Management**: Secure password change capabilities
- ☁️ **Cloudinary Integration**: Profile picture storage and management

## 📖 Documentation

- **[Complete Implementation Guide](COMPLETE_IMPLEMENTATION_GUIDE.md)** - Comprehensive guide covering edit profile, image upload, and Cloudinary integration
- **[Firebase Setup Guide](FIREBASE_SETUP_GUIDE.md)** - Firebase configuration and setup
- **[Movie Management Guide](MOVIE_MANAGEMENT_COMPLETE.md)** - Movie CRUD operations and management

## Project Structure

```
lib/
├── constants/
│   └── app_constants.dart          # App-wide constants
├── providers/
│   └── theme_provider.dart         # Theme state management
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart       # Login page with OAuth
│   │   ├── signup_screen.dart      # Sign up page
│   │   └── welcome_screen.dart     # Welcome/landing page
│   ├── home/
│   │   └── home_screen.dart        # Main home screen
│   └── onboarding/
│       └── onboarding_screen.dart  # App onboarding flow
├── theme/
│   └── app_theme.dart              # Light and dark theme definitions
├── utils/
│   ├── navigation_utils.dart       # Navigation helpers
│   ├── responsive_utils.dart       # Responsive design utilities
│   └── validation_utils.dart       # Form validation helpers
├── widgets/
│   ├── custom_app_bar.dart         # Reusable app bar with theme toggle
│   ├── custom_button.dart          # Customizable button widget
│   ├── custom_text_field.dart      # Enhanced text input field
│   ├── loading_screen.dart         # Loading screen widget
│   └── oauth_button.dart           # OAuth provider buttons
└── main.dart                       # App entry point
```

## Dependencies

- **provider**: State management
- **google_sign_in**: Google OAuth authentication
- **sign_in_with_apple**: Apple OAuth authentication
- **smooth_page_indicator**: Onboarding page indicators
- **animate_do**: Smooth animations
- **font_awesome_flutter**: Beautiful icons
- **shared_preferences**: Local storage for theme preference

## Getting Started

1. **Clone the repository**
```bash
git clone <your-repo-url>
cd cinec_movie_app
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
flutter run
```

## Key Components

### Theme System
- **Light Theme**: Clean, modern design with blue primary colors
- **Dark Theme**: Elegant dark mode with consistent color scheme
- **Theme Toggle**: Available in app bars across the app

### Authentication Flow
1. **Onboarding**: 3-screen introduction to app features
2. **Welcome**: Landing page with create account and login options
3. **Login/Signup**: Forms with validation and OAuth options
4. **Home**: Main app interface after authentication

### Reusable Widgets

#### CustomButton
```dart
CustomButton(
  text: 'Login',
  type: ButtonType.primary,
  onPressed: () => _login(),
  isLoading: _isLoading,
)
```

#### CustomTextField
```dart
CustomTextField(
  label: 'Email',
  hint: 'Enter your email',
  prefixIcon: Icon(Icons.email),
  validator: ValidationUtils.validateEmail,
)
```

#### OAuthButton
```dart
OAuthButton(
  provider: OAuthProvider.google,
  onPressed: _signInWithGoogle,
)
```

## Customization

### Colors
Edit `lib/theme/app_theme.dart` to customize the color scheme:
```dart
static const Color primaryColor = Color(0xFF1E88E5);
static const Color secondaryColor = Color(0xFFFF6B35);
```

### Onboarding Content
Modify `lib/constants/app_constants.dart` to update onboarding screens:
```dart
static const List<Map<String, String>> onboardingData = [
  {
    'title': 'Your Title',
    'description': 'Your description',
    'image': '🎬',
  },
];
```

## TODO

- [ ] Implement actual OAuth authentication
- [ ] Add movie browsing functionality
- [ ] Create ticket booking system
- [ ] Add user profile management
- [ ] Implement search functionality
- [ ] Add movie details screens
- [ ] Create seat selection interface

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
