import 'package:bezoni/screens/categories_screen.dart';
import 'package:bezoni/screens/restaurant_details_screen.dart';
import 'package:bezoni/screens/settings_screen.dart';
import 'package:bezoni/screens/support_screen.dart';
import 'package:bezoni/screens/splash.dart';
import 'package:bezoni/widgets/screen_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:bezoni/screens/onboarding.dart';
import 'package:bezoni/screens/auth/login_screen.dart';
import 'package:bezoni/screens/auth/signup_screen.dart';
import 'package:bezoni/screens/main_navigation.dart';
// Import your tab screens
import 'package:bezoni/screens/search_screen.dart';
import 'package:bezoni/screens/cart_screen.dart';
import 'package:bezoni/screens/messages.dart';
import 'package:bezoni/screens/profile_screen.dart';

class AppRoutes {
  // Authentication routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';

  // Main app route (with bottom navigation)
  static const String home = '/home';

  // Tab routes (handled by NavigationService)
  static const String homeTab = '/home/tab';
  static const String search = '/search';
  static const String cart = '/cart';
  static const String messages = '/messages';
  static const String profile = '/profile';

  // Other routes
  static const String categories = '/categories';
  static const String restaurant = '/restaurant';
  static const String preferences = '/preferences';
  static const String settingscreen = '/settings';
  static const String support = '/support';

  // Generate routes
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

      case onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
          settings: settings,
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const UserLoginScreen(),
          settings: settings,
        );

      case signup:
        return MaterialPageRoute(
          builder: (_) => const UserSignupScreen(),
          settings: settings,
        );

      case home:
        // MainNavigation handles all tab-based navigation
        return MaterialPageRoute(
          builder: (_) => const MainNavigation(),
          settings: settings,
        );

      // Search Tab
      case search:
        return MaterialPageRoute(
          builder: (_) => const SearchScreen(),
          settings: settings,
        );

      // Cart Tab
      case cart:
        return MaterialPageRoute(
          builder: (_) => const CartTabWrapper(child: CartScreen()),
          settings: settings,
        );

      // Messages Tab
      case messages:
        return MaterialPageRoute(
          builder: (_) => const MessagesTabWrapper(child: MessagesScreen()),
          settings: settings,
        );

      // Profile Tab
      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileTabWrapper(child: ProfileScreen()),
          settings: settings,
        );

      // Settings screen (no bottom nav)
      case settingscreen:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );

      // Support screen (no bottom nav)
      case support:
        return MaterialPageRoute(
          builder: (_) => const SupportScreen(),
          settings: settings,
        );

      // Other screens (with back button, no bottom nav)
      case categories:
        return MaterialPageRoute(
          builder: (_) => ScreenWrapper(
            currentRoute: settings.name!,
            showBottomNav: false,
            child: const CategoriesScreen(),
          ),
          settings: settings,
        );

      case restaurant:
        return MaterialPageRoute(
          builder: (_) => ScreenWrapper(
            currentRoute: settings.name!,
            showBottomNav: false,
            child: const RestaurantDetailsScreen(),
          ),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  // Navigation helpers
  static Future<dynamic> navigateTo(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static Future<dynamic> navigateAndReplace(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }

  static Future<dynamic> navigateAndRemoveUntil(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static void goBack(BuildContext context, {dynamic result}) {
    Navigator.pop(context, result);
  }
}