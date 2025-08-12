import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/loading_screen.dart';
import '../../providers/auth_provider.dart';
import '../../services/preferences_service.dart';
import '../onboarding/onboarding_screen.dart';
import '../auth/welcome_screen.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Check if user should stay logged in (remember me + firebase auth)
      final shouldStayLoggedIn = await PreferencesService.shouldStayLoggedIn();
      
      if (authProvider.isLoggedIn && shouldStayLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // If remember me is false but user is still in Firebase, sign them out
        if (authProvider.isLoggedIn && !shouldStayLoggedIn) {
          await authProvider.signOut();
        }
        
        // Check if user has seen onboarding
        final hasSeenOnboarding = await PreferencesService.hasSeenOnboarding();
        if (hasSeenOnboarding) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: LoadingScreen(),
      ),
    );
  }
}
