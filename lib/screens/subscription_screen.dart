
import 'package:bezoni/models/subscription_plan.dart';
import 'package:bezoni/widgets/profile_modals.dart';
import 'package:flutter/material.dart';
import '../../../themes/theme_extensions.dart';

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
    selectedPlan = 'lite';
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
        decoration: BoxDecoration(
          color: context.colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.arrow_back, color: context.textColor),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Delivery Subscription',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: context.textColor,
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
        backgroundColor: context.surfaceColor,
        title: Text('Cancel Subscription', style: TextStyle(color: context.textColor)),
        content: Text(
          'Are you sure you want to cancel your current subscription?',
          style: TextStyle(color: context.subtitleColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Keep', style: TextStyle(color: context.subtitleColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showToast(context, 'Subscription cancelled');
            },
            child: Text(
              'Cancel Subscription',
              style: TextStyle(color: context.errorColor),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.primaryColor,
      ),
    );
  }
}
