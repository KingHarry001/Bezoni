import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bezoni/components/cart_notifier.dart';
import 'package:bezoni/services/theme_service.dart';

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
  orderCompleted,
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
    _orders.insert(0, order);
    notifyListeners();
    _simulateOrderProgress(order);
  }

  void _simulateOrderProgress(Order order) {
    Future.delayed(const Duration(seconds: 2), () {
      if (order.currentStage == OrderStage.paymentConfirmation) {
        _updateOrderStage(order, OrderStage.paymentReceived, "Order started");
      }
    });

    Future.delayed(const Duration(seconds: 10), () {
      if (order.currentStage == OrderStage.paymentReceived) {
        _updateOrderStage(
          order,
          OrderStage.preparingOrder,
          "Your order will be ready soon",
        );
      }
    });

    Future.delayed(const Duration(seconds: 20), () {
      if (order.currentStage == OrderStage.preparingOrder) {
        _updateOrderStage(
          order,
          OrderStage.orderInTransit,
          "Your order is on the way",
        );
      }
    });
  }

  void _updateOrderStage(Order order, OrderStage newStage, String message) {
    order.currentStage = newStage;
    order.statusHistory.add(
      OrderStatus(
        stage: newStage,
        timestamp: DateTime.now(),
        message: message,
        estimatedDuration: _getEstimatedDuration(newStage),
      ),
    );
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
/// Enhanced Cart Screen with Theme Support
/// =====================
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: const Text("Cart"),
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Theme.of(context).colorScheme.surface,bottom: TabBar(
            labelColor: const Color(0xFF10B981),
            unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            indicatorColor: const Color(0xFF10B981),
            tabs: const [
              Tab(text: "Current Cart"),
              Tab(text: "Orders"),
            ],
          ),
        ),
        body: const TabBarView(children: [_CartTab(), _OrdersTab()]),
      ),
    );
  }

  IconData _getThemeIcon(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return Icons.light_mode;
      case AppTheme.dark:
        return Icons.dark_mode;
      case AppTheme.system:
        return Icons.auto_mode;
    }
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
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Your cart is empty",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Add items to get started",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
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
                    color: Theme.of(context).colorScheme.surface,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total:",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
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
    final orderId =
        "BFA${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";

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

    OrderManager().addOrder(order);
    cart.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Order $orderId placed successfully!"),
        backgroundColor: const Color(0xFF10B981),
      ),
    );

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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 80,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  "No orders yet",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Your orders will appear here",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
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
      MaterialPageRoute(builder: (context) => OrderDetailsScreen(order: order)),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onTap});

  final Order order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
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
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
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
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatOrderStatus(order),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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

// Order Details Screen with Back Button
class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Order Details",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.share,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Share feature coming soon!")),
              );
            },
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
                  color: Theme.of(context).colorScheme.surface,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.brandNames,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Order Status",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatOrderStatus(order.currentStage),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
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
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ...order.statusHistory.asMap().entries.map((entry) {
                        final index = entry.key;
                        final status = entry.value;
                        final isLast = index == order.statusHistory.length - 1;
                        final isCurrent = status.stage == order.currentStage;
                        final isPending =
                            _getStageIndex(status.stage) >
                            _getStageIndex(order.currentStage);

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

                // Map Section
                if (order.currentStage == OrderStage.orderInTransit)
                  Container(
                    height: 200,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.map_outlined,
                                    size: 48,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Tracking Map",
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).shadowColor.withOpacity(0.2),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          order.customerName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                        Text(
                                          "Dispatch",
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                                        icon: Icon(
                                          Icons.phone,
                                          size: 20,
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.message,
                                          size: 20,
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.note_add_outlined,
                            size: 20,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Add Order Note",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 20,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              order.address,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
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
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

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
          opacity: widget.isActive
              ? _fadeAnimation
              : const AlwaysStoppedAnimation(0.5),
          child: ScaleTransition(
            scale: widget.isCurrent
                ? _scaleAnimation
                : const AlwaysStoppedAnimation(1.0),
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
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                          border: widget.isCurrent
                              ? Border.all(
                                  color: const Color(0xFF10B981),
                                  width: 3,
                                )
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
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
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
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                              ),
                            ),
                            if (widget.isActive)
                              Text(
                                _formatTime(widget.status.timestamp),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                            fontSize: 14,
                          ),
                        ),
                        if (widget.isActive)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _formatDuration(widget.status.estimatedDuration),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
  const _CartItemTile({required this.item, required this.onRemove});

  final CartItem item;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
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
            child: const Icon(Icons.fastfood, color: Color(0xFF10B981)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  "From ${item.restaurant}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
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