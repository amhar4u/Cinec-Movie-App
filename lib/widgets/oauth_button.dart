import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/app_constants.dart';

enum OAuthProvider { google, apple, facebook }

class OAuthButton extends StatelessWidget {
  final OAuthProvider provider;
  final VoidCallback? onPressed;
  final bool isLoading;

  const OAuthButton({
    super.key,
    required this.provider,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIcon(),
                  const SizedBox(width: AppConstants.paddingMedium),
                  Text(
                    _getText(),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildIcon() {
    switch (provider) {
      case OAuthProvider.google:
        return const FaIcon(
          FontAwesomeIcons.google,
          size: 20,
          color: Color(0xFFDB4437),
        );
      case OAuthProvider.apple:
        return const FaIcon(
          FontAwesomeIcons.apple,
          size: 20,
          color: Colors.black,
        );
      case OAuthProvider.facebook:
        return const FaIcon(
          FontAwesomeIcons.facebookF,
          size: 20,
          color: Color(0xFF4267B2),
        );
    }
  }

  String _getText() {
    switch (provider) {
      case OAuthProvider.google:
        return 'Continue with Google';
      case OAuthProvider.apple:
        return 'Continue with Apple';
      case OAuthProvider.facebook:
        return 'Continue with Facebook';
    }
  }
}
