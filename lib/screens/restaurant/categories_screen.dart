import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bezoni/core/api_client.dart';
import 'package:bezoni/core/api_models.dart';
import 'package:bezoni/themes/theme_extensions.dart';

/// =====================
/// Fully Functional API-Integrated Categories Screen
/// =====================
class CategoriesScreen extends StatefulWidget {
  final VoidCallback? onCartUpdated;
  
  const CategoriesScreen({super.key, this.onCartUpdated});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final ApiClient _apiClient = ApiClient();

  // Predefined categories with icons, colors, and search terms
  final List<CategoryData> _categories = [
    CategoryData("Food", Icons.restaurant, const Color(0xFFEF4444), ["food", "meal"]),
    CategoryData("Burgers", Icons.lunch_dining, const Color(0xFFEA580C), ["burger"]),
    CategoryData("Pizza", Icons.local_pizza, const Color(0xFFF59E0B), ["pizza"]),
    CategoryData("Rice", Icons.rice_bowl, const Color(0xFF10B981), ["rice", "jollof", "fried rice"]),
    CategoryData("Chicken", Icons.set_meal, const Color(0xFFD97706), ["chicken", "poultry"]),
    CategoryData("Drinks", Icons.local_drink, const Color(0xFF0EA5E9), ["drink", "beverage", "juice", "soda"]),
    CategoryData("Snacks", Icons.cookie_outlined, const Color(0xFF8B5CF6), ["snack", "chips", "pastry"]),
    CategoryData("Seafood", Icons.set_meal, const Color(0xFF06B6D4), ["fish", "seafood", "shrimp"]),
    CategoryData("Desserts", Icons.cake, const Color(0xFFEC4899), ["dessert", "cake", "ice cream", "sweet"]),
    CategoryData("Vegetables", Icons.eco, const Color(0xFF22C55E), ["vegetable", "salad", "veggie"]),
    CategoryData("Bread", Icons.bakery_dining, const Color(0xFF94A3B8), ["bread", "bakery", "pastry"]),
    CategoryData("Soup", Icons.soup_kitchen, const Color(0xFFDC2626), ["soup", "stew"]),
  ];

  @override
  void initState() {
    super.initState();
    _apiClient.initialize();
  }

  void _showCategoryProducts(CategoryData category) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryProductsScreen(
          category: category,
          onCartUpdated: widget.onCartUpdated,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth > 600;
    
    // Responsive grid layout
    final crossAxisCount = isTablet ? 4 : (isSmallScreen ? 2 : 3);
    final childAspectRatio = isSmallScreen ? 1.0 : (isTablet ? 1.2 : 1.1);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(
          "Categories",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: isSmallScreen ? 16 : 18,
            color: context.textColor,
          ),
        ),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: context.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(isSmallScreen ? 12 : (isTablet ? 20 : 16)),
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: isSmallScreen ? 10 : (isTablet ? 16 : 12),
          crossAxisSpacing: isSmallScreen ? 10 : (isTablet ? 16 : 12),
          childAspectRatio: childAspectRatio,
        ),
        itemBuilder: (_, index) {
          final category = _categories[index];
          return _CategoryTile(
            category: category,
            onTap: () => _showCategoryProducts(category),
            isSmallScreen: isSmallScreen,
            isTablet: isTablet,
          );
        },
      ),
    );
  }
}

/// =====================
/// Category Data Model with Search Terms
/// =====================
class CategoryData {
  final String name;
  final IconData icon;
  final Color color;
  final List<String> searchTerms;

  CategoryData(this.name, this.icon, this.color, this.searchTerms);
}

/// =====================
/// Responsive Category Tile Widget
/// =====================
class _CategoryTile extends StatelessWidget {
  final CategoryData category;
  final VoidCallback onTap;
  final bool isSmallScreen;
  final bool isTablet;

  const _CategoryTile({
    required this.category,
    required this.onTap,
    required this.isSmallScreen,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = isTablet ? 36.0 : (isSmallScreen ? 28.0 : 32.0);
    final fontSize = isTablet ? 15.0 : (isSmallScreen ? 12.0 : 14.0);
    final padding = isTablet ? 16.0 : (isSmallScreen ? 12.0 : 14.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 14),
          gradient: LinearGradient(
            colors: [
              category.color.withOpacity(context.isDarkMode ? 0.15 : 0.10),
              context.surfaceColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: ThemeUtils.createShadow(context, elevation: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(padding),
              decoration: BoxDecoration(
                color: category.color.withOpacity(context.isDarkMode ? 0.20 : 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                category.icon,
                size: iconSize,
                color: category.color,
              ),
            ),
            SizedBox(height: isSmallScreen ? 8 : 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                category.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: fontSize,
                  color: context.textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =====================
/// Category Products Screen - Shows products filtered by category
/// =====================
class CategoryProductsScreen extends StatefulWidget {
  final CategoryData category;
  final VoidCallback? onCartUpdated;

  const CategoryProductsScreen({
    super.key,
    required this.category,
    this.onCartUpdated,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final ApiClient _apiClient = ApiClient();
  List<Product>? _products;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _apiClient.initialize();
      
      // Try each search term until we find products
      List<Product> allProducts = [];
      
      for (String searchTerm in widget.category.searchTerms) {
        final response = await _apiClient.getFoods(search: searchTerm);
        
        if (response.isSuccess && response.data != null) {
          allProducts.addAll(response.data!);
        }
      }

      // Remove duplicates by SKU
      final uniqueProducts = <String, Product>{};
      for (var product in allProducts) {
        uniqueProducts[product.sku] = product;
      }

      setState(() {
        _products = uniqueProducts.values.toList();
        _isLoading = false;
      });

      debugPrint('✅ Found ${_products!.length} products for ${widget.category.name}');
    } catch (e) {
      setState(() {
        _products = [];
        _isLoading = false;
        _errorMessage = 'Error loading products: ${e.toString()}';
      });
      debugPrint('❌ Error loading category products: $e');
    }
  }

  Future<void> _addToCart(Product product) async {
    try {
      HapticFeedback.mediumImpact();
      
      final response = await _apiClient.addToCart(
        sku: product.sku,
        quantity: 1,
      );

      if (!mounted) return;

      if (response.isSuccess) {
        // Trigger cart update callback
        widget.onCartUpdated?.call();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${product.name} added to cart',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: context.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.errorMessage ?? 'Failed to add to cart'),
            backgroundColor: context.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: context.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.category.name,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: isSmallScreen ? 16 : 18,
            color: context.textColor,
          ),
        ),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: context.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: context.textColor,
            ),
            onPressed: _loadProducts,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: widget.category.color,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading ${widget.category.name.toLowerCase()}...',
                    style: TextStyle(
                      color: context.subtitleColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: context.errorColor.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: context.textColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _loadProducts,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.category.color,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _products == null || _products!.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.category.icon,
                              size: 80,
                              color: widget.category.color.withOpacity(0.3),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'No ${widget.category.name.toLowerCase()} available yet',
                              style: TextStyle(
                                fontSize: isTablet ? 18 : 16,
                                fontWeight: FontWeight.w700,
                                color: context.textColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Check back later for delicious ${widget.category.name.toLowerCase()}!',
                              style: TextStyle(
                                color: context.subtitleColor,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            OutlinedButton.icon(
                              onPressed: _loadProducts,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: widget.category.color),
                                foregroundColor: widget.category.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadProducts,
                      color: widget.category.color,
                      child: ListView.builder(
                        padding: EdgeInsets.all(isSmallScreen ? 12 : (isTablet ? 20 : 16)),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _products!.length,
                        itemBuilder: (context, index) {
                          final product = _products![index];
                          return _ProductCard(
                            product: product,
                            categoryColor: widget.category.color,
                            onAddToCart: () => _addToCart(product),
                            isSmallScreen: isSmallScreen,
                            isTablet: isTablet,
                          );
                        },
                      ),
                    ),
    );
  }
}

/// =====================
/// Responsive Product Card Widget
/// =====================
class _ProductCard extends StatelessWidget {
  final Product product;
  final Color categoryColor;
  final VoidCallback onAddToCart;
  final bool isSmallScreen;
  final bool isTablet;

  const _ProductCard({
    required this.product,
    required this.categoryColor,
    required this.onAddToCart,
    required this.isSmallScreen,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final imageSize = isTablet ? 110.0 : (isSmallScreen ? 70.0 : 90.0);
    final cardPadding = isTablet ? 14.0 : (isSmallScreen ? 10.0 : 12.0);
    final spacing = isTablet ? 14.0 : (isSmallScreen ? 10.0 : 12.0);

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 10 : (isTablet ? 14 : 12)),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: ThemeUtils.createShadow(context, elevation: 2),
      ),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: imageSize,
                height: imageSize,
                color: categoryColor.withOpacity(0.1),
                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.fastfood,
                          color: categoryColor,
                          size: imageSize * 0.4,
                        ),
                        loadingBuilder: (_, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: categoryColor,
                              strokeWidth: 2,
                            ),
                          );
                        },
                      )
                    : Icon(
                        Icons.fastfood,
                        color: categoryColor,
                        size: imageSize * 0.4,
                      ),
              ),
            ),
            SizedBox(width: spacing),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: isTablet ? 17 : (isSmallScreen ? 14 : 16),
                      fontWeight: FontWeight.w700,
                      color: context.textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (product.description.isNotEmpty)
                    Text(
                      product.description,
                      style: TextStyle(
                        color: context.subtitleColor,
                        fontSize: isTablet ? 13 : (isSmallScreen ? 11 : 12),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: isSmallScreen ? 8 : 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "₦${product.price.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: isTablet ? 18 : (isSmallScreen ? 14 : 16),
                              fontWeight: FontWeight.w800,
                              color: categoryColor,
                            ),
                          ),
                          if (product.stock > 0)
                            Text(
                              '${product.stock} in stock',
                              style: TextStyle(
                                fontSize: 10,
                                color: context.subtitleColor,
                              ),
                            ),
                        ],
                      ),
                      if (product.stock > 0)
                        ElevatedButton.icon(
                          onPressed: onAddToCart,
                          icon: Icon(
                            Icons.add_shopping_cart,
                            size: isTablet ? 18 : (isSmallScreen ? 14 : 16),
                          ),
                          label: Text(
                            "Add to Cart",
                            style: TextStyle(
                              fontSize: isTablet ? 13 : (isSmallScreen ? 11 : 12),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: categoryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 14 : (isSmallScreen ? 10 : 12),
                              vertical: isTablet ? 10 : (isSmallScreen ? 6 : 8),
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 12 : 10,
                            vertical: isTablet ? 8 : 6,
                          ),
                          decoration: BoxDecoration(
                            color: context.errorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Out of Stock",
                            style: TextStyle(
                              color: context.errorColor,
                              fontSize: isTablet ? 11 : 10,
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
    );
  }
}