// File: lib/screens/home_screen.dart (Updated with Enhanced Categories)
import 'package:bezoni/screens/restaurant/categories_screen.dart';
import 'package:bezoni/screens/restaurant/restaurant_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bezoni/core/api_client.dart';
import 'package:bezoni/core/api_models.dart';
import 'package:bezoni/themes/theme_extensions.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onCartUpdated;
  
  const HomeScreen({super.key, this.onCartUpdated});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ApiClient _apiClient = ApiClient();
  UserProfile? _userProfile;
  List<Vendor>? _vendors;
  bool _isLoadingProfile = true;
  bool _isLoadingVendors = true;
  bool _welcomeShown = false;
  String? _vendorError;

  late final AnimationController _fadeCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(
    parent: _fadeCtrl,
    curve: Curves.easeInOut,
  );

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await _apiClient.initialize();
    await Future.wait([_loadUserProfile(), _loadVendors()]);

    if (!_welcomeShown && mounted) {
      _welcomeShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showWelcomeDialog();
      });
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      debugPrint('🔍 Loading user profile...');
      final response = await _apiClient.getProfile();

      if (response.isSuccess && response.data != null) {
        setState(() {
          _userProfile = response.data;
          _isLoadingProfile = false;
        });
        debugPrint('✅ Profile loaded: ${_userProfile!.name}');
      } else {
        setState(() => _isLoadingProfile = false);
        debugPrint('⚠️ Profile load error: ${response.errorMessage}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.errorMessage ?? 'Failed to load profile'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      setState(() => _isLoadingProfile = false);
      debugPrint('❌ Profile load exception: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  Future<void> _loadVendors() async {
    if (!mounted) return;

    debugPrint('🔍 Starting vendor load...');
    setState(() {
      _isLoadingVendors = true;
      _vendorError = null;
    });

    try {
      final response = await _apiClient.getAvailableVendors();
      if (!mounted) return;

      if (response.isSuccess) {
        if (response.data != null && response.data!.isNotEmpty) {
          setState(() {
            _vendors = response.data;
            _isLoadingVendors = false;
          });
          debugPrint('✅ Vendors loaded: ${_vendors!.length} vendors');
        } else {
          setState(() {
            _vendors = [];
            _isLoadingVendors = false;
            _vendorError = 'No restaurants available yet.\n\nVendors need to create profiles first.';
          });
        }
      } else {
        setState(() {
          _isLoadingVendors = false;
          _vendorError = response.errorMessage ?? 'Failed to load restaurants';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingVendors = false;
        _vendorError = 'Error loading restaurants: ${e.toString()}';
      });
    }
  }

  Future<void> _refreshData() async {
    HapticFeedback.lightImpact();
    await Future.wait([_loadUserProfile(), _loadVendors()]);
  }

  void _showWelcomeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: context.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  Icons.celebration,
                  color: context.successColor,
                  size: 40,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                "Welcome to Bezoni!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: context.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "We're excited to have you on board! From hot meals to urgent parcels, we deliver what you need—fast and hassle-free.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: context.subtitleColor,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Let's Go!",
                    style: TextStyle(
                      color: context.isDarkMode ? Colors.black : Colors.white,
                      fontWeight: FontWeight.w700,
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

  void _navigateToCategories() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoriesScreen(onCartUpdated: widget.onCartUpdated),
      ),
    );
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: RefreshIndicator(
            onRefresh: _refreshData,
            color: context.primaryColor,
            child: _HomeContent(
              userProfile: _userProfile,
              vendors: _vendors,
              isLoadingVendors: _isLoadingVendors,
              vendorError: _vendorError,
              onSearch: () => Navigator.pushNamed(context, '/search'),
              onRetryVendors: _loadVendors,
              onCartUpdated: widget.onCartUpdated,
              onNavigateToCategories: _navigateToCategories,
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final UserProfile? userProfile;
  final List<Vendor>? vendors;
  final bool isLoadingVendors;
  final String? vendorError;
  final VoidCallback onSearch;
  final VoidCallback onRetryVendors;
  final VoidCallback? onCartUpdated;
  final VoidCallback onNavigateToCategories;

  const _HomeContent({
    this.userProfile,
    this.vendors,
    required this.isLoadingVendors,
    this.vendorError,
    required this.onSearch,
    required this.onRetryVendors,
    this.onCartUpdated,
    required this.onNavigateToCategories,
  });

  @override
  Widget build(BuildContext context) {
    final address = userProfile?.address ?? "Herbert Macaulay Way, Yaba...";
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Column(
      children: [
        // Header Section
        Container(
          color: context.surfaceColor,
          padding: EdgeInsets.fromLTRB(
            isTablet ? 24 : 16,
            isSmallScreen ? 12 : 14,
            isTablet ? 24 : 16,
            16,
          ),
          child: Column(
            children: [
              // Location & Notifications
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: context.subtitleColor,
                    size: isSmallScreen ? 20 : (isTablet ? 26 : 24),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : (isTablet ? 17 : 16),
                        color: context.textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: context.subtitleColor,
                      size: isSmallScreen ? 22 : (isTablet ? 26 : 24),
                    ),
                    onPressed: () => Navigator.pushNamed(context, '/notifications'),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 10 : 12),

              // Search Bar
              GestureDetector(
                onTap: onSearch,
                child: Container(
                  decoration: BoxDecoration(
                    color: context.isDarkMode
                        ? context.colors.surfaceVariant
                        : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.isDarkMode
                          ? context.colors.outline
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : (isTablet ? 18 : 16),
                    vertical: isSmallScreen ? 12 : (isTablet ? 16 : 14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: context.subtitleColor,
                        size: isSmallScreen ? 20 : (isTablet ? 26 : 24),
                      ),
                      SizedBox(width: isSmallScreen ? 10 : 12),
                      Text(
                        "Search for food, restaurants...",
                        style: TextStyle(
                          color: context.subtitleColor,
                          fontSize: isSmallScreen ? 13 : (isTablet ? 15 : 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Scrollable Content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _PromoBanner(),
                SizedBox(height: isSmallScreen ? 6 : 8),

                // Categories Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Categories",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : (isTablet ? 20 : 18),
                          fontWeight: FontWeight.w800,
                          color: context.textColor,
                        ),
                      ),
                      TextButton(
                        onPressed: onNavigateToCategories,
                        child: Text(
                          "See all",
                          style: TextStyle(
                            color: context.primaryColor,
                            fontSize: isSmallScreen ? 13 : (isTablet ? 15 : 14),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 10 : 12),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                  child: _CategoriesGrid(onNavigateToCategories: onNavigateToCategories),
                ),

                SizedBox(height: isSmallScreen ? 16 : 18),

                // Featured Restaurants
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                  child: Text(
                    "Featured Restaurants",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : (isTablet ? 20 : 18),
                      fontWeight: FontWeight.w800,
                      color: context.textColor,
                    ),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 10 : 12),

                // Vendors List
                if (isLoadingVendors)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                    child: Column(
                      children: List.generate(3, (_) => const _VendorCardSkeleton()),
                    ),
                  )
                else if (vendorError != null)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 56,
                            color: context.errorColor.withOpacity(0.8),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            vendorError!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: context.textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: onRetryVendors,
                            icon: const Icon(Icons.refresh, size: 20),
                            label: const Text('Try Again'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (vendors == null || vendors!.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.store_outlined,
                            size: 56,
                            color: context.subtitleColor.withOpacity(0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No restaurants available",
                            style: TextStyle(
                              color: context.textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Restaurants will appear here once vendors create their profiles.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: context.subtitleColor.withOpacity(0.8),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                    child: Column(
                      children: vendors!.map((vendor) {
                        return _VendorCard(
                          vendor: vendor,
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/restaurant',
                            arguments: vendor,
                          ),
                          onCartUpdated: onCartUpdated,
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// =====================
/// Promo Banner Widget
/// =====================
class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Container(
      margin: EdgeInsets.all(isTablet ? 24 : 16),
      padding: EdgeInsets.all(isSmallScreen ? 14 : (isTablet ? 20 : 16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: context.isDarkMode
              ? [
                  context.primaryColor.withOpacity(0.8),
                  context.primaryColor.withOpacity(0.6),
                ]
              : [context.primaryColor, context.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: context.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Get 20% Off Your First Order!",
                  style: TextStyle(
                    color: context.isDarkMode ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: isSmallScreen ? 14 : (isTablet ? 18 : 16),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Use the code: WELCOME20",
                  style: TextStyle(
                    color: context.isDarkMode
                        ? Colors.black.withOpacity(0.8)
                        : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 12 : (isTablet ? 14 : 13),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 8 : (isTablet ? 12 : 10),
              vertical: isSmallScreen ? 6 : (isTablet ? 10 : 8),
            ),
            decoration: BoxDecoration(
              color: context.isDarkMode
                  ? Colors.black.withOpacity(0.2)
                  : Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "20%",
              style: TextStyle(
                color: context.isDarkMode ? Colors.black : Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: isSmallScreen ? 14 : (isTablet ? 18 : 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// =====================
/// Categories Grid Widget
/// =====================
class _CategoriesGrid extends StatelessWidget {
  final VoidCallback onNavigateToCategories;
  
  const _CategoriesGrid({required this.onNavigateToCategories});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth > 600;
    final crossAxisCount = isTablet ? 4 : (isSmallScreen ? 2 : 3);
    final childAspectRatio = isTablet ? 0.95 : (isSmallScreen ? 0.9 : 0.86);

    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio,
      mainAxisSpacing: isTablet ? 14 : 12,
      crossAxisSpacing: isTablet ? 14 : 12,
      children: [
        _CategoryTile(
          title: "Food\nDelivery",
          icon: Icons.restaurant,
          color: const Color(0xFFEF4444),
          onTap: onNavigateToCategories,
        ),
        _CategoryTile(
          title: "Parcel\nDelivery",
          icon: Icons.local_shipping,
          color: const Color(0xFF10B981),
          onTap: onNavigateToCategories,
        ),
        _CategoryTile(
          title: "Groceries",
          icon: Icons.shopping_bag,
          color: const Color(0xFF8B5CF6),
          onTap: onNavigateToCategories,
        ),
        _CategoryTile(
          title: "Drinks",
          icon: Icons.local_drink,
          color: const Color(0xFF0EA5E9),
          onTap: onNavigateToCategories,
        ),
        _CategoryTile(
          title: "Snacks",
          icon: Icons.cookie_outlined,
          color: const Color(0xFFF59E0B),
          onTap: onNavigateToCategories,
        ),
        _CategoryTile(
          title: "Pharmacy",
          icon: Icons.local_pharmacy,
          color: const Color(0xFF10B981),
          onTap: onNavigateToCategories,
        ),
      ],
    );
  }
}

/// =====================
/// Category Tile Widget
/// =====================
class _CategoryTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    final isTablet = MediaQuery.of(context).size.width > 600;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(context.isDarkMode ? 0.15 : 0.10),
              context.surfaceColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: ThemeUtils.createShadow(context, elevation: 2),
        ),
        padding: EdgeInsets.all(isSmallScreen ? 10 : (isTablet ? 14 : 12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 8 : (isTablet ? 12 : 10)),
              decoration: BoxDecoration(
                color: color.withOpacity(context.isDarkMode ? 0.20 : 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: isSmallScreen ? 20 : (isTablet ? 28 : 24),
              ),
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmallScreen ? 11 : (isTablet ? 13 : 12),
                fontWeight: FontWeight.w700,
                color: context.textColor,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// =====================
/// Vendor Card & Skeleton (Same as before)
/// =====================
class _VendorCard extends StatelessWidget {
  final Vendor vendor;
  final VoidCallback onTap;
  final VoidCallback? onCartUpdated;

  const _VendorCard({
    required this.vendor,
    required this.onTap,
    this.onCartUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    final color = _getVendorColor(vendor.type);

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 10 : 14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: ThemeUtils.createShadow(context, elevation: 2),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RestaurantDetailsScreen(
                vendor: vendor,
                onCartUpdated: onCartUpdated,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: isSmallScreen ? 70 : 86,
                  height: isSmallScreen ? 70 : 86,
                  color: color.withOpacity(context.isDarkMode ? 0.25 : 0.18),
                  child: Icon(
                    Icons.restaurant,
                    color: color,
                    size: isSmallScreen ? 32 : 42,
                  ),
                ),
              ),
              SizedBox(width: isSmallScreen ? 12 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (vendor.isAvailable != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: vendor.isAvailable!
                              ? context.successColor.withOpacity(0.1)
                              : context.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          vendor.isAvailable! ? "Open Now" : "Closed",
                          style: TextStyle(
                            fontSize: 11,
                            color: vendor.isAvailable!
                                ? context.successColor
                                : context.errorColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      vendor.name,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w800,
                        color: context.textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (vendor.city != null)
                      Text(
                        vendor.city!,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 11 : 12,
                          color: context.subtitleColor,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color.withOpacity(0.2),
                          ),
                          child: Icon(Icons.star, size: 12, color: color),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "4.5",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.textColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "• ${vendor.type}",
                          style: TextStyle(
                            fontSize: 11,
                            color: context.subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getVendorColor(String type) {
    switch (type.toUpperCase()) {
      case 'RESTAURANT':
        return const Color(0xFFEF4444);
      case 'GROCERY':
        return const Color(0xFF10B981);
      case 'PHARMACY':
        return const Color(0xFF8B5CF6);
      case 'CAFE':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6366F1);
    }
  }
}

/// =====================
/// Vendor Card Skeleton (Loading State)
/// =====================
class _VendorCardSkeleton extends StatelessWidget {
  const _VendorCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: ThemeUtils.createShadow(context, elevation: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: context.dividerColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 12,
                  decoration: BoxDecoration(
                    color: context.dividerColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: context.dividerColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: context.dividerColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}