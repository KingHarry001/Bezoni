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
        debugPrint(
          '✅ API Client initialized with token: ${_authToken!.substring(0, 20)}...',
        );
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
        debugPrint('⚠️ 401 Unauthorized - clearing token');
        clearToken();
        return ApiResponse.error('Session expired. Please login again.');
      } else if (response.statusCode == 403) {
        return ApiResponse.error('Access denied. You don\'t have permission.');
      } else if (response.statusCode == 404) {
        return ApiResponse.error('Resource not found.');
      } else if (response.statusCode == 422) {
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

    if (response.isSuccess && response.data?.token != null) {
      await _saveTokens(response.data!.token!, response.data!.refreshToken);
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

    if (response.isSuccess && response.data?.token != null) {
      await _saveTokens(response.data!.token!, response.data!.refreshToken);
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
  debugPrint('📤 Getting user profile...');
  
  return get<UserProfile>(
    '/auth/me',
    parser: (data) {
      debugPrint('🔍 PARSING PROFILE');
      debugPrint('   Full response: $data');
      
      try {
        Map<String, dynamic> userData;
        
        // Backend returns: { "success": true, "data": { email, name, phone, ... } }
        if (data is Map<String, dynamic>) {
          if (data.containsKey('data')) {
            userData = data['data'] as Map<String, dynamic>;
            debugPrint('   Extracted from data wrapper: $userData');
          } else {
            userData = data;
            debugPrint('   Using root data: $userData');
          }
          
          // Build UserProfile directly (don't use fromJson to avoid issues)
          final profile = UserProfile(
            id: userData['id'] as String? ?? '',
            role: userData['role'] as String? ?? 'USER',
            name: userData['name'] as String? ?? 'User',
            email: userData['email'] as String? ?? '',
            phone: userData['phone'] as String?,
            address: userData['address'] as String?,
            emailVerified: userData['isAccountVerified'] as bool? ?? false,
            createdAt: userData['createdAt'] != null 
                ? DateTime.tryParse(userData['createdAt'] as String)
                : null,
          );
          
          debugPrint('✅ SUCCESSFULLY PARSED:');
          debugPrint('   Name: ${profile.name}');
          debugPrint('   Email: ${profile.email}');
          debugPrint('   Phone: ${profile.phone}');
          debugPrint('   Verified: ${profile.emailVerified}');
          
          return profile;
        }
        
        throw Exception('Invalid data type: ${data.runtimeType}');
      } catch (e, stack) {
        debugPrint('❌ PARSING FAILED: $e');
        debugPrint('   Stack: $stack');
        rethrow;
      }
    },
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

  // Update these two methods in api_client.dart

  // Email verification - sends verification code to user's email
  Future<ApiResponse<void>> sendVerificationEmail() async {
    debugPrint('📤 Sending verification email...');
    final response = await post('/auth/send-verification');

    if (response.isSuccess) {
      debugPrint('✅ Verification email sent successfully');
    } else {
      debugPrint(
        '❌ Failed to send verification email: ${response.errorMessage}',
      );
    }

    return response;
  }

  // Email verification - verify the code
  Future<ApiResponse<void>> verifyEmail(String token) async {
    debugPrint('📤 Verifying email with token: ${token.substring(0, 3)}...');

    final response = await post('/auth/verify-email', body: {'token': token});

    if (response.isSuccess) {
      debugPrint('✅ Email verified successfully!');

      // IMPORTANT: After verification, refresh the user profile to get updated status
      try {
        final profileResponse = await getProfile();
        if (profileResponse.isSuccess && profileResponse.data != null) {
          debugPrint(
            '✅ Profile refreshed - emailVerified: ${profileResponse.data!.emailVerified}',
          );
        }
      } catch (e) {
        debugPrint('⚠️ Could not refresh profile after verification: $e');
      }
    } else {
      debugPrint('❌ Email verification failed: ${response.errorMessage}');
    }

    return response;
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

  // FIXED: Better parsing for orders response
  Future<ApiResponse<List<OrderResponse>>> getUserOrders() async {
    return get<List<OrderResponse>>(
      '/order/user/order',
      parser: (data) {
        try {
          debugPrint('🔍 Parsing orders response...');
          debugPrint('   Response type: ${data.runtimeType}');

          // Backend returns: { "success": true, "data": { "orders": [...], "pagination": {...} } }
          if (data is Map<String, dynamic>) {
            final responseData = data['data'] as Map<String, dynamic>?;

            if (responseData != null) {
              final ordersList = responseData['orders'] as List?;

              if (ordersList != null && ordersList.isNotEmpty) {
                debugPrint('✅ Found ${ordersList.length} orders');
                return ordersList
                    .map(
                      (e) => OrderResponse.fromJson(e as Map<String, dynamic>),
                    )
                    .toList();
              }
            }

            // Check if orders are at root level
            if (data['orders'] is List) {
              final ordersList = data['orders'] as List;
              debugPrint('✅ Found ${ordersList.length} orders at root');
              return ordersList
                  .map((e) => OrderResponse.fromJson(e as Map<String, dynamic>))
                  .toList();
            }
          }

          // Fallback for direct list response
          if (data is List) {
            debugPrint('✅ Parsing ${data.length} orders (direct list)');
            return data
                .map((e) => OrderResponse.fromJson(e as Map<String, dynamic>))
                .toList();
          }

          debugPrint('⚠️ No orders found in response');
          return [];
        } catch (e, stack) {
          debugPrint('❌ Error parsing orders: $e');
          debugPrint('   Stack: $stack');
          return [];
        }
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

  Future<ApiResponse<List<Product>>> getFoods({String? search}) async {
    return get<List<Product>>(
      '/product/foods',
      queryParams: search != null ? {'search': search} : null,
      parser: (data) {
        try {
          if (data is Map<String, dynamic>) {
            final foodsData = data['data'] ?? data['foods'];
            if (foodsData is List) {
              return foodsData
                  .map((e) => Product.fromJson(e as Map<String, dynamic>))
                  .toList();
            }
          }

          if (data is List) {
            return data
                .map((e) => Product.fromJson(e as Map<String, dynamic>))
                .toList();
          }

          return [];
        } catch (e) {
          debugPrint('❌ Error parsing foods: $e');
          return [];
        }
      },
    );
  }

  Future<ApiResponse<Product>> getFoodById(String id) async {
    return get<Product>(
      '/product/foods/$id',
      parser: (data) {
        // Handle wrapped response
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          return Product.fromJson(data['data'] as Map<String, dynamic>);
        }
        return Product.fromJson(data as Map<String, dynamic>);
      },
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
        try {
          debugPrint('🔍 Parsing vendors response...');
          debugPrint('   Raw data type: ${data.runtimeType}');

          // Handle the actual API response structure
          if (data is Map<String, dynamic>) {
            // First check if there's a 'data' wrapper
            if (data.containsKey('data')) {
              final innerData = data['data'];

              // Check if 'data' contains 'vendors' array
              if (innerData is Map<String, dynamic> &&
                  innerData.containsKey('vendors')) {
                final vendorsList = innerData['vendors'] as List?;

                if (vendorsList != null && vendorsList.isNotEmpty) {
                  debugPrint(
                    '✅ Found ${vendorsList.length} vendors in data.vendors',
                  );
                  return vendorsList
                      .map((e) => Vendor.fromJson(e as Map<String, dynamic>))
                      .toList();
                }
              }

              // Check if 'data' is directly the vendors array
              if (innerData is List) {
                debugPrint('✅ Found ${innerData.length} vendors in data array');
                return innerData
                    .map((e) => Vendor.fromJson(e as Map<String, dynamic>))
                    .toList();
              }
            }

            // Check for vendors at root level
            if (data.containsKey('vendors')) {
              final vendorsList = data['vendors'] as List?;
              if (vendorsList != null && vendorsList.isNotEmpty) {
                debugPrint('✅ Found ${vendorsList.length} vendors at root');
                return vendorsList
                    .map((e) => Vendor.fromJson(e as Map<String, dynamic>))
                    .toList();
              }
            }
          }

          // Handle direct array response
          if (data is List) {
            debugPrint('✅ Found ${data.length} vendors (direct array)');
            return data
                .map((e) => Vendor.fromJson(e as Map<String, dynamic>))
                .toList();
          }

          debugPrint('⚠️ No vendors found in response structure');
          debugPrint(
            '   Data keys: ${data is Map ? (data as Map).keys.toList() : "not a map"}',
          );
          return [];
        } catch (e, stack) {
          debugPrint('❌ Error parsing vendors: $e');
          debugPrint('   Stack: $stack');
          return [];
        }
      },
    );
  }

  /// Get vendor by ID
  /// Documentation: GET /vendor/byId/:id
  Future<ApiResponse<Vendor>> getVendorById(String id) async {
    return get<Vendor>(
      '/vendor/byId/$id',
      parser: (data) {
        try {
          // Handle wrapped response
          if (data is Map<String, dynamic> && data.containsKey('data')) {
            return Vendor.fromJson(data['data'] as Map<String, dynamic>);
          }
          return Vendor.fromJson(data as Map<String, dynamic>);
        } catch (e) {
          debugPrint('❌ Error parsing vendor: $e');
          rethrow;
        }
      },
    );
  }

  // ============================================================================
  // PRODUCT/FOOD ENDPOINTS - AS PER DOCUMENTATION
  // ============================================================================

  /// Get all products
  /// Documentation: GET /order/products
  Future<ApiResponse<List<Product>>> getProducts({String? search}) async {
    return get<List<Product>>(
      '/order/products',
      queryParams: search != null ? {'search': search} : null,
      parser: (data) {
        try {
          debugPrint('🔍 Parsing products response...');

          if (data is List) {
            debugPrint('✅ Found ${data.length} products');
            return data
                .map((e) => Product.fromJson(e as Map<String, dynamic>))
                .toList();
          }

          if (data is Map<String, dynamic>) {
            final productsData = data['data'] ?? data['products'];
            if (productsData is List) {
              return productsData
                  .map((e) => Product.fromJson(e as Map<String, dynamic>))
                  .toList();
            }
          }

          return [];
        } catch (e) {
          debugPrint('❌ Error parsing products: $e');
          return [];
        }
      },
    );
  }
  // ============================================================================
  // NOTIFICATION ENDPOINTS - FIXED
  // ============================================================================

  /// Get notifications
  /// Documentation: POST /notification/details (yes, it's POST!)
  Future<ApiResponse<List<NotificationModel>>> getNotifications() async {
    return post<List<NotificationModel>>(
      '/notification/details',
      parser: (data) {
        try {
          debugPrint('🔍 Parsing notifications response...');

          if (data is List) {
            debugPrint('✅ Found ${data.length} notifications');
            return data
                .map(
                  (e) => NotificationModel.fromJson(e as Map<String, dynamic>),
                )
                .toList();
          }

          if (data is Map<String, dynamic>) {
            final notificationsData = data['data'] ?? data['notifications'];
            if (notificationsData is List) {
              return notificationsData
                  .map(
                    (e) =>
                        NotificationModel.fromJson(e as Map<String, dynamic>),
                  )
                  .toList();
            }
          }

          return [];
        } catch (e) {
          debugPrint('❌ Error parsing notifications: $e');
          return [];
        }
      },
    );
  }

  // ============================================================================
  // HELPER: Test Vendor Endpoint Specifically
  // ============================================================================

  /// Diagnose why vendors aren't showing
  Future<Map<String, dynamic>> diagnoseVendorIssue() async {
    try {
      if (!_isInitialized) await initialize();

      final uri = Uri.parse('$_baseUrl/vendor/availablevendors');
      debugPrint('🔍 Testing vendor endpoint...');
      debugPrint('   URL: $uri');
      debugPrint('   Token: ${_authToken?.substring(0, 20) ?? "NO TOKEN"}...');

      final response = await http.get(uri, headers: _headers);

      debugPrint('📥 Status: ${response.statusCode}');
      debugPrint('📥 Body: ${response.body}');

      final result = {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'statusCode': response.statusCode,
        'hasToken': _authToken != null,
        'rawBody': response.body,
      };

      if (result['success'] as bool) {
        try {
          final parsed = jsonDecode(response.body);
          result['parsedData'] = parsed;

          if (parsed is List) {
            result['vendorCount'] = parsed.length;
            result['message'] = 'Found ${parsed.length} vendors';
          } else if (parsed is Map) {
            final data = parsed['data'];
            if (data is List) {
              result['vendorCount'] = data.length;
              result['message'] = 'Found ${data.length} vendors (wrapped)';
            } else {
              result['message'] = 'No vendors array found';
              result['vendorCount'] = 0;
            }
          }
        } catch (e) {
          result['parseError'] = e.toString();
        }
      } else {
        result['message'] = 'Request failed with status ${response.statusCode}';
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Network error occurred',
      };
    }
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

  // ============================================================================
  // DIAGNOSTIC TOOLS
  // ============================================================================

  /// Get raw response from an endpoint for debugging
  Future<Map<String, dynamic>> getRawResponse(String endpoint) async {
    try {
      if (!_isInitialized) await initialize();

      final uri = Uri.parse('$_baseUrl$endpoint');
      debugPrint('🔍 Testing endpoint: $endpoint');

      final response = await http.get(uri, headers: _headers);

      return {
        'endpoint': endpoint,
        'statusCode': response.statusCode,
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'body': response.body,
        'bodyParsed': response.statusCode >= 200 && response.statusCode < 300
            ? jsonDecode(response.body)
            : null,
      };
    } catch (e) {
      return {'endpoint': endpoint, 'success': false, 'error': e.toString()};
    }
  }

  /// Test all critical endpoints
  Future<Map<String, bool>> testAllEndpoints() async {
    final results = <String, bool>{};

    final endpoints = [
      '/vendor/availablevendors',
      '/product/foods',
      '/order/products',
      '/auth/me',
      '/order/cart',
      '/wallet/balance',
    ];

    for (final endpoint in endpoints) {
      try {
        final result = await getRawResponse(endpoint);
        results[endpoint] = result['success'] as bool;
        debugPrint('${result['success'] ? "✅" : "❌"} $endpoint');
      } catch (e) {
        results[endpoint] = false;
        debugPrint('❌ $endpoint - Error: $e');
      }
    }

    return results;
  }
}
