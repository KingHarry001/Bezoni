import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String restaurant;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.restaurant,
  });
}

class CartNotifier extends ChangeNotifier {
  final List<CartItem> _items = [];
  List<CartItem> get items => List.unmodifiable(_items);

  double get total =>
      _items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  int get itemCount =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  void addItem(CartItem item) {
    final existingIndex = _items.indexWhere((i) => i.id == item.id);
    if (existingIndex >= 0) {
      _items[existingIndex] = CartItem(
        id: item.id,
        name: item.name,
        price: item.price,
        quantity: _items[existingIndex].quantity + 1,
        restaurant: item.restaurant,
      );
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
