import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patientappointment/core/providers/auth_provider.dart';
import 'package:patientappointment/presentation/screens/onboarding_screen.dart';
import 'package:patientappointment/presentation/screens/sign_in_phone_screen.dart';
import 'package:patientappointment/presentation/screens/home_tabs_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeTabsScreen()),
      );
    } else {
      final hasSeenOnboarding = false;
      if (hasSeenOnboarding) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignInPhoneScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FlutterLogo(size: 100),
      ),
    );
  }
}