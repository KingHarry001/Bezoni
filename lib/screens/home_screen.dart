import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bezoni/components/cart_notifier.dart'; 
import 'package:bezoni/screens/preferences.dart';
import 'package:bezoni/screens/search_screen.dart';
import 'package:bezoni/screens/cart.dart';
import 'package:bezoni/screens/messages.dart';
import 'package:bezoni/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _tab = 0;
  bool _welcomeShownForThisArrival = false;
  UserPreferences? _prefs;
  final _cartNotifier = CartNotifier();

  late final AnimationController _fadeCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..forward();
  late final Animation<double> _fade = CurvedAnimation(
    parent: _fadeCtrl,
    curve: Curves.easeInOut,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is UserPreferences) {
      _prefs = args;
      if (!_welcomeShownForThisArrival) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _showWelcome());
        _welcomeShownForThisArrival = true;
      }
    }
  }

  void _showWelcome() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.celebration,
                  color: Color(0xFF10B981),
                  size: 40,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "Welcome to Bezoni!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "We're excited to have you on board! From hot meals to urgent parcels, we deliver what you need—fast and hassle-free. If you need help, support is a tap away in your profile.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Let's Go!",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _HomeContent(
        address: _prefs?.address ?? "Herbert Macaulay Way, Yaba...",
        preferredFoodType: _prefs?.foodType,
        onSeeAllCategories: () => Navigator.pushNamed(context, '/categories'),
        onSearch: () => Navigator.pushNamed(context, '/search'),
      ),
    ];

    return ListenableBuilder(
      listenable: _cartNotifier,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: SafeArea(
            child: FadeTransition(opacity: _fade, child: pages[_tab]),
          ),);
      },
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.address,
    required this.onSeeAllCategories,
    required this.onSearch,
    this.preferredFoodType,
  });

  final String address;
  final String? preferredFoodType;
  final VoidCallback onSeeAllCategories;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final tailoredSubtitle = preferredFoodType == null
        ? "Delicious & healthy meals to start the day"
        : "Top picks in $preferredFoodType near you";

    return Column(
      children: [
        // Header + search
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, color: Color(0xFF6B7280)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1A1A1A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Color(0xFF6B7280),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("No new notifications")),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: onSearch,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: Color(0xFF6B7280)),
                      SizedBox(width: 12),
                      Text(
                        "Search for food, restaurants...",
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Body scroll
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _PromoBanner(),
                const SizedBox(height: 8),

                // Categories title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Categories",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      TextButton(
                        onPressed: onSeeAllCategories,
                        child: const Text("See all"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Categories grid
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _CategoriesGrid(),
                ),

                const SizedBox(height: 18),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Featured Restaurants",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Featured cards (tailored subtitle)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _RestaurantCard(
                        title: "Chicken Republic",
                        subtitle: tailoredSubtitle,
                        meta: "4.3K People Ordered",
                        rating: "4.5",
                        color: Colors.orange,
                        tag: "Breakfast 10am • 10:30am",
                        onTap: () => Navigator.pushNamed(context, '/restaurant'),
                      ),
                      const SizedBox(height: 14),
                      _RestaurantCard(
                        title: "Platter Kitchen",
                        subtitle: preferredFoodType == null
                            ? "Local dishes with authentic flavors"
                            : "Great for $preferredFoodType lovers",
                        meta: "2.1K People Ordered",
                        rating: "4.2",
                        color: Colors.red,
                        tag: "Lunch 12pm • 01:30pm",
                        onTap: () => Navigator.pushNamed(context, '/restaurant'),
                      ),
                      const SizedBox(height: 14),
                      _RestaurantCard(
                        title: "Sweet Sensation",
                        subtitle: "Fresh pastries and desserts daily",
                        meta: "1.8K People Ordered",
                        rating: "4.7",
                        color: const Color(0xFF8B5CF6),
                        tag: "All Day",
                        onTap: () => Navigator.pushNamed(context, '/restaurant'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Get 20% Off Your First Order!",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Use the code: WELCOME20",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "20%",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoriesGrid extends StatelessWidget {
  const _CategoriesGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 3,
      childAspectRatio: .86,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: const [
        _CategoryTile(
          title: "Food\nDelivery",
          icon: Icons.restaurant,
          color: Color(0xFFEF4444),
        ),
        _CategoryTile(
          title: "Parcel\nDelivery",
          icon: Icons.local_shipping,
          color: Color(0xFF10B981),
        ),
        _CategoryTile(
          title: "Groceries\nDelivery",
          icon: Icons.shopping_bag,
          color: Color(0xFF8B5CF6),
        ),
        _CategoryTile(
          title: "Book\nDelivery",
          icon: Icons.menu_book,
          color: Color(0xFF10B981),
        ),
        _CategoryTile(
          title: "Ride\nHailing",
          icon: Icons.directions_car,
          color: Color(0xFFF59E0B),
        ),
        _CategoryTile(
          title: "Pharmacy\nDrug",
          icon: Icons.local_pharmacy,
          color: Color(0xFF10B981),
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.title,
    required this.icon,
    required this.color,
  });

  final String title;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pushNamed(context, '/categories');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(.10), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.rating,
    required this.color,
    required this.onTap,
    this.tag,
  });

  final String title;
  final String subtitle;
  final String meta;
  final String rating;
  final Color color;
  final VoidCallback onTap;
  final String? tag;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 86,
                height: 86,
                color: color.withOpacity(.18),
                child: Icon(Icons.restaurant, color: color, size: 42),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tag != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFEF4444),
                        ),
                        child: const Icon(
                          Icons.star,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        rating,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "• $meta",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

