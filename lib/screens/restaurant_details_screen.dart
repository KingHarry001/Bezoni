import 'package:bezoni/themes/theme_extensions.dart';
import 'package:flutter/material.dart';
// Add this to your restaurant_details_screen.dart file

import 'package:flutter/material.dart';
import 'package:bezoni/themes/theme_extensions.dart';

class RestaurantDetailsScreen extends StatelessWidget {
  final Restaurant? restaurant;

  const RestaurantDetailsScreen({
    super.key,
    this.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    // If no restaurant is passed, show a placeholder or fetch from arguments
    final Restaurant displayRestaurant = restaurant ?? 
      (ModalRoute.of(context)?.settings.arguments as Restaurant?) ??
      Restaurant(
        id: 'demo',
        name: 'Demo Restaurant',
        description: 'A sample restaurant',
        imageUrl: '',
        rating: 4.5,
        deliveryTime: 30,
        tags: ['Food'],
        isBestSeller: false,
      );

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
          displayRestaurant.name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: context.textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border, color: context.textColor),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to favorites')),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.share, color: context.textColor),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share restaurant')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Header Image
            Container(
              height: 250,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
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

            // Restaurant Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Rating
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayRestaurant.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: context.textColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Color(0xFF10B981),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              displayRestaurant.rating.toString(),
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    displayRestaurant.description,
                    style: TextStyle(
                      color: context.subtitleColor,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: displayRestaurant.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: context.subtitleColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: context.subtitleColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Delivery Info
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 20,
                        color: context.subtitleColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${displayRestaurant.deliveryTime} min delivery',
                        style: TextStyle(
                          color: context.subtitleColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Menu Section (Placeholder)
                  Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: context.textColor,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sample menu items
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: ThemeUtils.createShadow(
                            context,
                            elevation: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.1),
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
                                    'Menu Item ${index + 1}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: context.textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Delicious food item',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: context.subtitleColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '₦${(2000 + index * 500).toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: context.textColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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

// Search Data Models
class Restaurant {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double rating;
  final int deliveryTime;
  final List<String> tags;
  final bool isBestSeller;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.deliveryTime,
    required this.tags,
    this.isBestSeller = false,
  });
}

class SearchResult {
  final String id;
  final String title;
  final String subtitle;
  final String type;
  final String? imageUrl;

  SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    this.imageUrl,
  });
}

// Search Manager
class SearchManager extends ChangeNotifier {
  static final SearchManager _instance = SearchManager._internal();
  factory SearchManager() => _instance;
  SearchManager._internal() {
    _initializeData();
  }

  List<String> _recentSearches = [];
  List<String> _popularSearches = [];
  List<Restaurant> _restaurants = [];
  List<SearchResult> _currentResults = [];
  bool _isSearching = false;

  List<String> get recentSearches => _recentSearches;
  List<String> get popularSearches => _popularSearches;
  List<Restaurant> get restaurants => _restaurants;
  List<SearchResult> get currentResults => _currentResults;
  bool get isSearching => _isSearching;

  void _initializeData() {
    _recentSearches = ['Smokey Jollof', 'Chicken Leg', 'Sunset Plaza Hotel'];

    _popularSearches = [
      'Chicken Republic',
      'Dominos Pizza',
      'KFC',
      'Mr. Biggs',
      'Tantalizers',
      'Sweet Sensation',
    ];

    _restaurants = [
      Restaurant(
        id: '1',
        name: 'Smokey Jollof',
        description: 'Delicious & healthy meals to start the day',
        imageUrl: 'https://example.com/smokey-jollof.jpg',
        rating: 4.5,
        deliveryTime: 25,
        tags: ['Nigerian', 'Rice', 'Jollof'],
        isBestSeller: true,
      ),
      Restaurant(
        id: '2',
        name: 'Chicken Republic',
        description: 'Delicious & healthy meals to start the day',
        imageUrl: 'https://example.com/chicken-republic.jpg',
        rating: 4.2,
        deliveryTime: 20,
        tags: ['Fast Food', 'Chicken', 'Burgers'],
      ),
    ];
  }

  void addRecentSearch(String query) {
    if (query.trim().isEmpty) return;

    _recentSearches.remove(query);
    _recentSearches.insert(0, query);

    if (_recentSearches.length > 5) {
      _recentSearches = _recentSearches.take(5).toList();
    }

    notifyListeners();
  }

  void removeRecentSearch(String query) {
    _recentSearches.remove(query);
    notifyListeners();
  }

  void clearRecentSearches() {
    _recentSearches.clear();
    notifyListeners();
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _currentResults.clear();
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    _currentResults.clear();

    final lowerQuery = query.toLowerCase();

    // Search restaurants
    for (final restaurant in _restaurants) {
      if (restaurant.name.toLowerCase().contains(lowerQuery) ||
          restaurant.description.toLowerCase().contains(lowerQuery) ||
          restaurant.tags.any(
            (tag) => tag.toLowerCase().contains(lowerQuery),
          )) {
        _currentResults.add(
          SearchResult(
            id: restaurant.id,
            title: restaurant.name,
            subtitle: restaurant.description,
            type: 'restaurant',
            imageUrl: restaurant.imageUrl,
          ),
        );
      }
    }

    _isSearching = false;
    notifyListeners();
  }
}


class _AnimatedSearchTile extends StatefulWidget {
  const _AnimatedSearchTile({
    required this.text,
    required this.icon,
    required this.delay,
    required this.onTap,
    this.onRemove,
    this.showRemove = false,
  });

  final String text;
  final IconData icon;
  final Duration delay;
  final VoidCallback onTap;
  final VoidCallback? onRemove;
  final bool showRemove;

  @override
  State<_AnimatedSearchTile> createState() => _AnimatedSearchTileState();
}

class _AnimatedSearchTileState extends State<_AnimatedSearchTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: context.shadowColor,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.icon,
                        size: 20,
                        color: context.subtitleColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.text,
                          style: TextStyle(
                            fontSize: 15,
                            color: context.textColor,
                          ),
                        ),
                      ),
                      if (widget.showRemove && widget.onRemove != null)
                        GestureDetector(
                          onTap: widget.onRemove,
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: context.subtitleColor,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RestaurantCard extends StatefulWidget {
  const _RestaurantCard({required this.restaurant, required this.delay});

  final Restaurant restaurant;
  final Duration delay;

  @override
  State<_RestaurantCard> createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<_RestaurantCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: context.shadowColor,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () {
                  // Navigate to restaurant
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Opening ${widget.restaurant.name}"),
                      backgroundColor: const Color(0xFF10B981),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Restaurant Image
                    Stack(
                      children: [
                        Container(
                          height: 140,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.restaurant,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (widget.restaurant.isBestSeller)
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "Best Seller",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Restaurant Info
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.restaurant.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: context.textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.restaurant.description,
                            style: TextStyle(
                              color: context.subtitleColor,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 12,
                                      color: Color(0xFF10B981),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.restaurant.rating.toString(),
                                      style: const TextStyle(
                                        color: Color(0xFF10B981),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: context.subtitleColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 12,
                                      color: context.subtitleColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${widget.restaurant.deliveryTime} min",
                                      style: TextStyle(
                                        color: context.subtitleColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
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
            ),
          ),
        );
      },
    );
  }
}