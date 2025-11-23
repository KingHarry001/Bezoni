import 'package:flutter/material.dart';
import 'package:bezoni/themes/theme_extensions.dart';
import 'package:bezoni/core/api_client.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final ApiClient _apiClient = ApiClient();

  String _searchQuery = '';
  int? _expandedFaqIndex;
  String _selectedIssueType = 'General Inquiry';
  bool _isSubmitting = false;

  final List<String> _issueTypes = [
    'General Inquiry',
    'Order Issues',
    'Payment Problems',
    'Delivery Issues',
    'Account Access',
    'App Technical Issues',
    'Restaurant/Vendor Issues',
    'Refund Request',
    'Safety Concerns',
    'Other',
  ];

  final List<FAQCategory> _categories = [
    FAQCategory(
      title: 'Orders & Delivery',
      icon: Icons.shopping_bag_outlined,
      color: const Color(0xFF2196F3),
      faqs: [
        FAQ(
          question: 'How do I track my order?',
          answer:
              'You can track your order in real-time from the Orders tab. Tap on any active order to see live updates including: Order Confirmed, Restaurant Preparing, Rider Assigned, Out for Delivery, and Delivered. You\'ll also receive push notifications at each stage.',
        ),
        FAQ(
          question: 'Can I cancel my order?',
          answer:
              'Yes, you can cancel your order before the restaurant confirms it (usually within 2-3 minutes). Go to Orders > Active Orders, select your order, and tap "Cancel Order". If the restaurant has already started preparing, cancellation may not be possible. Refunds for cancelled orders are processed within 3-5 business days.',
        ),
        FAQ(
          question: 'What if my order is late?',
          answer:
              'If your order is delayed beyond the estimated delivery time, you can: 1) Track the rider in real-time on the map, 2) Contact the rider directly via the in-app call button, 3) Contact our support team. We offer compensation for significant delays through credits or refunds.',
        ),
        FAQ(
          question: 'How long does delivery take?',
          answer:
              'Delivery times typically range from 20-45 minutes depending on: restaurant preparation time, distance, traffic conditions, and rider availability. You\'ll see an estimated delivery time before placing your order. Premium members get priority delivery.',
        ),
        FAQ(
          question: 'Can I change my delivery address after ordering?',
          answer:
              'You can modify your delivery address only before the restaurant confirms the order. After confirmation, address changes may incur additional delivery fees. Contact support immediately if you need to change the address after confirmation.',
        ),
      ],
    ),
    FAQCategory(
      title: 'Payments & Refunds',
      icon: Icons.payment,
      color: const Color(0xFF4CAF50),
      faqs: [
        FAQ(
          question: 'What payment methods are accepted?',
          answer:
              'We accept: Credit/Debit Cards (Visa, Mastercard, Verve), Bank Transfers, Mobile Wallets (PayStack, Flutterwave), Bezoni Wallet, and Cash on Delivery. All online payments are secured with SSL encryption and PCI DSS compliance.',
        ),
        FAQ(
          question: 'How do refunds work?',
          answer:
              'Refunds are processed automatically for: cancelled orders (before preparation), failed deliveries, wrong or missing items. Card/wallet refunds take 3-5 business days. Cash on delivery cancellations result in no charge. Wallet refunds are instant.',
        ),
        FAQ(
          question: 'Are there any hidden charges?',
          answer:
              'Absolutely not! The final price includes: Food cost, Delivery fee (varies by distance), Service charge (10%), and applicable taxes. You\'ll see a complete breakdown before checkout. No surprises!',
        ),
        FAQ(
          question: 'Can I save my payment details?',
          answer:
              'Yes! You can securely save multiple payment cards in Settings > Payment Methods for faster checkout. Your card details are tokenized and stored with bank-level encryption. We never store your CVV.',
        ),
        FAQ(
          question: 'What is Bezoni Wallet?',
          answer:
              'Bezoni Wallet is your in-app digital wallet for faster payments. Add funds via bank transfer or card, and enjoy instant checkouts. Wallet funds never expire and can be used for any order or parcel delivery.',
        ),
      ],
    ),
    FAQCategory(
      title: 'Account & Profile',
      icon: Icons.person_outline,
      color: const Color(0xFFFF9800),
      faqs: [
        FAQ(
          question: 'How do I update my profile?',
          answer:
              'Go to Profile tab, tap the edit icon, and update your: Name, Email, Phone number, Profile picture, Default delivery address. Remember to verify your email for full access to all features.',
        ),
        FAQ(
          question: 'I forgot my password',
          answer:
              'Tap "Forgot Password" on the login screen. Enter your registered email, and we\'ll send a secure reset link. The link expires in 1 hour. If you don\'t receive it, check your spam folder or request a new link.',
        ),
        FAQ(
          question: 'How do I manage saved addresses?',
          answer:
              'Go to Profile > Delivery Addresses. You can: Add new addresses with labels (Home, Work, etc.), Edit existing addresses, Delete unused addresses, Set a default delivery address. Saved addresses make checkout faster!',
        ),
        FAQ(
          question: 'Can I have multiple accounts?',
          answer:
              'Each phone number and email can only be linked to one account for security. However, you can log out and create a new account with different credentials. We don\'t recommend this as you\'ll lose order history and wallet balance.',
        ),
        FAQ(
          question: 'How do I delete my account?',
          answer:
              'Go to Profile > Settings > Account Settings > Delete Account. This action is permanent and will: Delete your profile data, Cancel active orders, Remove saved cards, Clear wallet balance. We\'ll send a confirmation email before final deletion.',
        ),
      ],
    ),
    FAQCategory(
      title: 'Promo Codes & Offers',
      icon: Icons.local_offer_outlined,
      color: const Color(0xFFE91E63),
      faqs: [
        FAQ(
          question: 'How do I use promo codes?',
          answer:
              'At checkout, tap "Apply Promo Code", enter your code, and tap Apply. Valid codes are automatically applied to eligible orders. You can also add codes in Profile > Promo Codes section to use later.',
        ),
        FAQ(
          question: 'Why isn\'t my promo code working?',
          answer:
              'Promo codes may not work if: They\'ve expired, Minimum order value not met, Valid only for specific restaurants, Already used (one-time codes), Not applicable to your order type. Check the terms in the Promo Codes section.',
        ),
        FAQ(
          question: 'Can I use multiple promo codes?',
          answer:
              'Only one promo code can be applied per order. The app will automatically suggest the best discount for your order. Choose wisely!',
        ),
        FAQ(
          question: 'Where can I find promo codes?',
          answer:
              'Get promo codes from: Email newsletters, In-app notifications, Social media pages (@bezoniapp), Referral program (invite friends), Special seasonal campaigns. Enable notifications to never miss a deal!',
        ),
      ],
    ),
    FAQCategory(
      title: 'Premium Subscription',
      icon: Icons.workspace_premium,
      color: const Color(0xFF9C27B0),
      faqs: [
        FAQ(
          question: 'What are the benefits of Premium?',
          answer:
              'Premium members enjoy: Unlimited free delivery on orders over ₦2,000, Exclusive 15% discounts at partner restaurants, Priority customer support, Early access to new features, No surge pricing during peak hours, Special birthday perks.',
        ),
        FAQ(
          question: 'How much does Premium cost?',
          answer:
              'Premium costs ₦4,999/month or ₦49,999/year (save 17%). First month is free for new subscribers! Cancel anytime with no penalties. Annual subscribers get 2 months free.',
        ),
        FAQ(
          question: 'Can I cancel my subscription?',
          answer:
              'Yes, cancel anytime from Profile > Premium Subscription > Cancel. Your benefits continue until the end of your billing period. No refunds for partial months, but you keep access until expiry.',
        ),
        FAQ(
          question: 'Do I save money with Premium?',
          answer:
              'If you order 3+ times per month, Premium pays for itself! Average users save ₦8,000-₦15,000 monthly on delivery fees and exclusive discounts. Plus, enjoy peace of mind with priority support.',
        ),
      ],
    ),
    FAQCategory(
      title: 'Safety & Security',
      icon: Icons.security,
      color: const Color(0xFFF44336),
      faqs: [
        FAQ(
          question: 'How is my data protected?',
          answer:
              'We use bank-level security: SSL/TLS encryption for all data transmission, Secure cloud storage, Regular security audits, GDPR compliance, No sharing of personal data with third parties. Your privacy is our priority.',
        ),
        FAQ(
          question: 'What if I receive the wrong order?',
          answer:
              'Contact support immediately via the app. Don\'t accept the order. We\'ll: Send the correct order at no charge, Issue a full refund, Compensate with credits. Take photos of the wrong items for faster resolution.',
        ),
        FAQ(
          question: 'Contactless delivery options?',
          answer:
              'Yes! Select "Contactless Delivery" at checkout. Rider will: Leave order at your door, Ring bell/knock, Step back 6 feet, Wait for you to collect. Perfect for maintaining social distancing.',
        ),
        FAQ(
          question: 'How do I report a safety concern?',
          answer:
              'Report immediately via: In-app support chat, Safety hotline: +234-800-BEZONI, Email: safety@bezoni.com. For emergencies, contact local authorities first. All reports are taken seriously and investigated within 24 hours.',
        ),
      ],
    ),
  ];

  List<FAQCategory> get _filteredCategories {
    if (_searchQuery.isEmpty) return _categories;

    return _categories
        .map((category) => FAQCategory(
              title: category.title,
              icon: category.icon,
              color: category.color,
              faqs: category.faqs
                  .where((faq) =>
                      faq.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      faq.answer.toLowerCase().contains(_searchQuery.toLowerCase()))
                  .toList(),
            ))
        .where((category) => category.faqs.isNotEmpty)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _messageController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Support & Help Center',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  'We\'re here to help 24/7',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
              Container(
                color: Colors.white.withOpacity(0.2),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(0.6),
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(text: 'Help & FAQ'),
                    Tab(text: 'Contact Us'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHelpTab(),
          _buildContactTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startLiveChat,
        backgroundColor: context.primaryColor,
        elevation: 4,
        icon: const Icon(Icons.chat_bubble, color: Colors.white),
        label: const Text(
          'Live Chat',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildHelpTab() {
    return Column(
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.all(20),
          color: context.surfaceColor,
          child: TextField(
            controller: _searchController,
            style: TextStyle(color: context.textColor),
            decoration: InputDecoration(
              hintText: 'Search for help...',
              hintStyle: TextStyle(color: context.subtitleColor),
              prefixIcon: Icon(Icons.search, color: context.primaryColor),
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
              fillColor: context.backgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: context.dividerColor.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: context.primaryColor, width: 2),
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
        if (_searchQuery.isEmpty) _buildQuickActions(),

        // FAQ List
        Expanded(
          child: _filteredCategories.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = _filteredCategories[index];
                    return _buildCategorySection(category, index);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.textColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.phone,
                  title: 'Call Support',
                  subtitle: '24/7 Available',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                  ),
                  onTap: () => _makePhoneCall('+234-800-BEZONI'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.email,
                  title: 'Email Us',
                  subtitle: 'Get Help',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                  ),
                  onTap: () => _tabController.animateTo(1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
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
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(FAQCategory category, int categoryIndex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [category.color, category.color.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: category.color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(category.icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    category.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.textColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${category.faqs.length}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: category.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...category.faqs.asMap().entries.map((entry) {
            final index = entry.key;
            final faq = entry.value;
            final globalIndex = categoryIndex * 100 + index;
            final isExpanded = _expandedFaqIndex == globalIndex;

            return Column(
              children: [
                if (index > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(color: context.dividerColor.withOpacity(0.3), height: 1),
                  ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _expandedFaqIndex = isExpanded ? null : globalIndex;
                      });
                    },
                    borderRadius: index == category.faqs.length - 1
                        ? const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          )
                        : BorderRadius.zero,
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
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: isExpanded
                                      ? context.primaryColor.withOpacity(0.1)
                                      : context.dividerColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  isExpanded ? Icons.remove : Icons.add,
                                  color: isExpanded ? context.primaryColor : context.subtitleColor,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                          if (isExpanded) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: context.backgroundColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                faq.answer,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.subtitleColor,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
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
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 64,
                color: context.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.textColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try searching with different keywords\nor contact our support team',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: context.subtitleColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _tabController.animateTo(1),
              icon: const Icon(Icons.support_agent, color: Colors.white),
              label: const Text(
                'Contact Support',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contact Methods
          _buildContactMethods(),

          const SizedBox(height: 32),
          Divider(color: context.dividerColor.withOpacity(0.3)),
          const SizedBox(height: 32),

          // Contact Form
          Text(
            'Send us a message',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: context.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We typically respond within 2-4 hours',
            style: TextStyle(
              fontSize: 15,
              color: context.subtitleColor,
            ),
          ),
          const SizedBox(height: 24),

          _buildContactForm(),
        ],
      ),
    );
  }

  Widget _buildContactMethods() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(20),
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
          Text(
            'Get in touch',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.textColor,
            ),
          ),
          const SizedBox(height: 20),
          _buildContactMethod(
            icon: Icons.phone,
            title: 'Phone Support',
            subtitle: '+234-800-BEZONI (239664)',
            trailing: 'Call Now',
            color: const Color(0xFF4CAF50),
            onTap: () => _makePhoneCall('+234-800-239664'),
          ),
          const SizedBox(height: 16),
          _buildContactMethod(
            icon: Icons.email,
            title: 'Email',
            subtitle: 'support@bezoni.com',
            trailing: 'Send Email',
            color: const Color(0xFF2196F3),
            onTap: _sendEmail,
          ),
          const SizedBox(height: 16),
          _buildContactMethod(
            icon: Icons.chat_bubble,
            title: 'Live Chat',
            subtitle: 'Available 24/7',
            trailing: 'Start Chat',
            color: const Color(0xFFFF9800),
            onTap: _startLiveChat,
          ),
          const SizedBox(height: 16),
          _buildContactMethod(
            icon: Icons.location_on,
            title: 'Office',
            subtitle: '123 Tech Avenue, Lagos, Nigeria',
            trailing: 'Get Directions',
            color: const Color(0xFFE91E63),
            onTap: () => _showToast('Opening maps...'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactMethod({
    required IconData icon,
    required String title,
    required String subtitle,
    required String trailing,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
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
                    const SizedBox(height: 4),
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
              Text(
                trailing,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(20),
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
          // Issue Type
          Text(
            'Issue Type',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: context.textColor,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: context.backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.dividerColor.withOpacity(0.3)),
            ),
            child: DropdownButton<String>(
              value: _selectedIssueType,
              isExpanded: true,
              underline: const SizedBox(),
              dropdownColor: context.cardColor,
              icon: Icon(Icons.keyboard_arrow_down, color: context.primaryColor),
              items: _issueTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(
                    type,
                    style: TextStyle(
                      color: context.textColor,
                      fontSize: 15,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedIssueType = newValue!;
                });
              },
            ),
          ),

          const SizedBox(height: 24),

          // Subject
          Text(
            'Subject',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: context.textColor,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _subjectController,
            style: TextStyle(color: context.textColor),
            decoration: InputDecoration(
              hintText: 'Brief description of your issue',
              hintStyle: TextStyle(color: context.subtitleColor),
              filled: true,
              fillColor: context.backgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: context.dividerColor.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: context.primaryColor, width: 2),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Message
          Text(
            'Message',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: context.textColor,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _messageController,
            maxLines: 6,
            style: TextStyle(color: context.textColor),
            decoration: InputDecoration(
              hintText: 'Please describe your issue in detail...\n\nInclude:\n• What happened\n• When it happened\n• Steps to reproduce (if applicable)',
              hintStyle: TextStyle(color: context.subtitleColor, fontSize: 14),
              filled: true,
              fillColor: context.backgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: context.dividerColor.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: context.primaryColor, width: 2),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitMessage,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                disabledBackgroundColor: context.primaryColor.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.send, color: Colors.white, size: 20),
                        SizedBox(width: 12),
                        Text(
                          'Send Message',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // Info Text
          Row(
            children: [
              Icon(Icons.info_outline, color: context.subtitleColor, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'You\'ll receive a confirmation email once we receive your message',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.subtitleColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper Methods

  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        _showToast('Could not launch phone dialer');
      }
    } catch (e) {
      _showToast('Error: ${e.toString()}');
    }
  }

  Future<void> _sendEmail() async {
    try {
      final Uri launchUri = Uri(
        scheme: 'mailto',
        path: 'support@bezoni.com',
        queryParameters: {
          'subject': 'Support Request - Bezoni App',
          'body': 'Please describe your issue here...',
        },
      );
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        _showToast('Could not launch email client');
      }
    } catch (e) {
      _showToast('Error: ${e.toString()}');
    }
  }

  void _startLiveChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: context.backgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle
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

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [context.primaryColor, context.primaryColor.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.support_agent, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Live Chat Support',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: context.textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Online - Avg response: 2 min',
                              style: TextStyle(
                                fontSize: 13,
                                color: context.subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: context.textColor),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Divider(color: context.dividerColor.withOpacity(0.3), height: 1),

            // Coming Soon Content
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              context.primaryColor.withOpacity(0.1),
                              context.primaryColor.withOpacity(0.05),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: context.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Live Chat Coming Soon!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: context.textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'We\'re working on bringing you real-time chat support. In the meantime, you can:',
                        style: TextStyle(
                          fontSize: 15,
                          color: context.subtitleColor,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      _buildComingSoonOption(
                        icon: Icons.phone,
                        title: 'Call us now',
                        subtitle: '+234-800-BEZONI',
                        onTap: () {
                          Navigator.pop(context);
                          _makePhoneCall('+234-800-239664');
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildComingSoonOption(
                        icon: Icons.email,
                        title: 'Send an email',
                        subtitle: 'support@bezoni.com',
                        onTap: () {
                          Navigator.pop(context);
                          _tabController.animateTo(1);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoonOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.dividerColor.withOpacity(0.3)),
          ),
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
                    const SizedBox(height: 4),
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
              Icon(Icons.arrow_forward_ios, color: context.primaryColor, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitMessage() async {
    // Validation
    if (_subjectController.text.trim().isEmpty) {
      _showToast('Please enter a subject');
      return;
    }

    if (_messageController.text.trim().isEmpty) {
      _showToast('Please enter your message');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: Replace with actual API call
      // Example: await _apiClient.submitSupportTicket(...)
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Clear form
      _subjectController.clear();
      _messageController.clear();
      setState(() {
        _selectedIssueType = 'General Inquiry';
        _isSubmitting = false;
      });

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: context.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF4CAF50),
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Message Sent!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Thank you for contacting us. Our support team will get back to you within 2-4 hours.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: context.subtitleColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      _showToast('Failed to send message. Please try again.');
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
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
// MODELS
// ============================================================================

class FAQCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<FAQ> faqs;

  FAQCategory({
    required this.title,
    required this.icon,
    required this.color,
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