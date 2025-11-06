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