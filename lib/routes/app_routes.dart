import 'package:bezoni/core/api_models.dart';
import 'package:bezoni/screens/api_diagnostic_screen.dart';
import 'package:bezoni/screens/common/cart_screen.dart';
import 'package:bezoni/screens/common/favorites_screen.dart';
import 'package:bezoni/screens/common/main_navigation.dart';
import 'package:bezoni/screens/common/search_screen.dart';
import 'package:bezoni/screens/orders/order_history_screen.dart';
import 'package:bezoni/screens/orders/order_tracking_screen.dart';
import 'package:bezoni/screens/profile/addresses_screen.dart';
import 'package:bezoni/screens/profile/payment_methods_screen.dart';
import 'package:bezoni/screens/profile/personal_details_screen.dart';
import 'package:bezoni/screens/profile/profile_screen.dart';
import 'package:bezoni/screens/restaurant/categories_screen.dart';
import 'package:bezoni/screens/restaurant/restaurant_details_screen.dart';
import 'package:bezoni/screens/settings/settings_screen.dart';
import 'package:bezoni/screens/settings/terms_conditions_screen.dart';
import 'package:bezoni/screens/splash.dart';
import 'package:bezoni/screens/support_screen.dart';
import 'package:bezoni/screens/wallet/wallet_screen.dart';
import 'package:bezoni/widgets/screen_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:bezoni/screens/onboarding.dart';
import 'package:bezoni/screens/auth/login_screen.dart';
import 'package:bezoni/screens/auth/signup_screen.dart';
import 'package:bezoni/screens/promo_codes_screen.dart';
import 'package:bezoni/screens/notifications_settings_screen.dart';

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

  // Profile sub-routes
  static const String personalDetails = '/personal_details';
  static const String orderHistory = '/order_history';
  static const String favorites = '/favorites';
  static const String promoCodes = '/promos';
  static const String notifications = '/notifications';
  static const String help = '/help';
  static const String termsConditions = '/terms';
  static const String privacyPolicy = '/privacy';
  static const String addresses = '/addresses';
  static const String payment = '/payment_methods';
  static const String trackOrder = '/track_order';

  // Other routes
  static const String categories = '/categories';
  static const String wallet = '/wallet';
  static const String restaurant = '/restaurant';
  static const String preferences = '/preferences';
  static const String settingscreen = '/settings';
  static const String support = '/support';
  static const String apiDiagnostic = '/api_diagnostic';

  // Generate routes with proper error handling
  static Route<dynamic> generateRoute(RouteSettings settings) {
    debugPrint('🧭 Navigating to: ${settings.name}');

    try {
      switch (settings.name) {
        // ============ Authentication Routes ============
        case splash:
          return _buildRoute(const SplashScreen(), settings);

        case onboarding:
          return _buildRoute(const OnboardingScreen(), settings);

        case login:
          return _buildRoute(const UserLoginScreen(), settings);

        case signup:
          return _buildRoute(const UserSignupScreen(), settings);

        // ============ Main Navigation ============
        case home:
          return _buildRoute(const MainNavigation(), settings);

        // ============ Tab Routes ============
        case search:
          return _buildRoute(const SearchScreen(), settings);

        case cart:
          return _buildRoute(
            const CartTabWrapper(child: CartScreen()),
            settings,
          );

        case profile:
          return _buildRoute(
            const ProfileTabWrapper(child: ProfileScreen()),
            settings,
          );

        // ============ Settings & Support ============
        case settingscreen:
          return _buildRoute(const SettingsScreen(), settings);

        // ============ Profile Sub-Routes ============
        case personalDetails:
          return _buildWrappedRoute(const PersonalDetailsScreen(), settings);

        case orderHistory:
          return _buildWrappedRoute(const OrderHistoryScreen(), settings);

        case favorites:
          return _buildWrappedRoute(const FavoritesScreen(), settings);

        case promoCodes:
          return _buildWrappedRoute(const PromoCodesScreen(), settings);

        case notifications:
          return _buildWrappedRoute(
            const NotificationsSettingsScreen(),
            settings,
          );

        case help:
          return _buildWrappedRoute(const SupportScreen(), settings);

        case termsConditions:
          return _buildWrappedRoute(const TermsConditionsScreen(), settings);

        case privacyPolicy:
          return _buildWrappedRoute(const PrivacyPolicyScreen(), settings);

        case addresses:
          return _buildWrappedRoute(const AddressesScreen(), settings);

        case payment:
          return _buildWrappedRoute(const PaymentMethodsScreen(), settings);

        // ============ Other Routes ============
        case categories:
          return _buildWrappedRoute(const CategoriesScreen(), settings);

        case wallet:
          return _buildWrappedRoute(const WalletScreen(), settings);

        case restaurant:
          return _buildWrappedRoute(const RestaurantDetailsScreen(), settings);

        case trackOrder:
          final order = settings.arguments as OrderResponse;
          return MaterialPageRoute(
            builder: (_) => OrderTrackingScreen(order: order),
          );

        case apiDiagnostic:
          return MaterialPageRoute(builder: (_) => const ApiDiagnosticScreen());
        // ============ Default/Error Route ============
        default:
          return _buildRoute(
            RouteNotFoundScreen(routeName: settings.name ?? 'Unknown'),
            settings,
          );
      }
    } catch (e) {
      debugPrint('❌ Error building route ${settings.name}: $e');
      return _buildRoute(
        RouteErrorScreen(
          routeName: settings.name ?? 'Unknown',
          error: e.toString(),
        ),
        settings,
      );
    }
  }

  // Helper method to build standard routes
  static MaterialPageRoute _buildRoute(Widget screen, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => screen, settings: settings);
  }

  // Helper method to build wrapped routes (with back button, no bottom nav)
  static MaterialPageRoute _buildWrappedRoute(
    Widget screen,
    RouteSettings settings,
  ) {
    return MaterialPageRoute(
      builder: (_) => ScreenWrapper(
        currentRoute: settings.name!,
        showBottomNav: false,
        child: screen,
      ),
      settings: settings,
    );
  }

  // ============================================================================
  // NAVIGATION HELPERS
  // ============================================================================

  /// Navigate to a route
  static Future<dynamic> navigateTo(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  /// Replace current route
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

  /// Clear navigation stack and navigate
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

  /// Go back
  static void goBack(BuildContext context, {dynamic result}) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context, result);
    } else {
      debugPrint('⚠️ Cannot pop - no routes in stack');
    }
  }

  /// Check if can go back
  static bool canGoBack(BuildContext context) {
    return Navigator.canPop(context);
  }

  /// Pop until a specific route
  static void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }

  /// Get current route name
  static String? getCurrentRoute(BuildContext context) {
    return ModalRoute.of(context)?.settings.name;
  }
}

// ============================================================================
// PLACEHOLDER SCREENS FOR MISSING ROUTES
// ============================================================================

/// Privacy Policy Screen placeholder
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Last updated: ${DateTime.now().toString().split(' ')[0]}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Information We Collect',
              'We collect information you provide directly to us, such as when you create an account, place an order, or contact customer support.',
            ),
            _buildSection(
              context,
              'How We Use Your Information',
              'We use the information we collect to provide, maintain, and improve our services, process your orders, and communicate with you.',
            ),
            _buildSection(
              context,
              'Information Sharing',
              'We do not share your personal information with third parties except as described in this policy or with your consent.',
            ),
            _buildSection(
              context,
              'Data Security',
              'We implement appropriate security measures to protect your personal information from unauthorized access, alteration, or destruction.',
            ),
            _buildSection(
              context,
              'Your Rights',
              'You have the right to access, update, or delete your personal information. Contact us at privacy@bezoni.com for assistance.',
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'For questions about our privacy policy, contact us at privacy@bezoni.com',
                      style: TextStyle(fontSize: 14),
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

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}

/// Track Order Screen placeholder
class TrackOrderScreen extends StatelessWidget {
  const TrackOrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Order'), elevation: 0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_shipping_outlined,
                size: 100,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                'Track Your Order',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Real-time order tracking coming soon!\nYou\'ll be able to see exactly where your order is.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
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

/// Route Not Found Error Screen
class RouteNotFoundScreen extends StatelessWidget {
  final String routeName;

  const RouteNotFoundScreen({Key? key, required this.routeName})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
        backgroundColor: Colors.red.shade700,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 100, color: Colors.red.shade300),
              const SizedBox(height: 24),
              Text(
                '404',
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Page Not Found',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Route: $routeName',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacementNamed(context, AppRoutes.home);
                      }
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.home,
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Home'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Route Error Screen
class RouteErrorScreen extends StatelessWidget {
  final String routeName;
  final String error;

  const RouteErrorScreen({
    Key? key,
    required this.routeName,
    required this.error,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation Error'),
        backgroundColor: Colors.orange.shade700,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 100,
                color: Colors.orange.shade300,
              ),
              const SizedBox(height: 24),
              Text(
                'Navigation Error',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Route: $routeName',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Error: $error',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text('Return Home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
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
