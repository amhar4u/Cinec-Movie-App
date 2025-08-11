import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_app_bar.dart';
import '../../utils/responsive_utils.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';

class CreateAdminScreen extends StatefulWidget {
  const CreateAdminScreen({super.key});

  @override
  State<CreateAdminScreen> createState() => _CreateAdminScreenState();
}

class _CreateAdminScreenState extends State<CreateAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _adminKeyController = TextEditingController();
  
  // For demo purposes, you can change this to a more secure method
  static const String _adminSecretKey = "CINEC_ADMIN_2024";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isLandscape = ResponsiveUtils.isLandscape(context);
    final contentWidth = ResponsiveUtils.getContentWidth(context);
    final padding = ResponsiveUtils.getPadding(context);

    return Scaffold(
      appBar: const CustomAppBar(showThemeToggle: true),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: SizedBox(
            width: contentWidth,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: padding.left,
                right: padding.right,
                top: padding.top,
                bottom: ResponsiveUtils.getBottomPadding(context),
              ),
              child: Form(
                key: _formKey,
                child: isLandscape
                    ? _buildLandscapeLayout(context, theme, size)
                    : _buildPortraitLayout(context, theme, size),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context, ThemeData theme, Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, theme),
        SizedBox(height: ResponsiveUtils.getOrientationHeight(context) * 0.05),
        _buildFormFields(context, theme),
        SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 24, tablet: 30, desktop: 40)),
        _buildActions(context, theme),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, ThemeData theme, Size size) {
    return Row(
      children: [
        // Left side - Header
        Expanded(
          flex: 1,
          child: _buildHeader(context, theme),
        ),
        
        SizedBox(width: ResponsiveUtils.getSpacing(context, mobile: 20, tablet: 30, desktop: 40)),
        
        // Right side - Form
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildFormFields(context, theme),
              SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 20, tablet: 30, desktop: 40)),
              _buildActions(context, theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return FadeInDown(
      duration: const Duration(milliseconds: 800),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.admin_panel_settings,
            size: ResponsiveUtils.getSpacing(context, mobile: 60, tablet: 70, desktop: 80),
            color: theme.colorScheme.primary,
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
          Text(
            'Create Admin Account',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtils.getSpacing(context, mobile: 28, tablet: 32, desktop: 36),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 8, tablet: 12, desktop: 16)),
          Text(
            'Enter the admin key and create your administrator account',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
              fontSize: ResponsiveUtils.getSpacing(context, mobile: 16, tablet: 18, desktop: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields(BuildContext context, ThemeData theme) {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      delay: const Duration(milliseconds: 200),
      child: Column(
        children: [
          // Admin Key Field
          CustomTextField(
            controller: _adminKeyController,
            label: 'Admin Secret Key',
            prefixIcon: const Icon(Icons.key),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the admin secret key';
              }
              if (value != _adminSecretKey) {
                return 'Invalid admin secret key';
              }
              return null;
            },
          ),
          
          SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
          
          // Name Field
          CustomTextField(
            controller: _nameController,
            label: 'Full Name',
            prefixIcon: const Icon(Icons.person),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your full name';
              }
              if (value.length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
          ),
          
          SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
          
          // Email Field
          CustomTextField(
            controller: _emailController,
            label: 'Email Address',
            prefixIcon: const Icon(Icons.email),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          
          SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
          
          // Password Field
          CustomTextField(
            controller: _passwordController,
            label: 'Password',
            prefixIcon: const Icon(Icons.lock),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          
          SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
          
          // Confirm Password Field
          CustomTextField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            prefixIcon: const Icon(Icons.lock_outline),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, ThemeData theme) {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      delay: const Duration(milliseconds: 400),
      child: Column(
        children: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return CustomButton(
                text: 'Create Admin Account',
                onPressed: authProvider.isLoading ? null : _createAdminAccount,
                isLoading: authProvider.isLoading,
                width: double.infinity,
              );
            },
          ),
          
          SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
          
          // Error Message
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              if (authProvider.errorMessage != null) {
                return Container(
                  padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, mobile: 12, tablet: 16, desktop: 20)),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.colorScheme.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authProvider.errorMessage!,
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          
          SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 24, tablet: 30, desktop: 40)),
          
          // Back to Login
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Back to Login',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontSize: ResponsiveUtils.getSpacing(context, mobile: 14, tablet: 16, desktop: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createAdminAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.createAdminAccount(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
    );

    if (success && mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Admin account created successfully!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      
      // Navigate to home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _adminKeyController.dispose();
    super.dispose();
  }
}
