// File: lib/core/models/api_models.dart

/// API Response wrapper for all API calls
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

// ============================================================================
// AUTH MODELS
// ============================================================================

class AuthResponse {
  final String? accessToken;
  final String? refreshToken;
  final UserProfile? user;
  final String? message;

  AuthResponse({this.accessToken, this.refreshToken, this.user, this.message});

  // Backward compatibility getter
  String? get token => accessToken;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    try {
      // The backend now returns: { "data": { "accessToken": "...", "user": {...} }, "message": "..." }
      final data = json['data'] as Map<String, dynamic>? ?? json;

      return AuthResponse(
        accessToken: data['accessToken'] as String? ?? data['token'] as String?,
        refreshToken: data['refreshToken'] as String?,
        user: data['user'] != null
            ? UserProfile.fromJson(data['user'] as Map<String, dynamic>)
            : null,
        message: json['message'] as String?,
      );
    } catch (e) {
      print('❌ Error parsing AuthResponse: $e');
      print('   JSON: $json');
      return AuthResponse(message: 'Failed to parse auth response');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user?.toJson(),
      'message': message,
    };
  }
}

// For immediate fix, also update your UserProfile model to handle null values:
// In api_models.dart:

class UserProfile {
  final String id;
  final String role;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final bool emailVerified;
  final DateTime? createdAt;

  UserProfile({
    required this.id,
    required this.role,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    required this.emailVerified,
    this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? json['userId'] as String? ?? '',
      role: json['role'] as String? ?? 'USER',
      name: json['name'] as String? ?? 'User',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      emailVerified:
          json['isAccountVerified'] as bool? ??
          json['emailVerified'] as bool? ??
          false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role,
    'name': name,
    'email': email,
    'phone': phone,
    'address': address,
    'emailVerified': emailVerified,
    'createdAt': createdAt?.toIso8601String(),
  };
}

// ============================================================================
// PRODUCT MODELS
// ============================================================================
// In api_models.dart, replace the Product class with this enhanced version:

class Product {
  final String id;
  final String sku;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String? imageSignedUrl; // NEW: Signed S3 URL
  final List<String>? ingredients;
  final int stock;
  final String vendorId;
  final DateTime? createdAt;
  final DateTime? updatedAt; // NEW
  final String? slug; // NEW
  final String? category; // NEW
  final VendorInfo? vendor; // NEW: Nested vendor info

  Product({
    required this.id,
    required this.sku,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.imageSignedUrl,
    this.ingredients,
    required this.stock,
    required this.vendorId,
    this.createdAt,
    this.updatedAt,
    this.slug,
    this.category,
    this.vendor,
  });

  // Helper to get the best image URL (signed URL takes priority)
  String? get bestImageUrl => imageSignedUrl ?? imageUrl;

  factory Product.fromJson(Map<String, dynamic> json) {
    try {
      return Product(
        id: json['id'] as String,
        sku: json['sku'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        price: (json['price'] as num).toDouble(),
        imageUrl: json['imageUrl'] as String?,
        imageSignedUrl: json['imageSignedUrl'] as String?, // NEW
        ingredients: json['ingredients'] != null
            ? List<String>.from(json['ingredients'] as List)
            : null,
        stock: json['stock'] as int? ?? 0,
        vendorId: json['vendorId'] as String,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
        updatedAt:
            json['updatedAt'] !=
                null // NEW
            ? DateTime.tryParse(json['updatedAt'] as String)
            : null,
        slug: json['slug'] as String?, // NEW
        category: json['category'] as String?, // NEW
        vendor:
            json['vendor'] !=
                null // NEW
            ? VendorInfo.fromJson(json['vendor'] as Map<String, dynamic>)
            : null,
      );
    } catch (e, stack) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'imageSignedUrl': imageSignedUrl,
      'ingredients': ingredients,
      'stock': stock,
      'vendorId': vendorId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'slug': slug,
      'category': category,
      'vendor': vendor?.toJson(),
    };
  }
}

// NEW: Nested vendor info that comes with products
class VendorInfo {
  final String id;
  final String name;
  final String? location;

  VendorInfo({required this.id, required this.name, this.location});

  factory VendorInfo.fromJson(Map<String, dynamic> json) {
    return VendorInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'location': location};
  }
}

// ============================================================================
// VENDOR MODELS
// ============================================================================
class Vendor {
  final String id;
  final String name;
  final String? city;
  final String address;
  final String type;
  final bool? isAvailable;
  final DateTime? createdAt;
  final List<Product>? products; // Add this line

  Vendor({
    required this.id,
    required this.name,
    this.city,
    required this.address,
    required this.type,
    this.isAvailable,
    this.createdAt,
    this.products, // Add this line
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'] as String,
      name: json['name'] as String,
      city: json['city'] as String?,
      address: json['address'] as String? ?? '',
      type: json['type'] as String? ?? 'RESTAURANT',
      isAvailable: json['isAvailable'] as bool?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      products:
          json['products'] !=
              null // Add this block
          ? (json['products'] as List)
                .map((p) => Product.fromJson(p as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'address': address,
      'type': type,
      'isAvailable': isAvailable,
      'createdAt': createdAt?.toIso8601String(),
      'products': products?.map((p) => p.toJson()).toList(), // Add this line
    };
  }
}

// ============================================================================
// CART MODELS
// ============================================================================
class CartResponse {
  final String cartId;
  final List<CartItemModel> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final int totalItems;

  CartResponse({
    required this.cartId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.totalItems,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    try {
      final data = json['data'] ?? json;

      // Extract all items from all vendors
      final allItems = <CartItemModel>[];
      double totalAmount = 0.0;
      int itemCount = 0;

      if (data['vendors'] is List) {
        final vendors = data['vendors'] as List;

        for (var vendor in vendors) {
          if (vendor['items'] is List) {
            final vendorItems = vendor['items'] as List;

            for (var item in vendorItems) {
              allItems.add(
                CartItemModel.fromJson(item as Map<String, dynamic>),
              );
              itemCount++;
            }
          }
        }
      }

      totalAmount =
          (data['totalAmount'] as num?)?.toDouble() ??
          allItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

      return CartResponse(
        cartId: data['cartId'] as String? ?? '',
        items: allItems,
        subtotal: totalAmount,
        deliveryFee: 0.0,
        total: totalAmount,
        totalItems: data['totalItems'] as int? ?? itemCount,
      );
    } catch (e, stack) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'cartId': cartId,
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'totalItems': totalItems,
    };
  }
}

class CartItemModel {
  final String productId;
  final String sku;
  final String name;
  final double price;
  final int quantity;
  final double subtotal;
  final String? imageUrl;
  final String? vendorId;

  CartItemModel({
    required this.productId,
    required this.sku,
    required this.name,
    required this.price,
    required this.quantity,
    required this.subtotal,
    this.imageUrl,
    this.vendorId,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['productId'] as String? ?? '',
      sku: json['sku'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      subtotal:
          (json['subtotal'] as num?)?.toDouble() ??
          ((json['price'] as num).toDouble() * (json['quantity'] as int)),
      imageUrl: json['imageUrl'] as String?,
      vendorId: json['vendorId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'sku': sku,
      'name': name,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
      'imageUrl': imageUrl,
      'vendorId': vendorId,
    };
  }
}
// ============================================================================
// ORDER MODELS
// ============================================================================

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
    // Handle nested 'data' object
    final data = json['data'] ?? json;

    return OrderPreview(
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (data['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      serviceFee: (data['serviceFee'] as num?)?.toDouble() ?? 0.0,
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      items:
          (data['items'] as List?)
              ?.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'serviceFee': serviceFee,
      'total': total,
      'items': items.map((e) => e.toJson()).toList(),
    };
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
  final String? vendorId;
  final String? riderId;

  OrderResponse({
    required this.id,
    required this.status,
    required this.total,
    required this.paymentMethod,
    required this.dropoffAddr,
    required this.items,
    required this.createdAt,
    this.vendorId,
    this.riderId,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    try {
      final data = json['data'] ?? json;
      final orderData =
          data['orders'] != null && (data['orders'] as List).isNotEmpty
          ? (data['orders'] as List)[0] as Map<String, dynamic>
          : data;

      // Parse items from products array
      final items = <CartItemModel>[];
      if (orderData['products'] != null) {
        final products = orderData['products'] as List;
        for (var product in products) {
          final productData = product['product'] as Map<String, dynamic>?;
          if (productData != null) {
            final price = (productData['price'] as num?)?.toDouble() ?? 0.0;
            final quantity = product['quantity'] as int? ?? 1;

            items.add(
              CartItemModel(
                productId: productData['id'] as String? ?? '',
                sku: productData['sku'] as String? ?? '',
                name: productData['name'] as String? ?? 'Unknown',
                price: price,
                quantity: quantity,
                subtotal: price * quantity,
                imageUrl: productData['imageUrl'] as String?,
                vendorId: orderData['vendorId'] as String?,
              ),
            );
          }
        }
      }

      // Calculate total (handle null)
      double total = 0.0;
      if (orderData['total'] != null) {
        total = (orderData['total'] as num).toDouble();
      } else {
        final itemsTotal = items.fold<double>(
          0,
          (sum, item) => sum + item.subtotal,
        );
        final deliveryFee =
            (orderData['deliveryPrice'] as num?)?.toDouble() ?? 0.0;
        total = itemsTotal + deliveryFee;
      }

      // Get dropoff address
      String dropoffAddr = '';
      if (orderData['delivery'] != null) {
        final delivery = orderData['delivery'] as Map<String, dynamic>;
        dropoffAddr = delivery['dropoffAddr'] as String? ?? '';
      } else if (orderData['dropoffAddr'] != null) {
        dropoffAddr = orderData['dropoffAddr'] as String;
      }

      return OrderResponse(
        id: orderData['id'] as String,
        status: orderData['status'] as String? ?? 'PENDING',
        total: total,
        paymentMethod: orderData['paymentMethod'] as String? ?? 'CARD',
        dropoffAddr: dropoffAddr,
        items: items,
        createdAt: DateTime.parse(orderData['createdAt'] as String),
        vendorId: orderData['vendorId'] as String?,
        riderId: orderData['rideId'] as String?,
      );
    } catch (e, stack) {
      rethrow;
    }
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'total': total,
      'paymentMethod': paymentMethod,
      'dropoffAddr': dropoffAddr,
      'items': items.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'vendorId': vendorId,
      'riderId': riderId,
    };
  }
}

// ============================================================================
// WALLET MODELS
// ============================================================================

class WalletBalance {
  final double balance;
  final String? currency;
  final Map<String, double>? periodBalances;

  WalletBalance({required this.balance, this.currency, this.periodBalances});

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    // Handle nested 'data' object
    final data = json['data'] ?? json;

    // The API returns multiple balance fields (day, week, month, etc.)
    // Extract the 'current' balance or sum them up
    double balance = 0.0;

    if (data['current'] != null) {
      balance = (data['current'] as num).toDouble();
    } else if (data['balance'] != null) {
      balance = (data['balance'] as num).toDouble();
    } else {
      // Sum up all the period balances
      final periods = [
        'day',
        'week',
        'month',
        'year',
        'halfYear',
        'quarter1',
        'quarter2',
        'quarter3',
        'quarter4',
      ];
      for (var period in periods) {
        if (data[period] != null) {
          balance += (data[period] as num).toDouble();
        }
      }
    }

    // Store period balances for detailed view
    final periodBalances = <String, double>{};
    data.forEach((key, value) {
      if (value is num) {
        periodBalances[key] = value.toDouble();
      }
    });

    return WalletBalance(
      balance: balance,
      currency: data['currency'] as String? ?? 'NGN',
      periodBalances: periodBalances.isNotEmpty ? periodBalances : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'currency': currency,
      if (periodBalances != null) ...periodBalances!,
    };
  }
}

// ============================================================================
// NOTIFICATION MODELS
// ============================================================================

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool read;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.read,
    required this.createdAt,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String? ?? 'INFO',
      read: json['read'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'read': read,
      'createdAt': createdAt.toIso8601String(),
      'data': data,
    };
  }
}

// ============================================================================
// PARCEL MODELS
// ============================================================================

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

  factory ParcelRequest.fromJson(Map<String, dynamic> json) {
    return ParcelRequest(
      pickup: ParcelLocation.fromJson(json['pickup'] as Map<String, dynamic>),
      dropoff: ParcelLocation.fromJson(json['dropoff'] as Map<String, dynamic>),
      packageData: PackageData.fromJson(
        json['packageData'] as Map<String, dynamic>,
      ),
    );
  }
}

class ParcelLocation {
  final String address;
  final ContactInfo contact;

  ParcelLocation({required this.address, required this.contact});

  Map<String, dynamic> toJson() {
    return {'address': address, 'contact': contact.toJson()};
  }

  factory ParcelLocation.fromJson(Map<String, dynamic> json) {
    return ParcelLocation(
      address: json['address'] as String,
      contact: ContactInfo.fromJson(json['contact'] as Map<String, dynamic>),
    );
  }
}

class ContactInfo {
  final String name;
  final String phone;

  ContactInfo({required this.name, required this.phone});

  Map<String, dynamic> toJson() {
    return {'name': name, 'phone': phone};
  }

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      name: json['name'] as String,
      phone: json['phone'] as String,
    );
  }
}

class PackageData {
  final String type;
  final double weightKg;
  final String? notes;

  PackageData({required this.type, required this.weightKg, this.notes});

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'weightKg': weightKg,
      if (notes != null) 'notes': notes,
    };
  }

  factory PackageData.fromJson(Map<String, dynamic> json) {
    return PackageData(
      type: json['type'] as String,
      weightKg: (json['weightKg'] as num).toDouble(),
      notes: json['notes'] as String?,
    );
  }
}

class ParcelResponse {
  final String id;
  final String status;
  final double estimatedCost;
  final DateTime createdAt;
  final String? riderId;

  ParcelResponse({
    required this.id,
    required this.status,
    required this.estimatedCost,
    required this.createdAt,
    this.riderId,
  });

  factory ParcelResponse.fromJson(Map<String, dynamic> json) {
    // Handle nested 'data' object
    final data = json['data'] ?? json;

    return ParcelResponse(
      id: data['id'] as String,
      status: data['status'] as String? ?? 'PENDING',
      estimatedCost: (data['estimatedCost'] as num).toDouble(),
      createdAt: DateTime.parse(data['createdAt'] as String),
      riderId: data['riderId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'estimatedCost': estimatedCost,
      'createdAt': createdAt.toIso8601String(),
      'riderId': riderId,
    };
  }
}
