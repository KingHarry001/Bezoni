import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bezoni/core/api_client.dart';
import 'package:bezoni/routes/app_routes.dart';
import 'package:bezoni/themes/theme_extensions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.elasticOut),
      ),
    );

    // Start animation
    _controller.forward();

    // Check authentication and navigate
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Wait for minimum splash duration (for branding)
      await Future.delayed(const Duration(milliseconds: 2500));

      if (!mounted) return;

      // Check app initialization status
      final prefs = await SharedPreferences.getInstance();

      // Check if this is first launch
      final bool isFirstLaunch = prefs.getBool('first_launch') ?? true;

      // Check if user has completed onboarding
      final bool hasCompletedOnboarding =
          prefs.getBool('completed_onboarding') ?? false;

      // Check if user has auth token
      final String? authToken = prefs.getString('auth_token');

      // Determine navigation path
      if (isFirstLaunch || !hasCompletedOnboarding) {
        // First time user - show onboarding
        _navigateToOnboarding();
      } else if (authToken != null && authToken.isNotEmpty) {
        // User has auth token - verify it's valid
        final isValid = await _verifyAuthToken();
        if (isValid) {
          _navigateToHome();
        } else {
          // Token invalid - show login
          _navigateToLogin();
        }
      } else {
        // No auth token - show onboarding (which has login option)
        _navigateToOnboarding();
      }
    } catch (e) {
      debugPrint('Splash initialization error: $e');
      // On error, default to onboarding
      _navigateToOnboarding();
    }
  }

  Future<bool> _verifyAuthToken() async {
    try {
      // Verify token by fetching user profile
      final response = await ApiClient().getProfile();
      return response.isSuccess;
    } catch (e) {
      debugPrint('Token verification failed: $e');
      return false;
    }
  }

  void _navigateToOnboarding() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
  }

  void _navigateToLogin() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar style based on theme
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: context.isDarkMode
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: context.isDarkMode
          ? const Color(0xFF0A0A0A)
          : Colors.white,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with theme-aware styling
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.isDarkMode
                            ? Colors.white.withOpacity(0.05)
                            : const Color(0xFF2ECC40).withOpacity(0.05),
                        boxShadow: context.isDarkMode
                            ? []
                            : [
                                BoxShadow(
                                  color: const Color(
                                    0xFF2ECC40,
                                  ).withOpacity(0.1),
                                  blurRadius: 30,
                                  spreadRadius: 10,
                                ),
                              ],
                      ),
                      child: Image.asset(
                        "assets/images/bezoni.png",
                        width: 150,
                        height: 150,
                        fit: BoxFit.contain,
                        // Add color filter for dark mode if needed
                        color: context.isDarkMode ? Colors.white : null,
                        colorBlendMode: context.isDarkMode
                            ? BlendMode.srcIn
                            : null,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback if image not found
                          return Container(
                            width: 150,
                            height: 150,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF2ECC40),
                            ),
                            child: Center(
                              child: Text(
                                'B',
                                style: TextStyle(
                                  fontSize: 80,
                                  fontWeight: FontWeight.bold,
                                  color: context.isDarkMode
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Tagline
                    Text(
                      'Order Anything, Anywhere',
                      style: TextStyle(
                        fontSize: 14,
                        color: context.subtitleColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Loading indicator
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          context.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
