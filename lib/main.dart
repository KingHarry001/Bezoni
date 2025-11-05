import 'package:bezoni/screens/categories_screen.dart';
import 'package:bezoni/screens/restaurant_details_screen.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/cart.dart';
import 'screens/messages.dart';
import 'screens/profile_screen.dart';
import 'screens/preferences.dart';
import 'core/navigation_service.dart';
import 'widgets/screen_wrapper.dart';
import 'core/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API client
  await ApiClient().initialize();

  runApp(const BezoniApp());
}

class BezoniApp extends StatelessWidget {
  const BezoniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bezoni',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF10B981),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        fontFamily: 'SF Pro',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF10B981)),
      ),
      initialRoute: NavigationService.preferencesRoute,
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Preferences/Onboarding (no bottom nav)
      case NavigationService.preferencesRoute:
      case '/':
        return MaterialPageRoute(
          builder: (_) => const PreferencesScreen(),
          settings: settings,
        );

      case NavigationService.homeRoute:
        return MaterialPageRoute(
          builder: (_) => ScreenWrapper(
            currentRoute: NavigationService.homeRoute,
            child: const HomeScreen(),
          ),
          settings: settings,
        );

      // Search Tab
      case NavigationService.searchRoute:
        return MaterialPageRoute(
          builder: (_) => const SearchTabWrapper(child: SearchScreen()),
          settings: settings,
        );

      // Cart Tab
      case NavigationService.cartRoute:
        return MaterialPageRoute(
          builder: (_) => const CartTabWrapper(child: CartScreen()),
          settings: settings,
        );

      // Messages Tab
      case NavigationService.messagesRoute:
        return MaterialPageRoute(
          builder: (_) => const MessagesTabWrapper(child: MessagesScreen()),
          settings: settings,
        );

      // Profile Tab
      case NavigationService.profileRoute:
        return MaterialPageRoute(
          builder: (_) => const ProfileTabWrapper(child: ProfileScreen()),
          settings: settings,
        );

      // Other screens (with back button, no bottom nav)
      case NavigationService.categoriesRoute:
        return MaterialPageRoute(
          builder: (_) => ScreenWrapper(
            currentRoute: settings.name!,
            showBottomNav: false,
            child: const CategoriesScreen(),
          ),
          settings: settings,
        );

      case NavigationService.restaurantRoute:
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
}
