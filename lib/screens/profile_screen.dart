import 'package:flutter/material.dart';
import 'package:bezoni/widgets/stat_card.dart';
import 'package:bezoni/themes/theme_extensions.dart';
import 'package:bezoni/core/api_client.dart';
import 'package:bezoni/core/api_models.dart';
import 'package:bezoni/utils/auth_utils.dart';
import 'package:bezoni/services/theme_service.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiClient _apiClient = ApiClient();
  UserProfile? _userProfile;
  WalletBalance? _walletBalance;
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;

  // Stats - calculated from API data
  final Map<String, dynamic> _stats = {'orders': 0, 'saved': 0.0, 'points': 0};

  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    await _apiClient.initialize();
    await _loadAllData();
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

  Future<void> _loadUserProfile() async {
    try {
      final response = await _apiClient.getProfile();

      if (response.isSuccess && response.data != null) {
        setState(() {
          _userProfile = response.data;
        });
      } else {
        setState(() {
          _errorMessage = response.errorMessage ?? 'Failed to load profile';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading profile: ${e.toString()}';
      });
    }
  }

  Future<void> _loadUserStats() async {
    try {
      final ordersResponse = await _apiClient.getUserOrders();

      if (ordersResponse.isSuccess && ordersResponse.data != null) {
        final orders = ordersResponse.data!;

        // Calculate stats from actual orders
        final completedOrders = orders
            .where((o) => o.status == 'DELIVERED' || o.status == 'COMPLETED')
            .toList();

        setState(() {
          _stats['orders'] = completedOrders.length;

          // Calculate total saved (example: 5% cashback on completed orders)
          _stats['saved'] = completedOrders.fold<double>(
            0,
            (sum, order) => sum + (order.total * 0.05),
          );

          // Calculate points (example: 50 points per completed order)
          _stats['points'] = completedOrders.length * 50;
        });
      }
    } catch (e) {
      debugPrint('Error loading stats: ${e.toString()}');
    }
  }

  Future<void> _loadWalletBalance() async {
    try {
      final response = await _apiClient.getWalletBalance();

      if (response.isSuccess && response.data != null) {
        setState(() {
          _walletBalance = response.data;
        });
      }
    } catch (e) {
      debugPrint('Error loading wallet: ${e.toString()}');
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
              CircularProgressIndicator(color: context.primaryColor),
              const SizedBox(height: 16),
              Text(
                'Loading profile...',
                style: TextStyle(color: context.subtitleColor, fontSize: 14),
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
                Icon(Icons.error_outline, size: 64, color: context.errorColor),
                const SizedBox(height: 16),
                Text(
                  'Error Loading Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: context.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.subtitleColor, fontSize: 14),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadAllData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
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
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        color: context.primaryColor,
        child: CustomScrollView(
          slivers: [
            // Custom App Bar with Profile Header
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: context.primaryColor,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: _userProfile != null
                    ? ProfileHeader(
                        name: _userProfile!.name,
                        email: _userProfile!.email,
                        phone: _userProfile!.phone,
                        isVerified: _userProfile!.emailVerified,
                        onEditTap: () => _editProfile(context),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              context.primaryColor,
                              context.primaryColor.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
              ),
            ),

            // Stats Cards
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -30),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icon: Icons.shopping_bag_outlined,
                          value: '${_stats['orders']}',
                          title: 'Orders',
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          icon: Icons.savings_outlined,
                          value: '₦${_stats['saved'].toStringAsFixed(0)}',
                          title: 'Saved',
                          color: const Color(0xFFFF9800),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          icon: Icons.account_balance_wallet_outlined,
                          value:
                              '₦${_walletBalance?.balance.toStringAsFixed(0) ?? '0'}',
                          title: 'Wallet',
                          color: const Color(0xFF2196F3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Main Content
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Email Verification Banner (if not verified)
                  if (_userProfile != null && !_userProfile!.emailVerified)
                    _buildVerificationBanner(),

                  const SizedBox(height: 16),

                  // Quick Actions Grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: [
                        _buildQuickAction(
                          context,
                          icon: Icons.receipt_long_outlined,
                          label: 'Orders',
                          color: const Color(0xFF2196F3),
                          onTap: () => _navigate(context, 'order_history'),
                        ),
                        _buildQuickAction(
                          context,
                          icon: Icons.favorite_outline,
                          label: 'Favorites',
                          color: const Color(0xFFE91E63),
                          onTap: () => _navigate(context, 'favorites'),
                        ),
                        _buildQuickAction(
                          context,
                          icon: Icons.local_offer_outlined,
                          label: 'Promos',
                          color: const Color(0xFFFF9800),
                          onTap: () => _navigate(context, 'promos'),
                        ),
                        _buildQuickAction(
                          context,
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Wallet',
                          color: const Color(0xFF4CAF50),
                          onTap: () => _showWalletDetails(context),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Account Section
                  ProfileSection(
                    title: 'ACCOUNT',
                    items: [
                      ProfileItem(
                        icon: Icons.person_outline,
                        title: 'Personal Information',
                        subtitle: _userProfile?.name ?? 'Update your details',
                        onTap: () => _showPersonalInfoDialog(context),
                      ),
                      ProfileItem(
                        icon: Icons.location_on_outlined,
                        title: 'Delivery Address',
                        subtitle:
                            _userProfile?.address ?? 'Add delivery address',
                        onTap: () => _navigate(context, 'addresses'),
                      ),
                      ProfileItem(
                        icon: Icons.phone_outlined,
                        title: 'Phone Number',
                        subtitle: _userProfile?.phone ?? 'Add phone number',
                        onTap: () => _showPersonalInfoDialog(context),
                      ),
                    ],
                  ),

                  // Orders & Activity Section
                  ProfileSection(
                    title: 'ORDERS & ACTIVITY',
                    items: [
                      ProfileItem(
                        icon: Icons.receipt_long_outlined,
                        title: 'Order History',
                        subtitle: '${_stats['orders']} completed orders',
                        onTap: () => _navigate(context, 'order_history'),
                      ),
                      ProfileItem(
                        icon: Icons.local_shipping_outlined,
                        title: 'Track Order',
                        subtitle: 'Track your active orders',
                        onTap: () => _navigate(context, 'track_order'),
                      ),
                      ProfileItem(
                        icon: Icons.favorite_outline,
                        title: 'Favorite Restaurants',
                        subtitle: 'Your saved restaurants',
                        onTap: () => _navigate(context, 'favorites'),
                      ),
                    ],
                  ),

                  // Preferences Section
                  ProfileSection(
                    title: 'PREFERENCES',
                    items: [
                      ProfileItem(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        subtitle: 'Push, Email, SMS',
                        onTap: () => _navigate(context, 'notifications'),
                      ),
                      ProfileItem(
                        icon: Icons.dark_mode_outlined,
                        title: 'Appearance',
                        subtitle: _getThemeModeName(context),
                        onTap: () => _showThemeDialog(context),
                      ),
                      ProfileItem(
                        icon: Icons.language,
                        title: 'Language',
                        subtitle: 'English',
                        onTap: () => _showLanguageDialog(context),
                      ),
                    ],
                  ),

                  // Help & Support Section
                  ProfileSection(
                    title: 'HELP & SUPPORT',
                    items: [
                      ProfileItem(
                        icon: Icons.support_agent,
                        title: 'Support Center',
                        subtitle: '24/7 customer support',
                        onTap: () => _showComingSoon(context, 'Support Center'),
                      ),
                      ProfileItem(
                        icon: Icons.help_outline,
                        title: 'Help & FAQ',
                        subtitle: 'Get quick answers',
                        onTap: () => _navigate(context, 'help'),
                      ),
                      ProfileItem(
                        icon: Icons.description_outlined,
                        title: 'Terms & Conditions',
                        onTap: () => _navigate(context, 'terms'),
                      ),
                      ProfileItem(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        onTap: () => _navigate(context, 'privacy'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // App Version
                  Text(
                    'Bezoni v1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.subtitleColor,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Logout Button
                  _buildLogoutButton(context),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.errorColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: context.errorColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verify your email',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: context.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Please verify your email to access all features',
                  style: TextStyle(fontSize: 12, color: context.subtitleColor),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _sendVerificationEmail,
            child: Text(
              'Verify',
              style: TextStyle(
                color: context.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendVerificationEmail() async {
    try {
      final response = await _apiClient.sendVerificationEmail();

      if (response.isSuccess) {
        if (!mounted) return;
        _showToast(context, 'Verification email sent! Check your inbox.');
      } else {
        if (!mounted) return;
        _showToast(context, response.errorMessage ?? 'Failed to send email');
      }
    } catch (e) {
      if (!mounted) return;
      _showToast(context, 'Error: ${e.toString()}');
    }
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: ThemeUtils.createShadow(context, elevation: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.textColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: OutlinedButton.icon(
          onPressed: () => _showLogoutDialog(context),
          icon: Icon(Icons.logout, color: context.errorColor),
          label: Text(
            'Logout',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: context.errorColor,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: context.errorColor, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  // Dialog and Sheet Methods

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
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
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
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.textColor,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(Icons.edit, color: context.primaryColor),
              title: Text(
                'Edit Profile',
                style: TextStyle(color: context.textColor),
              ),
              onTap: () {
                Navigator.pop(context);
                _showPersonalInfoDialog(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.email, color: context.primaryColor),
              title: Text(
                'Resend Verification Email',
                style: TextStyle(color: context.textColor),
              ),
              onTap: () {
                Navigator.pop(context);
                _sendVerificationEmail();
              },
            ),
            ListTile(
              leading: Icon(Icons.lock_reset, color: context.primaryColor),
              title: Text(
                'Change Password',
                style: TextStyle(color: context.textColor),
              ),
              onTap: () {
                Navigator.pop(context);
                _showPasswordDialog(context);
              },
            ),
          ],
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Update Profile',
          style: TextStyle(color: context.textColor),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: TextStyle(color: context.textColor),
                decoration: InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person, color: context.primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                style: TextStyle(color: context.textColor),
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email, color: context.primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                style: TextStyle(color: context.textColor),
                decoration: InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone, color: context.primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
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
              await _updateProfile(
                name: nameController.text.trim(),
                email: emailController.text.trim(),
                phone: phoneController.text.trim(),
              );
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Update', style: TextStyle(color: Colors.white)),
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
    try {
      final response = await _apiClient.updateProfile(
        name: name.isNotEmpty ? name : null,
        email: email.isNotEmpty ? email : null,
        phone: phone.isNotEmpty ? phone : null,
      );

      if (response.isSuccess) {
        await _loadUserProfile();
        if (!mounted) return;
        _showToast(context, 'Profile updated successfully');
      } else {
        if (!mounted) return;
        _showToast(
          context,
          response.errorMessage ?? 'Failed to update profile',
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showToast(context, 'Error: ${e.toString()}');
    }
  }

  void _showPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Change Password',
          style: TextStyle(color: context.textColor),
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
            ),
            child: const Text(
              'Send Email',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendPasswordReset() async {
    if (_userProfile?.email == null) return;

    try {
      final response = await _apiClient.forgotPassword(_userProfile!.email);

      if (response.isSuccess) {
        if (!mounted) return;
        _showToast(context, 'Password reset email sent!');
      } else {
        if (!mounted) return;
        _showToast(context, response.errorMessage ?? 'Failed to send email');
      }
    } catch (e) {
      if (!mounted) return;
      _showToast(context, 'Error: ${e.toString()}');
    }
  }

  void _showWalletDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.account_balance_wallet, color: context.primaryColor),
            const SizedBox(width: 8),
            Text('Wallet Balance', style: TextStyle(color: context.textColor)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '₦${_walletBalance?.balance.toStringAsFixed(2) ?? '0.00'}',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: context.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your current wallet balance',
              style: TextStyle(color: context.subtitleColor, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: context.subtitleColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon(context, 'Top Up Wallet');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Top Up', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.palette_outlined, color: context.primaryColor),
            const SizedBox(width: 8),
            Text('Choose Theme', style: TextStyle(color: context.textColor)),
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
            const SizedBox(height: 8),
            _themeOption(
              context,
              Icons.dark_mode,
              'Dark Mode',
              'Easy on the eyes',
              AppTheme.dark,
            ),
            const SizedBox(height: 8),
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? context.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: context.primaryColor.withOpacity(0.3),
                  width: 2,
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.primaryColor.withOpacity(0.2)
                    : context.dividerColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? context.primaryColor
                    : context.subtitleColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
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
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
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
              Icon(Icons.check_circle, color: context.primaryColor, size: 22),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Select Language',
          style: TextStyle(color: context.textColor),
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? context.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                language,
                style: TextStyle(
                  color: context.textColor,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: context.primaryColor, size: 20),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.logout, color: context.errorColor),
            const SizedBox(width: 8),
            Text('Logout', style: TextStyle(color: context.textColor)),
          ],
        ),
        content: Text(
          'Are you sure you want to logout of your account?',
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
    Navigator.pop(context); // Close dialog
    _showLoadingDialog(context, 'Logging out...');

    try {
      await _apiClient.logout();

      // Clear remember me credentials using the utility
      await AuthUtils.clearSavedCredentials();

      if (mounted) {
        Navigator.pop(context); // Close loading
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        _showToast(context, 'Logout failed: ${e.toString()}');
      }
    }
  },
  child: const Text('Logout'),
),
        ],
      ),
    );
  }

  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: context.primaryColor),
            const SizedBox(height: 16),
            Text(message, style: TextStyle(color: context.textColor)),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.rocket_launch, color: context.primaryColor),
            const SizedBox(width: 8),
            Text('Coming Soon', style: TextStyle(color: context.textColor)),
          ],
        ),
        content: Text(
          '$feature is coming soon! Stay tuned for updates.',
          style: TextStyle(color: context.subtitleColor),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Got it', style: TextStyle(color: Colors.white)),
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
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: context.primaryColor,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// ============================================================================
// PROFILE HEADER WIDGET
// ============================================================================

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? phone;
  final bool isVerified;
  final VoidCallback onEditTap;

  const ProfileHeader({
    Key? key,
    required this.name,
    required this.email,
    this.phone,
    required this.isVerified,
    required this.onEditTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [context.primaryColor, context.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Profile Avatar
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 36,
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
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.edit,
                          size: 16,
                          color: context.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Name
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isVerified) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.verified, color: Colors.white, size: 20),
                  ],
                ],
              ),
              const SizedBox(height: 8),

              // Email
              Text(
                email,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),

              // Phone (if available)
              if (phone != null && phone!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  phone!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// PROFILE SECTION WIDGET
// ============================================================================

class ProfileSection extends StatelessWidget {
  final String title;
  final List<ProfileItem> items;

  const ProfileSection({Key? key, required this.title, required this.items})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ThemeUtils.createShadow(context, elevation: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.subtitleColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                item,
                if (index < items.length - 1)
                  Divider(height: 1, indent: 56, color: context.dividerColor),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}

// ============================================================================
// PROFILE ITEM WIDGET
// ============================================================================

class ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const ProfileItem({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            trailing ?? Icon(Icons.chevron_right, color: context.subtitleColor),
          ],
        ),
      ),
    );
  }
}
