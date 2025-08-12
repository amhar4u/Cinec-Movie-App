// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../constants/app_constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/app_logo.dart';
import '../../utils/responsive_utils.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isLandscape = ResponsiveUtils.isLandscape(context);
    final isSmallScreen = ResponsiveUtils.isSmallScreen(context);
    final contentWidth = ResponsiveUtils.getContentWidth(context);
    final padding = ResponsiveUtils.getPadding(context);

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: SizedBox(
            width: contentWidth,
            child: Padding(
              padding: padding,
              child: isLandscape || isSmallScreen
                  ? _buildScrollableLayout(context, theme, size)
                  : _buildPortraitLayout(context, theme, size),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context, ThemeData theme, Size size) {
    return Column(
      children: [
        // Logo Section
        Expanded(
          flex: 2,
          child: _buildLogoSection(context, theme, size),
        ),
        
        // Welcome Text
        Expanded(
          flex: 1,
          child: _buildWelcomeSection(context, theme),
        ),
        
        // Action Buttons
        Expanded(
          flex: 1,
          child: _buildActionSection(context, theme),
        ),
      ],
    );
  }

  Widget _buildScrollableLayout(BuildContext context, ThemeData theme, Size size) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: size.height - MediaQuery.of(context).padding.vertical - 32,
        ),
        child: IntrinsicHeight(
          child: Column(
            children: [
              // Logo Section
              _buildLogoSection(context, theme, size, isCompact: true),
              
              SizedBox(height: ResponsiveUtils.getSpacing(context,
                mobile: 16, tablet: 20, desktop: 24)),
              
              // Welcome Text
              _buildWelcomeSection(context, theme, isCompact: true),
              
              SizedBox(height: ResponsiveUtils.getSpacing(context,
                mobile: 24, tablet: 32, desktop: 40)),
              
              // Action Buttons
              _buildActionSection(context, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection(BuildContext context, ThemeData theme, Size size, {bool isCompact = false}) {
    final logoSize = ResponsiveUtils.getImageSize(context,
      mobile: isCompact ? size.width * 0.2 : size.width * 0.25,
      tablet: isCompact ? size.width * 0.15 : size.width * 0.2,
      desktop: isCompact ? 120 : 150,
    );

    return Center(
      child: FadeInDown(
        duration: const Duration(milliseconds: 800),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: isCompact ? MainAxisSize.min : MainAxisSize.max,
          children: [
            // App Logo
            AppLogo(
              size: logoSize,
            ),
            
            SizedBox(height: ResponsiveUtils.getSpacing(context,
              mobile: isCompact ? 12 : 20, 
              tablet: isCompact ? 16 : 24, 
              desktop: isCompact ? 20 : 30)),
            
            // App Name
            Text(
              AppConstants.appName,
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                fontSize: ResponsiveUtils.getFontSize(context,
                  mobile: isCompact ? 28 : 36, 
                  tablet: isCompact ? 34 : 42, 
                  desktop: isCompact ? 40 : 48),
              ),
            ),
            
            SizedBox(height: ResponsiveUtils.getSpacing(context,
              mobile: isCompact ? 4 : 8, 
              tablet: isCompact ? 6 : 12, 
              desktop: isCompact ? 8 : 16)),
            
            // Tagline
            Text(
              'Your Gateway to Cinema',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontSize: ResponsiveUtils.getFontSize(context,
                  mobile: isCompact ? 14 : 16, 
                  tablet: isCompact ? 16 : 18, 
                  desktop: isCompact ? 18 : 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, ThemeData theme, {bool isCompact = false}) {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      delay: const Duration(milliseconds: 200),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: isCompact ? MainAxisSize.min : MainAxisSize.max,
        children: [
          Text(
            'Welcome to ${AppConstants.appName}',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtils.getFontSize(context,
                mobile: isCompact ? 20 : 24, 
                tablet: isCompact ? 24 : 28, 
                desktop: isCompact ? 28 : 32),
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: ResponsiveUtils.getSpacing(context,
            mobile: isCompact ? 8 : 12, 
            tablet: isCompact ? 12 : 16, 
            desktop: isCompact ? 16 : 20)),
          
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getSpacing(context,
                mobile: 16, tablet: 24, desktop: 32),
            ),
            child: Text(
              'Discover, book, and enjoy the best movies at your fingertips',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontSize: ResponsiveUtils.getFontSize(context,
                  mobile: isCompact ? 14 : 16, 
                  tablet: isCompact ? 16 : 18, 
                  desktop: isCompact ? 18 : 20),
              ),
              textAlign: TextAlign.center,
              maxLines: isCompact ? 2 : 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(BuildContext context, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Sign Up Button
        SlideInUp(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 400),
          child: CustomButton(
            text: 'Create Account',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignUpScreen(),
                ),
              );
            },
            width: double.infinity,
          ),
        ),
        
        SizedBox(height: ResponsiveUtils.getSpacing(context,
          mobile: 12, tablet: 16, desktop: 20)),
        
        // Login Button
        SlideInUp(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 500),
          child: CustomButton(
            text: 'Login',
            type: ButtonType.outline,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
            width: double.infinity,
          ),
        ),
        
        SizedBox(height: ResponsiveUtils.getSpacing(context,
          mobile: 16, tablet: 20, desktop: 24)),
        
        // Terms and Privacy
        FadeIn(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 600),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getSpacing(context,
                mobile: 8, tablet: 16, desktop: 24),
            ),
            child: Text.rich(
              TextSpan(
                text: 'By continuing, you agree to our ',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: ResponsiveUtils.getFontSize(context,
                    mobile: 12, tablet: 13, desktop: 14),
                ),
                children: [
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
