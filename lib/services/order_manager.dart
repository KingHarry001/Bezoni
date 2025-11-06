import 'package:flutter/material.dart';

// Order Model
class Order {
  final String id;
  final String customerName;
  final String deliveryAddress;
  final double totalAmount;
  final OrderStatus status;
  final DateTime orderTime;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.customerName,
    required this.deliveryAddress,
    required this.totalAmount,
    required this.status,
    required this.orderTime,
    required this.items,
  });
}

class OrderItem {
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
  });
}

enum OrderStatus {
  pending,
  preparing,
  ready,
  delivering,
  completed,
  cancelled,
}

// Order Manager
class OrderManager extends ChangeNotifier {
  List<Order> _orders = [];
  List<Order> get orders => _orders;

  List<Order> get pendingOrders =>
      _orders.where((order) => order.status == OrderStatus.pending).toList();

  List<Order> get activeOrders => _orders
      .where((order) =>
          order.status == OrderStatus.preparing ||
          order.status == OrderStatus.ready ||
          order.status == OrderStatus.delivering)
      .toList();

  List<Order> get completedOrders =>
      _orders.where((order) => order.status == OrderStatus.completed).toList();

  void addOrder(Order order) {
    _orders.add(order);
    notifyListeners();
  }

  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      // In a real app, you'd create a new Order instance with updated status
      // For now, we'll just trigger a rebuild
      notifyListeners();
    }
  }

  void removeOrder(String orderId) {
    _orders.removeWhere((order) => order.id == orderId);
    notifyListeners();
  }
}

