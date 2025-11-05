import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFF10B981),
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Dave Johnson",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const Text(
                      "dave@example.com",
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatCard(title: "Orders", value: "12"),
                        _StatCard(title: "Saved", value: "₦2,340"),
                        _StatCard(title: "Points", value: "450"),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Delivery Subscription Section
              _ProfileSection(
                title: "Subscription",
                items: [
                  _ProfileItem(
                    icon: Icons.delivery_dining,
                    title: "Delivery Subscription",
                    subtitle: "Save on every order",
                    onTap: () => _showDeliverySubscriptionModal(context),
                  ),
                ],
              ),

              // Menu Items
              _ProfileSection(
                title: "Account",
                items: [
                  _ProfileItem(
                    icon: Icons.person_outline,
                    title: "Personal Information",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PersonalDetailsScreen(),
                        ),
                      );
                    },
                  ),
                  _ProfileItem(
                    icon: Icons.location_on_outlined,
                    title: "Addresses",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddressesScreen(),
                        ),
                      );
                    },
                  ),
                  _ProfileItem(
                    icon: Icons.payment,
                    title: "Payment Methods",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentMethodsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              _ProfileSection(
                title: "Orders",
                items: [
                  _ProfileItem(
                    icon: Icons.history,
                    title: "Order History",
                    onTap: () => _showToast(context, "Order History"),
                  ),
                  _ProfileItem(
                    icon: Icons.favorite_outline,
                    title: "Favorites",
                    onTap: () => _showToast(context, "Favorites"),
                  ),
                ],
              ),

              _ProfileSection(
                title: "Support",
                items: [
                  _ProfileItem(
                    icon: Icons.help_outline,
                    title: "Help Center",
                    onTap: () => _showToast(context, "Help Center"),
                  ),
                  _ProfileItem(
                    icon: Icons.chat_bubble_outline,
                    title: "Contact Support",
                    onTap: () => Navigator.pushNamed(context, '/messages'),
                  ),
                  _ProfileItem(
                    icon: Icons.star_outline,
                    title: "Rate App",
                    onTap: () => _showToast(context, "Rate App"),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _showLogoutDialog(context),
                    child: const Text(
                      "Logout",
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeliverySubscriptionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DeliverySubscriptionModal(),
    );
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$message tapped")));
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
            child: const Text(
              "Logout",
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }
}

/// =====================
/// Stat Card Widget
/// =====================
class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

/// =====================
/// Profile Section Widget
/// =====================
class _ProfileSection extends StatelessWidget {
  final String title;
  final List<_ProfileItem> items;

  const _ProfileSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          ...items.map((item) => item).toList(),
        ],
      ),
    );
  }
}

/// =====================
/// Profile Item Widget
/// =====================
class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _ProfileItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF6B7280), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF6B7280),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

/// =====================
/// Subscription Plan Model
/// =====================
class SubscriptionPlan {
  final String id;
  final String name;
  final double price;
  final List<String> features;
  final bool isCurrentPlan;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.features,
    this.isCurrentPlan = false,
  });
}

/// =====================
/// Delivery Subscription Modal
/// =====================
class DeliverySubscriptionModal extends StatefulWidget {
  const DeliverySubscriptionModal({super.key});

  @override
  State<DeliverySubscriptionModal> createState() =>
      _DeliverySubscriptionModalState();
}

class _DeliverySubscriptionModalState extends State<DeliverySubscriptionModal>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  String? selectedPlan;

  final List<SubscriptionPlan> plans = [
    SubscriptionPlan(
      id: 'lite',
      name: '🟢 Lite',
      price: 4000,
      features: [
        '10 Free Deliveries',
        'Save 15% After Limit',
        'Roll Over 2 Unused Deliveries',
      ],
      isCurrentPlan: true,
    ),
    SubscriptionPlan(
      id: 'foodie',
      name: '🍽️ Foodie Plan',
      price: 7500,
      features: [
        'Unlimited Food Deliveries',
        'Exclusive Food Discounts',
        '1 Free Parcel/Month',
      ],
    ),
    SubscriptionPlan(
      id: 'combo',
      name: '🚚 Combo',
      price: 9500,
      features: [
        'Unlimited Food & Parcel Deliveries',
        'Free Parcel Pickups',
        'Double Order Mode',
      ],
    ),
    SubscriptionPlan(
      id: 'lunchlink',
      name: '🥙 LunchLink',
      price: 12500,
      features: [
        'Daily Lunch Deliveries',
        'Free Parcel Pickups',
        'Double Order Mode',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _slideController.forward();
    selectedPlan = 'lite'; // Default to current plan
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xFFF8F9FA),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Delivery Subscription',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Plans List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 200 + (index * 50)),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: SubscriptionPlanCard(
                      plan: plan,
                      isSelected: selectedPlan == plan.id,
                      onTap: () {
                        setState(() {
                          selectedPlan = plan.id;
                        });
                      },
                      onCheckout: () => _handleCheckout(context, plan),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCheckout(BuildContext context, SubscriptionPlan plan) {
    if (plan.isCurrentPlan) {
      _showCancelSubscriptionDialog(context);
    } else {
      _showCheckoutModal(context, plan);
    }
  }

  void _showCancelSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text(
          'Are you sure you want to cancel your current subscription?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showToast(context, 'Subscription cancelled');
            },
            child: const Text(
              'Cancel Subscription',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckoutModal(BuildContext context, SubscriptionPlan plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CheckoutModal(plan: plan),
    );
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

/// =====================
/// Subscription Plan Card
/// =====================
class SubscriptionPlanCard extends StatefulWidget {
  final SubscriptionPlan plan;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onCheckout;

  const SubscriptionPlanCard({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.onTap,
    required this.onCheckout,
  });

  @override
  State<SubscriptionPlanCard> createState() => _SubscriptionPlanCardState();
}

class _SubscriptionPlanCardState extends State<SubscriptionPlanCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected
                  ? const Color(0xFF10B981)
                  : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.plan.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    if (widget.plan.isCurrentPlan) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Current Plan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      '₦${widget.plan.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const Text(
                      '/month',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  "What's Included",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                ...widget.plan.features.map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Color(0xFF10B981),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          feature,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.plan.isCurrentPlan
                          ? Colors.red
                          : const Color(0xFF1A1A1A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: widget.onCheckout,
                    child: Text(
                      widget.plan.isCurrentPlan
                          ? 'Cancel Subscription'
                          : 'Checkout',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// =====================
/// Checkout Modal
/// =====================
class CheckoutModal extends StatefulWidget {
  final SubscriptionPlan plan;

  const CheckoutModal({super.key, required this.plan});

  @override
  State<CheckoutModal> createState() => _CheckoutModalState();
}

class _CheckoutModalState extends State<CheckoutModal>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  String selectedPaymentMethod = 'card';
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Color(0xFFF8F9FA),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Checkout',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Order Summary',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Text(
                                widget.plan.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4B5563),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '₦${widget.plan.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            children: [
                              Text(
                                'Subscription Fee',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4B5563),
                                ),
                              ),
                              Spacer(),
                              Text(
                                'Free',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF10B981),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              const Text(
                                'Total Amount',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '₦${widget.plan.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Payment Method Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Payment Method',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Add Bank Card Option
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedPaymentMethod = 'card';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: selectedPaymentMethod == 'card'
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFE5E7EB),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.add,
                                    color: Color(0xFF10B981),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Add Bank Card'),
                                  const Spacer(),
                                  Radio<String>(
                                    value: 'card',
                                    groupValue: selectedPaymentMethod,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedPaymentMethod = value!;
                                      });
                                    },
                                    activeColor: const Color(0xFF10B981),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Pay With Transfer Option
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedPaymentMethod = 'transfer';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: selectedPaymentMethod == 'transfer'
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFE5E7EB),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.account_balance,
                                    color: Color(0xFF6B7280),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Pay With Transfer'),
                                  const Spacer(),
                                  Radio<String>(
                                    value: 'transfer',
                                    groupValue: selectedPaymentMethod,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedPaymentMethod = value!;
                                      });
                                    },
                                    activeColor: const Color(0xFF10B981),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (selectedPaymentMethod == 'card') ...[
                      const SizedBox(height: 16),

                      // Card Details Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cards',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Card Number
                            const Text(
                              'Card Number',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF374151),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _cardNumberController,
                              decoration: InputDecoration(
                                hintText: '5641 XXXX XXXX 0337',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF9CA3AF),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE5E7EB),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Card Name
                            const Text(
                              'Name on Card',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF374151),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _cardNameController,
                              decoration: InputDecoration(
                                hintText: 'Al Hassan Yusuf',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF9CA3AF),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE5E7EB),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Expiry Date and CVV
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Expiry Date',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF374151),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: _expiryController,
                                        decoration: InputDecoration(
                                          hintText: '05/25',
                                          hintStyle: const TextStyle(
                                            color: Color(0xFF9CA3AF),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFE5E7EB),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xFF10B981),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'CVV',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF374151),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: _cvvController,
                                        decoration: InputDecoration(
                                          hintText: '324',
                                          hintStyle: const TextStyle(
                                            color: Color(0xFF9CA3AF),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFE5E7EB),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xFF10B981),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Action Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _handlePayment(context),
                      child: Text(
                        selectedPaymentMethod == 'card'
                            ? 'Add Card'
                            : 'Continue',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (selectedPaymentMethod == 'card') ...[
                    const SizedBox(height: 12),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock, size: 16, color: Color(0xFF6B7280)),
                        SizedBox(width: 4),
                        Text(
                          'Your payment information is secure',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePayment(BuildContext context) {
    if (selectedPaymentMethod == 'card') {
      // Validate card fields
      if (_cardNumberController.text.isEmpty ||
          _cardNameController.text.isEmpty ||
          _expiryController.text.isEmpty ||
          _cvvController.text.isEmpty) {
        _showToast(context, 'Please fill in all card details');
        return;
      }
    }

    // Show success modal
    _showSuccessModal(context);
  }

  void _showSuccessModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => SubscriptionSuccessModal(plan: widget.plan),
    );
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

/// =====================
/// Subscription Success Modal
/// =====================
class SubscriptionSuccessModal extends StatefulWidget {
  final SubscriptionPlan plan;

  const SubscriptionSuccessModal({super.key, required this.plan});

  @override
  State<SubscriptionSuccessModal> createState() =>
      _SubscriptionSuccessModalState();
}

class _SubscriptionSuccessModalState extends State<SubscriptionSuccessModal>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Success Icon
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 40),
                ),
              ),

              const SizedBox(height: 24),

              // Success Title
              const Text(
                'Subscription Successful',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),

              const SizedBox(height: 12),

              // Success Message
              Text(
                'You are now receiving delivery\nbased on subscription',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),

              const Spacer(),

              // Go Home Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Close all modals and go back to profile
                    Navigator.of(context)
                      ..pop() // Close success modal
                      ..pop() // Close checkout modal
                      ..pop(); // Close subscription modal
                  },
                  child: const Text(
                    'Go Home',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// =====================
/// Personal Details Screen
/// =====================
class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController(text: 'Dave');
  final _lastNameController = TextEditingController(text: 'Johnson');
  final _emailController = TextEditingController(text: 'dave@example.com');
  final _phoneController = TextEditingController(text: '+234 801 234 5678');
  final _dobController = TextEditingController(text: '15/03/1990');

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Personal Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundColor: Color(0xFF10B981),
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tap to change profile picture',
                      style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Personal Details Form
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // First Name
                    _buildTextField(
                      label: 'First Name',
                      controller: _firstNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'First name is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Last Name
                    _buildTextField(
                      label: 'Last Name',
                      controller: _lastNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Last name is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Email
                    _buildTextField(
                      label: 'Email Address',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Phone Number
                    _buildTextField(
                      label: 'Phone Number',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone number is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Date of Birth
                    _buildTextField(
                      label: 'Date of Birth',
                      controller: _dobController,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      suffixIcon: Icons.calendar_today,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _saveChanges,
                  child: const Text(
                    'Save Changes',
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
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF10B981)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: const Color(0xFF6B7280))
                : null,
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 3, 15),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF10B981)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Personal information updated successfully!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }
}

/// =====================
/// Addresses Screen
/// =====================
class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  List<Address> addresses = [
    Address(
      id: '1',
      label: 'Home',
      address: '123 Main Street, Victoria Island, Lagos',
      isDefault: true,
    ),
    Address(
      id: '2',
      label: 'Work',
      address: '456 Business District, Ikoyi, Lagos',
      isDefault: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Addresses',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF10B981)),
            onPressed: () => _showAddAddressModal(context),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          final address = addresses[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: address.isDefault
                  ? Border.all(color: const Color(0xFF10B981), width: 2)
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: address.isDefault
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        address.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: address.isDefault
                              ? Colors.white
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    if (address.isDefault) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Color(0xFF10B981),
                      ),
                      const Text(
                        'Default',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const Spacer(),
                    PopupMenuButton<String>(
                      onSelected: (value) =>
                          _handleAddressAction(value, address),
                      itemBuilder: (context) => [
                        if (!address.isDefault)
                          const PopupMenuItem(
                            value: 'set_default',
                            child: Text('Set as Default'),
                          ),
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                      child: const Icon(
                        Icons.more_vert,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  address.address,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4B5563),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAddressModal(context),
        backgroundColor: const Color(0xFF10B981),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _handleAddressAction(String action, Address address) {
    switch (action) {
      case 'set_default':
        setState(() {
          for (var addr in addresses) {
            addr.isDefault = addr.id == address.id;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Default address updated')),
        );
        break;
      case 'edit':
        _showEditAddressModal(context, address);
        break;
      case 'delete':
        _showDeleteConfirmation(context, address);
        break;
    }
  }

  void _showAddAddressModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddAddressModal(
        onAddAddress: (address) {
          setState(() {
            addresses.add(address);
          });
        },
      ),
    );
  }

  void _showEditAddressModal(BuildContext context, Address address) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddAddressModal(
        address: address,
        onAddAddress: (editedAddress) {
          setState(() {
            final index = addresses.indexWhere((a) => a.id == address.id);
            if (index != -1) {
              addresses[index] = editedAddress;
            }
          });
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Address address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                addresses.removeWhere((a) => a.id == address.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Address deleted')));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class Address {
  final String id;
  String label;
  String address;
  bool isDefault;

  Address({
    required this.id,
    required this.label,
    required this.address,
    required this.isDefault,
  });
}

class AddAddressModal extends StatefulWidget {
  final Address? address;
  final Function(Address) onAddAddress;

  const AddAddressModal({super.key, this.address, required this.onAddAddress});

  @override
  State<AddAddressModal> createState() => _AddAddressModalState();
}

class _AddAddressModalState extends State<AddAddressModal> {
  final _labelController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _labelController.text = widget.address!.label;
      _addressController.text = widget.address!.address;
      _isDefault = widget.address!.isDefault;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.address == null ? 'Add New Address' : 'Edit Address',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 24),

          // Label
          const Text(
            'Address Label',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _labelController,
            decoration: InputDecoration(
              hintText: 'e.g., Home, Work, School',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF10B981)),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Address
          const Text(
            'Full Address',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _addressController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter your full address...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF10B981)),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Set as Default
          Row(
            children: [
              Checkbox(
                value: _isDefault,
                onChanged: (value) {
                  setState(() {
                    _isDefault = value ?? false;
                  });
                },
                activeColor: const Color(0xFF10B981),
              ),
              const Text(
                'Set as default address',
                style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
              ),
            ],
          ),

          const Spacer(),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _saveAddress,
              child: Text(
                widget.address == null ? 'Add Address' : 'Update Address',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveAddress() {
    if (_labelController.text.isEmpty || _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final address = Address(
      id:
          widget.address?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      label: _labelController.text,
      address: _addressController.text,
      isDefault: _isDefault,
    );

    widget.onAddAddress(address);
    Navigator.pop(context);
  }
}

/// =====================
/// Payment Methods Screen
/// =====================
class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<PaymentMethod> paymentMethods = [
    PaymentMethod(
      id: '1',
      type: 'card',
      cardNumber: '**** **** **** 1234',
      cardType: 'Visa',
      expiryDate: '12/25',
      isDefault: true,
    ),
    PaymentMethod(
      id: '2',
      type: 'card',
      cardNumber: '**** **** **** 5678',
      cardType: 'Mastercard',
      expiryDate: '09/26',
      isDefault: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment Methods',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF10B981)),
            onPressed: () => _showAddPaymentModal(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Cards Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Saved Cards',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 16),
                ...paymentMethods
                    .map((method) => _buildPaymentCard(method))
                    .toList(),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Other Payment Methods
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Other Payment Methods',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 16),
                _buildPaymentOption(
                  icon: Icons.account_balance,
                  title: 'Bank Transfer',
                  subtitle: 'Pay directly from your bank account',
                  onTap: () => _showToast('Bank Transfer selected'),
                ),
                const Divider(height: 24),
                _buildPaymentOption(
                  icon: Icons.account_balance_wallet,
                  title: 'Mobile Wallet',
                  subtitle: 'Use your mobile wallet for payments',
                  onTap: () => _showToast('Mobile Wallet selected'),
                ),
                const Divider(height: 24),
                _buildPaymentOption(
                  icon: Icons.money,
                  title: 'Cash on Delivery',
                  subtitle: 'Pay when your order arrives',
                  onTap: () => _showToast('Cash on Delivery selected'),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPaymentModal(context),
        backgroundColor: const Color(0xFF10B981),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPaymentCard(PaymentMethod method) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: method.isDefault
            ? Border.all(color: const Color(0xFF10B981), width: 2)
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              method.cardType == 'Visa' ? Icons.credit_card : Icons.payment,
              color: const Color(0xFF10B981),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      method.cardNumber,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const Spacer(),
                    if (method.isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Default',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${method.cardType} • Expires ${method.expiryDate}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handlePaymentAction(value, method),
            itemBuilder: (context) => [
              if (!method.isDefault)
                const PopupMenuItem(
                  value: 'set_default',
                  child: Text('Set as Default'),
                ),
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
            child: const Icon(Icons.more_vert, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6B7280), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: Color(0xFF6B7280),
            size: 16,
          ),
        ],
      ),
    );
  }

  void _handlePaymentAction(String action, PaymentMethod method) {
    switch (action) {
      case 'set_default':
        setState(() {
          for (var pm in paymentMethods) {
            pm.isDefault = pm.id == method.id;
          }
        });
        _showToast('Default payment method updated');
        break;
      case 'edit':
        _showAddPaymentModal(context, method);
        break;
      case 'delete':
        _showDeletePaymentConfirmation(method);
        break;
    }
  }

  void _showAddPaymentModal(BuildContext context, [PaymentMethod? method]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddPaymentModal(
        paymentMethod: method,
        onAddPayment: (newMethod) {
          setState(() {
            if (method != null) {
              final index = paymentMethods.indexWhere(
                (pm) => pm.id == method.id,
              );
              if (index != -1) {
                paymentMethods[index] = newMethod;
              }
            } else {
              paymentMethods.add(newMethod);
            }
          });
        },
      ),
    );
  }

  void _showDeletePaymentConfirmation(PaymentMethod method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment Method'),
        content: const Text(
          'Are you sure you want to delete this payment method?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                paymentMethods.removeWhere((pm) => pm.id == method.id);
              });
              Navigator.pop(context);
              _showToast('Payment method deleted');
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class PaymentMethod {
  final String id;
  String type;
  String cardNumber;
  String cardType;
  String expiryDate;
  bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.cardNumber,
    required this.cardType,
    required this.expiryDate,
    required this.isDefault,
  });
}

class AddPaymentModal extends StatefulWidget {
  final PaymentMethod? paymentMethod;
  final Function(PaymentMethod) onAddPayment;

  const AddPaymentModal({
    super.key,
    this.paymentMethod,
    required this.onAddPayment,
  });

  @override
  State<AddPaymentModal> createState() => _AddPaymentModalState();
}

class _AddPaymentModalState extends State<AddPaymentModal> {
  final _cardNumberController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    if (widget.paymentMethod != null) {
      _cardNumberController.text = widget.paymentMethod!.cardNumber;
      _expiryController.text = widget.paymentMethod!.expiryDate;
      _isDefault = widget.paymentMethod!.isDefault;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.paymentMethod == null
                ? 'Add Payment Method'
                : 'Edit Payment Method',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card Number
                  _buildTextField(
                    'Card Number',
                    _cardNumberController,
                    '1234 5678 9012 3456',
                  ),
                  const SizedBox(height: 16),

                  // Card Name
                  _buildTextField(
                    'Name on Card',
                    _cardNameController,
                    'John Doe',
                  ),
                  const SizedBox(height: 16),

                  // Expiry and CVV
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          'Expiry Date',
                          _expiryController,
                          'MM/YY',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField('CVV', _cvvController, '123'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Set as Default
                  Row(
                    children: [
                      Checkbox(
                        value: _isDefault,
                        onChanged: (value) {
                          setState(() {
                            _isDefault = value ?? false;
                          });
                        },
                        activeColor: const Color(0xFF10B981),
                      ),
                      const Text(
                        'Set as default payment method',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _savePaymentMethod,
              child: Text(
                widget.paymentMethod == null ? 'Add Card' : 'Update Card',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF10B981)),
            ),
          ),
        ),
      ],
    );
  }

  void _savePaymentMethod() {
    if (_cardNumberController.text.isEmpty ||
        _cardNameController.text.isEmpty ||
        _expiryController.text.isEmpty ||
        _cvvController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final paymentMethod = PaymentMethod(
      id:
          widget.paymentMethod?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'card',
      cardNumber:
          '**** **** **** ${_cardNumberController.text.substring(_cardNumberController.text.length - 4)}',
      cardType: _getCardType(_cardNumberController.text),
      expiryDate: _expiryController.text,
      isDefault: _isDefault,
    );

    widget.onAddPayment(paymentMethod);
    Navigator.pop(context);
  }

  String _getCardType(String cardNumber) {
    if (cardNumber.startsWith('4')) return 'Visa';
    if (cardNumber.startsWith('5')) return 'Mastercard';
    return 'Card';
  }
}

/// =====================
/// Order History Screen
/// =====================
class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<Order> orders = [
    Order(
      id: '#ORD-001',
      restaurantName: 'KFC Ikeja',
      items: ['Zinger Burger', 'Chicken Wings', 'Coca Cola'],
      totalAmount: 4500,
      status: 'Delivered',
      orderDate: DateTime.now().subtract(const Duration(days: 2)),
      deliveryTime: '25 mins',
    ),
    Order(
      id: '#ORD-002',
      restaurantName: 'Dominos Pizza',
      items: ['Pepperoni Pizza (Large)', 'Chicken Wings'],
      totalAmount: 7800,
      status: 'Cancelled',
      orderDate: DateTime.now().subtract(const Duration(days: 5)),
      deliveryTime: '40 mins',
    ),
    Order(
      id: '#ORD-003',
      restaurantName: 'Mr Biggs',
      items: ['Meat Pie', 'Chicken & Chips', 'Malt Drink'],
      totalAmount: 3200,
      status: 'Delivered',
      orderDate: DateTime.now().subtract(const Duration(days: 7)),
      deliveryTime: '30 mins',
    ),
  ];

  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final filteredOrders = selectedFilter == 'All'
        ? orders
        : orders.where((order) => order.status == selectedFilter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Order History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['All', 'Delivered', 'Cancelled'].map((filter) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedFilter = filter;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: selectedFilter == filter
                          ? const Color(0xFF10B981)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: selectedFilter == filter
                            ? const Color(0xFF10B981)
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: selectedFilter == filter
                            ? Colors.white
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Orders List
          Expanded(
            child: filteredOrders.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Color(0xFF9CA3AF),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No orders found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Order Header
                            Row(
                              children: [
                                Text(
                                  order.id,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                      order.status,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    order.status,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: _getStatusColor(order.status),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Restaurant Name
                            Text(
                              order.restaurantName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF4B5563),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Order Items
                            Text(
                              order.items.join(', '),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 12),

                            // Order Footer
                            Row(
                              children: [
                                Text(
                                  _formatDate(order.orderDate),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '₦${order.totalAmount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Color(0xFFE5E7EB),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () => _showOrderDetails(order),
                                    child: const Text(
                                      'View Details',
                                      style: TextStyle(
                                        color: Color(0xFF6B7280),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF10B981),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () => _reorderItems(order),
                                    child: const Text(
                                      'Reorder',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return const Color(0xFF10B981);
      case 'cancelled':
        return const Color(0xFFEF4444);
      case 'pending':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';

    return '${date.day}/${date.month}/${date.year}';
  }

  void _showOrderDetails(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderDetailsModal(order: order),
    );
  }

  void _reorderItems(Order order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reordering items from ${order.restaurantName}...'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }
}

/// =====================
/// Order Class
/// =====================
class Order {
  final String id;
  final String restaurantName;
  final List<String> items;
  final double totalAmount;
  final String status;
  final DateTime orderDate;
  final String deliveryTime;

  Order({
    required this.id,
    required this.restaurantName,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    required this.deliveryTime,
  });
}

/// =====================
/// Order Details Modal
/// =====================
class OrderDetailsModal extends StatelessWidget {
  final Order order;

  const OrderDetailsModal({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Text(
                        'Order Details',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          order.status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _getStatusColor(order.status),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Order ID and Date
                  _buildDetailRow('Order ID', order.id),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    'Order Date',
                    _formatDateTime(order.orderDate),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Restaurant', order.restaurantName),
                  const SizedBox(height: 12),
                  _buildDetailRow('Delivery Time', order.deliveryTime),

                  const SizedBox(height: 24),

                  // Order Items
                  const Text(
                    'Order Items',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: order.items
                          .map(
                            (item) => Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF10B981),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Payment Summary
                  const Text(
                    'Payment Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildPaymentRow(
                          'Subtotal',
                          '₦${(order.totalAmount * 0.9).toStringAsFixed(0)}',
                        ),
                        const SizedBox(height: 8),
                        _buildPaymentRow(
                          'Delivery Fee',
                          '₦${(order.totalAmount * 0.08).toStringAsFixed(0)}',
                        ),
                        const SizedBox(height: 8),
                        _buildPaymentRow(
                          'Service Fee',
                          '₦${(order.totalAmount * 0.02).toStringAsFixed(0)}',
                        ),
                        const Divider(height: 16),
                        _buildPaymentRow(
                          'Total',
                          '₦${order.totalAmount.toStringAsFixed(0)}',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  if (order.status.toLowerCase() == 'delivered') ...[
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Reordering items from ${order.restaurantName}...',
                              ),
                              backgroundColor: const Color(0xFF10B981),
                            ),
                          );
                        },
                        child: const Text(
                          'Reorder',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Opening rating screen...'),
                            ),
                          );
                        },
                        child: const Text(
                          'Rate Order',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ] else if (order.status.toLowerCase() == 'cancelled') ...[
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Reordering items from ${order.restaurantName}...',
                              ),
                              backgroundColor: const Color(0xFF10B981),
                            ),
                          );
                        },
                        child: const Text(
                          'Order Again',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        const Spacer(),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return const Color(0xFF10B981);
      case 'cancelled':
        return const Color(0xFFEF4444);
      case 'pending':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _formatDateTime(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
