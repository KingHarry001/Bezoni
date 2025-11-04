import 'package:flutter/material.dart';
import 'package:bezoni/core/shared.dart';
import 'package:bezoni/screens/roles/admin_dashboard.dart';

// Dashboard Screen (Basic placeholder)
class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive padding (smaller padding on small screens)
    final horizontalPadding = screenWidth * 0.06; // 6% of screen width
    final verticalSpacing = screenHeight * 0.02; // 2% of screen height

    // Responsive font sizes
    final titleSize = screenWidth * 0.07; // 7% of screen width
    final subtitleSize = screenWidth * 0.04;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: verticalSpacing),
            Text(
              'Welcome to your Bezoni dashboard!',
              style: TextStyle(fontSize: subtitleSize, color: Colors.grey[600]),
            ),
            SizedBox(height: verticalSpacing * 2),

            // Dashboard cards
            _buildDashboardCard(
              title: 'Orders',
              value: '24',
              subtitle: 'Total orders today',
              icon: Icons.shopping_bag,
              screenWidth: screenWidth,
            ),
            SizedBox(height: verticalSpacing),
            _buildDashboardCard(
              title: 'Revenue',
              value: '\$1,240',
              subtitle: 'Total earnings today',
              icon: Icons.attach_money,
              screenWidth: screenWidth,
            ),
            SizedBox(height: verticalSpacing),
            _buildDashboardCard(
              title: 'Deliveries',
              value: '18',
              subtitle: 'Completed deliveries',
              icon: Icons.local_shipping,
              screenWidth: screenWidth,
            ),

            SizedBox(height: verticalSpacing * 2),

            // Logout button
            SizedBox(
              width: double.infinity,
              height: screenHeight * 0.07, // 7% of screen height
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminDashboard()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth * 0.045, // 4.5% of screen width
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required double screenWidth,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(screenWidth * 0.03),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: screenWidth * 0.06),
          ),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
