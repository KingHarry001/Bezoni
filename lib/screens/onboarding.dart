import 'package:flutter/material.dart';

void main() {
  runApp(BezoniApp());
}

class BezoniApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bezoni',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'SF Pro Display',
      ),
      home: OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: "Get Anything Delivered, Fast",
      description:
          "From tasty meals to urgent parcels —\nwe connect you to reliable drivers in minutes.",
      illustration: Image.asset(
        "assets/onboarding/Layer_1.png",
        fit: BoxFit.contain,
      ),
    ),
    OnboardingData(
      title: "Track Your Order in Real Time",
      description:
          "Know exactly where your food or parcel is,\nevery step of the way.",
      illustration: Image.asset(
        "assets/onboarding/Layer_2.png",
        fit: BoxFit.contain,
      ),
    ),
    OnboardingData(
      title: "Simple. Secure. Stress-Free.",
      description:
          "Pay with ease, get updates instantly,\nand enjoy support that's always available.",
      illustration: Image.asset(
        "assets/onboarding/Layer_3.png",
        fit: BoxFit.contain,
      ),
    ),
    OnboardingData(
      title: "Create Account",
      description: "Choose details to create new account",
      illustration: Image.asset(
        "assets/onboarding/Layer_4.png",
        fit: BoxFit.contain,
      ),
      isCreateAccount: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),

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
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Color(0xFF2ECC40)
                              : Color(0xFFE8E8E8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 40),

                  // Get Started button or Sign up buttons
                  if (_currentPage < _onboardingData.length - 1)
                    Container(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2ECC40),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
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
                        Container(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _signUpWithGoogle();
                            },
                            icon: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                    "assets/icons/google_icon.png",
                                  ),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            label: Text(
                              "Sign Up with Google",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Color(0xFFE0E0E0)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Apple Sign Up
                        Container(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _signUpWithApple();
                            },
                            icon: Icon(
                              Icons.apple,
                              color: Color(0xFF1A1A1A),
                              size: 20,
                            ),
                            label: Text(
                              "Sign Up with Apple",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Color(0xFFE0E0E0)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),

                        SizedBox(height: 24),

                        // OR divider
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Color(0xFFE0E0E0),
                              ),
                            ),
                            Padding(
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
                                color: Color(0xFFE0E0E0),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 24),

                        // Continue with Email
                        Container(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/signup');
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Color(0xFFE0E0E0)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            child: Text(
                              "Continue with Email Address",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 24),

                        // Already have account
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already Have An Account? ",
                              style: TextStyle(
                                color: Color(0xFF8E8E8E),
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _navigateToLogin();
                              },
                              child: Text(
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

                  SizedBox(height: 20),

                  // Skip button (only show on first three pages)
                  if (_currentPage < _onboardingData.length - 2)
                    TextButton(
                      onPressed: () {
                        _pageController.animateToPage(
                          _onboardingData.length - 1,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text(
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

  void _completeOnboarding() {
    // Navigate to login/signup screen or main app
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Welcome to Bezoni!"),
        content: Text("Onboarding completed. Ready to get started?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _signUpWithGoogle() {
    // Implement Google sign up
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Google Sign Up"),
        content: Text(
          "Google sign up functionality would be implemented here.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _signUpWithApple() {
    // Implement Apple sign up
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Apple Sign Up"),
        content: Text("Apple sign up functionality would be implemented here."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _continueWithEmail() {
    // Navigate to email signup form
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Email Sign Up"),
        content: Text("Email signup form would be shown here."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.pushNamed(context, '/business-login');
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
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            SizedBox(height: 40),

            // Illustration
            Container(
              height: data.isCreateAccount ? 240 : 320,
              child: data.illustration,
            ),

            SizedBox(height: data.isCreateAccount ? 40 : 60),

            // Title
            Text(
              data.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),

            SizedBox(height: 16),

            // Description
            Text(
              data.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
                height: 1.5,
                letterSpacing: 0.1,
              ),
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
