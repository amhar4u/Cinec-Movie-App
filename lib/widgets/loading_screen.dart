import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../constants/app_constants.dart';
import '../utils/responsive_utils.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isLandscape = ResponsiveUtils.isLandscape(context);
    final isSmallScreen = ResponsiveUtils.isSmallScreen(context);
    final needsCompactLayout = isLandscape || isSmallScreen;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: OrientationBuilder(
            builder: (context, orientation) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: needsCompactLayout
                    ? _buildLandscapeLayout(context, theme, size)
                    : _buildPortraitLayout(context, theme, size),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context, ThemeData theme, Size size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // App Logo
        FadeInDown(
          duration: const Duration(milliseconds: 800),
          child: _buildLogo(context, theme, size),
        ),
        
        SizedBox(height: ResponsiveUtils.getSpacing(context,
          mobile: 32, tablet: 40, desktop: 48)),
        
        // App Name
        FadeInUp(
          duration: const Duration(milliseconds: 800),
          delay: const Duration(milliseconds: 200),
          child: _buildAppName(context, theme),
        ),
        
        SizedBox(height: ResponsiveUtils.getSpacing(context,
          mobile: 16, tablet: 20, desktop: 24)),
        
        // Tagline
        FadeInUp(
          duration: const Duration(milliseconds: 800),
          delay: const Duration(milliseconds: 400),
          child: _buildTagline(context, theme),
        ),
        
        SizedBox(height: ResponsiveUtils.getSpacing(context,
          mobile: 48, tablet: 60, desktop: 72)),
        
        // Loading Indicator
        FadeIn(
          duration: const Duration(milliseconds: 800),
          delay: const Duration(milliseconds: 600),
          child: _buildLoadingIndicator(),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, ThemeData theme, Size size) {
    return Row(
      children: [
        // Left side - Logo
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInDown(
                duration: const Duration(milliseconds: 800),
                child: _buildLogo(context, theme, size, isCompact: true),
              ),
            ],
          ),
        ),
        
        // Right side - Text and Loading
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Name
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 200),
                child: _buildAppName(context, theme, isCompact: true),
              ),
              
              SizedBox(height: ResponsiveUtils.getSpacing(context,
                mobile: 12, tablet: 16, desktop: 20)),
              
              // Tagline
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 400),
                child: _buildTagline(context, theme, isCompact: true),
              ),
              
              SizedBox(height: ResponsiveUtils.getSpacing(context,
                mobile: 24, tablet: 30, desktop: 36)),
              
              // Loading Indicator
              FadeIn(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 600),
                child: _buildLoadingIndicator(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogo(BuildContext context, ThemeData theme, Size size, {bool isCompact = false}) {
    final logoSize = ResponsiveUtils.getCompactImageSize(context,
      mobile: size.width * (isCompact ? 0.15 : 0.25),
      tablet: size.width * (isCompact ? 0.12 : 0.2),
      desktop: isCompact ? 80 : 120,
    );

    return AppLogo(
      size: logoSize,
      primaryColor: Colors.white,
      secondaryColor: Colors.white.withValues(alpha: 0.8),
    );
  }

  Widget _buildAppName(BuildContext context, ThemeData theme, {bool isCompact = false}) {
    return Text(
      AppConstants.appName,
      style: theme.textTheme.headlineLarge?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: ResponsiveUtils.getCompactFontSize(context,
          mobile: isCompact ? 28 : 32,
          tablet: isCompact ? 32 : 36,
          desktop: isCompact ? 36 : 40,
        ),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildTagline(BuildContext context, ThemeData theme, {bool isCompact = false}) {
    return Text(
      'Your Gateway to Cinema',
      style: theme.textTheme.bodyLarge?.copyWith(
        color: Colors.white.withValues(alpha: 0.9),
        fontSize: ResponsiveUtils.getCompactFontSize(context,
          mobile: isCompact ? 14 : 16,
          tablet: isCompact ? 16 : 18,
          desktop: isCompact ? 18 : 20,
        ),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLoadingIndicator() {
    return const CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      strokeWidth: 3,
    );
  }
}
