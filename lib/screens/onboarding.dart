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
  bool _isLoading = false;

  // Brand colors
  static const Color _primaryGreen = Color(0xFF2ECC40);
  static const Color _darkText = Color(0xFF1A1A1A);
  static const Color _greyText = Color(0xFF666666);
  static const Color _lightGrey = Color(0xFF8E8E8E);
  static const Color _borderGrey = Color(0xFFE0E0E0);
  static const Color _backgroundGrey = Color(0xFFE8E8E8);

  late final List<OnboardingData> _onboardingData;

  @override
  void initState() {
    super.initState();
    _onboardingData = [
      OnboardingData(
        title: "Get Anything Delivered, Fast",
        description:
            "From tasty meals to urgent parcels —\nwe connect you to reliable drivers in minutes.",
        illustration: _buildImageWithFallback(
          "assets/onboarding/Layer_1.png",
          Icons.delivery_dining,
        ),
      ),
      OnboardingData(
        title: "Track Your Order in Real Time",
        description:
            "Know exactly where your food or parcel is,\nevery step of the way.",
        illustration: _buildImageWithFallback(
          "assets/onboarding/Layer_2.png",
          Icons.location_on,
        ),
      ),
      OnboardingData(
        title: "Simple. Secure. Stress-Free.",
        description:
            "Pay with ease, get updates instantly,\nand enjoy support that's always available.",
        illustration: _buildImageWithFallback(
          "assets/onboarding/Layer_3.png",
          Icons.payment,
        ),
      ),
      OnboardingData(
        title: "Create Account",
        description: "Choose how you want to get started",
        illustration: _buildImageWithFallback(
          "assets/onboarding/Layer_4.png",
          Icons.account_circle,
        ),
        isCreateAccount: true,
        imageHeight: 180,
      ),
    ];
  }

  Widget _buildImageWithFallback(String assetPath, IconData fallbackIcon) {
    return Image.asset(
      assetPath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(fallbackIcon, size: 200, color: _primaryGreen);
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _markOnboardingComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('first_launch', false);
      await prefs.setBool('completed_onboarding', true);
    } catch (e) {
      debugPrint('Error saving onboarding status: $e');
    }
  }

  Future<void> _navigateToLogin() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    await _markOnboardingComplete();
    
    if (!mounted) return;
    
    setState(() => _isLoading = false);
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  Future<void> _navigateToSignup() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    await _markOnboardingComplete();
    
    if (!mounted) return;
    
    setState(() => _isLoading = false);
    Navigator.pushReplacementNamed(context, AppRoutes.signup);
  }

  void _signUpWithGoogle() {
    if (_isLoading) return;
    
    _showComingSoonSnackBar('Google sign-up coming soon!');
    // TODO: Implement Google sign up
  }

  void _signUpWithApple() {
    if (_isLoading) return;
    
    _showComingSoonSnackBar('Apple sign-up coming soon!');
    // TODO: Implement Apple sign up
  }

  void _showComingSoonSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _goToNextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipToEnd() {
    _pageController.animateToPage(
      _onboardingData.length - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content - takes full screen
            Column(
              children: [
                const SizedBox(height: 10),
                
                // Page content
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
                _buildBottomSection(),
              ],
            ),
            
            // Skip button floating at top right - doesn't affect layout
            if (_currentPage < _onboardingData.length - 2)
              Positioned(
                top: 16,
                right: 24,
                child: _buildSkipButton(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          // Page indicators
          _buildPageIndicators(),
          
          const SizedBox(height: 40),

          // Action buttons
          if (_currentPage < _onboardingData.length - 1)
            _buildGetStartedButton()
          else
            _buildCreateAccountSection(),
        ],
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _onboardingData.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index ? _primaryGreen : _backgroundGrey,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _goToNextPage,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _primaryGreen.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                "Get Started",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
      ),
    );
  }

  Widget _buildCreateAccountSection() {
    return Column(
      children: [
        // Google Sign Up
        _buildSocialButton(
          onPressed: _signUpWithGoogle,
          icon: Image.asset(
            "assets/icons/google_icon.png",
            width: 20,
            height: 20,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.g_mobiledata,
                size: 20,
                color: Colors.red,
              );
            },
          ),
          label: "Sign Up with Google",
        ),

        const SizedBox(height: 16),

        // Apple Sign Up
        _buildSocialButton(
          onPressed: _signUpWithApple,
          icon: const Icon(
            Icons.apple,
            color: _darkText,
            size: 20,
          ),
          label: "Sign Up with Apple",
        ),

        const SizedBox(height: 24),

        // OR divider
        _buildOrDivider(),

        const SizedBox(height: 24),

        // Continue with Email
        _buildEmailButton(),

        const SizedBox(height: 24),

        // Already have account
        _buildLoginPrompt(),
      ],
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onPressed,
    required Widget icon,
    required String label,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: _isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: _isLoading ? _borderGrey.withOpacity(0.5) : _borderGrey,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[50],
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: icon,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: _borderGrey,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "OR",
            style: TextStyle(
              color: _lightGrey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: _borderGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _navigateToSignup,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: _isLoading ? _borderGrey.withOpacity(0.5) : _borderGrey,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[50],
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(_darkText),
                ),
              )
            : const Text(
                "Continue with Email Address",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _darkText,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Already Have An Account? ",
          style: TextStyle(
            color: _lightGrey,
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: _isLoading ? null : _navigateToLogin,
          child: Text(
            "Log In",
            style: TextStyle(
              color: _isLoading ? _primaryGreen.withOpacity(0.5) : _primaryGreen,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkipButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading ? null : _skipToEnd,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _borderGrey),
          ),
          child: Text(
            "Skip",
            style: TextStyle(
              color: _isLoading ? _lightGrey.withOpacity(0.5) : _darkText,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
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
  final double? imageHeight;

  OnboardingData({
    required this.title,
    required this.description,
    required this.illustration,
    this.isCreateAccount = false,
    this.imageHeight,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPage({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            SizedBox(height: data.isCreateAccount ? 20 : 40),

            // Illustration
            SizedBox(
              height: data.imageHeight ?? (data.isCreateAccount ? 240 : 320),
              child: data.illustration,
            ),

            SizedBox(height: data.isCreateAccount ? 24 : 60),

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

            SizedBox(height: data.isCreateAccount ? 20 : 40),
          ],
        ),
      ),
    );
  }
}