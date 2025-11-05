import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized API Client for Bezoni User App
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  // Base URL - Update this with your actual API URL
  static const String _baseUrl = 'https://bezoni.onrender.com';
  
  String? _authToken;
  
  // Initialize auth token from storage
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
  }
  
  // Save auth token to storage
  Future<void> _saveToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
  
  // Clear auth token
  Future<void> clearToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
  
  // Get headers with auth token
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }
  
  // Get headers for multipart requests
  Map<String, String> get _multipartHeaders {
    final headers = <String, String>{};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }
  
  // Generic GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? parser,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint').replace(
        queryParameters: queryParams?.map((k, v) => MapEntry(k, v.toString())),
      );
      
      final response = await http.get(uri, headers: _headers);
      return _handleResponse<T>(response, parser);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  // Generic POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? parser,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final response = await http.post(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      
      return _handleResponse<T>(response, parser);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  // Generic PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? parser,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final response = await http.put(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      
      return _handleResponse<T>(response, parser);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  // Generic PATCH request
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? parser,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final response = await http.patch(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      
      return _handleResponse<T>(response, parser);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  // Generic DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(dynamic)? parser,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final response = await http.delete(uri, headers: _headers);
      
      return _handleResponse<T>(response, parser);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  // Multipart POST request for file uploads
  Future<ApiResponse<T>> postMultipart<T>(
    String endpoint, {
    required Map<String, String> fields,
    Map<String, File>? files,
    T Function(dynamic)? parser,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final request = http.MultipartRequest('POST', uri);
      
      request.headers.addAll(_multipartHeaders);
      request.fields.addAll(fields);
      
      if (files != null) {
        for (var entry in files.entries) {
          request.files.add(
            await http.MultipartFile.fromPath(entry.key, entry.value.path),
          );
        }
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse<T>(response, parser);
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  // Handle API response
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? parser,
  ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      
      if (parser != null) {
        return ApiResponse.success(parser(data));
      } else {
        return ApiResponse.success(data as T);
      }
    } else {
      final errorData = jsonDecode(response.body);
      final message = errorData['message'] ?? 'An error occurred';
      return ApiResponse.error(message);
    }
  }
  
  // ============================================================================
  // AUTH ENDPOINTS
  // ============================================================================
  
  Future<ApiResponse<AuthResponse>> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String address,
  }) async {
    final response = await post<AuthResponse>(
      '/auth/register',
      body: {
        'name': name,
        'phone': phone,
        'email': email,
        'password': password,
        'role': 'USER',
        'address': address,
      },
      parser: (data) => AuthResponse.fromJson(data),
    );
    
    if (response.isSuccess && response.data?.token != null) {
      await _saveToken(response.data!.token!);
    }
    
    return response;
  }
  
  Future<ApiResponse<AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    final response = await post<AuthResponse>(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
      parser: (data) => AuthResponse.fromJson(data),
    );
    
    if (response.isSuccess && response.data?.token != null) {
      await _saveToken(response.data!.token!);
    }
    
    return response;
  }
  
  Future<ApiResponse<void>> logout() async {
    final response = await post('/auth/logout');
    await clearToken();
    return response;
  }
  
  Future<ApiResponse<AuthResponse>> refreshToken() async {
    return post<AuthResponse>(
      '/auth/refresh',
      parser: (data) => AuthResponse.fromJson(data),
    );
  }
  
  Future<ApiResponse<UserProfile>> getProfile() async {
    return post<UserProfile>(
      '/auth/me',
      parser: (data) => UserProfile.fromJson(data),
    );
  }
  
  Future<ApiResponse<UserProfile>> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    return put<UserProfile>(
      '/auth/update-profile',
      body: {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
      },
      parser: (data) => UserProfile.fromJson(data),
    );
  }
  
  Future<ApiResponse<void>> forgotPassword(String email) async {
    return post(
      '/auth/forgot-password',
      body: {'email': email},
    );
  }
  
  Future<ApiResponse<void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    return post(
      '/auth/reset-password',
      body: {
        'token': token,
        'newPassword': newPassword,
      },
    );
  }
  
  Future<ApiResponse<void>> sendVerificationEmail() async {
    return post('/auth/send-verification');
  }
  
  Future<ApiResponse<void>> verifyEmail(String token) async {
    return post(
      '/auth/verify-email',
      body: {'token': token},
    );
  }
  
  // ============================================================================
  // CART ENDPOINTS
  // ============================================================================
  
  Future<ApiResponse<CartResponse>> getCart() async {
    return get<CartResponse>(
      '/order/cart',
      parser: (data) => CartResponse.fromJson(data),
    );
  }
  
  Future<ApiResponse<CartResponse>> addToCart({
    required String sku,
    required int quantity,
  }) async {
    return post<CartResponse>(
      '/order/cart/add',
      body: {
        'sku': sku,
        'quantity': quantity,
      },
      parser: (data) => CartResponse.fromJson(data),
    );
  }
  
  Future<ApiResponse<CartResponse>> removeFromCart(String sku) async {
    return post<CartResponse>(
      '/order/cart/remove',
      body: {'sku': sku},
      parser: (data) => CartResponse.fromJson(data),
    );
  }
  
  Future<ApiResponse<CartResponse>> reduceCartQuantity({
    required String sku,
    required int quantity,
  }) async {
    return post<CartResponse>(
      '/order/cart/reduce-quantity',
      body: {
        'sku': sku,
        'quantity': quantity,
      },
      parser: (data) => CartResponse.fromJson(data),
    );
  }
  
  // ============================================================================
  // ORDER ENDPOINTS
  // ============================================================================
  
  Future<ApiResponse<OrderPreview>> previewOrder() async {
    return post<OrderPreview>(
      '/order/previeworder',
      parser: (data) => OrderPreview.fromJson(data),
    );
  }
  
  Future<ApiResponse<OrderResponse>> createOrder({
    required String dropoffAddr,
    required String paymentMethod,
  }) async {
    return post<OrderResponse>(
      '/order/create',
      body: {
        'dropoffAddr': dropoffAddr,
        'paymentMethod': paymentMethod,
      },
      parser: (data) => OrderResponse.fromJson(data),
    );
  }
  
  Future<ApiResponse<List<OrderResponse>>> getUserOrders() async {
    return get<List<OrderResponse>>(
      '/order/user/order',
      parser: (data) {
        final list = data as List;
        return list.map((e) => OrderResponse.fromJson(e)).toList();
      },
    );
  }
  
  Future<ApiResponse<OrderResponse>> updatePaymentMethod({
    required String orderId,
    required String newPaymentMethod,
  }) async {
    return patch<OrderResponse>(
      '/order/update/paymentmethod/$orderId',
      body: {'newPaymentMethod': newPaymentMethod},
      parser: (data) => OrderResponse.fromJson(data),
    );
  }
  
  Future<ApiResponse<dynamic>> processPayment(String orderId) async {
    return post('/order/product/payment/$orderId');
  }
  
  // ============================================================================
  // PRODUCT ENDPOINTS
  // ============================================================================
  
  Future<ApiResponse<List<Product>>> getProducts({
    String? search,
  }) async {
    return get<List<Product>>(
      '/order/products',
      queryParams: search != null ? {'search': search} : null,
      parser: (data) {
        final list = data as List;
        return list.map((e) => Product.fromJson(e)).toList();
      },
    );
  }
  
  Future<ApiResponse<List<Product>>> getFoods({
    String? search,
  }) async {
    return get<List<Product>>(
      '/product/foods',
      queryParams: search != null ? {'search': search} : null,
      parser: (data) {
        final list = data as List;
        return list.map((e) => Product.fromJson(e)).toList();
      },
    );
  }
  
  Future<ApiResponse<Product>> getFoodById(String id) async {
    return get<Product>(
      '/product/foods/$id',
      parser: (data) => Product.fromJson(data),
    );
  }
  
  // ============================================================================
  // VENDOR ENDPOINTS
  // ============================================================================
  
  Future<ApiResponse<List<Vendor>>> getAvailableVendors({
    String? search,
  }) async {
    return get<List<Vendor>>(
      '/vendor/availablevendors',
      queryParams: search != null ? {'search': search} : null,
      parser: (data) {
        final list = data as List;
        return list.map((e) => Vendor.fromJson(e)).toList();
      },
    );
  }
  
  Future<ApiResponse<Vendor>> getVendorById(String id) async {
    return get<Vendor>(
      '/vendor/byId/$id',
      parser: (data) => Vendor.fromJson(data),
    );
  }
  
  // ============================================================================
  // WALLET ENDPOINTS
  // ============================================================================
  
  Future<ApiResponse<WalletBalance>> getWalletBalance() async {
    return get<WalletBalance>(
      '/wallet/balance',
      parser: (data) => WalletBalance.fromJson(data),
    );
  }
  
  // ============================================================================
  // NOTIFICATION ENDPOINTS
  // ============================================================================
  
  Future<ApiResponse<List<NotificationModel>>> getNotifications() async {
    return post<List<NotificationModel>>(
      '/notification/details',
      parser: (data) {
        final list = data as List;
        return list.map((e) => NotificationModel.fromJson(e)).toList();
      },
    );
  }
  
  // ============================================================================
  // PARCEL ENDPOINTS
  // ============================================================================
  
  Future<ApiResponse<ParcelResponse>> createParcel({
    required ParcelRequest parcelData,
  }) async {
    return post<ParcelResponse>(
      '/parcel',
      body: parcelData.toJson(),
      parser: (data) => ParcelResponse.fromJson(data),
    );
  }
  
  Future<ApiResponse<dynamic>> processParcelPayment({
    required String parcelId,
    required String paymentMethod,
  }) async {
    return post(
      '/parcel/payment/$parcelId',
      body: {'paymentMethod': paymentMethod},
    );
  }
}

// ============================================================================
// API RESPONSE MODEL
// ============================================================================

class ApiResponse<T> {
  final bool isSuccess;
  final T? data;
  final String? errorMessage;
  
  ApiResponse._({
    required this.isSuccess,
    this.data,
    this.errorMessage,
  });
  
  factory ApiResponse.success(T data) {
    return ApiResponse._(
      isSuccess: true,
      data: data,
    );
  }
  
  factory ApiResponse.error(String message) {
    return ApiResponse._(
      isSuccess: false,
      errorMessage: message,
    );
  }
}

// ============================================================================
// DATA MODELS
// ============================================================================

class AuthResponse {
  final String? token;
  final UserProfile? user;
  final String? message;
  
  AuthResponse({this.token, this.user, this.message});
  
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      user: json['user'] != null ? UserProfile.fromJson(json['user']) : null,
      message: json['message'],
    );
  }
}

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String role;
  final bool emailVerified;
  
  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    required this.role,
    required this.emailVerified,
  });
  
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      role: json['role'],
      emailVerified: json['emailVerified'] ?? false,
    );
  }
}

class Product {
  final String id;
  final String sku;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final List<String>? ingredients;
  final int stock;
  final String vendorId;
  
  Product({
    required this.id,
    required this.sku,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.ingredients,
    required this.stock,
    required this.vendorId,
  });
  
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      sku: json['sku'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'],
      ingredients: json['ingredients'] != null 
          ? List<String>.from(json['ingredients']) 
          : null,
      stock: json['stock'],
      vendorId: json['vendorId'],
    );
  }
}

class Vendor {
  final String id;
  final String name;
  final String? city;
  final String address;
  final String type;
  
  Vendor({
    required this.id,
    required this.name,
    this.city,
    required this.address,
    required this.type,
  });
  
  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'],
      name: json['name'],
      city: json['city'],
      address: json['address'],
      type: json['type'],
    );
  }
}

class CartResponse {
  final List<CartItemModel> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  
  CartResponse({
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  });
  
  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      items: (json['items'] as List)
          .map((e) => CartItemModel.fromJson(e))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
    );
  }
}

class CartItemModel {
  final String sku;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;
  
  CartItemModel({
    required this.sku,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });
  
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      sku: json['sku'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'],
      imageUrl: json['imageUrl'],
    );
  }
}

class OrderPreview {
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double total;
  final List<CartItemModel> items;
  
  OrderPreview({
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.total,
    required this.items,
  });
  
  factory OrderPreview.fromJson(Map<String, dynamic> json) {
    return OrderPreview(
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      serviceFee: (json['serviceFee'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      items: (json['items'] as List)
          .map((e) => CartItemModel.fromJson(e))
          .toList(),
    );
  }
}

class OrderResponse {
  final String id;
  final String status;
  final double total;
  final String paymentMethod;
  final String dropoffAddr;
  final List<CartItemModel> items;
  final DateTime createdAt;
  
  OrderResponse({
    required this.id,
    required this.status,
    required this.total,
    required this.paymentMethod,
    required this.dropoffAddr,
    required this.items,
    required this.createdAt,
  });
  
  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      id: json['id'],
      status: json['status'],
      total: (json['total'] as num).toDouble(),
      paymentMethod: json['paymentMethod'],
      dropoffAddr: json['dropoffAddr'],
      items: (json['items'] as List)
          .map((e) => CartItemModel.fromJson(e))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class WalletBalance {
  final double balance;
  
  WalletBalance({required this.balance});
  
  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      balance: (json['balance'] as num).toDouble(),
    );
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool read;
  final DateTime createdAt;
  
  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.read,
    required this.createdAt,
  });
  
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      read: json['read'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ParcelRequest {
  final ParcelLocation pickup;
  final ParcelLocation dropoff;
  final PackageData packageData;
  
  ParcelRequest({
    required this.pickup,
    required this.dropoff,
    required this.packageData,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'pickup': pickup.toJson(),
      'dropoff': dropoff.toJson(),
      'packageData': packageData.toJson(),
    };
  }
}

class ParcelLocation {
  final String address;
  final ContactInfo contact;
  
  ParcelLocation({
    required this.address,
    required this.contact,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'contact': contact.toJson(),
    };
  }
}

class ContactInfo {
  final String name;
  final String phone;
  
  ContactInfo({required this.name, required this.phone});
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
    };
  }
}

class PackageData {
  final String type;
  final double weightKg;
  final String? notes;
  
  PackageData({
    required this.type,
    required this.weightKg,
    this.notes,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'weightKg': weightKg,
      if (notes != null) 'notes': notes,
    };
  }
}

class ParcelResponse {
  final String id;
  final String status;
  final double estimatedCost;
  final DateTime createdAt;
  
  ParcelResponse({
    required this.id,
    required this.status,
    required this.estimatedCost,
    required this.createdAt,
  });
  
  factory ParcelResponse.fromJson(Map<String, dynamic> json) {
    return ParcelResponse(
      id: json['id'],
      status: json['status'],
      estimatedCost: (json['estimatedCost'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}