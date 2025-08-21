import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Data passed from Preferences -> Home
class UserPreferences {
  final String address;
  final String? foodType;
  final List<String> allergies;

  const UserPreferences({
    required this.address,
    this.foodType,
    required this.allergies,
  });
}

/// Cart Item Model
class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String restaurant;

  const CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.restaurant,
  });
}

/// Global Cart State
class CartNotifier extends ChangeNotifier {
  static final CartNotifier _instance = CartNotifier._internal();
  factory CartNotifier() => _instance;
  CartNotifier._internal();

  final List<CartItem> _items = [];
  List<CartItem> get items => List.unmodifiable(_items);

  double get total => _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

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

/// =====================
/// Preferences / Onboarding
/// =====================
class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  String _selectedFoodType = '';
  final List<String> _selectedAllergies = [];

  final List<String> _foodTypes = const [
    'Local',
    'Fast Food',
    'Vegan',
    'Seafood',
    'Healthy',
    'Desserts',
    'Chinese',
  ];

  final List<String> _allergies = const [
    'Nuts',
    'Dairy',
    'Gluten',
    'Shellfish',
    'Eggs',
    'Soy',
  ];

  late final AnimationController _anim;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeInOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, .08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _anim.forward();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _anim.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final prefs = UserPreferences(
      address: _addressController.text.trim(),
      foodType: _selectedFoodType.isEmpty ? null : _selectedFoodType,
      allergies: List<String>.from(_selectedAllergies),
    );

    HapticFeedback.lightImpact();
    Navigator.pushReplacementNamed(
      context,
      '/home',
      arguments: prefs,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      "Let's personalize your experience",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Set your preferences for faster, better deliveries.",
                      style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                    ),

                    const SizedBox(height: 22),
                    _sectionTitle("Address"),
                    const SizedBox(height: 10),
                    _decoratedField(
                      child: TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          hintText: "Enter your address",
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          suffixIcon: TextButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _addressController.text =
                                    "Herbert Macaulay Way, Yaba, Lagos";
                              });
                            },
                            child: const Text(
                              "Use Current Location",
                              style: TextStyle(color: Color(0xFF10B981)),
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Please enter your address';
                          }
                          if (v.trim().length < 6) {
                            return 'Address looks too short';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 24),
                    _sectionTitle("What type of food do you enjoy?"),
                    const SizedBox(height: 4),
                    const Text(
                      "Select one",
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _foodTypes
                          .map(
                            (t) => _choiceChip(
                              label: t,
                              selected: _selectedFoodType == t,
                              onTap: () => setState(() {
                                HapticFeedback.selectionClick();
                                _selectedFoodType = _selectedFoodType == t
                                    ? ''
                                    : t;
                              }),
                            ),
                          )
                          .toList(),
                    ),

                    const SizedBox(height: 24),
                    _sectionTitle("Any Allergies"),
                    const SizedBox(height: 4),
                    Text(
                      _selectedAllergies.isEmpty
                          ? "None selected"
                          : _selectedAllergies.join(", "),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _allergies
                          .map(
                            (a) => _choiceChip(
                              label: a,
                              selected: _selectedAllergies.contains(a),
                              outlined: true,
                              onTap: () => setState(() {
                                HapticFeedback.selectionClick();
                                if (_selectedAllergies.contains(a)) {
                                  _selectedAllergies.remove(a);
                                } else {
                                  _selectedAllergies.add(a);
                                }
                              }),
                            ),
                          )
                          .toList(),
                    ),

                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _submit,
                        child: const Text(
                          "Continue",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: Color(0xFF1A1A1A),
    ),
  );

  Widget _decoratedField({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _choiceChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    bool outlined = false,
  }) {
    final Color primary = const Color(0xFF10B981);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected && !outlined ? primary : Colors.white,
          border: Border.all(
            color: selected ? primary : const Color(0xFFE5E7EB),
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected && !outlined
                ? Colors.white
                : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }
}

/// =====================
/// Home
/// =====================
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
      const SearchScreen(),
      const CartScreen(),
      const MessagesScreen(),
      const ProfileScreen(),
    ];

    return ListenableBuilder(
      listenable: _cartNotifier,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: SafeArea(
            child: FadeTransition(opacity: _fade, child: pages[_tab]),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (i) => setState(() => _tab = i),
            indicatorColor: const Color(0xFF10B981).withOpacity(.15),
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              const NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
              NavigationDestination(
                icon: Stack(
                  children: [
                    const Icon(Icons.shopping_cart_outlined),
                    if (_cartNotifier.itemCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${_cartNotifier.itemCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                selectedIcon: const Icon(Icons.shopping_cart),
                label: 'Cart',
              ),
              const NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon: Icon(Icons.chat_bubble),
                label: 'Messages',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
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

/// =====================
/// Search Screen
/// =====================
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final List<String> _recentSearches = ['Chicken Republic', 'Pizza', 'Burgers'];
  final List<String> _popularSearches = ['Fried Rice', 'Jollof Rice', 'Suya', 'Shawarma'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "Search for food, restaurants...",
              prefixIcon: Icon(Icons.search, color: Color(0xFF6B7280)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_searchController.text.isEmpty) ...[
              const Text(
                "Recent Searches",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _recentSearches.map((search) => _searchChip(search)).toList(),
              ),
              const SizedBox(height: 24),
              const Text(
                "Popular Searches",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _popularSearches.map((search) => _searchChip(search)).toList(),
              ),
            ] else ...[
              const Text(
                "Search Results",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    _SearchResultTile(
                      title: "Chicken Republic",
                      subtitle: "Fast food • 15 min delivery",
                      icon: Icons.restaurant,
                      color: Colors.orange,
                    ),
                    _SearchResultTile(
                      title: "Grilled Chicken",
                      subtitle: "From KFC • ₦2,500",
                      icon: Icons.food_bank,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _searchChip(String text) {
    return GestureDetector(
      onTap: () {
        _searchController.text = text;
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history, size: 16, color: Color(0xFF6B7280)),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(color: Color(0xFF374151)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        onTap: () => Navigator.pushNamed(context, '/restaurant'),
      ),
    );
  }
}

/// =====================
/// Cart Screen
/// =====================
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CartNotifier(),
      builder: (context, _) {
        final cart = CartNotifier();
        
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            title: Text("Cart (${cart.itemCount} items)"),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            actions: [
              if (cart.items.isNotEmpty)
                TextButton(
                  onPressed: () {
                    cart.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Cart cleared")),
                    );
                  },
                  child: const Text("Clear All"),
                ),
            ],
          ),
          body: cart.items.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 80,
                        color: Color(0xFF6B7280),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Your cart is empty",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Add items to get started",
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cart.items.length,
                        itemBuilder: (context, index) {
                          final item = cart.items[index];
                          return _CartItemTile(
                            item: item,
                            onRemove: () => cart.removeItem(item.id),
                          );
                        },
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total:",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                "₦${cart.total.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                _showCheckoutDialog(context, cart);
                              },
                              child: const Text(
                                "Proceed to Checkout",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  void _showCheckoutDialog(BuildContext context, CartNotifier cart) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Order Confirmation"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Your order has been placed successfully!"),
            const SizedBox(height: 16),
            Text(
              "Total: ₦${cart.total.toStringAsFixed(0)}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              cart.clear();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Order placed successfully!")),
              );
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.item,
    required this.onRemove,
  });

  final CartItem item;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.fastfood,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "From ${item.restaurant}",
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "₦${item.price.toStringAsFixed(0)} x ${item.quantity}",
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                "₦${(item.price * item.quantity).toStringAsFixed(0)}",
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// =====================
/// Messages Screen
/// =====================
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final messages = [
      _Message(
        name: "Bezoni Support",
        message: "Welcome to Bezoni! How can we help you today?",
        time: "2m ago",
        unread: true,
      ),
      _Message(
        name: "Delivery Update",
        message: "Your order from Chicken Republic is on the way!",
        time: "1h ago",
        unread: false,
      ),
      _Message(
        name: "Promo Alert",
        message: "🎉 Get 30% off your next order with code SAVE30",
        time: "3h ago",
        unread: false,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Messages"),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF10B981).withOpacity(0.15),
                child: const Icon(
                  Icons.message,
                  color: Color(0xFF10B981),
                ),
              ),
              title: Text(
                message.name,
                style: TextStyle(
                  fontWeight: message.unread ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              subtitle: Text(
                message.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    message.time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  if (message.unread)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Opening chat with ${message.name}")),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _Message {
  final String name;
  final String message;
  final String time;
  final bool unread;

  _Message({
    required this.name,
    required this.message,
    required this.time,
    required this.unread,
  });
}

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

/// =====================
/// Restaurant Details Screen
/// =====================
class RestaurantDetailsScreen extends StatefulWidget {
  const RestaurantDetailsScreen({super.key});

  @override
  State<RestaurantDetailsScreen> createState() => _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  final _cart = CartNotifier();

  final List<_MenuItem> _menuItems = [
    _MenuItem(
      id: "1",
      name: "Fried Rice & Chicken",
      description: "Delicious fried rice with grilled chicken",
      price: 2500,
      restaurant: "Chicken Republic",
    ),
    _MenuItem(
      id: "2",
      name: "Jollof Rice Special",
      description: "Traditional jollof rice with beef",
      price: 2200,
      restaurant: "Chicken Republic",
    ),
    _MenuItem(
      id: "3",
      name: "Chicken Burger",
      description: "Crispy chicken burger with fries",
      price: 1800,
      restaurant: "Chicken Republic",
    ),
    _MenuItem(
      id: "4",
      name: "Shawarma Deluxe",
      description: "Premium shawarma with extra meat",
      price: 1500,
      restaurant: "Chicken Republic",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.orange,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.withOpacity(0.8), Colors.orange],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.restaurant,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Chicken Republic",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFEF4444),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          "4.5",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.access_time,
                          color: Color(0xFF6B7280),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          "15-20 min",
                          style: TextStyle(color: Color(0xFF6B7280)),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "Free Delivery",
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Menu",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _menuItems.length,
                    itemBuilder: (context, index) {
                      final item = _menuItems[index];
                      return _MenuItemTile(
                        item: item,
                        onAddToCart: () {
                          _cart.addItem(CartItem(
                            id: item.id,
                            name: item.name,
                            price: item.price,
                            quantity: 1,
                            restaurant: item.restaurant,
                          ));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${item.name} added to cart"),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String restaurant;

  _MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.restaurant,
  });
}

class _MenuItemTile extends StatelessWidget {
  const _MenuItemTile({
    required this.item,
    required this.onAddToCart,
  });

  final _MenuItem item;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.fastfood,
              color: Colors.orange,
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "₦${item.price.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: onAddToCart,
            child: const Text(
              "Add",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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