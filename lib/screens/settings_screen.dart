import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'support_screen.dart';
import '../services/theme_service.dart';
import '../themes/theme_extensions.dart';

class VendorSettingsScreen extends StatefulWidget {
  @override
  _VendorSettingsScreenState createState() => _VendorSettingsScreenState();
}

class _VendorSettingsScreenState extends State<VendorSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        foregroundColor: context.colors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: context.shadowColor,
        title: Text(
          'Settings',
          style: TextStyle(
            color: context.colors.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: context.colors.onSurface,
            size: 20,
          ),
        ),
      ),
      body: Consumer2<ApiService, ThemeService>(
        builder: (context, apiService, themeService, child) {
          final profile = apiService.userProfile;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Store Status Card
                _buildStoreStatusCard(apiService),
                SizedBox(height: 16),

                // Store Operations
                _buildSectionCard(
                  title: 'Store Operations',
                  children: [
                    _buildSwitchTile(
                      title: 'Accept New Orders',
                      subtitle: 'Toggle your availability to receive orders',
                      value: apiService.isOnline,
                      onChanged: (value) => _toggleStoreStatus(apiService),
                      icon: Icons.store,
                    ),
                    Divider(height: 1, color: context.dividerColor),
                    _buildSwitchTile(
                      title: 'Auto-Accept Orders',
                      subtitle: 'Automatically accept incoming orders',
                      value: false,
                      onChanged: (value) => _updateAutoAccept(apiService, value),
                      icon: Icons.auto_mode,
                    ),
                    Divider(height: 1, color: context.dividerColor),
                    _buildTile(
                      title: 'Operating Hours',
                      subtitle: profile?.operatingHours ?? 'Set your business hours',
                      icon: Icons.access_time,
                      onTap: () => _showOperatingHoursDialog(apiService),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Order Management
                _buildSectionCard(
                  title: 'Order Management',
                  children: [
                    _buildTile(
                      title: 'Preparation Time Settings',
                      subtitle: 'Set default prep times for different items',
                      icon: Icons.timer_outlined,
                      onTap: () => _showFeatureComingSoon(),
                    ),
                    Divider(height: 1, color: context.dividerColor),
                    _buildTile(
                      title: 'Delivery Radius',
                      subtitle: 'Set your delivery coverage area',
                      icon: Icons.location_on_outlined,
                      onTap: () => _showFeatureComingSoon(),
                    ),
                    Divider(height: 1, color: context.dividerColor),
                    _buildSwitchTile(
                      title: 'Busy Mode',
                      subtitle: 'Temporarily pause new orders during rush',
                      value: false,
                      onChanged: (value) => _toggleBusyMode(apiService, value),
                      icon: Icons.pause_circle_outline,
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Notifications Settings
                _buildSectionCard(
                  title: 'Notifications',
                  children: [
                    _buildSwitchTile(
                      title: 'Order Notifications',
                      subtitle: 'Get notified for new orders',
                      value: true,
                      onChanged: (value) => _updateNotificationSetting(apiService, 'orders', value),
                      icon: Icons.notifications_outlined,
                    ),
                    Divider(height: 1, color: context.dividerColor),
                    _buildSwitchTile(
                      title: 'Sound Alerts',
                      subtitle: 'Play sound for new order notifications',
                      value: true,
                      onChanged: (value) => _updateNotificationSetting(apiService, 'sound', value),
                      icon: Icons.volume_up_outlined,
                    ),
                    Divider(height: 1, color: context.dividerColor),
                    _buildSwitchTile(
                      title: 'Vibration',
                      subtitle: 'Vibrate device for important alerts',
                      value: true,
                      onChanged: (value) => _updateNotificationSetting(apiService, 'vibration', value),
                      icon: Icons.vibration,
                    ),
                    Divider(height: 1, color: context.dividerColor),
                    _buildSwitchTile(
                      title: 'Low Stock Alerts',
                      subtitle: 'Get notified when products are running low',
                      value: true,
                      onChanged: (value) => _updateNotificationSetting(apiService, 'stock', value),
                      icon: Icons.inventory_2_outlined,
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Appearance Settings
                _buildSectionCard(
                  title: 'Appearance',
                  children: [_buildThemeSelector(themeService)],
                ),
                SizedBox(height: 16),

                // Store Information
                if (profile != null) ...[
                  _buildSectionCard(
                    title: 'Store Information',
                    children: [
                      _buildTile(
                        title: 'Store Profile',
                        subtitle: '${profile.storeName} - ${profile.businessType}',
                        icon: Icons.store_outlined,
                        onTap: () => _navigateToStoreProfile(),
                      ),
                      Divider(height: 1, color: context.dividerColor),
                      _buildTile(
                        title: 'Business Documents',
                        subtitle: 'Manage licenses and permits',
                        icon: Icons.document_scanner_outlined,
                        onTap: () => _showFeatureComingSoon(),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                ],

                // Financial Settings
                _buildSectionCard(
                  title: 'Financial',
                  children: [
                    _buildTile(
                      title: 'Payment Methods',
                      subtitle: 'Manage accepted payment options',
                      icon: Icons.payment_outlined,
                      onTap: () => _showFeatureComingSoon(),
                    ),
                    Divider(height: 1, color: context.dividerColor),
                    _buildTile(
                      title: 'Bank Account',
                      subtitle: 'Update withdrawal account details',
                      icon: Icons.account_balance_outlined,
                      onTap: () => _showFeatureComingSoon(),
                    ),
                    Divider(height: 1, color: context.dividerColor),
                    _buildTile(
                      title: 'Commission & Fees',
                      subtitle: 'View platform fees and commission rates',
                      icon: Icons.percent_outlined,
                      onTap: () => _showFeatureComingSoon(),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Support & Help
                _buildSectionCard(
                  title: 'Support & Help',
                  children: [
                    _buildTile(
                      title: 'Help Center',
                      subtitle: 'FAQs and guides for vendors',
                      icon: Icons.help_outline,
                      onTap: () => _showFeatureComingSoon(),
                    ),
                    Divider(height: 1, color: context.dividerColor),
                    _buildTile(
                      title: 'Contact Support',
                      subtitle: 'Get help from our support team',
                      icon: Icons.support_agent_outlined,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SupportScreen(),
                        ),
                      ),
                    ),
                    Divider(height: 1, color: context.dividerColor),
                    _buildTile(
                      title: 'Terms & Policies',
                      subtitle: 'View vendor agreement and policies',
                      icon: Icons.policy_outlined,
                      onTap: () => _showFeatureComingSoon(),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // About
                _buildSectionCard(
                  title: 'About',
                  children: [
                    _buildTile(
                      title: 'App Version',
                      subtitle: 'Version 1.0.0 (Build 100)',
                      icon: Icons.info_outline,
                      onTap: () {},
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Logout Button
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton.icon(
                    onPressed: () => _showLogoutDialog(),
                    icon: Icon(Icons.logout, color: Colors.white),
                    label: Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.errorColor,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoreStatusCard(ApiService apiService) {
    final isOpen = apiService.isOnline;
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOpen
              ? [context.successColor.withOpacity(0.8), context.successColor]
              : [
                  context.colors.onSurface.withOpacity(0.6),
                  context.colors.onSurface.withOpacity(0.4),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isOpen ? context.successColor : context.colors.onSurface)
                .withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isOpen ? Icons.store : Icons.store_mall_directory_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOpen ? 'Store is Open' : 'Store is Closed',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isOpen
                          ? 'Currently accepting orders'
                          : 'Not accepting orders at the moment',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isOpen,
                onChanged: (value) => _toggleStoreStatus(apiService),
                activeColor: Colors.white,
                activeTrackColor: Colors.white.withOpacity(0.3),
                inactiveThumbColor: Colors.white.withOpacity(0.7),
                inactiveTrackColor: Colors.white.withOpacity(0.2),
              ),
            ],
          ),
          if (isOpen) ...[
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusInfo(
                    'Pending',
                    apiService.pendingOrders.toString(),
                  ),
                  Container(
                    height: 30,
                    width: 1,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  _buildStatusInfo(
                    'Active',
                    apiService.activeOrders.toString(),
                  ),
                  Container(
                    height: 30,
                    width: 1,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  _buildStatusInfo(
                    'Today',
                    apiService.todayStats['totalOrders'].toString(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusInfo(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ThemeUtils.createShadow(context, elevation: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.textColor,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildThemeSelector(ThemeService themeService) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.palette_outlined,
          color: context.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        'Theme',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: context.textColor,
        ),
      ),
      subtitle: Text(
        'Choose your preferred theme',
        style: TextStyle(color: context.subtitleColor, fontSize: 14),
      ),
      trailing: DropdownButton<AppTheme>(
        value: themeService.currentTheme,
        items: AppTheme.values.map((AppTheme theme) {
          return DropdownMenuItem<AppTheme>(
            value: theme,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getThemeIcon(theme), size: 16, color: context.textColor),
                SizedBox(width: 8),
                Text(
                  _getThemeName(theme),
                  style: TextStyle(color: context.textColor),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (AppTheme? newTheme) {
          if (newTheme != null) {
            themeService.setTheme(newTheme);
          }
        },
        underline: Container(),
        icon: Icon(Icons.arrow_drop_down, color: context.subtitleColor),
        dropdownColor: context.surfaceColor,
      ),
    );
  }
  
 Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: value
              ? context.primaryColor.withOpacity(0.1)
              : context.colors.onSurface.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: value
              ? context.primaryColor
              : context.colors.onSurface.withOpacity(0.6),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: context.textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: context.subtitleColor, fontSize: 14),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: context.primaryColor,
        inactiveThumbColor: context.colors.onSurface.withOpacity(0.6),
        inactiveTrackColor: context.colors.onSurface.withOpacity(0.1),
      ),
    );
  }
  
    Widget _buildTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.colors.onSurface.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: context.subtitleColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: context.textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: context.subtitleColor, fontSize: 14),
      ),
      trailing: Icon(Icons.chevron_right, color: context.subtitleColor),
      onTap: onTap,
    );
  }

  IconData _getThemeIcon(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return Icons.light_mode;
      case AppTheme.dark:
        return Icons.dark_mode;
      case AppTheme.system:
        return Icons.auto_mode;
    }
  }

  String _getThemeName(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return 'Light';
      case AppTheme.dark:
        return 'Dark';
      case AppTheme.system:
        return 'System';
    }
  }

  // Action methods
  void _toggleStoreStatus(ApiService apiService) async {
    try {
      apiService.toggleOnlineStatus();
      _showSuccessSnackBar(
        apiService.isOnline
            ? 'Store is now open and accepting orders'
            : 'Store is now closed',
      );
    } catch (e) {
      _showErrorSnackBar('Failed to update store status');
    }
  }

  void _updateNotificationSetting(
    ApiService apiService,
    String setting,
    bool value,
  ) async {
    _showSuccessSnackBar('Notification setting updated');
  }

  void _updateAutoAccept(ApiService apiService, bool value) async {
    _showSuccessSnackBar(
      value ? 'Auto-accept enabled' : 'Auto-accept disabled',
    );
  }

  void _toggleBusyMode(ApiService apiService, bool value) async {
    _showSuccessSnackBar(
      value ? 'Busy mode activated' : 'Busy mode deactivated',
    );
  }

  void _showOperatingHoursDialog(ApiService apiService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Operating Hours',
          style: TextStyle(color: context.textColor),
        ),
        content: Text(
          'Configure your daily operating hours',
          style: TextStyle(color: context.subtitleColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: context.subtitleColor)),
          ),
        ],
      ),
    );
  }

  void _navigateToStoreProfile() {
    // Navigate to store profile edit screen
    _showFeatureComingSoon();
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Logout', style: TextStyle(color: context.textColor)),
        content: Text(
          'Are you sure you want to logout?',
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
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: context.errorColor),
            child: Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showFeatureComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('This feature is coming soon!'),
        backgroundColor: context.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }
}