import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:animate_do/animate_do.dart';
import '../../constants/app_constants.dart';
import '../../widgets/custom_button.dart';
import '../../utils/responsive_utils.dart';
import '../../services/preferences_service.dart';
import '../auth/welcome_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final contentWidth = ResponsiveUtils.getContentWidth(context);
    final padding = ResponsiveUtils.getOrientationPadding(context);
    final isLandscape = ResponsiveUtils.isLandscape(context);

    return Scaffold(
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              alignment: Alignment.center,
              child: SizedBox(
                width: contentWidth,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isLandscape 
                      ? _buildScrollableLayout(theme, size, padding)
                      : _buildPortraitLayout(theme, size, padding),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(ThemeData theme, Size size, EdgeInsets padding) {
    final isSmallScreen = ResponsiveUtils.isSmallScreen(context) || 
                         ResponsiveUtils.isVerySmallScreen(context);
    
    // Use scrollable layout for small screens even in portrait
    if (isSmallScreen) {
      return _buildScrollableLayout(theme, size, padding);
    }
    
    return Column(
      children: [
        // Skip Button
        Padding(
          padding: padding.copyWith(bottom: 0),
          child: Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: () => _navigateToWelcome(),
              child: Text(
                'Skip',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: ResponsiveUtils.getFontSize(context, 
                    mobile: 14, tablet: 16, desktop: 18),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        
        // PageView
        Expanded(
          flex: 3,
          child: _buildPageView(theme, size),
        ),
        
        // Page Indicator and Navigation
        Expanded(
          flex: 1,
          child: _buildBottomSection(theme, size, padding),
        ),
      ],
    );
  }

  Widget _buildScrollableLayout(ThemeData theme, Size size, EdgeInsets padding) {
    final safeHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).padding.vertical;
    
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: safeHeight,
        ),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Skip Button
              Padding(
                padding: EdgeInsets.only(
                  left: padding.left,
                  right: padding.right,
                  top: ResponsiveUtils.getCompactSpacing(context, mobile: 4, tablet: 8, desktop: 12),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () => _navigateToWelcome(),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: ResponsiveUtils.getCompactFontSize(context, 
                          mobile: 14, tablet: 16, desktop: 18),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              
              // PageView with flexible height
              Flexible(
                flex: 3,
                child: SizedBox(
                  height: safeHeight * 0.5, // Fixed height relative to available space
                  child: _buildPageView(theme, size, isCompact: true),
                ),
              ),
              
              SizedBox(height: ResponsiveUtils.getCompactSpacing(context,
                mobile: 8, tablet: 12, desktop: 16)),
              
              // Page Indicator and Navigation
              Flexible(
                flex: 1,
                child: Padding(
                  padding: padding.copyWith(top: 0),
                  child: _buildBottomSection(theme, size, padding, isCompact: true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageView(ThemeData theme, Size size, {bool isCompact = false}) {
    return PageView.builder(
      key: const PageStorageKey<String>('onboarding_page_view'),
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
      },
      itemCount: AppConstants.onboardingData.length,
      itemBuilder: (context, index) {
        final data = AppConstants.onboardingData[index];
        final isLandscape = ResponsiveUtils.isLandscape(context);
        
        // Very compact sizing for landscape mode
        final baseImageSize = ResponsiveUtils.getImageSize(context,
          mobile: size.width * 0.25,
          tablet: size.width * 0.18,
          desktop: 150,
        );
        
        // Further reduce image size for compact mode or landscape
        final imageSize = isCompact || isLandscape 
            ? baseImageSize * 0.5  // Much smaller for better fit
            : baseImageSize;
        
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.getCompactSpacing(context,
              mobile: 8, tablet: 12, desktop: 16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Use minimum space needed
            children: [
              // Image/Emoji - more compact
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                delay: Duration(milliseconds: index * 200),
                child: Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(imageSize / 2),
                  ),
                  child: Center(
                    child: Text(
                      data['image']!,
                      style: TextStyle(
                        fontSize: imageSize * 0.4,
                      ),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: ResponsiveUtils.getSpacing(context,
                mobile: isCompact ? 8 : 20, 
                tablet: isCompact ? 12 : 30, 
                desktop: isCompact ? 16 : 40)),
              
              // Title - more compact
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: Duration(milliseconds: index * 200 + 200),
                child: Text(
                  data['title']!,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                    fontSize: ResponsiveUtils.getFontSize(context,
                      mobile: isCompact ? 18 : 24, 
                      tablet: isCompact ? 22 : 28, 
                      desktop: isCompact ? 26 : 32),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: isCompact ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              SizedBox(height: ResponsiveUtils.getSpacing(context,
                mobile: isCompact ? 4 : 12, 
                tablet: isCompact ? 8 : 16, 
                desktop: isCompact ? 12 : 20)),
              
              // Description - more compact
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: Duration(milliseconds: index * 200 + 400),
                child: Text(
                  data['description']!,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    height: isCompact ? 1.2 : 1.4,
                    fontSize: ResponsiveUtils.getFontSize(context,
                      mobile: isCompact ? 12 : 16, 
                      tablet: isCompact ? 14 : 18, 
                      desktop: isCompact ? 16 : 20),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: isCompact ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSection(ThemeData theme, Size size, EdgeInsets padding, {bool isCompact = false}) {
    return Padding(
      padding: isCompact ? padding.copyWith(top: 0) : padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Page Indicator
          FadeIn(
            duration: const Duration(milliseconds: 600),
            child: SmoothPageIndicator(
              controller: _pageController,
              count: AppConstants.onboardingData.length,
              effect: ExpandingDotsEffect(
                activeDotColor: theme.colorScheme.primary,
                dotColor: theme.colorScheme.primary.withOpacity(0.3),
                dotHeight: isCompact ? 6 : (ResponsiveUtils.isMobile(context) ? 8 : 10),
                dotWidth: isCompact ? 6 : (ResponsiveUtils.isMobile(context) ? 8 : 10),
                expansionFactor: 3,
              ),
            ),
          ),
          
          SizedBox(height: ResponsiveUtils.getSpacing(context,
            mobile: isCompact ? 8 : 20, 
            tablet: isCompact ? 12 : 30, 
            desktop: isCompact ? 16 : 40)),
          
          // Navigation Button
          SlideInUp(
            duration: const Duration(milliseconds: 600),
            child: CustomButton(
              text: _currentPage == AppConstants.onboardingData.length - 1
                  ? 'Get Started'
                  : 'Next',
              onPressed: () {
                if (_currentPage == AppConstants.onboardingData.length - 1) {
                  _navigateToWelcome();
                } else {
                  _pageController.nextPage(
                    duration: AppConstants.animationDuration,
                    curve: Curves.easeInOut,
                  );
                }
              },
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToWelcome() async {
    // Mark onboarding as seen
    await PreferencesService.setOnboardingSeen();
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const WelcomeScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
