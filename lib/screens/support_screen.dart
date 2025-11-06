import 'package:bezoni/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
// import '../core/api_service.dart';
import '../widgets/screen_wrapper.dart';
import '../themes/theme_extensions.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  String _selectedIssueType = 'General Inquiry';

  final List<String> _issueTypes = [
    'General Inquiry',
    'Order Issues',
    'Payment Problems',
    'Account Access',
    'App Technical Issues',
    'Safety Concerns',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      currentRoute: '/support',
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: AppBar(
          title: Text(
            'Support Center',
            style: TextStyle(
              color: context.colors.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
          backgroundColor: context.colors.surface,
          foregroundColor: context.colors.onSurface,
          elevation: 0,
          scrolledUnderElevation: 1,
          shadowColor: context.shadowColor,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Help'),
              Tab(text: 'Contact'),
              Tab(text: 'Tickets'),
              Tab(text: 'FAQ'),
            ],
            labelColor: context.primaryColor,
            unselectedLabelColor: context.subtitleColor,
            indicatorColor: context.primaryColor,
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildHelpTab(),
            _buildContactTab(),
            // _buildTicketsTab(),
            _buildFAQTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How can we help you?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find quick solutions or get in touch with our support team',
            style: TextStyle(fontSize: 16, color: context.subtitleColor),
          ),
          const SizedBox(height: 32),

          // Quick Actions
          _buildQuickActions(),

          const SizedBox(height: 32),

          // Popular Topics
          _buildPopularTopics(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: context.textColor,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.phone,
                title: 'Call Support',
                subtitle: '24/7 Available',
                color: context.successColor,
                onTap: () => _makePhoneCall('+234-800-BEZONI'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.chat,
                title: 'Live Chat',
                subtitle: 'Chat with agent',
                color: context.primaryColor,
                onTap: () => _startLiveChat(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.email,
                title: 'Email Us',
                subtitle: 'support@bezoni.com',
                color: context.infoColor,
                onTap: () => _sendEmail(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.report_problem,
                title: 'Report Issue',
                subtitle: 'Submit ticket',
                color: context.warningColor,
                onTap: () => _tabController.animateTo(2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ThemeUtils.createShadow(context, elevation: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: context.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: context.subtitleColor),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopularTopics() {
    final topics = [
      {
        'icon': Icons.delivery_dining,
        'title': 'Order Management',
        'description': 'How to accept, track, and complete deliveries',
      },
      {
        'icon': Icons.payment,
        'title': 'Earnings & Payments',
        'description': 'Understanding your earnings and payment schedule',
      },
      {
        'icon': Icons.location_on,
        'title': 'Location Services',
        'description': 'GPS, navigation, and delivery routing',
      },
      {
        'icon': Icons.account_circle,
        'title': 'Account Settings',
        'description': 'Profile, documents, and account management',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Topics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: context.textColor,
          ),
        ),
        const SizedBox(height: 16),
        ...topics.map(
          (topic) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: ThemeUtils.createShadow(context, elevation: 2),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _openHelpTopic(topic['title'] as String),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: context.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            topic['icon'] as IconData,
                            color: context.primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                topic['title'] as String,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: context.textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                topic['description'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.subtitleColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: context.subtitleColor),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Support',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Send us a message and we\'ll get back to you as soon as possible',
            style: TextStyle(fontSize: 16, color: context.subtitleColor),
          ),
          const SizedBox(height: 32),

          // Contact Form
          _buildContactForm(),
        ],
      ),
    );
  }

  Widget _buildContactForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Issue Type Dropdown
        Text(
          'Issue Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: context.textColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: context.dividerColor),
            borderRadius: BorderRadius.circular(12),
            color: context.cardColor,
          ),
          child: DropdownButton<String>(
            value: _selectedIssueType,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: context.cardColor,
            items: _issueTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type, style: TextStyle(color: context.textColor)),
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

        // Subject Field
        Text(
          'Subject',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: context.textColor,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _subjectController,
          decoration: InputDecoration(
            hintText: 'Brief description of your issue',
            hintStyle: TextStyle(color: context.subtitleColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.primaryColor),
            ),
            fillColor: context.cardColor,
            filled: true,
          ),
          style: TextStyle(color: context.textColor),
        ),

        const SizedBox(height: 24),

        // Message Field
        Text(
          'Message',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: context.textColor,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _messageController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Please describe your issue in detail...',
            hintStyle: TextStyle(color: context.subtitleColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.primaryColor),
            ),
            fillColor: context.cardColor,
            filled: true,
          ),
          style: TextStyle(color: context.textColor),
        ),

        const SizedBox(height: 32),

        // Submit Button
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: ElevatedButton.icon(
            onPressed: _submitMessage,
            icon: const Icon(Icons.send, color: Colors.white),
            label: const Text(
              'Send Message',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget _buildTicketsTab() {
  //   return Consumer<ApiService>(
  //     builder: (context, apiService, child) {
  //       return SingleChildScrollView(
  //         padding: const EdgeInsets.all(20),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   'Support Tickets',
  //                   style: TextStyle(
  //                     fontSize: 24,
  //                     fontWeight: FontWeight.bold,
  //                     color: context.textColor,
  //                   ),
  //                 ),
  //                 ElevatedButton.icon(
  //                   onPressed: () => _tabController.animateTo(1),
  //                   icon: const Icon(Icons.add, color: Colors.white),
  //                   label: const Text(
  //                     'New Ticket',
  //                     style: TextStyle(
  //                       color: Colors.white,
  //                       fontWeight: FontWeight.w600,
  //                     ),
  //                   ),
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: context.primaryColor,
  //                     elevation: 0,
  //                     padding: const EdgeInsets.symmetric(
  //                       horizontal: 16,
  //                       vertical: 12,
  //                     ),
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(12),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(height: 8),
  //             Text(
  //               'Track your submitted tickets and their status',
  //               style: TextStyle(fontSize: 16, color: context.subtitleColor),
  //             ),
  //             const SizedBox(height: 32),

  //             // Mock tickets - replace with real data from API
  //             _buildTicketsList(),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _buildTicketsList() {
    final mockTickets = [
      {
        'id': 'TKT-001',
        'subject': 'Unable to receive orders',
        'status': 'Open',
        'priority': 'High',
        'created': '2 hours ago',
        'lastUpdate': '1 hour ago',
      },
      {
        'id': 'TKT-002',
        'subject': 'Payment not received',
        'status': 'In Progress',
        'priority': 'Medium',
        'created': '1 day ago',
        'lastUpdate': '4 hours ago',
      },
      {
        'id': 'TKT-003',
        'subject': 'App crashes on startup',
        'status': 'Resolved',
        'priority': 'Low',
        'created': '3 days ago',
        'lastUpdate': '2 days ago',
      },
    ];

    if (mockTickets.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 80),
            Icon(Icons.support_agent, size: 64, color: context.subtitleColor),
            const SizedBox(height: 16),
            Text(
              'No support tickets yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'When you submit a support request, it will appear here',
              style: TextStyle(color: context.subtitleColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: mockTickets.map((ticket) {
        Color statusColor;
        switch (ticket['status']) {
          case 'Open':
            statusColor = context.errorColor;
            break;
          case 'In Progress':
            statusColor = context.warningColor;
            break;
          case 'Resolved':
            statusColor = context.successColor;
            break;
          default:
            statusColor = context.subtitleColor;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: ThemeUtils.createShadow(context, elevation: 2),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _viewTicket(ticket['id'] as String),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ticket['id'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: context.primaryColor,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              ticket['status'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ticket['subject'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: context.subtitleColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Created ${ticket['created']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.subtitleColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.update,
                            size: 16,
                            color: context.subtitleColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Updated ${ticket['lastUpdate']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFAQTab() {
    final faqs = [
      {
        'question': 'How do I go online to receive orders?',
        'answer':
            'Tap the toggle switch on your dashboard to go online. Make sure your location services are enabled and you have a stable internet connection.',
      },
      {
        'question': 'How are my earnings calculated?',
        'answer':
            'You earn 70% of the delivery fee for each completed order, plus any tips from customers. Payments are processed daily and sent to your registered account.',
      },
      {
        'question': 'What if a customer is not available for delivery?',
        'answer':
            'Try calling the customer first. If they don\'t respond after 5 minutes, contact support through the app. You may need to return the order to the restaurant.',
      },
      {
        'question': 'How do I update my vehicle information?',
        'answer':
            'Go to Profile > Vehicle Information in the app. You can update your vehicle type, registration, and insurance details there.',
      },
      {
        'question': 'What should I do if the app crashes?',
        'answer':
            'First, try closing and reopening the app. If the problem persists, restart your phone. Contact support if the issue continues.',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Quick answers to common questions',
            style: TextStyle(fontSize: 16, color: context.subtitleColor),
          ),
          const SizedBox(height: 32),

          ...faqs.map(
            (faq) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: ThemeUtils.createShadow(context, elevation: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ExpansionTile(
                    title: Text(
                      faq['question'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: context.textColor,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(
                          faq['answer'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: context.subtitleColor,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                    iconColor: context.primaryColor,
                    collapsedIconColor: context.subtitleColor,
                    backgroundColor: context.surfaceColor,
                    collapsedBackgroundColor: context.surfaceColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      _showErrorSnackBar('Could not launch phone dialer');
    }
  }

  void _sendEmail() async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: 'support@bezoni.com',
      queryParameters: {'subject': 'Rider Support Request'},
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      _showErrorSnackBar('Could not launch email client');
    }
  }

  void _startLiveChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildLiveChatModal(),
    );
  }

  Widget _buildLiveChatModal() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'Live Chat Support',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: context.textColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: context.textColor),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: context.subtitleColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chat feature coming soon!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: context.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'For now, please use the contact form or call us directly',
                    style: TextStyle(color: context.subtitleColor),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitMessage() async {
    if (_subjectController.text.isEmpty || _messageController.text.isEmpty) {
      _showErrorSnackBar('Please fill in all fields');
      return;
    }

    try {
      // Simulate API call - replace with actual implementation
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await Future.delayed(const Duration(seconds: 2));

      Navigator.of(context).pop(); // Close loading dialog

      // Clear form
      _subjectController.clear();
      _messageController.clear();
      setState(() {
        _selectedIssueType = 'General Inquiry';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Message sent successfully! We\'ll get back to you soon.',
          ),
          backgroundColor: context.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Switch to tickets tab
      _tabController.animateTo(2);
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      _showErrorSnackBar('Failed to send message. Please try again.');
    }
  }

  void _openHelpTopic(String topic) {
    // Navigate to detailed help topic screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening help for: $topic'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _viewTicket(String ticketId) {
    // Navigate to ticket detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ticket: $ticketId'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
