import 'package:flutter/material.dart';

class ResponsiveUtils {
  // Screen size breakpoints
  static const double mobileMaxWidth = 768;
  static const double tabletMaxWidth = 1024;
  static const double desktopMinWidth = 1024;
  
  // Check if device is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileMaxWidth;
  }
  
  // Check if device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileMaxWidth && width < tabletMaxWidth;
  }
  
  // Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopMinWidth;
  }
  
  // Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
  
  // Check if device is in portrait mode
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }
  
  // Get screen dimensions
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }
  
  // Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }
  
  // Get keyboard height
  static double getKeyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }
  
  // Get responsive width
  static double getWidth(BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isMobile(context)) {
      return mobile ?? MediaQuery.of(context).size.width;
    } else if (isTablet(context)) {
      return tablet ?? mobile ?? MediaQuery.of(context).size.width;
    } else {
      return desktop ?? tablet ?? mobile ?? MediaQuery.of(context).size.width;
    }
  }
  
  // Get responsive height
  static double getHeight(BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isMobile(context)) {
      return mobile ?? MediaQuery.of(context).size.height;
    } else if (isTablet(context)) {
      return tablet ?? mobile ?? MediaQuery.of(context).size.height;
    } else {
      return desktop ?? tablet ?? mobile ?? MediaQuery.of(context).size.height;
    }
  }
  
  // Get responsive padding
  static EdgeInsets getPadding(BuildContext context, {
    EdgeInsets? mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    if (isMobile(context)) {
      return mobile ?? const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return tablet ?? mobile ?? const EdgeInsets.all(24);
    } else {
      return desktop ?? tablet ?? mobile ?? const EdgeInsets.all(32);
    }
  }
  
  // Get responsive font size
  static double getFontSize(BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isMobile(context)) {
      return mobile ?? 14;
    } else if (isTablet(context)) {
      return tablet ?? mobile ?? 16;
    } else {
      return desktop ?? tablet ?? mobile ?? 18;
    }
  }
  
  // Get responsive spacing
  static double getSpacing(BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isMobile(context)) {
      return mobile ?? 16;
    } else if (isTablet(context)) {
      return tablet ?? mobile ?? 20;
    } else {
      return desktop ?? tablet ?? mobile ?? 24;
    }
  }
  
  // Get responsive container width for centering content
  static double getContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isDesktop(context)) {
      return screenWidth > 1200 ? 800 : screenWidth * 0.7;
    } else if (isTablet(context)) {
      return screenWidth * 0.8;
    } else {
      return screenWidth;
    }
  }
  
  // Get responsive image size
  static double getImageSize(BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isMobile(context)) {
      return mobile ?? screenWidth * 0.6;
    } else if (isTablet(context)) {
      return tablet ?? mobile ?? screenWidth * 0.4;
    } else {
      return desktop ?? tablet ?? mobile ?? 300;
    }
  }
  
  // Get responsive columns for grid
  static int getGridColumns(BuildContext context) {
    if (isDesktop(context)) {
      return 4;
    } else if (isTablet(context)) {
      return 3;
    } else {
      return 2;
    }
  }
  
  // Get orientation-aware height
  static double getOrientationHeight(BuildContext context, {
    double portraitFactor = 0.4,
    double landscapeFactor = 0.6,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    return isLandscape(context) 
        ? screenHeight * landscapeFactor 
        : screenHeight * portraitFactor;
  }
  
  // Get adaptive bottom padding (considering keyboard)
  static double getBottomPadding(BuildContext context) {
    final keyboardHeight = getKeyboardHeight(context);
    final defaultPadding = getSpacing(context);
    return keyboardHeight > 0 ? keyboardHeight + defaultPadding : defaultPadding;
  }
  
  // Check if screen is small (for compact layouts)
  static bool isSmallScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width < 360 || size.height < 640;
  }
  
  // Check if screen is very small (for ultra-compact layouts)
  static bool isVerySmallScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width < 320 || size.height < 568;
  }

  // Check if we need compact layout (landscape on mobile or very small screen)
  static bool needsCompactLayout(BuildContext context) {
    return (isMobile(context) && isLandscape(context)) || 
           isVerySmallScreen(context) || 
           isSmallScreen(context);
  }

  // Get adaptive spacing for compact layouts
  static double getCompactSpacing(BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final baseSpacing = getSpacing(context, 
      mobile: mobile, tablet: tablet, desktop: desktop);
    return needsCompactLayout(context) ? baseSpacing * 0.7 : baseSpacing;
  }

  // Get adaptive font size for compact layouts
  static double getCompactFontSize(BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final baseFontSize = getFontSize(context, 
      mobile: mobile, tablet: tablet, desktop: desktop);
    return needsCompactLayout(context) ? baseFontSize * 0.9 : baseFontSize;
  }

  // Get adaptive image size for compact layouts
  static double getCompactImageSize(BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final baseImageSize = getImageSize(context, 
      mobile: mobile, tablet: tablet, desktop: desktop);
    return needsCompactLayout(context) ? baseImageSize * 0.8 : baseImageSize;
  }

  // Get minimum height for scrollable containers
  static double getMinScrollHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaPadding = MediaQuery.of(context).padding.vertical;
    final appBarHeight = kToolbarHeight;
    return screenHeight - safeAreaPadding - appBarHeight - 32; // 32 for padding
  }

  // Get orientation-aware spacing that's more compact in landscape
  static double getOrientationSpacing(BuildContext context, {
    double portraitFactor = 1.0,
    double landscapeFactor = 0.6,
  }) {
    final baseSpacing = getSpacing(context);
    return isLandscape(context) 
        ? baseSpacing * landscapeFactor 
        : baseSpacing * portraitFactor;
  }

  // Get orientation-aware padding that's more compact in landscape
  static EdgeInsets getOrientationPadding(BuildContext context, {
    double portraitFactor = 1.0,
    double landscapeFactor = 0.7,
  }) {
    final basePadding = getPadding(context);
    return isLandscape(context) 
        ? basePadding * landscapeFactor 
        : basePadding * portraitFactor;
  }

  // Get safe minimum height for content in landscape
  static double getSafeLandscapeHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaPadding = MediaQuery.of(context).padding.vertical;
    // Reserve space for navigation bar and some padding
    return (screenHeight - safeAreaPadding) * 0.85;
  }
}
