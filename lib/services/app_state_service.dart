// File: lib/services/app_state_service.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bezoni/core/api_client.dart';
import 'package:bezoni/core/api_models.dart';

/// Global app state manager that keeps everything in sync
class AppStateService extends ChangeNotifier {
  static final AppStateService _instance = AppStateService._internal();
  factory AppStateService() => _instance;
  AppStateService._internal();

  final ApiClient _apiClient = ApiClient();

  // State
  UserProfile? _user;
  UserPreferences? _preferences;
  List<OrderResponse>? _activeOrders;
  WalletBalance? _walletBalance;
  bool _isInitialized = false;

  // Getters
  UserProfile? get user => _user;
  UserPreferences? get preferences => _preferences;
  List<OrderResponse>? get activeOrders => _activeOrders;
  WalletBalance? get walletBalance => _walletBalance;
  bool get isInitialized => _isInitialized;

  String get currentAddress {
    return _preferences?.address ??
           _user?.address ??
           'Set your delivery address';
  }

  String get userName => _user?.name ?? 'User';
  String get userEmail => _user?.email ?? '';
  bool get isVerified => _user?.emailVerified ?? false;

  /// Initialize app state - call this on app start
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('✅ AppState already initialized');
      return;
    }

    debugPrint('🔄 Initializing AppState...');

    await _apiClient.initialize();

    await Future.wait([
      _loadUser(),
      _loadPreferences(),
      _loadActiveOrders(),
      _loadWalletBalance(),
    ], eagerError: false);

    _isInitialized = true;
    notifyListeners();
    debugPrint('✅ AppState initialized');
  }

  /// Load user profile
  Future<void> _loadUser() async {
    try {
      final response = await _apiClient.getProfile();
      if (response.isSuccess && response.data != null) {
        _user = response.data;
        debugPrint('✅ User loaded: ${_user!.name}');
      }
    } catch (e) {
      debugPrint('❌ Error loading user: $e');
    }
  }

  /// Load user preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final address = prefs.getString('user_address');
      final foodType = prefs.getString('user_food_type');
      final allergiesJson = prefs.getString('user_allergies');

      if (address != null) {
        _preferences = UserPreferences(
          userId: _user?.id ?? '',
          address: address,
          foodType: foodType,
          allergies: allergiesJson != null
              ? List<String>.from(allergiesJson.split(','))
              : [],
        );
        debugPrint('✅ Preferences loaded: $address');
      }
    } catch (e) {
      debugPrint('❌ Error loading preferences: $e');
    }
  }

  /// Load active orders
  Future<void> _loadActiveOrders() async {
    try {
      final response = await _apiClient.getUserOrders();
      if (response.isSuccess && response.data != null) {
        _activeOrders = response.data!
            .where((order) => order.status != 'DELIVERED' && order.status != 'CANCELLED')
            .toList();
        debugPrint('✅ Active orders loaded: ${_activeOrders!.length}');
      }
    } catch (e) {
      debugPrint('❌ Error loading orders: $e');
    }
  }

  /// Load wallet balance
  Future<void> _loadWalletBalance() async {
    try {
      final response = await _apiClient.getWalletBalance();
      if (response.isSuccess && response.data != null) {
        _walletBalance = response.data;
        debugPrint('✅ Wallet loaded: ₦${_walletBalance!.balance}');
      }
    } catch (e) {
      debugPrint('❌ Error loading wallet: $e');
    }
  }

  /// Save preferences locally and notify listeners
  Future<void> savePreferences(UserPreferences prefs) async {
    try {
      final sharedPrefs = await SharedPreferences.getInstance();
      await sharedPrefs.setString('user_address', prefs.address);
      await sharedPrefs.setBool('has_preferences', true);

      if (prefs.foodType != null) {
        await sharedPrefs.setString('user_food_type', prefs.foodType!);
      }

      if (prefs.allergies.isNotEmpty) {
        await sharedPrefs.setString(
          'user_allergies',
          prefs.allergies.join(','),
        );
      }

      _preferences = prefs;

      // TODO: Send to backend when endpoint is ready
      // await _apiClient.saveUserPreferences(prefs);

      notifyListeners();
      debugPrint('✅ Preferences saved: ${prefs.address}');
    } catch (e) {
      debugPrint('❌ Error saving preferences: $e');
    }
  }

  /// Update address and sync everywhere
  Future<void> updateAddress(String address) async {
    try {
      if (_preferences != null) {
        _preferences = UserPreferences(
          userId: _preferences!.userId,
          address: address,
          foodType: _preferences!.foodType,
          allergies: _preferences!.allergies,
        );
      } else {
        _preferences = UserPreferences(
          userId: _user?.id ?? '',
          address: address,
          foodType: null,
          allergies: [],
        );
      }

      await savePreferences(_preferences!);
      notifyListeners();
      debugPrint('✅ Address updated: $address');
    } catch (e) {
      debugPrint('❌ Error updating address: $e');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(UserProfile profile) async {
    _user = profile;
    notifyListeners();
    debugPrint('✅ User profile updated');
  }

  /// Handle order status update (from notifications/websocket)
  void onOrderStatusUpdate(String orderId, String status) {
    if (_activeOrders != null) {
      final index = _activeOrders!.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        // Create updated order with new status
        final order = _activeOrders![index];
        _activeOrders![index] = OrderResponse(
          id: order.id,
          status: status,
          total: order.total,
          paymentMethod: order.paymentMethod,
          dropoffAddr: order.dropoffAddr,
          items: order.items,
          createdAt: order.createdAt,
          vendorId: order.vendorId,
          riderId: order.riderId,
        );

        notifyListeners();
        debugPrint('✅ Order $orderId status updated to $status');
      }
    }
  }

  /// Add new order to active orders
  void addOrder(OrderResponse order) {
    _activeOrders ??= [];
    _activeOrders!.insert(0, order);
    notifyListeners();
    debugPrint('✅ Order ${order.id} added');
  }

  /// Refresh all data
  Future<void> refresh() async {
    debugPrint('🔄 Refreshing app state...');
    await Future.wait([
      _loadUser(),
      _loadPreferences(),
      _loadActiveOrders(),
      _loadWalletBalance(),
    ], eagerError: false);
    notifyListeners();
    debugPrint('✅ App state refreshed');
  }

  /// Update wallet balance
  void updateWalletBalance(double newBalance) {
    if (_walletBalance != null) {
      _walletBalance = WalletBalance(
        balance: newBalance,
        currency: _walletBalance!.currency,
      );
      notifyListeners();
      debugPrint('✅ Wallet balance updated: ₦$newBalance');
    }
  }

  /// Clear all state (on logout)
  Future<void> clear() async {
    _user = null;
    _preferences = null;
    _activeOrders = null;
    _walletBalance = null;
    _isInitialized = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_address');
    await prefs.remove('user_food_type');
    await prefs.remove('user_allergies');
    await prefs.remove('has_preferences');

    notifyListeners();
    debugPrint('✅ App state cleared');
  }
}

/// User preferences model
class UserPreferences {
  final String userId;
  final String address;
  final String? foodType;
  final List<String> allergies;

  UserPreferences({
    required this.userId,
    required this.address,
    this.foodType,
    required this.allergies,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'address': address,
      'foodType': foodType,
      'allergies': allergies,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      userId: json['userId'] as String,
      address: json['address'] as String,
      foodType: json['foodType'] as String?,
      allergies: List<String>.from(json['allergies'] ?? []),
    );
  }
}