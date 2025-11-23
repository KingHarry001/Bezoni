
import 'package:bezoni/screens/common/cart_screen.dart';
import 'package:bezoni/screens/common/search_screen.dart';
import 'package:bezoni/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:bezoni/themes/theme_extensions.dart';
import 'package:bezoni/screens/home_screen.dart';
import 'package:bezoni/core/api_client.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> with WidgetsBindingObserver {
  late int _currentIndex;
  late PageController _pageController;
  final ApiClient _apiClient = ApiClient();
  
  // Cart state
  int _cartItemCount = 0;
  bool _isLoadingCart = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Get initial index from route arguments if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final initialIndex = args?['initialIndex'] ?? 0;
      if (initialIndex != 0) {
        _onTabTapped(initialIndex);
      }
    });
    
    _currentIndex = 0;
    _pageController = PageController(initialPage: 0);
    
    // Load cart count initially
    _loadCartCount();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh cart when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      _loadCartCount();
    }
  }

  // Load cart count from API
  Future<void> _loadCartCount() async {
    if (_isLoadingCart) return;
    
    setState(() {
      _isLoadingCart = true;
    });

    try {
      await _apiClient.initialize();
      final response = await _apiClient.getCart();
      
      if (response.isSuccess && response.data != null) {
        final cart = response.data!;
        
        // Use totalItems from CartResponse (already an int)
        if (mounted) {
          setState(() {
            _cartItemCount = cart.totalItems;
            _isLoadingCart = false;
          });
        }
        
        debugPrint('🛒 Cart updated: $_cartItemCount items');
      } else {
        if (mounted) {
          setState(() {
            _cartItemCount = 0;
            _isLoadingCart = false;
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading cart count: $e');
      if (mounted) {
        setState(() {
          _cartItemCount = 0; // Reset to 0 on error
          _isLoadingCart = false;
        });
      }
    }
  }

  // Public method to refresh cart from child screens
  void refreshCart() {
    _loadCartCount();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    
    // Refresh cart count when switching tabs
    if (index == 2) {
      // Going to cart tab
      _loadCartCount();
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Refresh cart count when page changes
    if (index == 2) {
      _loadCartCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe
        children: [
          // Home Tab - Pass callback to refresh cart
          HomeScreen(onCartUpdated: _loadCartCount),

          // Search Tab
          SearchScreen(),

          // Cart Tab - Pass callback to refresh cart
          CartScreen(onCartUpdated: _loadCartCount),

          // Profile Tab
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          boxShadow: [
            BoxShadow(
              color: context.shadowColor,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.search_outlined,
                  activeIcon: Icons.search,
                  label: 'Search',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.shopping_cart_outlined,
                  activeIcon: Icons.shopping_cart,
                  label: 'Cart',
                  index: 2,
                  showBadge: _cartItemCount > 0,
                  badgeCount: _cartItemCount,
                ),
                _buildNavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    bool showBadge = false,
    int badgeCount = 0,
  }) {
    final isActive = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _onTabTapped(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    isActive ? activeIcon : icon,
                    color: isActive
                        ? const Color(0xFF2ECC40)
                        : context.subtitleColor,
                    size: 24,
                  ),
                  if (showBadge && badgeCount > 0)
                    Positioned(
                      right: -8,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          badgeCount > 99 ? '99+' : badgeCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? const Color(0xFF2ECC40)
                      : context.subtitleColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}