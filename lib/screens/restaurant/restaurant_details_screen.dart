// File: lib/screens/restaurant_details_screen.dart (Updated with Cart Callback)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bezoni/core/api_client.dart';
import 'package:bezoni/core/api_models.dart';
import 'package:bezoni/themes/theme_extensions.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  final Vendor? vendor;
  final VoidCallback? onCartUpdated; // Added cart callback

  const RestaurantDetailsScreen({
    super.key,
    this.vendor,
    this.onCartUpdated, // Added parameter
  });

  @override
  State<RestaurantDetailsScreen> createState() =>
      _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  final ApiClient _apiClient = ApiClient();
  Vendor? _vendor;
  List<Product>? _products;
  bool _isLoadingProducts = true;
  bool _isFavorite = false;
  String? _error;
  final Set<String> _addingToCart = {}; // Track which items are being added

  @override
  void initState() {
    super.initState();
    _apiClient.initialize();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize vendor after the first build when context is available
    if (_vendor == null) {
      _initializeVendor();
    }
  }

  void _initializeVendor() {
    // Get vendor from widget or route arguments
    final vendor =
        widget.vendor ??
        (ModalRoute.of(context)?.settings.arguments as Vendor?);

    if (vendor != null) {
      setState(() {
        _vendor = vendor;
      });
      _loadVendorProducts();
    } else {
      setState(() {
        _error = 'No vendor information available';
        _isLoadingProducts = false;
      });
    }
  }

  Future<void> _loadVendorProducts() async {
    if (!mounted) return;

    setState(() {
      _isLoadingProducts = true;
      _error = null;
    });

    try {
      // Check if vendor already has products
      if (_vendor!.products != null && _vendor!.products!.isNotEmpty) {
        setState(() {
          _products = _vendor!.products;
          _isLoadingProducts = false;
        });
        debugPrint('✅ Using ${_products!.length} products from vendor data');
        return;
      }

      // Otherwise fetch all products and filter by vendor
      final response = await _apiClient.getProducts();

      if (!mounted) return;

      if (response.isSuccess && response.data != null) {
        // Filter products for this vendor
        final vendorProducts = response.data!
            .where((p) => p.vendorId == _vendor!.id)
            .toList();

        setState(() {
          _products = vendorProducts;
          _isLoadingProducts = false;
        });

        debugPrint(
          '✅ Loaded ${vendorProducts.length} products for ${_vendor!.name}',
        );
      } else {
        setState(() {
          _error = response.errorMessage ?? 'Failed to load products';
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Error loading products: ${e.toString()}';
        _isLoadingProducts = false;
      });
      debugPrint('❌ Error loading products: $e');
    }
  }

  Future<void> _addToCart(Product product) async {
    if (!mounted) return;

    // Prevent multiple simultaneous adds
    if (_addingToCart.contains(product.sku)) {
      debugPrint('⚠️ Already adding ${product.sku} to cart');
      return;
    }

    setState(() {
      _addingToCart.add(product.sku);
    });

    try {
      HapticFeedback.lightImpact();

      final response = await _apiClient.addToCart(
        sku: product.sku,
        quantity: 1,
      );

      if (!mounted) return;

      if (response.isSuccess) {
        HapticFeedback.mediumImpact();
        
        // IMPORTANT: Notify parent to update cart badge
        widget.onCartUpdated?.call();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} added to cart'),
            backgroundColor: context.successColor,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'View Cart',
              textColor: Colors.white,
              onPressed: () => Navigator.pushNamed(context, '/cart'),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.errorMessage ?? 'Failed to add to cart'),
            backgroundColor: context.errorColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: context.errorColor,
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _addingToCart.remove(product.sku);
        });
      }
    }
  }

  void _toggleFavorite() {
    HapticFeedback.lightImpact();
    setState(() => _isFavorite = !_isFavorite);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite ? 'Added to favorites' : 'Removed from favorites',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareRestaurant() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share ${_vendor?.name ?? "restaurant"}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getVendorColor(String type) {
    switch (type.toUpperCase()) {
      case 'RESTAURANT':
        return const Color(0xFFEF4444);
      case 'GROCERY':
        return const Color(0xFF10B981);
      case 'PHARMACY':
        return const Color(0xFF8B5CF6);
      case 'CAFE':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6366F1);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_vendor == null) {
      return Scaffold(
        backgroundColor: context.backgroundColor,
        appBar: AppBar(
          backgroundColor: context.surfaceColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.textColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: context.errorColor),
              const SizedBox(height: 16),
              Text(
                _error ?? 'No vendor information',
                style: TextStyle(fontSize: 16, color: context.textColor),
              ),
            ],
          ),
        ),
      );
    }

    final vendorColor = _getVendorColor(_vendor!.type);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: context.surfaceColor,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.surfaceColor.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: context.textColor),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.surfaceColor.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : context.textColor,
                  ),
                  onPressed: _toggleFavorite,
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.surfaceColor.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.share, color: context.textColor),
                  onPressed: _shareRestaurant,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [vendorColor, vendorColor.withOpacity(0.7)],
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Center(
                      child: Icon(
                        Icons.restaurant,
                        size: 100,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    // Gradient overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 100,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              context.backgroundColor.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Restaurant Info
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge
                      if (_vendor!.isAvailable != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _vendor!.isAvailable!
                                ? context.successColor.withOpacity(0.1)
                                : context.errorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _vendor!.isAvailable!
                                      ? context.successColor
                                      : context.errorColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _vendor!.isAvailable! ? "Open Now" : "Closed",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _vendor!.isAvailable!
                                      ? context.successColor
                                      : context.errorColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 12),

                      // Name
                      Text(
                        _vendor!.name,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: context.textColor,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Type Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: vendorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _vendor!.type,
                          style: TextStyle(
                            fontSize: 12,
                            color: vendorColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Address
                      if (_vendor!.address != null)
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 20,
                              color: context.subtitleColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _vendor!.address!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.subtitleColor,
                                ),
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 12),

                      // Info Cards Row
                      Row(
                        children: [
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.star,
                              label: 'Rating',
                              value: '4.5',
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.access_time,
                              label: 'Delivery',
                              value: '25-30 min',
                              color: context.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.delivery_dining,
                              label: 'Delivery Fee',
                              value: '₦500',
                              color: context.successColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Menu Section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Menu',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: context.textColor,
                            ),
                          ),
                          if (_products != null && _products!.isNotEmpty)
                            Text(
                              '${_products!.length} items',
                              style: TextStyle(
                                fontSize: 14,
                                color: context.subtitleColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Products List
                      if (_isLoadingProducts)
                        Column(
                          children: List.generate(
                            3,
                            (_) => const _ProductCardSkeleton(),
                          ),
                        )
                      else if (_error != null)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: context.errorColor,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _error!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: context.textColor,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _loadVendorProducts,
                                  icon: const Icon(Icons.refresh, size: 18),
                                  label: const Text('Try Again'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: context.primaryColor,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (_products == null || _products!.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.fastfood_outlined,
                                  size: 48,
                                  color: context.subtitleColor.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No menu items available',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: context.textColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'This restaurant hasn\'t added any items yet',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: context.subtitleColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _products!.length,
                          itemBuilder: (context, index) {
                            final product = _products![index];
                            return _ProductCard(
                              product: product,
                              vendorColor: vendorColor,
                              onAddToCart: () => _addToCart(product),
                              isAdding: _addingToCart.contains(product.sku),
                            );
                          },
                        ),
                    ],
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

// Info Card Widget
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: context.textColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: context.subtitleColor),
          ),
        ],
      ),
    );
  }
}

// Product Card Widget
class _ProductCard extends StatelessWidget {
  final Product product;
  final Color vendorColor;
  final VoidCallback onAddToCart;
  final bool isAdding;

  const _ProductCard({
    required this.product,
    required this.vendorColor,
    required this.onAddToCart,
    this.isAdding = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = product.imageUrl != null && product.imageUrl!.isNotEmpty;
    final isOutOfStock = product.stock != null && product.stock! <= 0;
    final isDisabled = isOutOfStock || isAdding;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ThemeUtils.createShadow(context, elevation: 2),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isOutOfStock ? null : onAddToCart,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 90,
                    height: 90,
                    color: vendorColor.withOpacity(0.1),
                    child: hasImage
                        ? Image.network(
                            product.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.fastfood,
                              color: vendorColor,
                              size: 40,
                            ),
                          )
                        : Icon(Icons.fastfood, color: vendorColor, size: 40),
                  ),
                ),

                const SizedBox(width: 14),

                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: context.textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      if (product.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          product.description!,
                          style: TextStyle(
                            fontSize: 13,
                            color: context.subtitleColor,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Text(
                            '₦${product.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: context.primaryColor,
                            ),
                          ),

                          const Spacer(),

                          if (isOutOfStock)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: context.errorColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Out of Stock',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.errorColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          else if (isAdding)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF2ECC40),
                                  ),
                                ),
                              ),
                            )
                          else
                            Container(
                              decoration: BoxDecoration(
                                color: context.primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: onAddToCart,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.add_shopping_cart,
                                          size: 16,
                                          color: context.isDarkMode
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Add',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: context.isDarkMode
                                                ? Colors.black
                                                : Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
      ),
    );
  }
}

// Product Card Skeleton
class _ProductCardSkeleton extends StatelessWidget {
  const _ProductCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ThemeUtils.createShadow(context, elevation: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: context.dividerColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 14),
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
                  width: 150,
                  height: 12,
                  decoration: BoxDecoration(
                    color: context.dividerColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 14,
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