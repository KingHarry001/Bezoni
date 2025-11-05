import 'package:bezoni/core/navigation_service.dart';
import 'package:flutter/material.dart';
import 'bottom_navigation.dart';

/// Wrapper widget that provides consistent layout with bottom navigation
class ScreenWrapper extends StatelessWidget {
  final Widget child;
  final String currentRoute;
  final bool showBottomNav;
  final Color? backgroundColor;
  final PreferredSizeWidget? appBar;

  const ScreenWrapper({
    Key? key,
    required this.child,
    required this.currentRoute,
    this.showBottomNav = true,
    this.backgroundColor,
    this.appBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigationService = NavigationService();
    final currentIndex = navigationService.getIndexFromRouteName(currentRoute);

    return Scaffold(
      backgroundColor: backgroundColor ?? const Color(0xFFF8F9FA),
      appBar: appBar,
      body: child,
      bottomNavigationBar: showBottomNav 
          ? BottomNavigation(currentIndex: currentIndex) 
          : null,
    );
  }
}

/// Wrapper for home tab screens that need consistent bottom navigation
class HomeTabWrapper extends StatelessWidget {
  final Widget child;

  const HomeTabWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      currentRoute: NavigationService.homeRoute,
      child: child,
    );
  }
}

/// Wrapper for search screen
class SearchTabWrapper extends StatelessWidget {
  final Widget child;

  const SearchTabWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      currentRoute: NavigationService.searchRoute,
      child: child,
    );
  }
}

/// Wrapper for cart screen
class CartTabWrapper extends StatelessWidget {
  final Widget child;

  const CartTabWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      currentRoute: NavigationService.cartRoute,
      child: child,
    );
  }
}

/// Wrapper for messages screen
class MessagesTabWrapper extends StatelessWidget {
  final Widget child;

  const MessagesTabWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      currentRoute: NavigationService.messagesRoute,
      child: child,
    );
  }
}

/// Wrapper for profile screen
class ProfileTabWrapper extends StatelessWidget {
  final Widget child;

  const ProfileTabWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      currentRoute: NavigationService.profileRoute,
      child: child,
    );
  }
}