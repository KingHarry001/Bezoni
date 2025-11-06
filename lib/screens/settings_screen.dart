import 'package:bezoni/screens/support_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bezoni/services/theme_service.dart';
import 'package:bezoni/themes/theme_extensions.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: context.surfaceColor,
        elevation: 0,
      ),
      body: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Theme Section
              SectionHeader(title: 'Appearance'),
              ThemeAwareCard(
                child: Column(
                  children: [
                    _buildThemeOption(
                      context: context,
                      themeService: themeService,
                      theme: AppTheme.light,
                      icon: Icons.light_mode,
                      title: 'Light Mode',
                      subtitle: 'Clean and bright',
                    ),
                    Divider(color: context.dividerColor, height: 1),
                    _buildThemeOption(
                      context: context,
                      themeService: themeService,
                      theme: AppTheme.dark,
                      icon: Icons.dark_mode,
                      title: 'Dark Mode',
                      subtitle: 'Easy on the eyes',
                    ),
                    Divider(color: context.dividerColor, height: 1),
                    _buildThemeOption(
                      context: context,
                      themeService: themeService,
                      theme: AppTheme.system,
                      icon: Icons.auto_mode,
                      title: 'System Default',
                      subtitle: 'Follow device settings',
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Notifications Section
              SectionHeader(title: 'Notifications'),
              ThemeAwareCard(
                child: Column(
                  children: [
                    _buildSwitchTile(
                      context: context,
                      icon: Icons.notifications_outlined,
                      title: 'Push Notifications',
                      subtitle: 'Receive order updates',
                      value: true,
                      onChanged: (value) {},
                    ),
                    Divider(color: context.dividerColor, height: 1),
                    _buildSwitchTile(
                      context: context,
                      icon: Icons.email_outlined,
                      title: 'Email Notifications',
                      subtitle: 'Receive promotional emails',
                      value: false,
                      onChanged: (value) {},
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Help & Support Section
              SectionHeader(title: 'Help & Support'),
              ThemeAwareCard(
                child: Column(
                  children: [
                    _buildInfoTile(
                      context: context,
                      icon: Icons.support_agent,
                      title: 'Support Center',
                      subtitle: 'Get help with your account',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SupportScreen(),
                          ),
                        );
                      },
                    ),
                    Divider(color: context.dividerColor, height: 1),
                    _buildInfoTile(
                      context: context,
                      icon: Icons.help_outline,
                      title: 'FAQs',
                      subtitle: 'Frequently asked questions',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SupportScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // About Section
              SectionHeader(title: 'About'),
              ThemeAwareCard(
                child: Column(
                  children: [
                    _buildInfoTile(
                      context: context,
                      icon: Icons.info_outline,
                      title: 'App Version',
                      subtitle: '1.0.0',
                    ),
                    Divider(color: context.dividerColor, height: 1),
                    _buildInfoTile(
                      context: context,
                      icon: Icons.description_outlined,
                      title: 'Terms & Conditions',
                      onTap: () {},
                    ),
                    Divider(color: context.dividerColor, height: 1),
                    _buildInfoTile(
                      context: context,
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required ThemeService themeService,
    required AppTheme theme,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = themeService.currentTheme == theme;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? context.primaryColor : context.subtitleColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: context.textColor,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: context.subtitleColor, fontSize: 12),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: context.primaryColor)
          : null,
      onTap: () async {
        await themeService.setTheme(theme);
      },
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: context.subtitleColor),
      title: Text(
        title,
        style: TextStyle(color: context.textColor),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: context.subtitleColor, fontSize: 12),
      ),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildInfoTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: context.subtitleColor),
      title: Text(
        title,
        style: TextStyle(color: context.textColor),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(color: context.subtitleColor, fontSize: 12),
            )
          : null,
      trailing: onTap != null
          ? Icon(Icons.chevron_right, color: context.subtitleColor)
          : null,
      onTap: onTap,
    );
  }
}