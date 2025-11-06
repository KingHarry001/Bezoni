// File: lib/screens/profile/screens/payment_methods_screen.dart
import 'package:flutter/material.dart';
import '../../../themes/theme_extensions.dart';
import '../../../models/payment_method.dart';
import '../widgets/profile_modals.dart';

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
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Payment Methods',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: context.textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: context.primaryColor),
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
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: ThemeUtils.createShadow(context, elevation: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saved Cards',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.textColor,
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
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: ThemeUtils.createShadow(context, elevation: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Other Payment Methods',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.textColor,
                  ),
                ),
                const SizedBox(height: 16),
                _buildPaymentOption(
                  icon: Icons.account_balance,
                  title: 'Bank Transfer',
                  subtitle: 'Pay directly from your bank account',
                  onTap: () => _showToast('Bank Transfer selected'),
                ),
                Divider(height: 24, color: context.dividerColor),
                _buildPaymentOption(
                  icon: Icons.account_balance_wallet,
                  title: 'Mobile Wallet',
                  subtitle: 'Use your mobile wallet for payments',
                  onTap: () => _showToast('Mobile Wallet selected'),
                ),
                Divider(height: 24, color: context.dividerColor),
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
        backgroundColor: context.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPaymentCard(PaymentMethod method) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(8),
        border: method.isDefault
            ? Border.all(color: context.primaryColor, width: 2)
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              method.cardType == 'Visa' ? Icons.credit_card : Icons.payment,
              color: context.primaryColor,
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
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: context.textColor,
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
                          color: context.primaryColor,
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
                  style: TextStyle(
                    fontSize: 12,
                    color: context.subtitleColor,
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
            icon: Icon(Icons.more_vert, color: context.subtitleColor),
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
          Icon(icon, color: context.subtitleColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: context.textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.subtitleColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: context.subtitleColor,
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
        backgroundColor: context.surfaceColor,
        title: Text('Delete Payment Method', style: TextStyle(color: context.textColor)),
        content: Text(
          'Are you sure you want to delete this payment method?',
          style: TextStyle(color: context.subtitleColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: context.subtitleColor)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                paymentMethods.removeWhere((pm) => pm.id == method.id);
              });
              Navigator.pop(context);
              _showToast('Payment method deleted');
            },
            child: Text('Delete', style: TextStyle(color: context.errorColor)),
          ),
        ],
      ),
    );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.primaryColor,
      ),
    );
  }
}