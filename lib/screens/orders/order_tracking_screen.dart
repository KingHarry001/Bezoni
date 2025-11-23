// File: lib/screens/order_tracking_screen.dart
import 'package:flutter/material.dart';
import 'package:bezoni/themes/theme_extensions.dart';
import 'package:bezoni/services/socket_service.dart';
import 'package:bezoni/core/api_models.dart';
import 'dart:async';

class OrderTrackingScreen extends StatefulWidget {
  final OrderResponse order;

  const OrderTrackingScreen({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final SocketService _socketService = SocketService();
  StreamSubscription? _locationSubscription;
  StreamSubscription? _statusSubscription;
  StreamSubscription? _connectionSubscription;

  Map<String, dynamic>? _currentLocation;
  String _orderStatus = 'PENDING';
  bool _isSocketConnected = false;
  int? _etaMinutes;
  String? _riderAddress;

  @override
  void initState() {
    super.initState();
    _orderStatus = widget.order.status;
    _initializeTracking();
  }

  @override
  void dispose() {
    _stopTracking();
    super.dispose();
  }

  Future<void> _initializeTracking() async {
    // Connect to socket
    await _socketService.connect();

    // Listen to connection status
    _connectionSubscription = _socketService.connectionStream.listen((connected) {
      if (mounted) {
        setState(() {
          _isSocketConnected = connected;
        });
      }

      if (connected) {
        // Start tracking when connected
        _socketService.trackOrder(widget.order.id);
      }
    });

    // Listen to location updates
    _locationSubscription = _socketService.locationStream.listen((location) {
      debugPrint('📍 Location updated: $location');
      if (mounted) {
        setState(() {
          _currentLocation = location;
          _etaMinutes = location['etaMinutes'] as int?;
          _riderAddress = location['address'] as String?;
          if (location['status'] != null) {
            _orderStatus = location['status'] as String;
          }
        });
      }
    });

    // Listen to status updates
    _statusSubscription = _socketService.orderStatusStream.listen((update) {
      debugPrint('📦 Status updated: $update');
      if (mounted) {
        setState(() {
          _orderStatus = update['status'] as String;
        });

        // Show delivery notification
        if (_orderStatus == 'DELIVERED') {
          _showDeliveryDialog();
        }
      }
    });

    // Start tracking
    if (_isSocketConnected) {
      _socketService.trackOrder(widget.order.id);
    }
  }

  void _stopTracking() {
    _socketService.stopTracking(widget.order.id);
    _locationSubscription?.cancel();
    _statusSubscription?.cancel();
    _connectionSubscription?.cancel();
  }

  void _showDeliveryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF4CAF50),
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Delivered!',
              style: TextStyle(
                color: context.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Your order has been delivered successfully!',
          style: TextStyle(color: context.subtitleColor, fontSize: 15),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to orders
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Track Order',
          style: TextStyle(color: context.textColor, fontWeight: FontWeight.w600),
        ),
        backgroundColor: context.surfaceColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Connection indicator
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _isSocketConnected ? const Color(0xFF4CAF50) : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Order Info Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order #${widget.order.id.substring(0, 8)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.textColor,
                        ),
                      ),
                      _buildStatusChip(_orderStatus),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.shopping_bag,
                    '${widget.order.items.length} items',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.attach_money,
                    '₦${widget.order.total.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.location_on,
                    widget.order.dropoffAddr,
                  ),
                ],
              ),
            ),

            // ETA Card
            if (_etaMinutes != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.primaryColor,
                      context.primaryColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.access_time,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estimated Arrival',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_etaMinutes minutes',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Rider Location
            if (_currentLocation != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.delivery_dining,
                            color: Color(0xFF2196F3),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Rider Location',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: context.textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_riderAddress != null)
                      Text(
                        _riderAddress!,
                        style: TextStyle(
                          color: context.subtitleColor,
                          fontSize: 14,
                        ),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Lat: ${_currentLocation!['latitude']?.toStringAsFixed(4) ?? 'N/A'}',
                          style: TextStyle(
                            color: context.subtitleColor,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Lng: ${_currentLocation!['longitude']?.toStringAsFixed(4) ?? 'N/A'}',
                          style: TextStyle(
                            color: context.subtitleColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Order Items
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Items',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...widget.order.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: context.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: item.imageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        item.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(
                                          Icons.fastfood,
                                          color: context.primaryColor,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.fastfood,
                                      color: context.primaryColor,
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: context.textColor,
                                    ),
                                  ),
                                  Text(
                                    'Qty: ${item.quantity}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.subtitleColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '₦${item.subtotal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: context.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toUpperCase()) {
      case 'PENDING':
        color = const Color(0xFFF59E0B);
        break;
      case 'CONFIRMED':
      case 'PREPARING':
        color = const Color(0xFF3B82F6);
        break;
      case 'IN_TRANSIT':
      case 'DELIVERING':
        color = const Color(0xFF8B5CF6);
        break;
      case 'DELIVERED':
        color = const Color(0xFF10B981);
        break;
      case 'CANCELLED':
        color = const Color(0xFFEF4444);
        break;
      default:
        color = const Color(0xFF6B7280);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: context.subtitleColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: context.textColor,
            ),
          ),
        ),
      ],
    );
  }
}