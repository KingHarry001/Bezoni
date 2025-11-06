import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bezoni/routes/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: "Get Anything Delivered, Fast",
      description:
          "From tasty meals to urgent parcels —\nwe connect you to reliable drivers in minutes.",
      illustration: Image.asset(
        "assets/onboarding/Layer_1.png",
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.delivery_dining, size: 200, color: Color(0xFF2ECC40));
        },
      ),
    ),
    OnboardingData(
      title: "Track Your Order in Real Time",
      description:
          "Know exactly where your food or parcel is,\nevery step of the way.",
      illustration: Image.asset(
        "assets/onboarding/Layer_2.png",
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.location_on, size: 200, color: Color(0xFF2ECC40));
        },
      ),
    ),
    OnboardingData(
      title: "Simple. Secure. Stress-Free.",
      description:
          "Pay with ease, get updates instantly,\nand enjoy support that's always available.",
      illustration: Image.asset(
        "assets/onboarding/Layer_3.png",
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.payment, size: 200, color: Color(0xFF2ECC40));
        },
      ),
    ),
    OnboardingData(
      title: "Create Account",
      description: "Choose how you want to get started",
      illustration: Image.asset(
        "assets/onboarding/Layer_4.png",
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.account_circle, size: 200, color: Color(0xFF2ECC40));
        },
      ),
      isCreateAccount: true,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch', false);
    await prefs.setBool('completed_onboarding', true);
  }

  void _navigateToLogin() async {
    await _markOnboardingComplete();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  void _navigateToSignup() async {
    await _markOnboardingComplete();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.signup);
  }

  void _signUpWithGoogle() {
    // TODO: Implement Google sign up
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google sign-up coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _signUpWithApple() {
    // TODO: Implement Apple sign up
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Apple sign-up coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  final data = _onboardingData[index];
                  return OnboardingPage(data: data);
                },
              ),
            ),

            // Bottom section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? const Color(0xFF2ECC40)
                              : const Color(0xFFE8E8E8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Get Started button or Sign up buttons
                  if (_currentPage < _onboardingData.length - 1)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2ECC40),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: const Text(
                          "Get Started",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    )
                  else
                    // Create account buttons
                    Column(
                      children: [
                        // Google Sign Up
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton.icon(
                            onPressed: _signUpWithGoogle,
                            icon: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage("assets/icons/google_icon.png"),
                                  fit: BoxFit.contain,
                                ),
                              ),
                              child: const Icon(Icons.g_mobiledata, size: 20, color: Colors.red),
                            ),
                            label: const Text(
                              "Sign Up with Google",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFE0E0E0)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Apple Sign Up
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton.icon(
                            onPressed: _signUpWithApple,
                            icon: const Icon(
                              Icons.apple,
                              color: Color(0xFF1A1A1A),
                              size: 20,
                            ),
                            label: const Text(
                              "Sign Up with Apple",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFE0E0E0)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // OR divider
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: const Color(0xFFE0E0E0),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                "OR",
                                style: TextStyle(
                                  color: Color(0xFF8E8E8E),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: const Color(0xFFE0E0E0),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Continue with Email
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: _navigateToSignup,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFE0E0E0)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            child: const Text(
                              "Continue with Email Address",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Already have account
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Already Have An Account? ",
                              style: TextStyle(
                                color: Color(0xFF8E8E8E),
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: _navigateToLogin,
                              child: const Text(
                                "Log In",
                                style: TextStyle(
                                  color: Color(0xFF2ECC40),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                  const SizedBox(height: 20),

                  // Skip button (only show on first three pages)
                  if (_currentPage < _onboardingData.length - 2)
                    TextButton(
                      onPressed: () {
                        _pageController.animateToPage(
                          _onboardingData.length - 1,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text(
                        "Skip",
                        style: TextStyle(
                          color: Color(0xFF8E8E8E),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
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
}

class OnboardingData {
  final String title;
  final String description;
  final Widget illustration;
  final bool isCreateAccount;

  OnboardingData({
    required this.title,
    required this.description,
    required this.illustration,
    this.isCreateAccount = false,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPage({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Illustration
            SizedBox(
              height: data.isCreateAccount ? 240 : 320,
              child: data.illustration,
            ),

            SizedBox(height: data.isCreateAccount ? 40 : 60),

            // Title
            Text(
              data.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 16),

            // Description
            Text(
              data.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
                height: 1.5,
                letterSpacing: 0.1,
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}