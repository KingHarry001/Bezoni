import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = const [
      ("Burgers", Icons.lunch_dining, Color(0xFFEF4444)),
      ("Pizza", Icons.local_pizza, Color(0xFFEA580C)),
      ("Drinks", Icons.local_drink, Color(0xFF0EA5E9)),
      ("Rice", Icons.rice_bowl, Color(0xFF10B981)),
      ("Chicken", Icons.set_meal, Color(0xFFF59E0B)),
      ("Snacks", Icons.cookie_outlined, Color(0xFF8B5CF6)),
      ("Seafood", Icons.set_meal, Color(0xFF06B6D4)),
      ("Desserts", Icons.cake, Color(0xFFEC4899)),
      ("Vegetables", Icons.eco, Color(0xFF22C55E)),
      ("Bread", Icons.bakery_dining, Color(0xFFA3A3A3)),
      ("Soup", Icons.soup_kitchen, Color(0xFFDC2626)),
      ("Pasta", Icons.ramen_dining, Color(0xFFFBBF24)),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Categories"),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemBuilder: (_, i) {
          final (label, icon, color) = categories[i];
          return GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("$label category selected")),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: [color.withOpacity(.10), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 36, color: color),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
