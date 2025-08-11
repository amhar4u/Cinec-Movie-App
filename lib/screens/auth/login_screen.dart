import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/oauth_button.dart';
import '../../widgets/custom_app_bar.dart';
import '../../utils/responsive_utils.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import 'signup_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

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
        SizedBox(height: ResponsiveUtils.getOrientationHeight(context) * 0.1),
        _buildFormFields(context, theme),
        SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 30, tablet: 40, desktop: 50)),
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
            'Welcome Back!',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtils.getFontSize(context,
                mobile: 28, tablet: 32, desktop: 36),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 8, tablet: 12, desktop: 16)),
          Text(
            'Sign in to continue your movie journey',
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
    return Column(
      children: [
        // Email Field
        FadeInLeft(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 200),
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

        SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),

        // Password Field
        FadeInRight(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 300),
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
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
        ),

        SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 12, tablet: 16, desktop: 20)),

        // Remember Me & Forgot Password
        FadeInUp(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 400),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                    ),
                    Flexible(
                      child: Text(
                        'Remember me',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: ResponsiveUtils.getFontSize(context,
                            mobile: 14, tablet: 15, desktop: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  _showForgotPasswordDialog();
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: ResponsiveUtils.getFontSize(context,
                      mobile: 14, tablet: 15, desktop: 16),
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
        // Login Button
        SlideInUp(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 500),
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
                text: 'Login',
                onPressed: authProvider.isLoading ? null : _login,
                isLoading: authProvider.isLoading,
                width: double.infinity,
              );
            },
          ),
        ),

        SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 20, tablet: 24, desktop: 30)),

        // Divider
        FadeIn(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 600),
          child: Row(
            children: [
              Expanded(
                child: Divider(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getSpacing(context, mobile: 12, tablet: 16, desktop: 20),
                ),
                child: Text(
                  'or continue with',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontSize: ResponsiveUtils.getFontSize(context,
                      mobile: 14, tablet: 15, desktop: 16),
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 20, tablet: 24, desktop: 30)),

        // OAuth Buttons
        SlideInUp(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 700),
          child: Column(
            children: [
              OAuthButton(
                provider: OAuthProvider.google,
                onPressed: _signInWithGoogle,
              ),
              SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 12, tablet: 16, desktop: 20)),
              OAuthButton(
                provider: OAuthProvider.apple,
                onPressed: _signInWithApple,
              ),
            ],
          ),
        ),

        SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 30, tablet: 40, desktop: 50)),

        // Sign Up Link
        FadeIn(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 800),
          child: Center(
            child: Text.rich(
              TextSpan(
                text: "Don't have an account? ",
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
                            builder: (context) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Sign Up',
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

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithGoogle();

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  Future<void> _signInWithApple() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithApple();

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email address to receive a password reset link.'),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (emailController.text.isNotEmpty) {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final success = await authProvider.resetPassword(emailController.text.trim());
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success 
                        ? 'Password reset email sent!' 
                        : 'Failed to send reset email. Please try again.'),
                      backgroundColor: success 
                        ? Colors.green 
                        : Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
