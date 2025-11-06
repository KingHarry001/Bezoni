
// File: lib/screens/profile/models/subscription_plan.dart
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