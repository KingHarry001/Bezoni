import 'package:flutter/material.dart';
import 'package:bezoni/components/cart_notifier.dart';

// Enhanced Order Model
class Order {
  final String id;
  final List<CartItem> items;
  final double total;
  final DateTime orderTime;
  final List<OrderStatus> statusHistory;
  OrderStage currentStage;
  final String customerName;
  final String address;

  Order({
    required this.id,
    required this.items,
    required this.total,
    required this.orderTime,
    required this.statusHistory,
    required this.currentStage,
    this.customerName = "David Oloyede",
    this.address = "53 Awolowo Road, Ikoyi Lagos...",
  });

  String get brandNames {
    final brands = items.map((item) => item.restaurant).toSet().toList();
    return brands.length == 1 ? brands.first : "${brands.length} Brands";
  }
}

enum OrderStage {
  paymentConfirmation,
  paymentReceived,
  preparingOrder,
  orderInTransit,
  orderCompleted
}

class OrderStatus {
  final OrderStage stage;
  final DateTime timestamp;
  final String message;
  final Duration estimatedDuration;

  OrderStatus({
    required this.stage,
    required this.timestamp,
    required this.message,
    required this.estimatedDuration,
  });
}

// Order Manager to handle multiple orders
class OrderManager extends ChangeNotifier {
  static final OrderManager _instance = OrderManager._internal();
  factory OrderManager() => _instance;
  OrderManager._internal();

  final List<Order> _orders = [];
  List<Order> get orders => _orders;

  void addOrder(Order order) {
    _orders.insert(0, order); // Add to beginning for latest first
    notifyListeners();
    _simulateOrderProgress(order);
  }

  void _simulateOrderProgress(Order order) {
    // Simulate order progression with realistic timing
    Future.delayed(const Duration(seconds: 2), () {
      if (order.currentStage == OrderStage.paymentConfirmation) {
        _updateOrderStage(order, OrderStage.paymentReceived, "Order started");
      }
    });

    Future.delayed(const Duration(seconds: 10), () {
      if (order.currentStage == OrderStage.paymentReceived) {
        _updateOrderStage(order, OrderStage.preparingOrder, "Your order will be ready soon");
      }
    });

    Future.delayed(const Duration(seconds: 20), () {
      if (order.currentStage == OrderStage.preparingOrder) {
        _updateOrderStage(order, OrderStage.orderInTransit, "Your order is on the way");
      }
    });
  }

  void _updateOrderStage(Order order, OrderStage newStage, String message) {
    order.currentStage = newStage;
    order.statusHistory.add(OrderStatus(
      stage: newStage,
      timestamp: DateTime.now(),
      message: message,
      estimatedDuration: _getEstimatedDuration(newStage),
    ));
    notifyListeners();
  }

  Duration _getEstimatedDuration(OrderStage stage) {
    switch (stage) {
      case OrderStage.paymentConfirmation:
        return const Duration(minutes: 2);
      case OrderStage.paymentReceived:
        return const Duration(minutes: 5);
      case OrderStage.preparingOrder:
        return const Duration(minutes: 10);
      case OrderStage.orderInTransit:
        return const Duration(minutes: 10);
      case OrderStage.orderCompleted:
        return Duration.zero;
    }
  }
}

/// =====================
/// Enhanced Cart Screen
/// =====================
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text("Cart"),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          bottom: const TabBar(
            labelColor: Color(0xFF10B981),
            unselectedLabelColor: Color(0xFF6B7280),
            indicatorColor: Color(0xFF10B981),
            tabs: [
              Tab(text: "Current Cart"),
              Tab(text: "Orders"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _CartTab(),
            _OrdersTab(),
          ],
        ),
      ),
    );
  }
}

class _CartTab extends StatelessWidget {
  const _CartTab();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CartNotifier(),
      builder: (context, _) {
        final cart = CartNotifier();
        
        return cart.items.isEmpty
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
                            onPressed: () => _processCheckout(context, cart),
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
              );
      },
    );
  }

  void _processCheckout(BuildContext context, CartNotifier cart) {
    final orderId = "BFA${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";
    
    // Create initial order with first status
    final order = Order(
      id: orderId,
      items: List.from(cart.items),
      total: cart.total,
      orderTime: DateTime.now(),
      currentStage: OrderStage.paymentConfirmation,
      statusHistory: [
        OrderStatus(
          stage: OrderStage.paymentConfirmation,
          timestamp: DateTime.now(),
          message: "Payment has been confirmed",
          estimatedDuration: const Duration(minutes: 2),
        ),
      ],
    );

    // Add order to manager
    OrderManager().addOrder(order);

    // Clear cart
    cart.clear();

    // Show success message and navigate to orders tab
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Order $orderId placed successfully!"),
        backgroundColor: const Color(0xFF10B981),
      ),
    );

    // Switch to orders tab
    DefaultTabController.of(context).animateTo(1);
  }
}

class _OrdersTab extends StatelessWidget {
  const _OrdersTab();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: OrderManager(),
      builder: (context, _) {
        final orders = OrderManager().orders;
        
        if (orders.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 80,
                  color: Color(0xFF6B7280),
                ),
                SizedBox(height: 16),
                Text(
                  "No orders yet",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Your orders will appear here",
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return _OrderCard(
              order: order,
              onTap: () => _showOrderDetails(context, order),
            );
          },
        );
      },
    );
  }

  void _showOrderDetails(BuildContext context, Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsScreen(order: order),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.onTap,
  });

  final Order order;
  final VoidCallback onTap;

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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Order ${order.id}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.currentStage).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusText(order.currentStage),
                      style: TextStyle(
                        color: _getStatusColor(order.currentStage),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                order.brandNames,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatOrderStatus(order),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color(0xFF6B7280),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStage stage) {
    switch (stage) {
      case OrderStage.paymentConfirmation:
      case OrderStage.paymentReceived:
        return const Color(0xFF10B981);
      case OrderStage.preparingOrder:
        return const Color(0xFFF59E0B);
      case OrderStage.orderInTransit:
        return const Color(0xFF3B82F6);
      case OrderStage.orderCompleted:
        return const Color(0xFF10B981);
    }
  }

  String _getStatusText(OrderStage stage) {
    switch (stage) {
      case OrderStage.paymentConfirmation:
        return "Payment Confirmed";
      case OrderStage.paymentReceived:
        return "Order Started";
      case OrderStage.preparingOrder:
        return "Preparing";
      case OrderStage.orderInTransit:
        return "In Transit";
      case OrderStage.orderCompleted:
        return "Completed";
    }
  }

  String _formatOrderStatus(Order order) {
    switch (order.currentStage) {
      case OrderStage.paymentConfirmation:
      case OrderStage.paymentReceived:
      case OrderStage.preparingOrder:
      case OrderStage.orderInTransit:
        return "Order In Transit";
      case OrderStage.orderCompleted:
        return "Order Completed";
    }
  }
}

// Order Details Screen
class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("Order ${order.id} (${order.brandNames})"),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => _contactSupport(context),
            child: const Text("Contact Support"),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: OrderManager(),
        builder: (context, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Order Header
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.brandNames,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Order Status",
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatOrderStatus(order.currentStage),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Order Timeline
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ...order.statusHistory.asMap().entries.map((entry) {
                        final index = entry.key;
                        final status = entry.value;
                        final isLast = index == order.statusHistory.length - 1;
                        final isCurrent = status.stage == order.currentStage;
                        final isPending = _getStageIndex(status.stage) > _getStageIndex(order.currentStage);
                        
                        return _TimelineItem(
                          status: status,
                          isActive: !isPending,
                          isCurrent: isCurrent,
                          isLast: isLast && _buildPendingStages().isEmpty,
                          showAllStages: order.statusHistory.length < 5,
                        );
                      }),
                      ..._buildPendingStages(),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Map Section (Placeholder)
                if (order.currentStage == OrderStage.orderInTransit)
                  Container(
                    height: 200,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: const Color(0xFFF3F4F6),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.map_outlined,
                                    size: 48,
                                    color: Color(0xFF6B7280),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Tracking Map",
                                    style: TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Color(0xFF10B981),
                                    child: Icon(
                                      Icons.motorcycle,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          order.customerName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          "Dispatch",
                                          style: const TextStyle(
                                            color: Color(0xFF6B7280),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.phone,
                                          size: 20,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.message,
                                          size: 20,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Order Info
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.note_add_outlined,
                            size: 20,
                            color: Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Add Order Note",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 20,
                            color: Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              order.address,
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          );
        },
      ),
    );
  }

  List<_TimelineItem> _buildPendingStages() {
    final allStages = [
      OrderStage.paymentConfirmation,
      OrderStage.paymentReceived,
      OrderStage.preparingOrder,
      OrderStage.orderInTransit,
      OrderStage.orderCompleted,
    ];
    
    final currentIndex = _getStageIndex(order.currentStage);
    final pendingStages = allStages.skip(currentIndex + 1);
    
    return pendingStages.map((stage) {
      return _TimelineItem(
        status: OrderStatus(
          stage: stage,
          timestamp: DateTime.now().add(const Duration(minutes: 10)),
          message: _getPendingMessage(stage),
          estimatedDuration: _getEstimatedDuration(stage),
        ),
        isActive: false,
        isCurrent: false,
        isLast: stage == OrderStage.orderCompleted,
        showAllStages: true,
      );
    }).toList();
  }

  String _getPendingMessage(OrderStage stage) {
    switch (stage) {
      case OrderStage.paymentConfirmation:
        return "Payment has been confirmed";
      case OrderStage.paymentReceived:
        return "Order started";
      case OrderStage.preparingOrder:
        return "Your order will be ready soon";
      case OrderStage.orderInTransit:
        return "Your order is on the way";
      case OrderStage.orderCompleted:
        return "Your order has been completed";
    }
  }

  Duration _getEstimatedDuration(OrderStage stage) {
    switch (stage) {
      case OrderStage.paymentConfirmation:
        return const Duration(minutes: 2);
      case OrderStage.paymentReceived:
        return const Duration(minutes: 5);
      case OrderStage.preparingOrder:
        return const Duration(minutes: 10);
      case OrderStage.orderInTransit:
        return const Duration(minutes: 10);
      case OrderStage.orderCompleted:
        return Duration.zero;
    }
  }

  int _getStageIndex(OrderStage stage) {
    switch (stage) {
      case OrderStage.paymentConfirmation:
        return 0;
      case OrderStage.paymentReceived:
        return 1;
      case OrderStage.preparingOrder:
        return 2;
      case OrderStage.orderInTransit:
        return 3;
      case OrderStage.orderCompleted:
        return 4;
    }
  }

  String _formatOrderStatus(OrderStage stage) {
    switch (stage) {
      case OrderStage.paymentConfirmation:
      case OrderStage.paymentReceived:
      case OrderStage.preparingOrder:
      case OrderStage.orderInTransit:
        return "Order In Transit";
      case OrderStage.orderCompleted:
        return "Order Completed";
    }
  }

  void _contactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Contact Support"),
        content: const Text("How would you like to contact support?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Call"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Message"),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatefulWidget {
  const _TimelineItem({
    required this.status,
    required this.isActive,
    required this.isCurrent,
    required this.isLast,
    required this.showAllStages,
  });

  final OrderStatus status;
  final bool isActive;
  final bool isCurrent;
  final bool isLast;
  final bool showAllStages;

  @override
  State<_TimelineItem> createState() => _TimelineItemState();
}

class _TimelineItemState extends State<_TimelineItem>
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
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    if (widget.isActive) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_TimelineItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward();
    }
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
          opacity: widget.isActive ? _fadeAnimation : const AlwaysStoppedAnimation(0.5),
          child: ScaleTransition(
            scale: widget.isCurrent ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.isActive 
                              ? const Color(0xFF10B981) 
                              : const Color(0xFFE5E7EB),
                          border: widget.isCurrent
                              ? Border.all(color: const Color(0xFF10B981), width: 3)
                              : null,
                        ),
                        child: widget.isActive
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12,
                              )
                            : null,
                      ),
                      if (!widget.isLast)
                        Container(
                          width: 2,
                          height: 40,
                          color: widget.isActive 
                              ? const Color(0xFF10B981) 
                              : const Color(0xFFE5E7EB),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _getStageTitle(widget.status.stage),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: widget.isActive 
                                    ? Colors.black 
                                    : const Color(0xFF9CA3AF),
                              ),
                            ),
                            if (widget.isActive)
                              Text(
                                _formatTime(widget.status.timestamp),
                                style: const TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.status.message,
                          style: TextStyle(
                            color: widget.isActive 
                                ? const Color(0xFF6B7280) 
                                : const Color(0xFF9CA3AF),
                            fontSize: 14,
                          ),
                        ),
                        if (widget.isActive)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _formatDuration(widget.status.estimatedDuration),
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getStageTitle(OrderStage stage) {
    switch (stage) {
      case OrderStage.paymentConfirmation:
        return "Payment Confirmation";
      case OrderStage.paymentReceived:
        return "Payment Received";
      case OrderStage.preparingOrder:
        return "Preparing your Order";
      case OrderStage.orderInTransit:
        return "Order in Transit";
      case OrderStage.orderCompleted:
        return "Order Completed";
    }
  }

  String _formatTime(DateTime time) {
    return "${time.hour}:${time.minute.toString().padLeft(2, '0')}am";
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes == 0) return "";
    return "${duration.inMinutes}mins";
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