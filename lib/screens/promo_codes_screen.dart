// File: lib/screens/profile/screens/promo_codes_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../themes/theme_extensions.dart';

class PromoCodesScreen extends StatefulWidget {
  const PromoCodesScreen({super.key});

  @override
  State<PromoCodesScreen> createState() => _PromoCodesScreenState();
}

class _PromoCodesScreenState extends State<PromoCodesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _promoCodeController = TextEditingController();

  final List<PromoCode> availablePromos = [
    PromoCode(
      code: 'WELCOME50',
      title: 'Welcome Bonus',
      description: 'Get ₦500 off on your first order',
      discount: 500,
      minOrder: 2000,
      expiryDate: DateTime.now().add(const Duration(days: 30)),
      type: 'fixed',
    ),
    PromoCode(
      code: 'FOOD20',
      title: '20% Off Food',
      description: 'Save 20% on all food orders',
      discount: 20,
      minOrder: 1500,
      expiryDate: DateTime.now().add(const Duration(days: 15)),
      type: 'percentage',
    ),
    PromoCode(
      code: 'FREEDEL',
      title: 'Free Delivery',
      description: 'Free delivery on orders above ₦3000',
      discount: 0,
      minOrder: 3000,
      expiryDate: DateTime.now().add(const Duration(days: 7)),
      type: 'delivery',
    ),
  ];

  final List<PromoCode> usedPromos = [
    PromoCode(
      code: 'SAVE100',
      title: 'Save ₦100',
      description: '₦100 off any order',
      discount: 100,
      minOrder: 1000,
      expiryDate: DateTime.now().subtract(const Duration(days: 5)),
      type: 'fixed',
      isUsed: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _promoCodeController.dispose();
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
          'Promo Codes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: context.textColor,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            color: context.surfaceColor,
            child: TabBar(
              controller: _tabController,
              indicatorColor: context.primaryColor,
              labelColor: context.primaryColor,
              unselectedLabelColor: context.subtitleColor,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'Available'),
                Tab(text: 'Used'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Enter Promo Code Section
          Container(
            padding: const EdgeInsets.all(16),
            color: context.surfaceColor,
            child: Column(
              children: [
                TextField(
                  controller: _promoCodeController,
                  style: TextStyle(color: context.textColor),
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Enter promo code',
                    hintStyle: TextStyle(color: context.subtitleColor),
                    filled: true,
                    fillColor: context.colors.background,
                    prefixIcon: Icon(
                      Icons.local_offer_outlined,
                      color: context.subtitleColor,
                    ),
                    suffixIcon: TextButton(
                      onPressed: _applyPromoCode,
                      child: Text(
                        'Apply',
                        style: TextStyle(
                          color: context.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
                  ),
                ),
              ],
            ),
          ),

          // Tabs Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAvailablePromos(),
                _buildUsedPromos(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailablePromos() {
    if (availablePromos.isEmpty) {
      return _buildEmptyState('No Available Promos');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: availablePromos.length,
      itemBuilder: (context, index) {
        return _buildPromoCard(availablePromos[index]);
      },
    );
  }

  Widget _buildUsedPromos() {
    if (usedPromos.isEmpty) {
      return _buildEmptyState('No Used Promos');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: usedPromos.length,
      itemBuilder: (context, index) {
        return _buildPromoCard(usedPromos[index]);
      },
    );
  }

  Widget _buildPromoCard(PromoCode promo) {
    final isExpired = promo.expiryDate.isBefore(DateTime.now());
    final daysLeft = promo.expiryDate.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: promo.isUsed
            ? Border.all(color: context.dividerColor)
            : Border.all(color: context.primaryColor.withOpacity(0.3), width: 2),
        boxShadow: promo.isUsed
            ? null
            : ThemeUtils.createShadow(context, elevation: 2),
      ),
      child: Stack(
        children: [
          // Decorative Background Pattern
          if (!promo.isUsed)
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.primaryColor.withOpacity(0.05),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: promo.isUsed
                            ? context.subtitleColor.withOpacity(0.1)
                            : context.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getPromoIcon(promo.type),
                        color: promo.isUsed
                            ? context.subtitleColor
                            : context.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title & Code
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            promo.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: promo.isUsed
                                  ? context.subtitleColor
                                  : context.textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: promo.isUsed
                                  ? context.dividerColor
                                  : context.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: promo.isUsed
                                    ? context.dividerColor
                                    : context.primaryColor.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              promo.code,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: promo.isUsed
                                    ? context.subtitleColor
                                    : context.primaryColor,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Copy Button
                    if (!promo.isUsed)
                      IconButton(
                        icon: Icon(
                          Icons.copy,
                          color: context.primaryColor,
                          size: 20,
                        ),
                        onPressed: () => _copyPromoCode(promo.code),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  promo.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.subtitleColor,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 12),

                // Details
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: context.subtitleColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Min. order: ₦${promo.minOrder}',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.subtitleColor,
                      ),
                    ),
                    const Spacer(),
                    if (!promo.isUsed && !isExpired)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: daysLeft <= 3
                              ? context.errorColor.withOpacity(0.1)
                              : context.successColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          daysLeft <= 0
                              ? 'Expires today'
                              : daysLeft <= 3
                                  ? '$daysLeft days left'
                                  : 'Valid for $daysLeft days',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: daysLeft <= 3
                                ? context.errorColor
                                : context.successColor,
                          ),
                        ),
                      ),
                    if (promo.isUsed)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.subtitleColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'USED',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: context.subtitleColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 64,
            color: context.subtitleColor,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: context.subtitleColor,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPromoIcon(String type) {
    switch (type) {
      case 'percentage':
        return Icons.percent;
      case 'delivery':
        return Icons.delivery_dining;
      case 'fixed':
      default:
        return Icons.local_offer;
    }
  }

  void _copyPromoCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Promo code "$code" copied!'),
        backgroundColor: context.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _applyPromoCode() {
    final code = _promoCodeController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    final promo = availablePromos.firstWhere(
      (p) => p.code == code,
      orElse: () => PromoCode(
        code: '',
        title: '',
        description: '',
        discount: 0,
        minOrder: 0,
        expiryDate: DateTime.now(),
        type: '',
      ),
    );

    if (promo.code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invalid promo code'),
          backgroundColor: context.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Promo code "$code" applied successfully!'),
          backgroundColor: context.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      _promoCodeController.clear();
    }
  }
}

// Promo Code Model
class PromoCode {
  final String code;
  final String title;
  final String description;
  final double discount;
  final double minOrder;
  final DateTime expiryDate;
  final String type;
  final bool isUsed;

  PromoCode({
    required this.code,
    required this.title,
    required this.description,
    required this.discount,
    required this.minOrder,
    required this.expiryDate,
    required this.type,
    this.isUsed = false,
  });
}