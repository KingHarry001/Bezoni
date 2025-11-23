// File: lib/screens/cart_screen.dart
import 'package:bezoni/screens/orders/order_tracking_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bezoni/core/api_client.dart';
import 'package:bezoni/core/api_models.dart';
import 'package:bezoni/themes/theme_extensions.dart';

/// =====================
/// API-Integrated Cart Screen with Wallet Balance Checking
/// =====================
class CartScreen extends StatefulWidget {
  final VoidCallback? onCartUpdated;

  const CartScreen({super.key, this.onCartUpdated});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiClient _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _apiClient.initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    // Check if this screen can be popped (has a previous route)
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        // Only show back button if there's a route to go back to
        automaticallyImplyLeading: canPop,
        title: Text(
          "Cart",
          style: TextStyle(
            color: context.textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: context.surfaceColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: context.primaryColor,
          unselectedLabelColor: context.subtitleColor,
          indicatorColor: context.primaryColor,
          labelStyle: TextStyle(
            fontSize: isSmallScreen ? 13 : 14,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: "Current Cart"),
            Tab(text: "Orders"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CartTab(
            apiClient: _apiClient,
            tabController: _tabController,
            onCartUpdated: widget.onCartUpdated,
          ),
          _OrdersTab(apiClient: _apiClient),
        ],
      ),
    );
  }
}

/// =====================
/// Cart Tab - Shows current cart items with wallet checking
/// =====================
class _CartTab extends StatefulWidget {
  final ApiClient apiClient;
  final TabController tabController;
  final VoidCallback? onCartUpdated;

  const _CartTab({
    required this.apiClient,
    required this.tabController,
    this.onCartUpdated,
  });

  @override
  State<_CartTab> createState() => _CartTabState();
}

class _CartTabState extends State<_CartTab> {
  CartResponse? _cart;
  WalletBalance? _walletBalance;
  bool _isLoading = true;
  bool _isLoadingWallet = false;
  String? _errorMessage;
  bool _isProcessingCheckout = false;

  @override
  void initState() {
    super.initState();
    _loadCartAndWallet();
  }

  Future<void> _loadCartAndWallet() async {
    await Future.wait([_loadCart(), _loadWalletBalance()]);
  }

  Future<void> _loadCart() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await widget.apiClient.getCart();

      if (!mounted) return;

      if (response.isSuccess && response.data != null) {
        setState(() {
          _cart = response.data;
          _isLoading = false;
        });
        debugPrint(
          '✅ Cart loaded: ${_cart!.items.length} items, Total: ₦${_cart!.total}',
        );

        // Notify parent to update badge
        widget.onCartUpdated?.call();
      } else {
        // Handle 404 (empty cart) gracefully
        if (response.errorMessage?.contains('404') ?? false) {
          setState(() {
            _cart = null;
            _isLoading = false;
            _errorMessage = null;
          });
          widget.onCartUpdated?.call();
        } else {
          setState(() {
            _errorMessage = response.errorMessage ?? 'Failed to load cart';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Error loading cart: ${e.toString()}';
        _isLoading = false;
      });
      debugPrint('❌ Cart load error: $e');
    }
  }

  Future<void> _loadWalletBalance() async {
    if (!mounted) return;

    setState(() => _isLoadingWallet = true);

    try {
      final response = await widget.apiClient.getWalletBalance();

      if (!mounted) return;

      if (response.isSuccess && response.data != null) {
        setState(() {
          _walletBalance = response.data;
          _isLoadingWallet = false;
        });
        debugPrint('✅ Wallet balance loaded: ₦${_walletBalance!.balance}');
      } else {
        setState(() => _isLoadingWallet = false);
        debugPrint('⚠️ Wallet load warning: ${response.errorMessage}');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoadingWallet = false);
      debugPrint('❌ Wallet load error: $e');
    }
  }

  Future<void> _updateQuantity(String sku, int newQuantity) async {
    if (!mounted) return;

    try {
      if (newQuantity <= 0) {
        await _removeItem(sku);
        return;
      }

      HapticFeedback.lightImpact();

      final currentItem = _cart?.items.firstWhere((item) => item.sku == sku);
      if (currentItem == null) return;

      // Calculate difference
      final difference = newQuantity - currentItem.quantity;

      if (difference == 0) return;

      if (difference < 0) {
        // Decreasing - try reduce endpoint first
        try {
          final response = await widget.apiClient.reduceCartQuantity(
            sku: sku,
            quantity: difference.abs(),
          );

          if (!mounted) return;

          if (response.isSuccess) {
            await _loadCart();
            return;
          }
        } catch (e) {
          debugPrint('⚠️ Reduce endpoint failed: $e');
        }

        // Fallback: Remove and re-add
        if (!mounted) return;

        await widget.apiClient.removeFromCart(sku);

        if (newQuantity > 0) {
          await widget.apiClient.addToCart(sku: sku, quantity: newQuantity);
        }

        if (!mounted) return;
        await _loadCart();
      } else {
        // Increasing - just add more
        final response = await widget.apiClient.addToCart(
          sku: sku,
          quantity: difference,
        );

        if (!mounted) return;

        if (response.isSuccess) {
          await _loadCart();
        } else {
          _showSnackBar(
            response.errorMessage ?? 'Failed to update quantity',
            isError: true,
          );
        }
      }
    } catch (e) {
      if (!mounted) return;

      _showSnackBar('Error: ${e.toString()}', isError: true);
    }
  }

  Future<void> _removeItem(String sku) async {
    if (!mounted) return;

    try {
      HapticFeedback.mediumImpact();

      final response = await widget.apiClient.removeFromCart(sku);

      if (!mounted) return;

      if (response.isSuccess) {
        await _loadCart();
        _showSnackBar('Item removed from cart', isError: false);
      } else {
        _showSnackBar(
          response.errorMessage ?? 'Failed to remove item',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showSnackBar('Error: ${e.toString()}', isError: true);
    }
  }

  Future<void> _processCheckout() async {
    if (_cart == null || _cart!.items.isEmpty) return;
    if (!mounted) return;

    setState(() => _isProcessingCheckout = true);

    try {
      // 1. Check wallet balance first
      if (_walletBalance == null) {
        await _loadWalletBalance();
      }

      if (!mounted) return;

      if (_walletBalance != null && _walletBalance!.balance < _cart!.total) {
        setState(() => _isProcessingCheckout = false);
        _showInsufficientFundsDialog();
        return;
      }

      // 2. Preview the order
      final previewResponse = await widget.apiClient.previewOrder();

      if (!mounted) return;

      if (!previewResponse.isSuccess) {
        throw Exception(
          previewResponse.errorMessage ?? 'Failed to preview order',
        );
      }

      // 3. Show order preview
      final confirmed = await _showOrderPreviewDialog(
        previewResponse.data!,
        _walletBalance!,
      );

      if (!confirmed || !mounted) {
        setState(() => _isProcessingCheckout = false);
        return;
      }

      // 4. Get delivery address
      final address = await _getDeliveryAddress();
      if (address == null || !mounted) {
        setState(() => _isProcessingCheckout = false);
        return;
      }

      // 5. Get payment method
      final paymentMethod = await _selectPaymentMethod();
      if (paymentMethod == null || !mounted) {
        setState(() => _isProcessingCheckout = false);
        return;
      }

      // 6. Create the order
      final orderResponse = await widget.apiClient.createOrder(
        dropoffAddr: address,
        paymentMethod: paymentMethod,
      );

      if (!mounted) return;

      if (orderResponse.isSuccess && orderResponse.data != null) {
        HapticFeedback.heavyImpact();

        _showSnackBar('Order placed successfully! 🎉', isError: false);

        // Reload wallet
        await _loadWalletBalance();

        // Switch to orders tab
        widget.tabController.animateTo(1);

        // Reload cart
        await _loadCart();
      } else {
        throw Exception(orderResponse.errorMessage ?? 'Failed to create order');
      }
    } catch (e) {
      if (!mounted) return;

      _showSnackBar('Checkout failed: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isProcessingCheckout = false);
      }
    }
  }

  void _showInsufficientFundsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.account_balance_wallet, color: context.errorColor),
            const SizedBox(width: 12),
            Text(
              'Insufficient Funds',
              style: TextStyle(color: context.textColor, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your wallet balance is not enough to complete this order.',
              style: TextStyle(color: context.textColor),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildBalanceRow(
                    'Wallet Balance',
                    _walletBalance?.balance ?? 0,
                    context,
                  ),
                  const Divider(height: 16),
                  _buildBalanceRow(
                    'Order Total',
                    _cart?.total ?? 0,
                    context,
                    isHighlight: true,
                  ),
                  const Divider(height: 16),
                  _buildBalanceRow(
                    'Shortfall',
                    (_cart?.total ?? 0) - (_walletBalance?.balance ?? 0),
                    context,
                    isError: true,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.subtitleColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/wallet');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Top Up Wallet',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceRow(
    String label,
    double amount,
    BuildContext context, {
    bool isHighlight = false,
    bool isError = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isError
                ? context.errorColor
                : (isHighlight ? context.textColor : context.subtitleColor),
            fontSize: 14,
            fontWeight: isHighlight || isError
                ? FontWeight.w600
                : FontWeight.normal,
          ),
        ),
        Text(
          '₦${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: isError
                ? context.errorColor
                : (isHighlight ? context.primaryColor : context.textColor),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Future<bool> _showOrderPreviewDialog(
    OrderPreview preview,
    WalletBalance wallet,
  ) async {
    final hasEnough = wallet.balance >= preview.total;

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: context.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Order Summary',
              style: TextStyle(
                color: context.textColor,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPriceRow('Subtotal', preview.subtotal),
                _buildPriceRow('Delivery Fee', preview.deliveryFee),
                _buildPriceRow('Service Fee', preview.serviceFee),
                const Divider(height: 24),
                _buildPriceRow('Total', preview.total, isTotal: true),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: hasEnough
                        ? context.successColor.withOpacity(0.1)
                        : context.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasEnough
                          ? context.successColor
                          : context.errorColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        hasEnough ? Icons.check_circle : Icons.warning,
                        color: hasEnough
                            ? context.successColor
                            : context.errorColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Wallet Balance',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.subtitleColor,
                              ),
                            ),
                            Text(
                              '₦${wallet.balance.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: hasEnough
                                    ? context.successColor
                                    : context.errorColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!hasEnough) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Insufficient funds. Please top up your wallet.',
                    style: TextStyle(color: context.errorColor, fontSize: 12),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: context.subtitleColor),
                ),
              ),
              ElevatedButton(
                onPressed: hasEnough
                    ? () => Navigator.pop(context, true)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasEnough
                      ? context.primaryColor
                      : context.dividerColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  hasEnough ? 'Confirm Order' : 'Top Up First',
                  style: TextStyle(
                    color: hasEnough ? Colors.white : context.subtitleColor,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: context.textColor,
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '₦${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: isTotal ? context.primaryColor : context.textColor,
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _getDeliveryAddress() async {
    final controller = TextEditingController();

    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delivery Address',
          style: TextStyle(color: context.textColor),
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(color: context.textColor),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter your delivery address',
            hintStyle: TextStyle(color: context.subtitleColor),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.primaryColor, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.subtitleColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final address = controller.text.trim();
              if (address.isNotEmpty) {
                Navigator.pop(context, address);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<String?> _selectPaymentMethod() async {
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Payment Method',
          style: TextStyle(color: context.textColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PaymentMethodTile(
              icon: Icons.account_balance_wallet,
              title: 'Wallet',
              subtitle: _walletBalance != null
                  ? '₦${_walletBalance!.balance.toStringAsFixed(2)} available'
                  : 'Loading...',
              onTap: () => Navigator.pop(context, 'WALLET'),
            ),
            const SizedBox(height: 12),
            _PaymentMethodTile(
              icon: Icons.credit_card,
              title: 'Card Payment',
              subtitle: 'Pay with credit/debit card',
              onTap: () => Navigator.pop(context, 'CARD'),
            ),
            const SizedBox(height: 12),
            _PaymentMethodTile(
              icon: Icons.money,
              title: 'Cash on Delivery',
              subtitle: 'Pay when order arrives',
              onTap: () => Navigator.pop(context, 'CASH'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? context.errorColor : context.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: context.primaryColor),
      );
    }

    if (_errorMessage != null &&
        !_errorMessage!.contains('empty') &&
        !_errorMessage!.contains('404')) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: context.errorColor),
              const SizedBox(height: 16),
              Text(
                'Error Loading Cart',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: context.subtitleColor),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadCart,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_cart == null || _cart!.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: context.subtitleColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              "Your cart is empty",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Add items to get started",
              style: TextStyle(color: context.subtitleColor),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              icon: const Icon(Icons.shopping_bag, size: 20),
              label: const Text('Start Shopping'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadCartAndWallet,
            color: context.primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _cart!.items.length,
              itemBuilder: (context, index) {
                final item = _cart!.items[index];
                return _CartItemTile(
                  item: item,
                  onRemove: () => _removeItem(item.sku),
                  onUpdateQuantity: (newQty) =>
                      _updateQuantity(item.sku, newQty),
                );
              },
            ),
          ),
        ),
        Container(
          color: context.surfaceColor,
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Subtotal:",
                      style: TextStyle(
                        fontSize: 14,
                        color: context.subtitleColor,
                      ),
                    ),
                    Text(
                      "₦${_cart!.subtotal.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Delivery Fee:",
                      style: TextStyle(
                        fontSize: 14,
                        color: context.subtitleColor,
                      ),
                    ),
                    Text(
                      "₦${_cart!.deliveryFee.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.textColor,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: context.textColor,
                      ),
                    ),
                    Text(
                      "₦${_cart!.total.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: context.primaryColor,
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
                      backgroundColor: context.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _isProcessingCheckout ? null : _processCheckout,
                    child: _isProcessingCheckout
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
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
        ),
      ],
    );
  }
}

/// =====================
/// Payment Method Tile
/// =====================
class _PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.surfaceColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: context.dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: context.primaryColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: context.textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: context.subtitleColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// =====================
/// Cart Item Tile Widget
/// =====================
class _CartItemTile extends StatefulWidget {
  final CartItemModel item;
  final VoidCallback onRemove;
  final Function(int) onUpdateQuantity;

  const _CartItemTile({
    required this.item,
    required this.onRemove,
    required this.onUpdateQuantity,
  });

  @override
  State<_CartItemTile> createState() => _CartItemTileState();
}

class _CartItemTileState extends State<_CartItemTile> {
  bool _isUpdating = false;

  Future<void> _handleQuantityChange(int newQuantity) async {
    if (_isUpdating) return; // Prevent multiple simultaneous updates

    setState(() => _isUpdating = true);

    try {
      await widget.onUpdateQuantity(newQuantity);
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: ThemeUtils.createShadow(context, elevation: 1),
      ),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      child: Column(
        children: [
          Row(
            children: [
              // Product Image/Icon
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: isSmallScreen ? 60 : 70,
                  height: isSmallScreen ? 60 : 70,
                  color: context.primaryColor.withOpacity(0.1),
                  child:
                      widget.item.imageUrl != null &&
                          widget.item.imageUrl!.isNotEmpty
                      ? Image.network(
                          widget.item.imageUrl!,
                          fit: BoxFit.cover,
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

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: isSmallScreen ? 14 : 16,
                        color: context.textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₦${widget.item.price.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: context.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: isSmallScreen ? 13 : 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Delete Button
              IconButton(
                onPressed: _isUpdating ? null : widget.onRemove,
                icon: Icon(
                  Icons.delete_outline,
                  color: _isUpdating
                      ? context.dividerColor
                      : context.errorColor,
                  size: isSmallScreen ? 22 : 24,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Quantity Controls and Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Quantity Controls
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: context.dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _isUpdating
                          ? null
                          : () {
                              HapticFeedback.lightImpact();
                              _handleQuantityChange(widget.item.quantity - 1);
                            },
                      icon: Icon(
                        Icons.remove,
                        size: 18,
                        color: _isUpdating
                            ? context.dividerColor
                            : context.textColor,
                      ),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: _isUpdating
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: context.primaryColor,
                              ),
                            )
                          : Text(
                              widget.item.quantity.toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: context.textColor,
                              ),
                            ),
                    ),
                    IconButton(
                      onPressed: _isUpdating
                          ? null
                          : () {
                              HapticFeedback.lightImpact();
                              _handleQuantityChange(widget.item.quantity + 1);
                            },
                      icon: Icon(
                        Icons.add,
                        size: 18,
                        color: _isUpdating
                            ? context.dividerColor
                            : context.primaryColor,
                      ),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Item Total
              Text(
                "₦${(widget.item.price * widget.item.quantity).toStringAsFixed(2)}",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: isSmallScreen ? 16 : 18,
                  color: context.textColor,
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
/// Orders Tab - Shows order history
/// =====================
class _OrdersTab extends StatefulWidget {
  final ApiClient apiClient;

  const _OrdersTab({required this.apiClient});

  @override
  State<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<_OrdersTab> {
  List<OrderResponse>? _orders;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await widget.apiClient.getUserOrders();

      if (!mounted) return;

      if (response.isSuccess && response.data != null) {
        setState(() {
          _orders = response.data;
          _isLoading = false;
        });
        debugPrint('✅ Orders loaded: ${_orders!.length} orders');
      } else {
        setState(() {
          _errorMessage = response.errorMessage ?? 'Failed to load orders';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Error loading orders: ${e.toString()}';
        _isLoading = false;
      });
      debugPrint('❌ Orders load error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: context.primaryColor),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: context.errorColor),
              const SizedBox(height: 16),
              Text(
                'Error Loading Orders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: context.subtitleColor),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadOrders,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_orders == null || _orders!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: context.subtitleColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              "No orders yet",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Your orders will appear here",
              style: TextStyle(color: context.subtitleColor),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: context.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders!.length,
        itemBuilder: (context, index) {
          final order = _orders![index];
          return _OrderCard(order: order);
        },
      ),
    );
  }
}

/// =====================
/// Order Card Widget
/// =====================
class _OrderCard extends StatelessWidget {
  final OrderResponse order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: ThemeUtils.createShadow(context, elevation: 1),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to order details
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderTrackingScreen(order: order),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Order #${order.id.substring(0, 8)}",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: isSmallScreen ? 14 : 16,
                        color: context.textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.status,
                      style: TextStyle(
                        color: _getStatusColor(order.status),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "${order.items.length} item(s)",
                style: TextStyle(
                  color: context.subtitleColor,
                  fontSize: isSmallScreen ? 12 : 13,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "₦${order.total.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: isSmallScreen ? 16 : 18,
                      color: context.primaryColor,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: context.subtitleColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return const Color(0xFFF59E0B);
      case 'CONFIRMED':
      case 'PREPARING':
        return const Color(0xFF3B82F6);
      case 'IN_TRANSIT':
      case 'DELIVERING':
        return const Color(0xFF8B5CF6);
      case 'DELIVERED':
      case 'COMPLETED':
        return const Color(0xFF10B981);
      case 'CANCELLED':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
