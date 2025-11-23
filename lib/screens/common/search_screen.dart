import 'package:bezoni/screens/restaurant/restaurant_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:bezoni/core/api_client.dart';
import 'package:bezoni/core/api_models.dart';
import 'package:bezoni/themes/theme_extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // Search results
  List<Product>? _productResults;
  List<Vendor>? _vendorResults;
  List<Vendor>? _featuredVendors;
  
  bool _isSearching = false;
  bool _isLoadingFeatured = true;
  String _currentQuery = '';
  
  // Search type: 'all', 'products', 'restaurants'
  String _searchType = 'all';

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Recent searches
  List<String> _recentSearches = [];
  final List<String> _popularSearches = [
    'Rice',
    'Chicken',
    'Pizza',
    'Burgers',
    'Jollof Rice',
    'Fried Rice',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
    _searchController.addListener(_onSearchChanged);
    _loadRecentSearches();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _initializeData() async {
    await _apiClient.initialize();
    await _loadFeaturedVendors();
  }

  Future<void> _loadFeaturedVendors() async {
    if (!mounted) return;
    
    setState(() => _isLoadingFeatured = true);

    try {
      final response = await _apiClient.getAvailableVendors();

      if (!mounted) return;

      if (response.isSuccess && response.data != null) {
        setState(() {
          _featuredVendors = response.data!.take(5).toList();
          _isLoadingFeatured = false;
        });
        debugPrint('✅ Loaded ${_featuredVendors!.length} featured vendors');
      } else {
        setState(() => _isLoadingFeatured = false);
        debugPrint('⚠️ Failed to load vendors: ${response.errorMessage}');
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() => _isLoadingFeatured = false);
      debugPrint('❌ Error loading featured vendors: $e');
    }
  }

  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final searches = prefs.getStringList('recent_searches') ?? [];
      if (mounted) {
        setState(() {
          _recentSearches = searches;
        });
      }
    } catch (e) {
      debugPrint('Error loading recent searches: $e');
    }
  }

  Future<void> _saveRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('recent_searches', _recentSearches);
    } catch (e) {
      debugPrint('Error saving recent searches: $e');
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query != _currentQuery) {
      _currentQuery = query;
      if (query.isEmpty) {
        if (mounted) {
          setState(() {
            _productResults = null;
            _vendorResults = null;
          });
        }
      } else if (query.length >= 2) {
        _performSearch(query);
      }
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty || !mounted) return;

    setState(() {
      _isSearching = true;
      _productResults = null;
      _vendorResults = null;
    });

    debugPrint('🔍 Searching for: $query (type: $_searchType)');

    try {
      // Search both products and vendors in parallel
      final results = await Future.wait([
        if (_searchType == 'all' || _searchType == 'products')
          _apiClient.getFoods(search: query),
        if (_searchType == 'all' || _searchType == 'restaurants')
          _apiClient.getAvailableVendors(search: query),
      ]);

      if (!mounted) return;

      // Parse results
      List<Product>? products;
      List<Vendor>? vendors;

      int resultIndex = 0;
      if (_searchType == 'all' || _searchType == 'products') {
        final productResponse = results[resultIndex] as ApiResponse<List<Product>>;
        products = productResponse.isSuccess ? productResponse.data : [];
        resultIndex++;
      }
      
      if (_searchType == 'all' || _searchType == 'restaurants') {
        final vendorResponse = results[resultIndex] as ApiResponse<List<Vendor>>;
        vendors = vendorResponse.isSuccess ? vendorResponse.data : [];
      }

      setState(() {
        _productResults = products;
        _vendorResults = vendors;
        _isSearching = false;
      });

      debugPrint('✅ Found ${products?.length ?? 0} products, ${vendors?.length ?? 0} vendors');
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _productResults = [];
        _vendorResults = [];
        _isSearching = false;
      });
      debugPrint('❌ Search error: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: ${e.toString()}'),
            backgroundColor: context.errorColor,
          ),
        );
      }
    }
  }

  void _addRecentSearch(String query) {
    if (query.trim().isEmpty || !mounted) return;

    setState(() {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.sublist(0, 10);
      }
    });
    
    _saveRecentSearches();
  }

  void _removeRecentSearch(String query) {
    if (!mounted) return;
    
    setState(() {
      _recentSearches.remove(query);
    });
    _saveRecentSearches();
  }

  void _clearRecentSearches() {
    if (!mounted) return;
    
    setState(() {
      _recentSearches.clear();
    });
    _saveRecentSearches();
  }

  void _selectSearch(String search) {
    _searchController.text = search;
    _focusNode.unfocus();
    _addRecentSearch(search);
    _performSearch(search);
  }

  void _navigateToVendor(Vendor vendor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantDetailsScreen(vendor: vendor),
      ),
    );
  }

  bool get _hasResults => 
    (_productResults != null && _productResults!.isNotEmpty) ||
    (_vendorResults != null && _vendorResults!.isNotEmpty);

  int get _totalResults => 
    (_productResults?.length ?? 0) + (_vendorResults?.length ?? 0);

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

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
            fontSize: isSmallScreen ? 16 : 18,
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
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                child: Column(
                  children: [
                    // Search Input
                    Container(
                      decoration: BoxDecoration(
                        color: context.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _focusNode.hasFocus
                              ? context.primaryColor
                              : context.dividerColor,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        style: TextStyle(color: context.textColor),
                        decoration: InputDecoration(
                          hintText: "Search for food or restaurants...",
                          hintStyle: TextStyle(
                            color: context.subtitleColor,
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: context.subtitleColor,
                            size: isSmallScreen ? 20 : 24,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: context.subtitleColor,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    if (mounted) {
                                      setState(() {
                                        _productResults = null;
                                        _vendorResults = null;
                                        _currentQuery = '';
                                      });
                                    }
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 12 : 16,
                            vertical: 12,
                          ),
                        ),
                        textInputAction: TextInputAction.search,
                        onSubmitted: (query) {
                          if (query.isNotEmpty) {
                            _addRecentSearch(query);
                            _performSearch(query);
                          }
                        },
                      ),
                    ),
                    
                    // Filter Chips (only show during search)
                    if (_currentQuery.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _FilterChip(
                              label: 'All',
                              isSelected: _searchType == 'all',
                              onTap: () {
                                setState(() => _searchType = 'all');
                                _performSearch(_currentQuery);
                              },
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: 'Products',
                              count: _productResults?.length,
                              isSelected: _searchType == 'products',
                              onTap: () {
                                setState(() => _searchType = 'products');
                                _performSearch(_currentQuery);
                              },
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: 'Restaurants',
                              count: _vendorResults?.length,
                              isSelected: _searchType == 'restaurants',
                              onTap: () {
                                setState(() => _searchType = 'restaurants');
                                _performSearch(_currentQuery);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Content
              Expanded(
                child: _hasResults
                    ? _buildSearchResults()
                    : _buildSearchSuggestions(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent Searches",
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: context.textColor,
                  ),
                ),
                TextButton(
                  onPressed: _clearRecentSearches,
                  child: Text(
                    "Clear All",
                    style: TextStyle(
                      color: context.primaryColor,
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
            ..._recentSearches.map((search) {
              return _SearchTile(
                text: search,
                icon: Icons.history,
                onTap: () => _selectSearch(search),
                onRemove: () => _removeRecentSearch(search),
                showRemove: true,
              );
            }),
            SizedBox(height: isSmallScreen ? 16 : 24),
          ],

          // Featured Restaurants
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Featured Restaurants",
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: context.textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 10 : 16),

          if (_isLoadingFeatured)
            ...List.generate(3, (_) => _VendorCardSkeleton())
          else if (_featuredVendors != null && _featuredVendors!.isNotEmpty)
            ..._featuredVendors!.map((vendor) {
              return _VendorCard(
                vendor: vendor,
                onTap: () => _navigateToVendor(vendor),
              );
            })
          else
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.store_outlined,
                      size: 48,
                      color: context.subtitleColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No restaurants available',
                      style: TextStyle(
                        color: context.subtitleColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          SizedBox(height: isSmallScreen ? 16 : 24),

          // Popular Searches
          Text(
            "Popular Searches",
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: context.textColor,
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          ..._popularSearches.map((search) {
            return _SearchTile(
              text: search,
              icon: Icons.trending_up,
              onTap: () => _selectSearch(search),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    if (_isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: context.primaryColor),
            const SizedBox(height: 16),
            Text(
              "Searching...",
              style: TextStyle(
                color: context.subtitleColor,
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
          ],
        ),
      );
    }

    if (!_hasResults) {
      return _buildNoResults();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Results for "$_currentQuery"',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: context.textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: context.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "$_totalResults",
                  style: TextStyle(
                    color: context.primaryColor,
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),

          // Restaurants Section
          if (_vendorResults != null && _vendorResults!.isNotEmpty &&
              (_searchType == 'all' || _searchType == 'restaurants')) ...[
            Text(
              'Restaurants (${_vendorResults!.length})',
              style: TextStyle(
                fontSize: isSmallScreen ? 13 : 14,
                fontWeight: FontWeight.w700,
                color: context.subtitleColor,
              ),
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
            ..._vendorResults!.map((vendor) {
              return _VendorCard(
                vendor: vendor,
                onTap: () => _navigateToVendor(vendor),
              );
            }),
            if (_productResults != null && _productResults!.isNotEmpty)
              SizedBox(height: isSmallScreen ? 16 : 20),
          ],

          // Products Section
          if (_productResults != null && _productResults!.isNotEmpty &&
              (_searchType == 'all' || _searchType == 'products')) ...[
            Text(
              'Products (${_productResults!.length})',
              style: TextStyle(
                fontSize: isSmallScreen ? 13 : 14,
                fontWeight: FontWeight.w700,
                color: context.subtitleColor,
              ),
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
            ..._productResults!.map((product) {
              return _ProductCard(
                product: product,
                onTap: () => _showProductBottomSheet(product),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isSmallScreen ? 100 : 120,
              height: isSmallScreen ? 100 : 120,
              decoration: BoxDecoration(
                color: context.surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.dividerColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.search_off,
                size: isSmallScreen ? 40 : 48,
                color: context.subtitleColor,
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 24),
            Text(
              'No Results for "$_currentQuery"',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w600,
                color: context.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Try searching for something else",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.subtitleColor,
                fontSize: isSmallScreen ? 12 : 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _productResults = null;
                  _vendorResults = null;
                  _currentQuery = '';
                });
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Clear Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductBottomSheet(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProductDetailSheet(product: product),
    );
  }
}

// ============================================================================
// WIDGETS
// ============================================================================

class _FilterChip extends StatelessWidget {
  final String label;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? context.primaryColor
              : context.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? context.primaryColor
                : context.dividerColor.withOpacity(0.5),
          ),
        ),
        child: Text(
          count != null ? '$label ($count)' : label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : context.textColor,
          ),
        ),
      ),
    );
  }
}

class _SearchTile extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onRemove;
  final bool showRemove;

  const _SearchTile({
    required this.text,
    required this.icon,
    required this.onTap,
    this.onRemove,
    this.showRemove = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 6 : 8),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
            vertical: isSmallScreen ? 10 : 12,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: isSmallScreen ? 16 : 18,
                  color: context.primaryColor,
                ),
              ),
              SizedBox(width: isSmallScreen ? 10 : 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 15,
                    color: context.textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (showRemove && onRemove != null)
                InkWell(
                  onTap: onRemove,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: context.subtitleColor,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: context.subtitleColor.withOpacity(0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 10 : 12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: isSmallScreen ? 70 : 80,
                  height: isSmallScreen ? 70 : 80,
                  decoration: BoxDecoration(
                    color: context.primaryColor.withOpacity(0.05),
                    border: Border.all(
                      color: context.dividerColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: product.bestImageUrl != null && product.bestImageUrl!.isNotEmpty
                      ? Image.network(
                          product.bestImageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: context.primaryColor,
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.fastfood,
                            color: context.primaryColor,
                            size: isSmallScreen ? 28 : 32,
                          ),
                        )
                      : Icon(
                          Icons.fastfood,
                          color: context.primaryColor,
                          size: isSmallScreen ? 28 : 32,
                        ),
                ),
              ),
              SizedBox(width: isSmallScreen ? 10 : 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w700,
                        color: context.textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (product.description.isNotEmpty)
                      Text(
                        product.description,
                        style: TextStyle(
                          color: context.subtitleColor,
                          fontSize: isSmallScreen ? 11 : 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          "₦${product.price.toStringAsFixed(0)}",
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w700,
                            color: context.primaryColor,
                          ),
                        ),
                        const Spacer(),
                        if (product.stock > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: context.successColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "Available",
                              style: TextStyle(
                                color: context.successColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: context.errorColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "Out of Stock",
                              style: TextStyle(
                                color: context.errorColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
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
    );
  }
}

class _VendorCard extends StatelessWidget {
  final Vendor vendor;
  final VoidCallback onTap;

  const _VendorCard({
    required this.vendor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 10 : 12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: isSmallScreen ? 60 : 70,
                  height: isSmallScreen ? 60 : 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.primaryColor.withOpacity(0.2),
                        context.primaryColor.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.restaurant,
                    color: context.primaryColor,
                    size: isSmallScreen ? 24 : 28,
                  ),
                ),
              ),
              SizedBox(width: isSmallScreen ? 10 : 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendor.name,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w700,
                        color: context.textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (vendor.city != null && vendor.city!.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: context.subtitleColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              vendor.city!,
                              style: TextStyle(
                                color: context.subtitleColor,
                                fontSize: isSmallScreen ? 11 : 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "4.5",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.textColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: context.subtitleColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            vendor.type.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              color: context.subtitleColor,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (vendor.isAvailable == true)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: context.successColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "Open",
                              style: TextStyle(
                                color: context.successColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
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
    );
  }
}

class _VendorCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: context.dividerColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: context.dividerColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 100,
                  height: 12,
                  decoration: BoxDecoration(
                    color: context.dividerColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: context.dividerColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
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

// Product Detail Bottom Sheet
class _ProductDetailSheet extends StatefulWidget {
  final Product product;

  const _ProductDetailSheet({required this.product});

  @override
  State<_ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<_ProductDetailSheet> {
  final ApiClient _apiClient = ApiClient();
  bool _isAdding = false;

  Future<void> _addToCart() async {
    if (_isAdding) return;

    setState(() => _isAdding = true);

    try {
      final response = await _apiClient.addToCart(
        sku: widget.product.sku,
        quantity: 1,
      );

      if (!mounted) return;

      if (response.isSuccess) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.product.name} added to cart'),
            backgroundColor: context.successColor,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'View Cart',
              textColor: Colors.white,
              onPressed: () => Navigator.pushNamed(context, '/cart'),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.errorMessage ?? 'Failed to add to cart'),
            backgroundColor: context.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: context.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = widget.product.stock <= 0;

    return Container(
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          
          // Product Image
          if (widget.product.bestImageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                widget.product.bestImageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: context.primaryColor.withOpacity(0.1),
                  child: Icon(
                    Icons.fastfood,
                    size: 64,
                    color: context.primaryColor,
                  ),
                ),
              ),
            )
          else
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: context.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.fastfood,
                size: 64,
                color: context.primaryColor,
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: context.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                
                if (widget.product.description.isNotEmpty)
                  Text(
                    widget.product.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.subtitleColor,
                      height: 1.5,
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Text(
                      "₦${widget.product.price.toStringAsFixed(0)}",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: context.primaryColor,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isOutOfStock
                            ? context.errorColor.withOpacity(0.1)
                            : context.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isOutOfStock ? "Out of Stock" : "In Stock",
                        style: TextStyle(
                          fontSize: 12,
                          color: isOutOfStock
                              ? context.errorColor
                              : context.successColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isOutOfStock || _isAdding ? null : _addToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryColor,
                      disabledBackgroundColor: context.dividerColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isAdding
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_shopping_cart, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                isOutOfStock ? "Out of Stock" : "Add to Cart",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
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