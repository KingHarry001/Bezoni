// File: lib/screens/profile/screens/help_faq_screen.dart
import 'package:flutter/material.dart';
import '../../../themes/theme_extensions.dart';

class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({super.key});

  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int? _expandedIndex;

  final List<FAQCategory> categories = [
    FAQCategory(
      title: 'Orders & Delivery',
      icon: Icons.shopping_bag_outlined,
      faqs: [
        FAQ(
          question: 'How do I track my order?',
          answer:
              'You can track your order in real-time from the Orders tab. You\'ll receive notifications at each stage: Order Confirmed, Preparing, Out for Delivery, and Delivered.',
        ),
        FAQ(
          question: 'Can I cancel my order?',
          answer:
              'Yes, you can cancel your order before it\'s confirmed by the restaurant. Go to Order History, select the order, and tap Cancel. Refunds are processed within 3-5 business days.',
        ),
        FAQ(
          question: 'What if my order is late?',
          answer:
              'If your order is delayed beyond the estimated time, you can contact support or the delivery driver directly through the app. We also offer compensation for significant delays.',
        ),
        FAQ(
          question: 'How long does delivery take?',
          answer:
              'Delivery times vary by restaurant and location, typically ranging from 20-45 minutes. You\'ll see the estimated delivery time before placing your order.',
        ),
      ],
    ),
    FAQCategory(
      title: 'Payments & Refunds',
      icon: Icons.payment,
      faqs: [
        FAQ(
          question: 'What payment methods are accepted?',
          answer:
              'We accept credit/debit cards, bank transfers, mobile wallets, and cash on delivery. All online payments are secure and encrypted.',
        ),
        FAQ(
          question: 'How do refunds work?',
          answer:
              'Refunds are processed automatically for cancelled orders. The amount is credited back to your original payment method within 3-5 business days.',
        ),
        FAQ(
          question: 'Are there any hidden charges?',
          answer:
              'No hidden charges! The final price includes food cost, delivery fee, and service charges. You\'ll see the complete breakdown before checkout.',
        ),
        FAQ(
          question: 'Can I save my payment details?',
          answer:
              'Yes, you can securely save your payment cards in the app for faster checkout. Your card details are encrypted and stored securely.',
        ),
      ],
    ),
    FAQCategory(
      title: 'Account & Profile',
      icon: Icons.person_outline,
      faqs: [
        FAQ(
          question: 'How do I update my profile?',
          answer:
              'Go to Profile > Personal Information. You can update your name, email, phone number, and profile picture.',
        ),
        FAQ(
          question: 'I forgot my password',
          answer:
              'Tap "Forgot Password" on the login screen. Enter your email, and we\'ll send you a reset link.',
        ),
        FAQ(
          question: 'How do I manage my addresses?',
          answer:
              'Go to Profile > Saved Addresses. You can add, edit, or delete addresses, and set a default delivery address.',
        ),
        FAQ(
          question: 'Can I have multiple accounts?',
          answer:
              'Each phone number and email can only be linked to one account. However, you can log out and create a new account with different credentials.',
        ),
      ],
    ),
    FAQCategory(
      title: 'Promo Codes & Offers',
      icon: Icons.local_offer_outlined,
      faqs: [
        FAQ(
          question: 'How do I use promo codes?',
          answer:
              'Enter your promo code at checkout or in the Promo Codes section of your profile. Valid codes will be automatically applied to eligible orders.',
        ),
        FAQ(
          question: 'Why isn\'t my promo code working?',
          answer:
              'Promo codes may have minimum order values, expiry dates, or be valid only for specific restaurants. Check the terms in the Promo Codes section.',
        ),
        FAQ(
          question: 'Can I use multiple promo codes?',
          answer:
              'Only one promo code can be applied per order. Choose the one that gives you the best discount.',
        ),
      ],
    ),
    FAQCategory(
      title: 'Subscription Plans',
      icon: Icons.card_membership,
      faqs: [
        FAQ(
          question: 'What are the benefits of subscription?',
          answer:
              'Subscribers get unlimited free delivery, exclusive discounts, priority support, and early access to new features and restaurants.',
        ),
        FAQ(
          question: 'Can I cancel my subscription?',
          answer:
              'Yes, you can cancel anytime from Profile > Delivery Subscription. Your benefits will continue until the end of your billing period.',
        ),
        FAQ(
          question: 'How do subscription refunds work?',
          answer:
              'If you cancel within 7 days of purchase, you\'ll receive a full refund. After that, the subscription remains active until the end of the billing cycle.',
        ),
      ],
    ),
  ];

  List<FAQCategory> get filteredCategories {
    if (_searchQuery.isEmpty) return categories;

    return categories
        .map((category) => FAQCategory(
              title: category.title,
              icon: category.icon,
              faqs: category.faqs
                  .where((faq) =>
                      faq.question
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      faq.answer
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                  .toList(),
            ))
        .where((category) => category.faqs.isNotEmpty)
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
          'Help & FAQ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: context.textColor,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: context.surfaceColor,
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: context.textColor),
              decoration: InputDecoration(
                hintText: 'Search for help...',
                hintStyle: TextStyle(color: context.subtitleColor),
                prefixIcon: Icon(
                  Icons.search,
                  color: context.subtitleColor,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: context.subtitleColor),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: context.colors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Quick Actions
          if (_searchQuery.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.support_agent,
                      title: 'Contact Support',
                      onTap: _contactSupport,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.chat_bubble_outline,
                      title: 'Live Chat',
                      onTap: _startLiveChat,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // FAQ List
          Expanded(
            child: filteredCategories.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, categoryIndex) {
                      final category = filteredCategories[categoryIndex];
                      return _buildCategorySection(category, categoryIndex);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _contactSupport,
        backgroundColor: context.primaryColor,
        icon: const Icon(Icons.headset_mic, color: Colors.white),
        label: const Text(
          'Contact Support',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.primaryColor.withOpacity(0.3)),
          boxShadow: ThemeUtils.createShadow(context, elevation: 1),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: context.primaryColor, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(FAQCategory category, int categoryIndex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ThemeUtils.createShadow(context, elevation: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    category.icon,
                    color: context.primaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  category.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.textColor,
                  ),
                ),
              ],
            ),
          ),
          ...category.faqs.asMap().entries.map((entry) {
            final index = entry.key;
            final faq = entry.value;
            final globalIndex = categoryIndex * 100 + index;
            final isExpanded = _expandedIndex == globalIndex;

            return Column(
              children: [
                if (index > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(
                      color: context.dividerColor,
                      height: 1,
                    ),
                  ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _expandedIndex = isExpanded ? null : globalIndex;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                faq.question,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: context.textColor,
                                ),
                              ),
                            ),
                            Icon(
                              isExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: context.subtitleColor,
                            ),
                          ],
                        ),
                        if (isExpanded) ...[
                          const SizedBox(height: 12),
                          Text(
                            faq.answer,
                            style: TextStyle(
                              fontSize: 14,
                              color: context.subtitleColor,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: context.subtitleColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: context.subtitleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _contactSupport() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              'Contact Support',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.textColor,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(Icons.email, color: context.primaryColor),
              title: Text('Email', style: TextStyle(color: context.textColor)),
              subtitle: Text('support@bezoni.com',
                  style: TextStyle(color: context.subtitleColor)),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.phone, color: context.primaryColor),
              title: Text('Phone', style: TextStyle(color: context.textColor)),
              subtitle: Text('+234 800 BEZONI',
                  style: TextStyle(color: context.subtitleColor)),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.chat, color: context.primaryColor),
              title:
                  Text('Live Chat', style: TextStyle(color: context.textColor)),
              subtitle: Text('Available 24/7',
                  style: TextStyle(color: context.subtitleColor)),
              onTap: _startLiveChat,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _startLiveChat() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Starting live chat...'),
        backgroundColor: context.primaryColor,
      ),
    );
  }
}

// Models
class FAQCategory {
  final String title;
  final IconData icon;
  final List<FAQ> faqs;

  FAQCategory({
    required this.title,
    required this.icon,
    required this.faqs,
  });
}

class FAQ {
  final String question;
  final String answer;

  FAQ({
    required this.question,
    required this.answer,
  });
}