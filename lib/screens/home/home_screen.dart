import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/profile_avatar.dart';
import '../../models/user_model.dart';
import '../../utils/responsive_utils.dart';
import '../../providers/auth_provider.dart';
import '../auth/welcome_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLandscape = ResponsiveUtils.isLandscape(context);
    final contentWidth = ResponsiveUtils.getContentWidth(context);
    final padding = ResponsiveUtils.getPadding(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: AppConstants.appName,
        showThemeToggle: true,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return IconButton(
                onPressed: () async {
                  await authProvider.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: SizedBox(
            width: contentWidth,
            child: Padding(
              padding: padding,
              child: isLandscape 
                  ? _buildLandscapeLayout(context, theme)
                  : _buildPortraitLayout(context, theme),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWelcomeSection(context, theme),
        SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 30, tablet: 40, desktop: 50)),
        Expanded(
          child: _buildFeatureGrid(context, theme),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        // Left side - Welcome section
        Expanded(
          flex: 1,
          child: _buildWelcomeSection(context, theme),
        ),
        
        SizedBox(width: ResponsiveUtils.getSpacing(context, mobile: 20, tablet: 30, desktop: 40)),
        
        // Right side - Feature grid
        Expanded(
          flex: 1,
          child: _buildFeatureGrid(context, theme),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome Message
        FadeInDown(
          duration: const Duration(milliseconds: 600),
          child: Text(
            'Welcome to ${AppConstants.appName}!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtils.getFontSize(context,
                mobile: 24, tablet: 28, desktop: 32),
            ),
          ),
        ),
        
        SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 12, tablet: 16, desktop: 20)),
        
        FadeInDown(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 200),
          child: Text(
            'You have successfully logged in to the movie booking app.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: ResponsiveUtils.getFontSize(context,
                mobile: 16, tablet: 18, desktop: 20),
            ),
          ),
        ),
        
        SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
        
        // User info
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.user != null && authProvider.userModel != null) {
              return FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 400),
                child: Container(
                  padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      ProfileAvatar(
                        userModel: authProvider.userModel,
                        radius: 30,
                        showOnlineIndicator: true,
                      ),
                      SizedBox(width: ResponsiveUtils.getSpacing(context, mobile: 12, tablet: 16, desktop: 20)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${authProvider.userModel!.name}!',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: ResponsiveUtils.getFontSize(context,
                                  mobile: 16, tablet: 18, desktop: 20),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              authProvider.userModel!.email,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                                fontSize: ResponsiveUtils.getFontSize(context,
                                  mobile: 14, tablet: 15, desktop: 16),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: authProvider.userModel!.role == UserRole.admin
                                    ? theme.colorScheme.error.withOpacity(0.1)
                                    : theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: authProvider.userModel!.role == UserRole.admin
                                      ? theme.colorScheme.error.withOpacity(0.3)
                                      : theme.colorScheme.primary.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                '${authProvider.userModel!.role.toString().split('.').last.toUpperCase()} ACCOUNT',
                                style: TextStyle(
                                  color: authProvider.userModel!.role == UserRole.admin
                                      ? theme.colorScheme.error
                                      : theme.colorScheme.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildFeatureGrid(BuildContext context, ThemeData theme) {
    final crossAxisCount = ResponsiveUtils.getGridColumns(context);
    final spacing = ResponsiveUtils.getSpacing(context, mobile: 12, tablet: 16, desktop: 20);
    
    return GridView.count(
      crossAxisCount: crossAxisCount.clamp(2, 4),
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      childAspectRatio: ResponsiveUtils.isMobile(context) ? 1.1 : 1.2,
      children: [
        _buildFeatureCard(
          context,
          icon: FontAwesomeIcons.film,
          title: 'Browse Movies',
          description: 'Discover the latest movies',
          color: theme.colorScheme.primary,
          delay: 600,
        ),
        _buildFeatureCard(
          context,
          icon: FontAwesomeIcons.ticket,
          title: 'Book Tickets',
          description: 'Reserve your seats',
          color: theme.colorScheme.secondary,
          delay: 700,
        ),
        _buildFeatureCard(
          context,
          icon: FontAwesomeIcons.star,
          title: 'Reviews',
          description: 'Read movie reviews',
          color: theme.colorScheme.tertiary,
          delay: 800,
        ),
        _buildFeatureCard(
          context,
          icon: FontAwesomeIcons.user,
          title: 'Profile',
          description: 'Manage your account',
          color: theme.colorScheme.error,
          delay: 900,
        ),
        _buildFeatureCard(
          context,
          icon: FontAwesomeIcons.clock,
          title: 'Showtimes',
          description: 'Check movie schedules',
          color: Colors.orange,
          delay: 1000,
        ),
        _buildFeatureCard(
          context,
          icon: FontAwesomeIcons.mapLocation,
          title: 'Theaters',
          description: 'Find nearby cinemas',
          color: Colors.teal,
          delay: 1100,
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required int delay,
  }) {
    final theme = Theme.of(context);
    final iconSize = ResponsiveUtils.getFontSize(context, mobile: 24, tablet: 28, desktop: 32);
    final padding = ResponsiveUtils.getSpacing(context, mobile: 12, tablet: 16, desktop: 20);
    
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      delay: Duration(milliseconds: delay),
      child: Card(
        elevation: ResponsiveUtils.isMobile(context) ? 2 : 4,
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title feature coming soon!')),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(padding * 0.8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(
                    icon,
                    color: color,
                    size: iconSize,
                  ),
                ),
                
                SizedBox(height: padding * 0.8),
                
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: ResponsiveUtils.getFontSize(context,
                      mobile: 14, tablet: 16, desktop: 18),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: padding * 0.4),
                
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontSize: ResponsiveUtils.getFontSize(context,
                      mobile: 12, tablet: 13, desktop: 14),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
