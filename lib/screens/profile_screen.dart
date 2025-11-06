import 'package:bezoni/widgets/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:bezoni/themes/theme_extensions.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Profile Header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: context.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: ProfileHeader(
                name: 'Dave Johnson',
                email: 'dave@example.com',
                isVerified: true,
                onEditTap: () => _editProfile(context),
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
                        value: '12',
                        title: 'Orders',
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        icon: Icons.savings_outlined,
                        value: '₦2,340',
                        title: 'Saved',
                        color: const Color(0xFFFF9800),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        icon: Icons.stars_outlined,
                        value: '450',
                        title: 'Points',
                        color: const Color(0xFF2196F3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Menu Sections
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Subscription Banner
                SubscriptionBanner(
                  title: 'Delivery Subscription',
                  subtitle: 'Save ₦500 on every order',
                  onTap: () => _showSubscription(context),
                ),

                const SizedBox(height: 16),

                // Account Section
                ProfileSection(
                  title: 'ACCOUNT',
                  items: [
                    ProfileItem(
                      icon: Icons.person_outline,
                      title: 'Personal Information',
                      subtitle: 'Update your details',
                      onTap: () => _navigate(context, 'personal_details'),
                    ),
                    ProfileItem(
                      icon: Icons.location_on_outlined,
                      title: 'Saved Addresses',
                      subtitle: '3 addresses',
                      onTap: () => _navigate(context, 'addresses'),
                    ),
                    ProfileItem(
                      icon: Icons.payment,
                      title: 'Payment Methods',
                      subtitle: '2 cards saved',
                      onTap: () => _navigate(context, 'payment'),
                    ),
                  ],
                ),

                // Orders & Favorites Section
                ProfileSection(
                  title: 'ORDERS & FAVORITES',
                  items: [
                    ProfileItem(
                      icon: Icons.receipt_long_outlined,
                      title: 'Order History',
                      subtitle: '12 completed orders',
                      onTap: () => _navigate(context, 'order_history'),
                    ),
                    ProfileItem(
                      icon: Icons.favorite_outline,
                      title: 'Favorite Restaurants',
                      subtitle: '8 restaurants',
                      onTap: () => _navigate(context, 'favorites'),
                    ),
                    ProfileItem(
                      icon: Icons.local_offer_outlined,
                      title: 'Promo Codes',
                      subtitle: '3 available',
                      onTap: () => _navigate(context, 'promos'),
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
                      icon: Icons.language,
                      title: 'Language',
                      subtitle: 'English',
                      onTap: () => _showLanguageDialog(context),
                    ),
                    ProfileItem(
                      icon: Icons.dark_mode_outlined,
                      title: 'Appearance',
                      subtitle: 'Theme settings',
                      onTap: () => Navigator.pushNamed(context, '/settings'),
                    ),
                  ],
                ),

                // Help & Legal Section
                ProfileSection(
                  title: 'HELP & LEGAL',
                  items: [
                    ProfileItem(
                      icon: Icons.support_agent,
                      title: 'Support Center',
                      subtitle: '24/7 customer support',
                      onTap: () => Navigator.pushNamed(context, '/support'),
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
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.subtitleColor,
                  ),
                ),

                const SizedBox(height: 32),

                // Logout Button
                _buildLogoutButton(context),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
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

  // Helper Methods
  void _editProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
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
              'Edit Profile Photo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.textColor,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(Icons.camera_alt, color: context.primaryColor),
              title: Text('Take Photo', style: TextStyle(color: context.textColor)),
              onTap: () {
                Navigator.pop(context);
                _showToast(context, 'Camera selected');
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: context.primaryColor),
              title: Text('Choose from Gallery', style: TextStyle(color: context.textColor)),
              onTap: () {
                Navigator.pop(context);
                _showToast(context, 'Gallery selected');
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: context.errorColor),
              title: Text('Remove Photo', style: TextStyle(color: context.errorColor)),
              onTap: () {
                Navigator.pop(context);
                _showToast(context, 'Photo removed');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSubscription(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.delivery_dining, color: context.primaryColor),
            const SizedBox(width: 8),
            Text('Delivery Subscription', style: TextStyle(color: context.textColor)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subscribe and save ₦500 on every order!',
              style: TextStyle(color: context.textColor),
            ),
            const SizedBox(height: 16),
            Text(
              '• Unlimited free delivery\n• Priority support\n• Exclusive deals',
              style: TextStyle(color: context.subtitleColor, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              'Only ₦2,999/month',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.primaryColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Later', style: TextStyle(color: context.subtitleColor)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showToast(context, 'Subscription activated!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Subscribe', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, String route) {
    _showToast(context, 'Navigating to $route');
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Select Language', style: TextStyle(color: context.textColor)),
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

  Widget _languageOption(BuildContext context, String flag, String language, bool selected) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _showToast(context, '$language selected');
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? context.primaryColor.withOpacity(0.1) : Colors.transparent,
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
            child: Text('Cancel', style: TextStyle(color: context.subtitleColor)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.errorColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: context.primaryColor,
      ),
    );
  }
}