import 'package:bezoni/widgets/screen_wrapper.dart';
import 'package:bezoni/themes/theme_extensions.dart';
import 'package:flutter/material.dart';

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

/// =====================
/// Enhanced Search Screen
/// =====================
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _showResults = false;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    _fadeController.forward();
    _slideController.forward();

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (query != _currentQuery) {
      _currentQuery = query;
      setState(() {
        _showResults = query.isNotEmpty;
      });
      SearchManager().search(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        surfaceTintColor: context.surfaceColor,
        elevation: 0,
        title: Text(
          "Search",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: context.textColor,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Search Bar
              Container(
                color: context.surfaceColor,
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: context.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _focusNode.hasFocus
                          ? const Color(0xFF10B981)
                          : context.dividerColor,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: "Search",
                      hintStyle: TextStyle(
                        color: context.subtitleColor,
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(Icons.search, color: context.subtitleColor),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (query) {
                      if (query.isNotEmpty) {
                        SearchManager().addRecentSearch(query);
                      }
                    },
                  ),
                ),
              ),

              // Content
              Expanded(
                child: ListenableBuilder(
                  listenable: SearchManager(),
                  builder: (context, _) {
                    if (_showResults) {
                      return _buildSearchResults();
                    } else {
                      return _buildSearchSuggestions();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    final searchManager = SearchManager();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          if (searchManager.recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.textColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    searchManager.clearRecentSearches();
                  },
                  child: Text(
                    "Clear All",
                    style: TextStyle(color: context.subtitleColor, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...searchManager.recentSearches.asMap().entries.map((entry) {
              final index = entry.key;
              final search = entry.value;
              return _AnimatedSearchTile(
                text: search,
                icon: Icons.history,
                delay: Duration(milliseconds: index * 100),
                onTap: () => _selectSearch(search),
                onRemove: () => searchManager.removeRecentSearch(search),
                showRemove: true,
              );
            }),
            const SizedBox(height: 24),
          ],

          // Explore Brands
          Text(
            "Explore Brands",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: context.textColor,
            ),
          ),
          const SizedBox(height: 16),

          // Featured Restaurant Card
          _RestaurantCard(
            restaurant: searchManager.restaurants.first,
            delay: const Duration(milliseconds: 200),
          ),

          const SizedBox(height: 24),

          // Popular Searches
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Popular",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.textColor,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  "View All",
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...searchManager.popularSearches.asMap().entries.map((entry) {
            final index = entry.key;
            final search = entry.value;
            return _AnimatedSearchTile(
              text: search,
              icon: Icons.trending_up,
              delay: Duration(milliseconds: (index + 3) * 100),
              onTap: () => _selectSearch(search),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final searchManager = SearchManager();

    if (searchManager.isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
            ),
            const SizedBox(height: 16),
            Text(
              "Searching...",
              style: TextStyle(color: context.subtitleColor, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (searchManager.currentResults.isEmpty) {
      return _buildNoResults();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Result for "$_currentQuery"',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.textColor,
                ),
              ),
              Text(
                "(${searchManager.currentResults.length}) Set",
                style: TextStyle(color: context.subtitleColor, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Results
          ...searchManager.currentResults.asMap().entries.map((entry) {
            final index = entry.key;
            final result = entry.value;

            if (result.type == 'restaurant') {
              final restaurant = searchManager.restaurants.firstWhere(
                (r) => r.id == result.id,
              );
              return _RestaurantCard(
                restaurant: restaurant,
                delay: Duration(milliseconds: index * 100),
              );
            }

            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: context.backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(color: context.dividerColor, width: 2),
            ),
            child: Icon(
              Icons.search_off,
              size: 48,
              color: context.subtitleColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Result for "$_currentQuery"',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: context.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Check the Spelling or try\nusing another keyword",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.subtitleColor,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _selectSearch(String search) {
    _searchController.text = search;
    _focusNode.unfocus();
    SearchManager().addRecentSearch(search);
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