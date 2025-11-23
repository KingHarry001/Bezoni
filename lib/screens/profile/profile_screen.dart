import 'package:bezoni/screens/auth/email_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:bezoni/themes/theme_extensions.dart';
import 'package:bezoni/core/api_client.dart';
import 'package:bezoni/core/api_models.dart';
import 'package:bezoni/utils/auth_utils.dart';
import 'package:bezoni/services/theme_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final ApiClient _apiClient = ApiClient();
  UserProfile? _userProfile;
  WalletBalance? _walletBalance;
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final Map<String, dynamic> _stats = {'orders': 0, 'saved': 0.0, 'points': 0};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _initializeProfile();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeProfile() async {
    await _apiClient.initialize();
    await _loadAllData();
    _animationController.forward();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.wait([
      _loadUserProfile(),
      _loadUserStats(),
      _loadWalletBalance(),
    ]);

    setState(() {
      _isLoading = false;
    });
  }

  // FIXED: Better profile loading with caching
  Future<void> _loadUserProfile() async {
    try {
      debugPrint('🔄 Loading user profile...');

      final response = await _apiClient.getProfile();

      if (response.isSuccess && response.data != null) {
        final profile = response.data!;

        debugPrint('✅ Profile data received:');
        debugPrint('   ID: ${profile.id}');
        debugPrint('   Name: ${profile.name}');
        debugPrint('   Email: ${profile.email}');
        debugPrint('   Phone: ${profile.phone}');
        debugPrint('   Verified: ${profile.emailVerified}');

        // Save to cache
        await _saveProfileToCache(profile);

        if (mounted) {
          setState(() {
            _userProfile = profile;
            _errorMessage = null;
          });
        }
      } else {
        debugPrint('⚠️ Profile API failed: ${response.errorMessage}');

        // Try cache as fallback
        final cachedProfile = await _loadProfileFromCache();

        if (cachedProfile != null && mounted) {
          debugPrint('📦 Using cached profile data');
          setState(() {
            _userProfile = cachedProfile;
            _errorMessage = null;
          });
        } else {
          if (mounted) {
            setState(() {
              _errorMessage = response.errorMessage ?? 'Failed to load profile';
            });
          }
        }
      }
    } catch (e, stack) {
      debugPrint('❌ Profile exception: $e');
      debugPrint('   Stack: $stack');

      // Try cache on exception
      final cachedProfile = await _loadProfileFromCache();

      if (cachedProfile != null && mounted) {
        debugPrint('📦 Using cached profile after error');
        setState(() {
          _userProfile = cachedProfile;
          _errorMessage = null;
        });
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Error loading profile: ${e.toString()}';
          });
        }
      }
    }
  }

  Future<void> _saveProfileToCache(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', profile.id);
      await prefs.setString('user_name', profile.name);
      await prefs.setString('user_email', profile.email);
      if (profile.phone != null) {
        await prefs.setString('user_phone', profile.phone!);
      }
      if (profile.address != null) {
        await prefs.setString('user_address', profile.address!);
      }
      await prefs.setBool('email_verified', profile.emailVerified);
      debugPrint('💾 Profile cached successfully');
    } catch (e) {
      debugPrint('⚠️ Could not cache profile: $e');
    }
  }

  Future<UserProfile?> _loadProfileFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('user_name');
      final savedEmail = prefs.getString('user_email');

      if (savedName != null && savedEmail != null) {
        debugPrint('📦 Loaded profile from cache');
        return UserProfile(
          id: prefs.getString('user_id') ?? '',
          role: 'USER',
          name: savedName,
          email: savedEmail,
          phone: prefs.getString('user_phone'),
          address: prefs.getString('user_address'),
          emailVerified: prefs.getBool('email_verified') ?? false,
        );
      }
    } catch (e) {
      debugPrint('⚠️ Could not load cached profile: $e');
    }
    return null;
  }

  Future<void> _loadUserStats() async {
    try {
      final ordersResponse = await _apiClient.getUserOrders();
      if (ordersResponse.isSuccess && ordersResponse.data != null) {
        final orders = ordersResponse.data!;
        final completedOrders = orders
            .where((o) => o.status == 'DELIVERED' || o.status == 'COMPLETED')
            .toList();

        if (mounted) {
          setState(() {
            _stats['orders'] = completedOrders.length;
            _stats['saved'] = completedOrders.fold<double>(
              0,
              (sum, order) => sum + (order.total * 0.05),
            );
            _stats['points'] = completedOrders.length * 50;
          });
        }
        debugPrint('✅ Stats loaded: ${_stats['orders']} orders');
      }
    } catch (e) {
      debugPrint('⚠️ Error loading stats: ${e.toString()}');
    }
  }

  Future<void> _loadWalletBalance() async {
    try {
      final response = await _apiClient.getWalletBalance();
      if (response.isSuccess && response.data != null) {
        if (mounted) {
          setState(() {
            _walletBalance = response.data;
          });
        }
        debugPrint('✅ Wallet balance: ₦${_walletBalance!.balance}');
      } else {
        debugPrint('⚠️ Wallet load failed: ${response.errorMessage}');
        // Don't show error, just keep wallet as null
        if (mounted) {
          setState(() {
            _walletBalance = null;
          });
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error loading wallet: ${e.toString()}');
      if (mounted) {
        setState(() {
          _walletBalance = null;
        });
      }
    }
  }

  Future<void> _refreshProfile() async {
    setState(() {
      _isRefreshing = true;
    });
    await _loadAllData();
    setState(() {
      _isRefreshing = false;
    });
    if (!mounted) return;
    _showToast(context, 'Profile refreshed');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1500),
                builder: (context, value, child) {
                  return CircularProgressIndicator(
                    value: value,
                    color: context.primaryColor,
                    strokeWidth: 3,
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Loading your profile...',
                style: TextStyle(
                  color: context.subtitleColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null && _userProfile == null) {
      return Scaffold(
        backgroundColor: context.backgroundColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.errorColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 64,
                    color: context.errorColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Oops! Something went wrong',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: context.textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.subtitleColor, fontSize: 15),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _loadAllData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
                const SizedBox(height: 16),
                // DEBUG BUTTON - Remove in production
                TextButton.icon(
                  onPressed: () async {
                    debugPrint('🔍 === PROFILE DIAGNOSTIC ===');
                    final raw = await _apiClient.getRawResponse('/auth/me');
                    debugPrint('📥 Raw Response: ${raw['body']}');
                    final profile = await _apiClient.getProfile();
                    debugPrint('📊 Success: ${profile.isSuccess}');
                    debugPrint('📊 Data: ${profile.data?.toJson()}');
                    _showToast(context, 'Check debug console');
                  },
                  icon: const Icon(Icons.bug_report),
                  label: const Text('Debug Profile'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Rest of your existing build method remains the same...
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        color: context.primaryColor,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _userProfile != null
                  ? ModernProfileHeader(
                      name: _userProfile!.name,
                      email: _userProfile!.email,
                      phone: _userProfile!.phone,
                      isVerified: _userProfile!.emailVerified,
                      onEditTap: () => _editProfile(context),
                      fadeAnimation: _fadeAnimation,
                    )
                  : Container(
                      height: 300,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            context.primaryColor,
                            context.primaryColor.withOpacity(0.8),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
            ),

            // Animated Stats Cards with Glassmorphism
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildGlassStatCard(
                            context,
                            icon: Icons.shopping_bag_outlined,
                            value: '${_stats['orders']}',
                            title: 'Orders',
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildGlassStatCard(
                            context,
                            icon: Icons.savings_outlined,
                            value: '₦${_stats['saved'].toStringAsFixed(0)}',
                            title: 'Saved',
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildGlassStatCard(
                            context,
                            icon: Icons.account_balance_wallet_outlined,
                            value: _formatWalletBalance(
                              _walletBalance?.balance ?? 0,
                            ),
                            title: 'Wallet',
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Email Verification Banner
            if (_userProfile != null && !_userProfile!.emailVerified)
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildModernVerificationBanner(),
                ),
              ),

            // Quick Actions with Modern Cards
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: context.textColor,
                        ),
                      ),
                      // const SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 4,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        children: [
                          _buildModernQuickAction(
                            context,
                            icon: Icons.receipt_long_outlined,
                            label: 'Orders',
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                            ),
                            onTap: () => _navigate(context, 'order_history'),
                          ),
                          _buildModernQuickAction(
                            context,
                            icon: Icons.favorite_outline,
                            label: 'Favorites',
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE91E63), Color(0xFFC2185B)],
                            ),
                            onTap: () => _navigate(context, 'favorites'),
                          ),
                          _buildModernQuickAction(
                            context,
                            icon: Icons.local_offer_outlined,
                            label: 'Promos',
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
                            ),
                            onTap: () => _navigate(context, 'promos'),
                          ),
                          _buildModernQuickAction(
                            context,
                            icon: Icons.account_balance_wallet_outlined,
                            label: 'Wallet',
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
                            ),
                            onTap: () =>
                                Navigator.pushNamed(context, '/wallet'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Modern Profile Sections
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    ModernProfileSection(
                      title: 'Account',
                      icon: Icons.person_outline,
                      items: [
                        ModernProfileItem(
                          icon: Icons.person_outline,
                          title: 'Personal Information',
                          subtitle: _userProfile?.name ?? 'Update your details',
                          onTap: () => _showPersonalInfoDialog(context),
                        ),
                        ModernProfileItem(
                          icon: Icons.location_on_outlined,
                          title: 'Delivery Address',
                          subtitle:
                              _userProfile?.address ?? 'Add delivery address',
                          onTap: () => _showAddressDialog(context),
                        ),
                        ModernProfileItem(
                          icon: Icons.phone_outlined,
                          title: 'Phone Number',
                          subtitle: _userProfile?.phone ?? 'Add phone number',
                          onTap: () => _showPersonalInfoDialog(context),
                        ),
                      ],
                    ),
                    ModernProfileSection(
                      title: 'Orders & Activity',
                      icon: Icons.shopping_bag_outlined,
                      items: [
                        ModernProfileItem(
                          icon: Icons.receipt_long_outlined,
                          title: 'Order History',
                          subtitle: '${_stats['orders']} completed orders',
                          onTap: () => _navigate(context, 'order_history'),
                        ),
                        ModernProfileItem(
                          icon: Icons.local_shipping_outlined,
                          title: 'Track Order',
                          subtitle: 'Track your active orders',
                          onTap: () => _navigate(context, 'track_order'),
                        ),
                        ModernProfileItem(
                          icon: Icons.favorite_outline,
                          title: 'Favorite Restaurants',
                          subtitle: 'Your saved restaurants',
                          onTap: () => _navigate(context, 'favorites'),
                        ),
                      ],
                    ),
                    ModernProfileSection(
                      title: 'Preferences',
                      icon: Icons.tune_outlined,
                      items: [
                        ModernProfileItem(
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          subtitle: 'Push, Email, SMS',
                          onTap: () => _navigate(context, 'notifications'),
                        ),
                        ModernProfileItem(
                          icon: Icons.dark_mode_outlined,
                          title: 'Appearance',
                          subtitle: _getThemeModeName(context),
                          onTap: () => _showThemeDialog(context),
                        ),
                        ModernProfileItem(
                          icon: Icons.language,
                          title: 'Language',
                          subtitle: 'English',
                          onTap: () => _showLanguageDialog(context),
                        ),
                      ],
                    ),
                    ModernProfileSection(
                      title: 'Help & Support',
                      icon: Icons.help_outline,
                      items: [
                        ModernProfileItem(
                          icon: Icons.help_outline,
                          title: 'Help & FAQ',
                          subtitle: 'Get quick answers',
                          onTap: () => _navigate(context, 'help'),
                        ),
                        ModernProfileItem(
                          icon: Icons.description_outlined,
                          title: 'Terms & Conditions',
                          onTap: () => _navigate(context, 'terms'),
                        ),
                        ModernProfileItem(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          onTap: () => _navigate(context, 'privacy'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Bezoni v1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.subtitleColor.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildModernLogoutButton(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String title,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: context.subtitleColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernVerificationBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.errorColor.withOpacity(0.1),
            context.errorColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.errorColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.errorColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: context.errorColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verify your email',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: context.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Unlock all features',
                  style: TextStyle(fontSize: 13, color: context.subtitleColor),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _sendVerificationEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.errorColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Verify',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              context.errorColor.withOpacity(0.1),
              context.errorColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showLogoutDialog(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: context.errorColor, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.errorColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Keep all your existing dialog methods from the original file...
  Future<void> _sendVerificationEmail() async {
    _showLoadingDialog(context, 'Sending verification email...');
    try {
      final response = await _apiClient.sendVerificationEmail();
      if (mounted) Navigator.pop(context);

      if (response.isSuccess) {
        if (!mounted) return;

        final verified = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) =>
                EmailVerificationScreen(email: _userProfile?.email),
          ),
        );

        if (verified == true && mounted) {
          debugPrint('✅ Email verified! Refreshing profile...');
          _showLoadingDialog(context, 'Updating profile...');
          await _loadUserProfile();
          if (mounted) {
            Navigator.pop(context);
            _showToast(context, 'Email verified successfully! ✓');
          }
        }
      } else {
        if (!mounted) return;
        _showToast(context, response.errorMessage ?? 'Failed to send email');
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (!mounted) return;
      _showToast(context, 'Error: ${e.toString()}');
    }
  }

  void _editProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: BoxDecoration(
          color: context.backgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Profile Options',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.textColor,
              ),
            ),
            const SizedBox(height: 24),
            _buildSheetOption(context, Icons.edit, 'Edit Profile', () {
              Navigator.pop(context);
              _showPersonalInfoDialog(context);
            }),
            _buildSheetOption(
              context,
              Icons.email,
              'Resend Verification Email',
              () {
                Navigator.pop(context);
                _sendVerificationEmail();
              },
            ),
            _buildSheetOption(context, Icons.lock_reset, 'Change Password', () {
              Navigator.pop(context);
              _showPasswordDialog(context);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetOption(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: context.primaryColor, size: 22),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPersonalInfoDialog(BuildContext context) {
    final nameController = TextEditingController(text: _userProfile?.name);
    final emailController = TextEditingController(text: _userProfile?.email);
    final phoneController = TextEditingController(text: _userProfile?.phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Update Profile',
          style: TextStyle(
            color: context.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(context, nameController, 'Name', Icons.person),
              const SizedBox(height: 16),
              _buildTextField(context, emailController, 'Email', Icons.email),
              const SizedBox(height: 16),
              _buildTextField(context, phoneController, 'Phone', Icons.phone),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.subtitleColor),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateProfile(
                name: nameController.text.trim(),
                email: emailController.text.trim(),
                phone: phoneController.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Update',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      style: TextStyle(color: context.textColor),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: context.primaryColor),
        filled: true,
        fillColor: context.backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: context.dividerColor.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: context.primaryColor, width: 2),
        ),
      ),
    );
  }

  void _showAddressDialog(BuildContext context) {
    final addressController = TextEditingController(
      text: _userProfile?.address,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Update Delivery Address',
          style: TextStyle(
            color: context.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: addressController,
          style: TextStyle(color: context.textColor),
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Address',
            prefixIcon: Icon(Icons.location_on, color: context.primaryColor),
            filled: true,
            fillColor: context.backgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: context.primaryColor, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.subtitleColor),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _showToast(context, 'Address updated (feature coming soon)');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Update',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    _showLoadingDialog(context, 'Updating profile...');
    try {
      final response = await _apiClient.updateProfile(
        name: name.isNotEmpty ? name : null,
        email: email.isNotEmpty ? email : null,
        phone: phone.isNotEmpty ? phone : null,
      );
      if (mounted) Navigator.pop(context);
      if (response.isSuccess) {
        await _loadUserProfile();
        if (!mounted) return;
        _showSuccessDialog(
          context,
          'Profile Updated',
          'Your profile has been updated successfully.',
        );
      } else {
        if (!mounted) return;
        _showToast(
          context,
          response.errorMessage ?? 'Failed to update profile',
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (!mounted) return;
      _showToast(context, 'Error: ${e.toString()}');
    }
  }

  void _showPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Change Password',
          style: TextStyle(
            color: context.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'An email with password reset instructions will be sent to ${_userProfile?.email}',
          style: TextStyle(color: context.subtitleColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.subtitleColor),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _sendPasswordReset();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Send Email',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendPasswordReset() async {
    if (_userProfile?.email == null) return;
    _showLoadingDialog(context, 'Sending reset email...');
    try {
      final response = await _apiClient.forgotPassword(_userProfile!.email);
      if (mounted) Navigator.pop(context);
      if (response.isSuccess) {
        if (!mounted) return;
        _showSuccessDialog(
          context,
          'Email Sent',
          'Password reset instructions have been sent to your email.',
        );
      } else {
        if (!mounted) return;
        _showToast(context, response.errorMessage ?? 'Failed to send email');
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (!mounted) return;
      _showToast(context, 'Error: ${e.toString()}');
    }
  }

  void _showWalletDetails(BuildContext context) {
    Navigator.pushNamed(context, '/wallet');
  }

  String _formatWalletBalance(double balance) {
    if (balance >= 1000000) {
      // Format as millions (1M, 2.5M, etc.)
      return '₦${(balance / 1000000).toStringAsFixed(1)}M';
    } else if (balance >= 1000) {
      // Format as thousands (1K, 2.5K, etc.)
      return '₦${(balance / 1000).toStringAsFixed(1)}K';
    } else {
      // Show full amount for under 1000
      return '₦${balance.toStringAsFixed(0)}';
    }
  }

  String _getThemeModeName(BuildContext context) {
    try {
      final themeService = Provider.of<ThemeService>(context, listen: false);
      return '${themeService.themeName} • ${themeService.themeDescription}';
    } catch (e) {
      final brightness = MediaQuery.of(context).platformBrightness;
      return brightness == Brightness.dark ? 'Dark mode' : 'Light mode';
    }
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.palette_outlined, color: context.primaryColor),
            const SizedBox(width: 12),
            Text(
              'Choose Theme',
              style: TextStyle(
                color: context.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _themeOption(
              context,
              Icons.light_mode,
              'Light Mode',
              'Clean and bright',
              AppTheme.light,
            ),
            const SizedBox(height: 12),
            _themeOption(
              context,
              Icons.dark_mode,
              'Dark Mode',
              'Easy on the eyes',
              AppTheme.dark,
            ),
            const SizedBox(height: 12),
            _themeOption(
              context,
              Icons.auto_mode,
              'System Default',
              'Follow device settings',
              AppTheme.system,
            ),
          ],
        ),
      ),
    );
  }

  Widget _themeOption(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    AppTheme theme,
  ) {
    bool isSelected = false;
    try {
      final themeService = Provider.of<ThemeService>(context, listen: false);
      isSelected = themeService.currentTheme == theme;
    } catch (e) {
      isSelected = false;
    }

    return InkWell(
      onTap: () async {
        try {
          final themeService = Provider.of<ThemeService>(
            context,
            listen: false,
          );
          await themeService.setTheme(theme);
          Navigator.pop(context);
          _showToast(context, '$title selected');
        } catch (e) {
          Navigator.pop(context);
          _showToast(context, 'Theme service not available');
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? context.primaryColor.withOpacity(0.1)
              : context.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? context.primaryColor
                : context.dividerColor.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.primaryColor.withOpacity(0.2)
                    : context.dividerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? context.primaryColor
                    : context.subtitleColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: context.textColor,
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: context.subtitleColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: context.primaryColor, size: 24),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Select Language',
          style: TextStyle(
            color: context.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _languageOption(context, '🇬🇧', 'English', true),
            const SizedBox(height: 8),
            _languageOption(context, '🇪🇸', 'Spanish', false),
            const SizedBox(height: 8),
            _languageOption(context, '🇫🇷', 'French', false),
            const SizedBox(height: 8),
            _languageOption(context, '🇳🇬', 'Yoruba', false),
          ],
        ),
      ),
    );
  }

  Widget _languageOption(
    BuildContext context,
    String flag,
    String language,
    bool selected,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _showToast(context, '$language selected');
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? context.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: selected
              ? Border.all(color: context.primaryColor, width: 2)
              : null,
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                language,
                style: TextStyle(
                  color: context.textColor,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: context.primaryColor, size: 24),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.logout, color: context.errorColor, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Logout',
              style: TextStyle(
                color: context.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to logout of your account?',
          style: TextStyle(color: context.subtitleColor, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: context.subtitleColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _showLoadingDialog(context, 'Logging out...');
              try {
                await _apiClient.logout();
                await AuthUtils.clearSavedCredentials();
                if (mounted) {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login');
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  _showToast(context, 'Logout failed: ${e.toString()}');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.errorColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          backgroundColor: context.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: context.primaryColor,
                strokeWidth: 3,
              ),
              const SizedBox(height: 20),
              Text(
                message,
                style: TextStyle(
                  color: context.textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF4CAF50),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: context.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(color: context.subtitleColor, fontSize: 15),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text(
              'OK',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.primaryColor,
                    context.primaryColor.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.rocket_launch,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Coming Soon',
              style: TextStyle(
                color: context.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          '$feature is coming soon! Stay tuned for updates.',
          style: TextStyle(color: context.subtitleColor, fontSize: 15),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text(
              'Got it',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, String route) {
    final routeMap = {
      'personal_details': '/personal_details',
      'addresses': '/addresses',
      'payment': '/payment_methods',
      'order_history': '/order_history',
      'track_order': '/track_order',
      'favorites': '/favorites',
      'promos': '/promos',
      'notifications': '/notifications',
      'help': '/help',
      'terms': '/terms',
      'privacy': '/privacy',
    };

    if (routeMap.containsKey(route)) {
      Navigator.pushNamed(context, routeMap[route]!);
    } else {
      _showToast(context, 'Navigating to $route');
    }
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: context.primaryColor,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// ============================================================================
// MODERN PROFILE HEADER WITH GLASSMORPHISM
// ============================================================================

class ModernProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? phone;
  final bool isVerified;
  final VoidCallback onEditTap;
  final Animation<double> fadeAnimation;

  const ModernProfileHeader({
    Key? key,
    required this.name,
    required this.email,
    this.phone,
    required this.isVerified,
    required this.onEditTap,
    required this.fadeAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient Background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.primaryColor,
                context.primaryColor.withOpacity(0.8),
                context.primaryColor.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Animated circles background
        Positioned(
          top: -50,
          right: -50,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -30,
          left: -30,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
        ),
        // Content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FadeTransition(
                  opacity: fadeAnimation,
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.white.withOpacity(0.8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: context.primaryColor.withOpacity(
                            0.2,
                          ),
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: onEditTap,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.edit,
                              size: 18,
                              color: context.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                FadeTransition(
                  opacity: fadeAnimation,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isVerified) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.verified,
                            color: context.primaryColor,
                            size: 20,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                FadeTransition(
                  opacity: fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.email, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            email,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (phone != null && phone!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  FadeTransition(
                    opacity: fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.phone,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            phone!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// MODERN PROFILE SECTION
// ============================================================================

class ModernProfileSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<ModernProfileItem> items;

  const ModernProfileSection({
    Key? key,
    required this.title,
    required this.icon,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: context.primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: context.subtitleColor,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                item,
                if (index < items.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(
                      height: 1,
                      color: context.dividerColor.withOpacity(0.3),
                    ),
                  ),
              ],
            );
          }).toList(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ============================================================================
// MODERN PROFILE ITEM
// ============================================================================

class ModernProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const ModernProfileItem({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.primaryColor.withOpacity(0.15),
                      context.primaryColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: context.primaryColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: context.textColor,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.subtitleColor,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              trailing ??
                  Icon(
                    Icons.arrow_forward_ios,
                    color: context.subtitleColor.withOpacity(0.5),
                    size: 16,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
