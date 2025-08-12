import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_app_bar.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/role_navigation.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _acceptTerms = false;

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
        SizedBox(height: ResponsiveUtils.getOrientationHeight(context) * 0.08),
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
      duration: const Duration(milliseconds: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create Account',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtils.getFontSize(context,
                mobile: 28, tablet: 32, desktop: 36),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 8, tablet: 12, desktop: 16)),
          Text(
            'Join us and start your cinematic adventure',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: ResponsiveUtils.getFontSize(context,
                mobile: 16, tablet: 18, desktop: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields(BuildContext context, ThemeData theme) {
    final spacing = ResponsiveUtils.getSpacing(context, mobile: 16, tablet: 20, desktop: 24);
    
    return Column(
      children: [
        // Name Field
        FadeInLeft(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 200),
          child: CustomTextField(
            label: 'Full Name',
            hint: 'Enter your full name',
            controller: _nameController,
            prefixIcon: const Icon(Icons.person_outlined),
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
        ),

        SizedBox(height: spacing),

        // Email Field
        FadeInRight(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 300),
          child: CustomTextField(
            label: 'Email',
            hint: 'Enter your email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
        ),

        SizedBox(height: spacing),

        // Password Field
        FadeInLeft(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 400),
          child: CustomTextField(
            label: 'Password',
            hint: 'Enter your password',
            controller: _passwordController,
            obscureText: true,
            showToggleVisibility: true,
            prefixIcon: const Icon(Icons.lock_outlined),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
                return 'Password must contain uppercase, lowercase, and number';
              }
              return null;
            },
          ),
        ),

        SizedBox(height: spacing),

        // Confirm Password Field
        FadeInRight(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 500),
          child: CustomTextField(
            label: 'Confirm Password',
            hint: 'Confirm your password',
            controller: _confirmPasswordController,
            obscureText: true,
            showToggleVisibility: true,
            prefixIcon: const Icon(Icons.lock_outlined),
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
        ),

        SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 12, tablet: 16, desktop: 20)),

        // Terms & Conditions
        FadeInUp(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 600),
          child: Row(
            children: [
              Checkbox(
                value: _acceptTerms,
                onChanged: (value) {
                  setState(() {
                    _acceptTerms = value ?? false;
                  });
                },
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: 'I agree to the ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: ResponsiveUtils.getFontSize(context,
                        mobile: 14, tablet: 15, desktop: 16),
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
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        // Sign Up Button
        SlideInUp(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 700),
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.errorMessage != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(authProvider.errorMessage!),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                  authProvider.clearError();
                });
              }

              return CustomButton(
                text: 'Create Account',
                onPressed: authProvider.isLoading ? null : _signUp,
                isLoading: authProvider.isLoading,
                width: double.infinity,
              );
            },
          ),
        ),

        SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 30, tablet: 40, desktop: 50)),

        // Login Link
        FadeIn(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 1000),
          child: Center(
            child: Text.rich(
              TextSpan(
                text: 'Already have an account? ',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: ResponsiveUtils.getFontSize(context,
                    mobile: 14, tablet: 15, desktop: 16),
                ),
                children: [
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: ResponsiveUtils.getFontSize(context,
                            mobile: 14, tablet: 15, desktop: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please accept the terms and conditions'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signUpWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
    );

    if (success && mounted) {
      // Navigate based on user role
      final userRole = authProvider.userModel?.role;
      RoleBasedNavigation.navigateToRoleBasedHomeAndClearStack(context, userRole);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
