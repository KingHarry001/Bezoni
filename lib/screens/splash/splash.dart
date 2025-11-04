import 'package:bezoni/screens/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:bezoni/screens/dashboard/dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLoggedIn = false; // Replace this with your real auth check

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    await Future.delayed(const Duration(seconds: 3)); // splash delay

    // TODO: Replace with your actual auth logic
    bool userAuthenticated = isLoggedIn;

    if (!mounted) return;

    if (userAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 👈 solid black background
      body: Center(
        child: Image.asset(
          "assets/images/bezoni.png", // 👈 PNG logo instead of SVG
          width: 500,
        ),
      ),
    );
  }
}
