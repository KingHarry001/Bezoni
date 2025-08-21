import 'package:flutter/material.dart';

/// =====================
/// Profile Screen
/// =====================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFF10B981),
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Dave Johnson",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const Text(
                      "dave@example.com",
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatCard(title: "Orders", value: "12"),
                        _StatCard(title: "Saved", value: "₦2,340"),
                        _StatCard(title: "Points", value: "450"),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Menu Items
              _ProfileSection(
                title: "Account",
                items: [
                  _ProfileItem(
                    icon: Icons.person_outline,
                    title: "Personal Information",
                    onTap: () => _showToast(context, "Personal Information"),
                  ),
                  _ProfileItem(
                    icon: Icons.location_on_outlined,
                    title: "Addresses",
                    onTap: () => _showToast(context, "Addresses"),
                  ),
                  _ProfileItem(
                    icon: Icons.payment,
                    title: "Payment Methods",
                    onTap: () => _showToast(context, "Payment Methods"),
                  ),
                ],
              ),
              
              _ProfileSection(
                title: "Orders",
                items: [
                  _ProfileItem(
                    icon: Icons.history,
                    title: "Order History",
                    onTap: () => _showToast(context, "Order History"),
                  ),
                  _ProfileItem(
                    icon: Icons.favorite_outline,
                    title: "Favorites",
                    onTap: () => _showToast(context, "Favorites"),
                  ),
                ],
              ),
              
              _ProfileSection(
                title: "Support",
                items: [
                  _ProfileItem(
                    icon: Icons.help_outline,
                    title: "Help Center",
                    onTap: () => _showToast(context, "Help Center"),
                  ),
                  _ProfileItem(
                    icon: Icons.chat_bubble_outline,
                    title: "Contact Support",
                    onTap: () => Navigator.pushNamed(context, '/messages'),
                  ),
                  _ProfileItem(
                    icon: Icons.star_outline,
                    title: "Rate App",
                    onTap: () => _showToast(context, "Rate App"),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _showLogoutDialog(context),
                    child: const Text(
                      "Logout",
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$message tapped")),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
            child: const Text(
              "Logout",
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF10B981),
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.title,
    required this.items,
  });

  final String title;
  final List<_ProfileItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          ...items.map((item) => ListTile(
                leading: Icon(item.icon, color: const Color(0xFF6B7280)),
                title: Text(item.title),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF6B7280),
                ),
                onTap: item.onTap,
              )),
        ],
      ),
    );
  }
}

class _ProfileItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _ProfileItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}
