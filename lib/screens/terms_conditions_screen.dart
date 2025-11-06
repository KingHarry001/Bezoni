// File: lib/screens/profile/screens/terms_conditions_screen.dart
import 'package:flutter/material.dart';
import '../../../themes/theme_extensions.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

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
          'Terms & Conditions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: context.textColor,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Last Updated: November 6, 2025',
            style: TextStyle(
              fontSize: 12,
              color: context.subtitleColor,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: '1. Acceptance of Terms',
            content:
                'By accessing and using Bezoni\'s food delivery services, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to these terms, please do not use our services.',
          ),
          _buildSection(
            context,
            title: '2. Service Description',
            content:
                'Bezoni provides an online platform that connects users with local restaurants and delivery services. We facilitate orders but do not directly provide food preparation or delivery services. Restaurant partners and delivery partners are independent contractors.',
          ),
          _buildSection(
            context,
            title: '3. User Accounts',
            content:
                'You must create an account to use our services. You are responsible for:\n\n• Maintaining the confidentiality of your account\n• All activities that occur under your account\n• Providing accurate and complete information\n• Updating your information as necessary',
          ),
          _buildSection(
            context,
            title: '4. Orders and Payments',
            content:
                'All orders are subject to acceptance by the restaurant. Prices are set by restaurants and may change without notice. Payment must be made at the time of order placement unless cash on delivery is selected. All transactions are final unless cancelled according to our cancellation policy.',
          ),
          _buildSection(
            context,
            title: '5. Cancellation and Refunds',
            content:
                'Orders may be cancelled before restaurant confirmation. Refunds are issued to the original payment method within 3-5 business days. We reserve the right to refuse or cancel orders that appear fraudulent or violate our terms.',
          ),
          _buildSection(
            context,
            title: '6. Delivery',
            content:
                'Delivery times are estimates and may vary. We are not liable for delays caused by factors beyond our control. You must be available at the delivery address during the estimated delivery window.',
          ),
          _buildSection(
            context,
            title: '7. User Conduct',
            content:
                'You agree not to:\n\n• Use the service for any illegal purpose\n• Harass or harm restaurant or delivery partners\n• Provide false information\n• Attempt to circumvent security features\n• Use automated systems to access the service',
          ),
          _buildSection(
            context,
            title: '8. Intellectual Property',
            content:
                'All content, trademarks, and data on Bezoni are the property of Bezoni or its licensors. You may not copy, distribute, or create derivative works without our express written permission.',
          ),
          _buildSection(
            context,
            title: '9. Limitation of Liability',
            content:
                'Bezoni is not liable for:\n\n• Food quality or preparation\n• Allergic reactions or food-borne illness\n• Delays in delivery\n• Loss or damage to property during delivery\n• Actions of restaurant or delivery partners',
          ),
          _buildSection(
            context,
            title: '10. Dispute Resolution',
            content:
                'Any disputes arising from these terms shall be resolved through binding arbitration in accordance with Nigerian law. You waive your right to participate in class actions.',
          ),
          _buildSection(
            context,
            title: '11. Changes to Terms',
            content:
                'We reserve the right to modify these terms at any time. Continued use of the service after changes constitutes acceptance of the new terms.',
          ),
          _buildSection(
            context,
            title: '12. Contact Information',
            content:
                'For questions about these terms, contact us at:\n\nEmail: legal@bezoni.com\nPhone: +234 800 BEZONI\nAddress: Lagos, Nigeria',
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: context.textColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: context.subtitleColor,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ============================================================================
// PRIVACY POLICY SCREEN
// ============================================================================

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: context.textColor,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Last Updated: November 6, 2025',
            style: TextStyle(
              fontSize: 12,
              color: context.subtitleColor,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: '1. Information We Collect',
            content:
                'We collect information you provide directly to us:\n\n• Personal information (name, email, phone number)\n• Delivery addresses\n• Payment information\n• Order history\n• Device information and location data\n• Usage data and preferences',
          ),
          _buildSection(
            context,
            title: '2. How We Use Your Information',
            content:
                'We use your information to:\n\n• Process and fulfill orders\n• Communicate about your orders\n• Improve our services\n• Send promotional offers (with your consent)\n• Prevent fraud and ensure security\n• Comply with legal obligations',
          ),
          _buildSection(
            context,
            title: '3. Information Sharing',
            content:
                'We share your information with:\n\n• Restaurant partners (to fulfill orders)\n• Delivery partners (for delivery)\n• Payment processors (for transactions)\n• Service providers (for analytics, customer support)\n• Law enforcement (when required by law)\n\nWe never sell your personal information to third parties.',
          ),
          _buildSection(
            context,
            title: '4. Data Security',
            content:
                'We implement industry-standard security measures to protect your data:\n\n• Encryption of sensitive data\n• Secure servers and databases\n• Regular security audits\n• Access controls and authentication\n\nHowever, no method of transmission over the internet is 100% secure.',
          ),
          _buildSection(
            context,
            title: '5. Your Privacy Rights',
            content:
                'You have the right to:\n\n• Access your personal data\n• Correct inaccurate information\n• Delete your account and data\n• Opt-out of marketing communications\n• Export your data\n• Object to data processing',
          ),
          _buildSection(
            context,
            title: '6. Cookies and Tracking',
            content:
                'We use cookies and similar technologies to:\n\n• Remember your preferences\n• Analyze usage patterns\n• Deliver personalized content\n• Track marketing campaign effectiveness\n\nYou can manage cookie preferences in your browser settings.',
          ),
          _buildSection(
            context,
            title: '7. Location Data',
            content:
                'We collect location data to:\n\n• Suggest nearby restaurants\n• Calculate delivery fees\n• Enable real-time order tracking\n• Improve delivery efficiency\n\nYou can disable location services in your device settings.',
          ),
          _buildSection(
            context,
            title: '8. Children\'s Privacy',
            content:
                'Our services are not intended for children under 18. We do not knowingly collect personal information from children. If you believe we have collected information from a child, please contact us immediately.',
          ),
          _buildSection(
            context,
            title: '9. Data Retention',
            content:
                'We retain your data for as long as necessary to:\n\n• Provide our services\n• Comply with legal obligations\n• Resolve disputes\n• Enforce our agreements\n\nYou can request deletion of your account at any time.',
          ),
          _buildSection(
            context,
            title: '10. International Transfers',
            content:
                'Your information may be transferred to and processed in countries other than Nigeria. We ensure appropriate safeguards are in place to protect your data.',
          ),
          _buildSection(
            context,
            title: '11. Changes to This Policy',
            content:
                'We may update this privacy policy from time to time. We will notify you of significant changes via email or app notification. Continued use after changes constitutes acceptance.',
          ),
          _buildSection(
            context,
            title: '12. Contact Us',
            content:
                'For privacy-related questions or concerns:\n\nEmail: privacy@bezoni.com\nPhone: +234 800 BEZONI\nAddress: Lagos, Nigeria\n\nData Protection Officer: dpo@bezoni.com',
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: context.textColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: context.subtitleColor,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}