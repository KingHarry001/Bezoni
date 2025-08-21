import 'package:flutter/material.dart';
import 'package:bezoni/core/shared.dart';
import 'package:bezoni/views/onboarding.dart';
import 'package:bezoni/views/auth/signup.dart';
import 'package:bezoni/views/auth/login.dart';
import 'package:bezoni/views/splash/splash.dart';
import 'package:bezoni/views/dashboard/dashboard.dart';
import 'package:bezoni/views/home/home.dart';

void main() {
  runApp(BezoniApp());
}

class BezoniApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bezoni',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Inter'),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => OnboardingScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/signup': (context) => CustomerSignupScreen(),
        '/business-signup': (context) => BusinessSignupScreen(),
        '/delivery-signup': (context) => DeliverySignupScreen(),
        '/business-login': (context) => BusinessLoginScreen(),
        '/delivery-login': (context) => DeliveryLoginScreen(),
        '/success': (context) => SuccessScreen(),
        '/landingpage': (context) => LandingScreen(),
        '/preferences': (ctx) => const PreferencesScreen(),
        '/home': (ctx) => const HomeScreen(),
        '/categories': (ctx) => const CategoriesScreen(),
        '/search': (ctx) => const SearchScreen(),
        '/cart': (ctx) => const CartScreen(),
        '/messages': (ctx) => const MessagesScreen(),
        '/profile': (ctx) => const ProfileScreen(),
        '/restaurant': (ctx) => const RestaurantDetailsScreen(),
      },
    );
  }
}

// Landing Screen - Choose between Business and Delivery
class LandingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.apps, color: Colors.white, size: 20),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Bezoni',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 60),
              // Welcome content
              Text(
                'Welcome to Bezoni',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Choose how you want to get started',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 60),
              // Business Option
              _buildOptionCard(
                context,
                title: 'For Business',
                subtitle: 'Grow your business with our delivery platform',
                icon: Icons.business,
                onSignUpTap: () =>
                    Navigator.pushNamed(context, '/business-signup'),
                onLoginTap: () =>
                    Navigator.pushNamed(context, '/business-login'),
              ),
              SizedBox(height: 24),
              // Delivery Option
              _buildOptionCard(
                context,
                title: 'For Delivery',
                subtitle: 'Join our delivery team and start earning',
                icon: Icons.delivery_dining,
                onSignUpTap: () =>
                    Navigator.pushNamed(context, '/delivery-signup'),
                onLoginTap: () =>
                    Navigator.pushNamed(context, '/delivery-login'),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onSignUpTap,
    required VoidCallback onLoginTap,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.black),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onLoginTap,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onSignUpTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Success Screen
class SuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background blob
                    Container(
                      width: 160,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.green[200],
                        borderRadius: BorderRadius.circular(80),
                      ),
                    ),
                    // Person illustration (simplified)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Head
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.orange[300],
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        SizedBox(height: 5),
                        // Body
                        Container(
                          width: 25,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.green[600],
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        // Laptop
                        Container(
                          width: 40,
                          height: 25,
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              Text(
                'Woohoo! You\'re in. 🎉',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Thanks for joining the Bezoni family! We can\'t wait to\nhelp grow your business. Here\'s to a bright future ahead!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/dashboard');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
