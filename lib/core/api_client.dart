// File: lib/core/api_client.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'api_models.dart';

/// Enhanced API Client for Bezoni User App with improved token management
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  // Base URL - Production URL
  static const String _baseUrl = 'https://bezoni.onrender.com';

  String? _authToken;
  String? _refreshToken;
  bool _isInitialized = false;

  // Initialize auth tokens from storage
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('✅ API Client already initialized');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString('auth_token');
      _refreshToken = prefs.getString('refresh_token');
      
      if (_authToken != null) {
        debugPrint('✅ API Client initialized with token: ${_authToken!.substring(0, 20)}...');
      } else {
        debugPrint('⚠️ API Client initialized without token');
      }
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('❌ Error initializing API client: $e');
    }
  }

  // Save auth tokens to storage
  Future<void> _saveTokens(String accessToken, String? refreshToken) async {
    try {
      _authToken = accessToken;
      _refreshToken = refreshToken;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', accessToken);
      if (refreshToken != null) {
        await prefs.setString('refresh_token', refreshToken);
      }
      
      debugPrint('✅ Auth tokens saved');
      debugPrint('   Access Token: ${accessToken.substring(0, 20)}...');
    } catch (e) {
      debugPrint('❌ Error saving tokens: $e');
    }
  }

  // Clear auth tokens
  Future<void> clearToken() async {
    try {
      _authToken = null;
      _refreshToken = null;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('refresh_token');
      
      debugPrint('✅ Auth tokens cleared');
    } catch (e) {
      debugPrint('❌ Error clearing tokens: $e');
    }
  }

  // Get headers with auth token
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
      debugPrint('🔑 Using token: ${_authToken!.substring(0, 20)}...');
    } else {
      debugPrint('⚠️ No auth token available');
    }
    
    return headers;
  }

  // Get headers for multipart requests
  Map<String, String> get _multipartHeaders {
    final headers = <String, String>{};
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Generic GET request with enhanced error handling
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? parser,
  }) async {
    try {
      // Ensure client is initialized
      if (!_isInitialized) {
        await initialize();
      }

      final uri = Uri.parse('$_baseUrl$endpoint').replace(
        queryParameters: queryParams?.map((k, v) => MapEntry(k, v.toString())),
      );

      debugPrint('📤 GET: $uri');

      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 30));

      return _handleResponse<T>(response, parser);
    } on SocketException {
      return ApiResponse.error(
        'No internet connection. Please check your network.',
      );
    } on HttpException {
      return ApiResponse.error('Server error. Please try again later.');
    } on FormatException {
      return ApiResponse.error('Invalid response format from server.');
    } catch (e) {
      debugPrint('❌ GET Error: $e');
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Generic POST request with enhanced error handling
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? parser,
  }) async {
    try {
      // Ensure client is initialized
      if (!_isInitialized) {
        await initialize();
      }

      final uri = Uri.parse('$_baseUrl$endpoint');

      debugPrint('📤 POST: $uri');
      if (body != null) debugPrint('   Body: ${jsonEncode(body)}');

      final response = await http
          .post(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse<T>(response, parser);
    } on SocketException {
      return ApiResponse.error(
        'No internet connection. Please check your network.',
      );
    } on HttpException {
      return ApiResponse.error('Server error. Please try again later.');
    } on FormatException {
      return ApiResponse.error('Invalid response format from server.');
    } catch (e) {
      debugPrint('❌ POST Error: $e');
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
      if (!_isInitialized) await initialize();

      final uri = Uri.parse('$_baseUrl$endpoint');
      debugPrint('📤 PUT: $uri');

      final response = await http
          .put(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse<T>(response, parser);
    } on SocketException {
      return ApiResponse.error(
        'No internet connection. Please check your network.',
      );
    } on HttpException {
      return ApiResponse.error('Server error. Please try again later.');
    } catch (e) {
      debugPrint('❌ PUT Error: $e');
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
      if (!_isInitialized) await initialize();

      final uri = Uri.parse('$_baseUrl$endpoint');
      debugPrint('📤 PATCH: $uri');

      final response = await http
          .patch(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse<T>(response, parser);
    } on SocketException {
      return ApiResponse.error(
        'No internet connection. Please check your network.',
      );
    } on HttpException {
      return ApiResponse.error('Server error. Please try again later.');
    } catch (e) {
      debugPrint('❌ PATCH Error: $e');
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Generic DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(dynamic)? parser,
  }) async {
    try {
      if (!_isInitialized) await initialize();

      final uri = Uri.parse('$_baseUrl$endpoint');
      debugPrint('📤 DELETE: $uri');

      final response = await http
          .delete(uri, headers: _headers)
          .timeout(const Duration(seconds: 30));

      return _handleResponse<T>(response, parser);
    } on SocketException {
      return ApiResponse.error(
        'No internet connection. Please check your network.',
      );
    } on HttpException {
      return ApiResponse.error('Server error. Please try again later.');
    } catch (e) {
      debugPrint('❌ DELETE Error: $e');
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
      if (!_isInitialized) await initialize();

      final uri = Uri.parse('$_baseUrl$endpoint');
      final request = http.MultipartRequest('POST', uri);

      debugPrint('📤 POST Multipart: $uri');

      request.headers.addAll(_multipartHeaders);
      request.fields.addAll(fields);

      if (files != null) {
        for (var entry in files.entries) {
          request.files.add(
            await http.MultipartFile.fromPath(entry.key, entry.value.path),
          );
        }
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse<T>(response, parser);
    } on SocketException {
      return ApiResponse.error(
        'No internet connection. Please check your network.',
      );
    } on HttpException {
      return ApiResponse.error('Server error. Please try again later.');
    } catch (e) {
      debugPrint('❌ Multipart POST Error: $e');
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Enhanced response handler with better error messages
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? parser,
  ) {
    debugPrint('📥 Response Status: ${response.statusCode}');
    debugPrint('📥 Response Body: ${response.body}');

    try {
      // Handle different status codes
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success response
        final data = jsonDecode(response.body);

        if (parser != null) {
          return ApiResponse.success(parser(data));
        } else {
          return ApiResponse.success(data as T);
        }
      } else if (response.statusCode == 401) {
        // Unauthorized - token expired or invalid
        debugPrint('⚠️ 401 Unauthorized - clearing token');
        clearToken();
        return ApiResponse.error('Session expired. Please login again.');
      } else if (response.statusCode == 403) {
        return ApiResponse.error('Access denied. You don\'t have permission.');
      } else if (response.statusCode == 404) {
        return ApiResponse.error('Resource not found.');
      } else if (response.statusCode == 422) {
        // Validation error
        try {
          final errorData = jsonDecode(response.body);
          final message = errorData['message'] ?? 'Validation error';
          return ApiResponse.error(message);
        } catch (e) {
          return ApiResponse.error('Validation error occurred.');
        }
      } else if (response.statusCode >= 500) {
        return ApiResponse.error('Server error. Please try again later.');
      } else {
        // Other client errors
        try {
          final errorData = jsonDecode(response.body);
          final message = errorData['message'] ?? 'An error occurred';
          return ApiResponse.error(message);
        } catch (e) {
          return ApiResponse.error(
            'An error occurred (${response.statusCode})',
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Response parsing error: $e');
      return ApiResponse.error('Failed to process server response');
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

    // Use the token getter for backward compatibility
    if (response.isSuccess && response.data?.token != null) {
      await _saveTokens(
        response.data!.token!,
        response.data!.refreshToken,
      );
    }

    return response;
  }

  Future<ApiResponse<AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    final response = await post<AuthResponse>(
      '/auth/login',
      body: {'email': email, 'password': password},
      parser: (data) => AuthResponse.fromJson(data),
    );

    // Use the token getter for backward compatibility
    if (response.isSuccess && response.data?.token != null) {
      await _saveTokens(
        response.data!.token!,
        response.data!.refreshToken,
      );
      debugPrint('✅ Login successful - tokens saved');
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
    return get<UserProfile>(
      '/auth/me',
      parser: (data) => UserProfile.fromJson(data),
    );
  }

  Future<ApiResponse<UserProfile>> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    final body = <String, dynamic>{};
    if (name != null && name.isNotEmpty) body['name'] = name;
    if (email != null && email.isNotEmpty) body['email'] = email;
    if (phone != null && phone.isNotEmpty) body['phone'] = phone;

    return put<UserProfile>(
      '/auth/update-profile',
      body: body,
      parser: (data) => UserProfile.fromJson(data),
    );
  }

  Future<ApiResponse<void>> forgotPassword(String email) async {
    return post('/auth/forgot-password', body: {'email': email});
  }

  Future<ApiResponse<void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    return post(
      '/auth/reset-password',
      body: {'token': token, 'newPassword': newPassword},
    );
  }

  Future<ApiResponse<void>> sendVerificationEmail() async {
    return post('/auth/send-verification');
  }

  Future<ApiResponse<void>> verifyEmail(String token) async {
    return post('/auth/verify-email', body: {'token': token});
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
      body: {'sku': sku, 'quantity': quantity},
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
      body: {'sku': sku, 'quantity': quantity},
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
      body: {'dropoffAddr': dropoffAddr, 'paymentMethod': paymentMethod},
      parser: (data) => OrderResponse.fromJson(data),
    );
  }

  Future<ApiResponse<List<OrderResponse>>> getUserOrders() async {
    return get<List<OrderResponse>>(
      '/order/user/order',
      parser: (data) {
        if (data is List) {
          return data.map((e) => OrderResponse.fromJson(e)).toList();
        }
        return [];
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

  Future<ApiResponse<List<Product>>> getProducts({String? search}) async {
    return get<List<Product>>(
      '/order/products',
      queryParams: search != null ? {'search': search} : null,
      parser: (data) {
        if (data is List) {
          return data.map((e) => Product.fromJson(e)).toList();
        }
        return [];
      },
    );
  }

  Future<ApiResponse<List<Product>>> getFoods({String? search}) async {
    return get<List<Product>>(
      '/product/foods',
      queryParams: search != null ? {'search': search} : null,
      parser: (data) {
        if (data is List) {
          return data.map((e) => Product.fromJson(e)).toList();
        }
        return [];
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
        if (data is List) {
          return data.map((e) => Vendor.fromJson(e)).toList();
        }
        return [];
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
    return get<List<NotificationModel>>(
      '/notification/details',
      parser: (data) {
        if (data is List) {
          return data.map((e) => NotificationModel.fromJson(e)).toList();
        }
        return [];
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

  ApiResponse._({required this.isSuccess, this.data, this.errorMessage});

  factory ApiResponse.success(T data) {
    return ApiResponse._(isSuccess: true, data: data);
  }

  factory ApiResponse.error(String message) {
    return ApiResponse._(isSuccess: false, errorMessage: message);
  }
}