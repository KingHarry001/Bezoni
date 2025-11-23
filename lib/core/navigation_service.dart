import 'package:flutter/material.dart';

/// Navigation service for managing app routing and tab navigation
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  // Tab indices
  static const int HOME_INDEX = 0;
  static const int SEARCH_INDEX = 1;
  static const int CART_INDEX = 2;
  static const int PROFILE_INDEX = 4;

  // Route names
  static const String homeRoute = '/home';
  static const String searchRoute = '/search';
  static const String cartRoute = '/cart';
  static const String profileRoute = '/profile';
  static const String categoriesRoute = '/categories';
  static const String restaurantRoute = '/restaurant';
  static const String preferencesRoute = '/preferences';
  static const String settingsRoute = '/settings';

  // Map route names to indices
  int getIndexFromRouteName(String route) {
    switch (route) {
      case homeRoute:
        return HOME_INDEX;
      case searchRoute:
        return SEARCH_INDEX;
      case cartRoute:
        return CART_INDEX;
      case profileRoute:
        return PROFILE_INDEX;
      default:
        return HOME_INDEX;
    }
  }

  // Map indices to route names
  String getRouteNameFromIndex(int index) {
    switch (index) {
      case HOME_INDEX:
        return homeRoute;
      case SEARCH_INDEX:
        return searchRoute;
      case CART_INDEX:
        return cartRoute;
      case PROFILE_INDEX:
        return profileRoute;
      default:
        return homeRoute;
    }
  }

  // Navigate to a specific tab
  void navigateToTab(BuildContext context, int index) {
    final routeName = getRouteNameFromIndex(index);
    
    // Use pushReplacementNamed to avoid stacking tab screens
    Navigator.pushReplacementNamed(context, routeName);
  }

  // Navigate to a specific route
  void navigateTo(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  // Navigate and replace current route
  void navigateAndReplace(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  // Pop current route
  void pop(BuildContext context, {dynamic result}) {
    Navigator.pop(context, result);
  }

  // Pop until specific route
  void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }

  // Clear stack and navigate to route
  void clearStackAndNavigate(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
}