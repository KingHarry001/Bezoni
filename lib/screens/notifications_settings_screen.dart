// File: lib/screens/profile/screens/notifications_settings_screen.dart
import 'package:flutter/material.dart';
import '../../../themes/theme_extensions.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;

  // Order notifications
  bool _orderUpdates = true;
  bool _orderConfirmation = true;
  bool _deliveryUpdates = true;
  bool _orderRatings = true;

  // Promotional notifications
  bool _promotions = true;
  bool _newRestaurants = true;
  bool _specialOffers = false;
  bool _weeklyDeals = true;

  // Account notifications
  bool _securityAlerts = true;
  bool _paymentAlerts = true;
  bool _accountUpdates = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notification Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: context.textColor,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Notification Channels
          _buildSection(
            title: 'NOTIFICATION CHANNELS',
            children: [
              _buildSwitchTile(
                icon: Icons.notifications_active,
                title: 'Push Notifications',
                subtitle: 'Receive notifications on this device',
                value: _pushNotifications,
                onChanged: (value) {
                  setState(() => _pushNotifications = value);
                },
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.email,
                title: 'Email Notifications',
                subtitle: 'Receive notifications via email',
                value: _emailNotifications,
                onChanged: (value) {
                  setState(() => _emailNotifications = value);
                },
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.sms,
                title: 'SMS Notifications',
                subtitle: 'Receive text message updates',
                value: _smsNotifications,
                onChanged: (value) {
                  setState(() => _smsNotifications = value);
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Order Notifications
          _buildSection(
            title: 'ORDER NOTIFICATIONS',
            children: [
              _buildSwitchTile(
                icon: Icons.check_circle_outline,
                title: 'Order Confirmation',
                subtitle: 'When your order is confirmed',
                value: _orderConfirmation,
                onChanged: (value) {
                  setState(() => _orderConfirmation = value);
                },
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.update,
                title: 'Order Updates',
                subtitle: 'Get updates on order status',
                value: _orderUpdates,
                onChanged: (value) {
                  setState(() => _orderUpdates = value);
                },
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.delivery_dining,
                title: 'Delivery Updates',
                subtitle: 'Track your delivery in real-time',
                value: _deliveryUpdates,
                onChanged: (value) {
                  setState(() => _deliveryUpdates = value);
                },
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.star_outline,
                title: 'Order Ratings',
                subtitle: 'Rate your completed orders',
                value: _orderRatings,
                onChanged: (value) {
                  setState(() => _orderRatings = value);
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Promotional Notifications
          _buildSection(
            title: 'PROMOTIONAL',
            children: [
              _buildSwitchTile(
                icon: Icons.local_offer,
                title: 'Promotions & Deals',
                subtitle: 'Special offers and discounts',
                value: _promotions,
                onChanged: (value) {
                  setState(() => _promotions = value);
                },
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.restaurant_menu,
                title: 'New Restaurants',
                subtitle: 'When new restaurants join',
                value: _newRestaurants,
                onChanged: (value) {
                  setState(() => _newRestaurants = value);
                },
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.card_giftcard,
                title: 'Special Offers',
                subtitle: 'Exclusive deals just for you',
                value: _specialOffers,
                onChanged: (value) {
                  setState(() => _specialOffers = value);
                },
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.calendar_today,
                title: 'Weekly Deals',
                subtitle: 'Best deals of the week',
                value: _weeklyDeals,
                onChanged: (value) {
                  setState(() => _weeklyDeals = value);
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Account Notifications
          _buildSection(
            title: 'ACCOUNT & SECURITY',
            children: [
              _buildSwitchTile(
                icon: Icons.security,
                title: 'Security Alerts',
                subtitle: 'Important security updates',
                value: _securityAlerts,
                onChanged: (value) {
                  setState(() => _securityAlerts = value);
                },
                isImportant: true,
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.payment,
                title: 'Payment Alerts',
                subtitle: 'Transaction and payment updates',
                value: _paymentAlerts,
                onChanged: (value) {
                  setState(() => _paymentAlerts = value);
                },
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.person,
                title: 'Account Updates',
                subtitle: 'Changes to your account',
                value: _accountUpdates,
                onChanged: (value) {
                  setState(() => _accountUpdates = value);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _saveSettings,
              child: const Text(
                'Save Preferences',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ThemeUtils.createShadow(context, elevation: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.subtitleColor,
                letterSpacing: 1,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isImportant = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: context.primaryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: context.textColor,
                      ),
                    ),
                    if (isImportant) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: context.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'REQUIRED',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: context.errorColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.subtitleColor,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: isImportant ? null : onChanged,
            activeColor: context.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 64),
      child: Divider(
        color: context.dividerColor,
        height: 1,
      ),
    );
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification preferences saved successfully!'),
        backgroundColor: context.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}