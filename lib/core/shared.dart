import 'package:flutter/material.dart';

PreferredSizeWidget buildAppBar() {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    leading: Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.apps, color: Colors.white),
    ),
    title: Text(
      'Bezoni',
      style: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    ),
  );
}

// Add these model classes
class Restaurant {
  final String id, name, cuisine, location, imageUrl, status;
  final double rating, monthlyRevenue;
  final int reviews;
  
  Restaurant({
    required this.id, required this.name, required this.cuisine,
    required this.location, required this.imageUrl, required this.status,
    required this.rating, required this.monthlyRevenue, required this.reviews,
  });
}

class Order {
  final String id, restaurantId, customerId, status;
  final double amount;
  final DateTime timestamp;
  
  Order({
    required this.id, required this.restaurantId, required this.customerId,
    required this.status, required this.amount, required this.timestamp,
  });
}

class DeliveryPartner {
  final String id, name, status;
  final double rating;
  final int completedDeliveries;
  
  DeliveryPartner({
    required this.id, required this.name, required this.status,
    required this.rating, required this.completedDeliveries,
  });
}

// PreferredSizeWidget buildAppBar() {
//   return AppBar(
//     backgroundColor: Colors.white,
//     elevation: 0,
//     leading: Container(
//       margin: EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: Colors.black,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Icon(Icons.apps, color: Colors.white),
//     ),
//     title: Text(
//       'Bezoni',
//       style: TextStyle(
//         color: Colors.black,
//         fontWeight: FontWeight.bold,
//         fontSize: 18,
//       ),
//     ),
//   );
// }
