// File: lib/screens/profile/screens/order_history_screen.dart
import 'package:bezoni/widgets/profile_modals.dart';
import 'package:flutter/material.dart';
import '../../../themes/theme_extensions.dart';
import '../../../models/order.dart';

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
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Order History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: context.textColor,
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
                          ? context.primaryColor
                          : context.surfaceColor,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: selectedFilter == filter
                            ? context.primaryColor
                            : context.dividerColor,
                      ),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: selectedFilter == filter
                            ? Colors.white
                            : context.subtitleColor,
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
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: context.subtitleColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No orders found',
                          style: TextStyle(
                            fontSize: 18,
                            color: context.subtitleColor,
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
                          color: context.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: ThemeUtils.createShadow(context, elevation: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Order Header
                            Row(
                              children: [
                                Text(
                                  order.id,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: context.textColor,
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
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: context.subtitleColor,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Order Items
                            Text(
                              order.items.join(', '),
                              style: TextStyle(
                                fontSize: 12,
                                color: context.subtitleColor,
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
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: context.subtitleColor,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '₦${order.totalAmount.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: context.textColor,
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
                                      side: BorderSide(
                                        color: context.dividerColor,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () => _showOrderDetails(order),
                                    child: Text(
                                      'View Details',
                                      style: TextStyle(
                                        color: context.subtitleColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: context.primaryColor,
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
        return context.successColor;
      case 'cancelled':
        return context.errorColor;
      case 'pending':
        return const Color(0xFFF59E0B);
      default:
        return context.subtitleColor;
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
        backgroundColor: context.primaryColor,
      ),
    );
  }
}