import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/profile_avatar.dart';
import '../../utils/responsive_utils.dart';
import '../../providers/auth_provider.dart';
import '../auth/welcome_screen.dart';
import 'admin_movie_list_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contentWidth = ResponsiveUtils.getContentWidth(context);
    final padding = ResponsiveUtils.getPadding(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: '${AppConstants.appName} - Admin',
        showThemeToggle: true,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return IconButton(
                onPressed: () => _showProfileBottomSheet(context),
                icon: ProfileAvatar(
                  userModel: authProvider.userModel,
                  radius: 16,
                ),
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
            child: SingleChildScrollView(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeSection(context, theme),
                  SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 24, tablet: 32, desktop: 40)),
                  _buildAdminActions(context, theme),
                  SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 24, tablet: 32, desktop: 40)),
                  _buildQuickStats(context, theme),
                  SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 24, tablet: 32, desktop: 40)),
                  _buildRecentActivity(context, theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, ThemeData theme) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.userModel;
        final firstName = user?.name.split(' ').first ?? 'Admin';
        
        return FadeInDown(
          duration: const Duration(milliseconds: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Dashboard',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontSize: ResponsiveUtils.getFontSize(context, mobile: 16, tablet: 18, desktop: 20),
                ),
              ),
              SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 4, tablet: 6, desktop: 8)),
              Text(
                'Welcome, $firstName',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveUtils.getFontSize(context, mobile: 24, tablet: 28, desktop: 32),
                ),
              ),
              SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 8, tablet: 12, desktop: 16)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getSpacing(context, mobile: 12, tablet: 16, desktop: 20),
                  vertical: ResponsiveUtils.getSpacing(context, mobile: 8, tablet: 10, desktop: 12),
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: 16,
                      color: Colors.orange,
                    ),
                    SizedBox(width: ResponsiveUtils.getSpacing(context, mobile: 8, tablet: 10, desktop: 12)),
                    Text(
                      'ADMIN',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                        fontSize: ResponsiveUtils.getFontSize(context, mobile: 12, tablet: 13, desktop: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdminActions(BuildContext context, ThemeData theme) {
    final actions = [
      {'icon': FontAwesomeIcons.film, 'title': 'Manage Movies', 'color': Colors.blue},
      {'icon': FontAwesomeIcons.users, 'title': 'User Management', 'color': Colors.green},
      {'icon': FontAwesomeIcons.calendarAlt, 'title': 'Showtimes', 'color': Colors.orange},
      {'icon': FontAwesomeIcons.chartBar, 'title': 'Analytics', 'color': Colors.purple},
      {'icon': FontAwesomeIcons.ticket, 'title': 'Bookings', 'color': Colors.red},
      {'icon': FontAwesomeIcons.cog, 'title': 'Settings', 'color': Colors.grey},
    ];

    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      delay: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Admin Tools',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtils.getFontSize(context, mobile: 20, tablet: 22, desktop: 24),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveUtils.isDesktop(context) ? 3 : 2,
              crossAxisSpacing: ResponsiveUtils.getSpacing(context, mobile: 12, tablet: 16, desktop: 20),
              mainAxisSpacing: ResponsiveUtils.getSpacing(context, mobile: 12, tablet: 16, desktop: 20),
              childAspectRatio: 1.2,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return _buildActionCard(context, theme, action);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, ThemeData theme, Map<String, dynamic> action) {
    return GestureDetector(
      onTap: () {
        // Handle action tap
        if (action['title'] == 'Manage Movies') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminMovieListScreen(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${action['title']} coming soon!')),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, mobile: 12, tablet: 16, desktop: 20)),
              decoration: BoxDecoration(
                color: (action['color'] as Color).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                action['icon'] as IconData,
                color: action['color'] as Color,
                size: ResponsiveUtils.getFontSize(context, mobile: 24, tablet: 28, desktop: 32),
              ),
            ),
            SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 8, tablet: 12, desktop: 16)),
            Text(
              action['title'] as String,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveUtils.getFontSize(context, mobile: 12, tablet: 14, desktop: 16),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, ThemeData theme) {
    final stats = [
      {'title': 'Total Users', 'value': '1,234', 'icon': FontAwesomeIcons.users, 'color': Colors.blue},
      {'title': 'Active Movies', 'value': '89', 'icon': FontAwesomeIcons.film, 'color': Colors.green},
      {'title': 'Today\'s Bookings', 'value': '156', 'icon': FontAwesomeIcons.ticket, 'color': Colors.orange},
      {'title': 'Revenue', 'value': '\$12,345', 'icon': FontAwesomeIcons.dollarSign, 'color': Colors.purple},
    ];

    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      delay: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Stats',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtils.getFontSize(context, mobile: 20, tablet: 22, desktop: 24),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveUtils.isDesktop(context) ? 4 : 2,
              crossAxisSpacing: ResponsiveUtils.getSpacing(context, mobile: 12, tablet: 16, desktop: 20),
              mainAxisSpacing: ResponsiveUtils.getSpacing(context, mobile: 12, tablet: 16, desktop: 20),
              childAspectRatio: 1.5,
            ),
            itemCount: stats.length,
            itemBuilder: (context, index) {
              final stat = stats[index];
              return _buildStatCard(context, theme, stat);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, ThemeData theme, Map<String, dynamic> stat) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            stat['icon'] as IconData,
            color: stat['color'] as Color,
            size: ResponsiveUtils.getFontSize(context, mobile: 24, tablet: 28, desktop: 32),
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 8, tablet: 12, desktop: 16)),
          Text(
            stat['value'] as String,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: stat['color'] as Color,
              fontSize: ResponsiveUtils.getFontSize(context, mobile: 18, tablet: 20, desktop: 24),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 4, tablet: 6, desktop: 8)),
          Text(
            stat['title'] as String,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: ResponsiveUtils.getFontSize(context, mobile: 10, tablet: 12, desktop: 14),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, ThemeData theme) {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      delay: const Duration(milliseconds: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtils.getFontSize(context, mobile: 20, tablet: 22, desktop: 24),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                _buildActivityItem(context, theme, 'New user registered', '2 min ago', Icons.person_add),
                _buildActivityItem(context, theme, 'Movie booking completed', '5 min ago', Icons.confirmation_number),
                _buildActivityItem(context, theme, 'New movie added', '10 min ago', Icons.movie),
                _buildActivityItem(context, theme, 'Payment processed', '15 min ago', Icons.payment),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, ThemeData theme, String title, String time, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.getSpacing(context, mobile: 8, tablet: 12, desktop: 16)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, mobile: 8, tablet: 10, desktop: 12)),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: ResponsiveUtils.getFontSize(context, mobile: 16, tablet: 18, desktop: 20),
            ),
          ),
          SizedBox(width: ResponsiveUtils.getSpacing(context, mobile: 12, tablet: 16, desktop: 20)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: ResponsiveUtils.getFontSize(context, mobile: 14, tablet: 16, desktop: 18),
                  ),
                ),
                Text(
                  time,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontSize: ResponsiveUtils.getFontSize(context, mobile: 12, tablet: 14, desktop: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ProfileAvatar(
                    userModel: authProvider.userModel,
                    radius: 40,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    authProvider.userModel?.name ?? 'Admin',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    authProvider.userModel?.email ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Text(
                      'ADMIN',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Edit Profile'),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to edit profile
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Admin Settings'),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to admin settings
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Sign Out'),
                    onTap: () async {
                      Navigator.pop(context);
                      await authProvider.signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                          (route) => false,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
