// File: lib/services/socket_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';

/// Socket.IO Service for real-time order tracking
/// Based on: Delivery_App_SocketIO_Guide_Frontend.pdf
class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;
  String? _authToken;
  
  // Stream controllers for real-time updates
  final _locationController = StreamController<Map<String, dynamic>>.broadcast();
  final _orderStatusController = StreamController<Map<String, dynamic>>.broadcast();
  final _availableOrdersController = StreamController<List<dynamic>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();
  
  // Getters for streams
  Stream<Map<String, dynamic>> get locationStream => _locationController.stream;
  Stream<Map<String, dynamic>> get orderStatusStream => _orderStatusController.stream;
  Stream<List<dynamic>> get availableOrdersStream => _availableOrdersController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  
  bool get isConnected => _isConnected;

  /// Initialize and connect to Socket.IO server
  Future<void> connect() async {
    if (_socket != null && _isConnected) {
      debugPrint('✅ Socket already connected');
      return;
    }

    try {
      // Get auth token
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString('auth_token');

      if (_authToken == null || _authToken!.isEmpty) {
        debugPrint('❌ No auth token found, cannot connect socket');
        return;
      }

      debugPrint('🔌 Connecting to Socket.IO server...');
      debugPrint('   Token: ${_authToken!.substring(0, 20)}...');

      // Create socket with configuration
      _socket = IO.io(
        'https://bezoni.onrender.com',
        IO.OptionBuilder()
            .setTransports(['websocket']) // Use websocket for Flutter
            .disableAutoConnect() // Manual connection control
            .setAuth({'token': _authToken}) // JWT authentication
            .setExtraHeaders({'Authorization': 'Bearer $_authToken'})
            .enableReconnection()
            .setReconnectionAttempts(5)
            .setReconnectionDelay(2000)
            .setTimeout(20000)
            .build(),
      );

      _setupEventListeners();
      _socket!.connect();
    } catch (e) {
      debugPrint('❌ Socket connection error: $e');
      _isConnected = false;
      _connectionController.add(false);
    }
  }

  /// Setup all event listeners
  void _setupEventListeners() {
    if (_socket == null) return;

    // Connection events
    _socket!.onConnect((_) {
      debugPrint('✅ Socket connected');
      _isConnected = true;
      _connectionController.add(true);
    });

    _socket!.onDisconnect((_) {
      debugPrint('⚠️ Socket disconnected');
      _isConnected = false;
      _connectionController.add(false);
    });

    _socket!.onConnectError((error) {
      debugPrint('❌ Connection error: $error');
      _isConnected = false;
      _connectionController.add(false);
    });

    _socket!.onError((error) {
      debugPrint('❌ Socket error: $error');
    });

    // Customer tracking events
    _socket!.on('receive-location', (data) {
      debugPrint('📍 Location update: $data');
      _locationController.add(data as Map<String, dynamic>);
    });

    _socket!.on('orderDelivered', (data) {
      debugPrint('✅ Order delivered: $data');
      _orderStatusController.add({
        'status': 'DELIVERED',
        'data': data,
      });
    });

    _socket!.on('parcelDelivered', (data) {
      debugPrint('✅ Parcel delivered: $data');
      _orderStatusController.add({
        'status': 'DELIVERED',
        'data': data,
      });
    });

    // Rider events (if user is rider)
    _socket!.on('availableOrders', (data) {
      debugPrint('📦 Available orders: $data');
      if (data is List) {
        _availableOrdersController.add(data);
      }
    });

    _socket!.on('availableParcels', (data) {
      debugPrint('📦 Available parcels: $data');
      if (data is List) {
        _availableOrdersController.add(data);
      }
    });

    _socket!.on('orderAssigned', (data) {
      debugPrint('✅ Order assigned: $data');
      _orderStatusController.add({
        'status': 'ASSIGNED',
        'data': data,
      });
    });

    _socket!.on('orderRejected', (data) {
      debugPrint('❌ Order rejected: $data');
      _orderStatusController.add({
        'status': 'REJECTED',
        'data': data,
      });
    });

    // Payment events
    _socket!.on('paymentProcessed', (data) {
      debugPrint('💰 Payment processed: $data');
      _orderStatusController.add({
        'status': 'PAYMENT_PROCESSED',
        'data': data,
      });
    });

    // Error events
    _socket!.on('orderError', (error) {
      debugPrint('❌ Order error: $error');
      _orderStatusController.add({
        'status': 'ERROR',
        'error': error,
      });
    });

    _socket!.on('parcelError', (error) {
      debugPrint('❌ Parcel error: $error');
    });

    _socket!.on('deliveryError', (error) {
      debugPrint('❌ Delivery error: $error');
    });
  }

  // ============================================================================
  // CUSTOMER METHODS
  // ============================================================================

  /// Track an order in real-time
  void trackOrder(String orderId) {
    if (!_isConnected) {
      debugPrint('⚠️ Socket not connected, cannot track order');
      return;
    }

    debugPrint('🔍 Tracking order: $orderId');
    _socket!.emit('track-order', {'orderId': orderId});
  }

  /// Stop tracking an order
  void stopTracking(String orderId) {
    if (!_isConnected) return;

    debugPrint('⏹️ Stop tracking order: $orderId');
    _socket!.emit('stop-tracking', {'orderId': orderId});
  }

  /// Confirm delivery and process payment
  void confirmDelivery({
    String? orderId,
    String? parcelId,
    required String token,
    required String paymentMethod,
  }) {
    if (!_isConnected) {
      debugPrint('⚠️ Socket not connected, cannot confirm delivery');
      return;
    }

    debugPrint('✅ Confirming delivery...');
    _socket!.emit('confirmDelivery', {
      if (orderId != null) 'orderId': orderId,
      if (parcelId != null) 'parcelId': parcelId,
      'token': token,
      'paymentMethod': paymentMethod,
    });
  }

  // ============================================================================
  // RIDER METHODS (For future rider app implementation)
  // ============================================================================

  /// Mark rider as online
  void goOnline(String riderId, {double? lat, double? lng}) {
    if (!_isConnected) return;

    debugPrint('🟢 Going online: $riderId');
    _socket!.emit('riderOnline', {
      'riderId': riderId,
      if (lat != null && lng != null)
        'location': {'lat': lat, 'lng': lng},
    });
  }

  /// Mark rider as offline
  void goOffline(String riderId) {
    if (!_isConnected) return;

    debugPrint('🔴 Going offline: $riderId');
    _socket!.emit('riderOffline', {'riderId': riderId});
  }

  /// Accept an order (rider)
  void acceptOrder(String orderId) {
    if (!_isConnected) return;

    debugPrint('✅ Accepting order: $orderId');
    _socket!.emit('acceptOrder', {'orderId': orderId});
  }

  /// Reject an order (rider)
  void rejectOrder(String orderId) {
    if (!_isConnected) return;

    debugPrint('❌ Rejecting order: $orderId');
    _socket!.emit('rejectOrder', {'orderId': orderId});
  }

  /// Start location tracking (rider)
  void startTracking(String address) {
    if (!_isConnected) return;

    debugPrint('📍 Starting location tracking');
    _socket!.emit('send-location', {'address': address});
  }

  /// Update rider location
  void updateLocation(double latitude, double longitude) {
    if (!_isConnected) return;

    // Rate limit: max 5 updates per minute
    _socket!.emit('update-location', {
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  /// Stop location tracking (rider)
  void stopLocationTracking(String orderId) {
    if (!_isConnected) return;

    debugPrint('⏹️ Stopping location tracking');
    _socket!.emit('stop-tracking-driver', {'orderId': orderId});
  }

  /// Disconnect from socket
  void disconnect() {
    if (_socket == null) return;

    debugPrint('🔌 Disconnecting socket...');
    _socket!.disconnect();
    _socket!.dispose();
    _socket = null;
    _isConnected = false;
    _connectionController.add(false);
  }

  /// Dispose all resources
  void dispose() {
    disconnect();
    _locationController.close();
    _orderStatusController.close();
    _availableOrdersController.close();
    _connectionController.close();
  }
}