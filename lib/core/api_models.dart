// File: lib/core/models/api_models.dart

/// API Response wrapper for all API calls
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
// AUTH MODELS
// ============================================================================

class AuthResponse {
  final String? accessToken;      // Changed from 'token' to 'accessToken'
  final String? refreshToken;     // Added refreshToken
  final UserProfile? user;
  final String? message;
  
  AuthResponse({
    this.accessToken, 
    this.refreshToken,
    this.user, 
    this.message,
  });
  
  // Backward compatibility getter
  String? get token => accessToken;
  
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    try {
      // Handle nested 'data' object from API response
      final data = json['data'] ?? json;
      
      return AuthResponse(
        accessToken: data['accessToken'] as String?,
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

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String role;
  final bool emailVerified;
  final DateTime? createdAt;
  
  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    required this.role,
    required this.emailVerified,
    this.createdAt,
  });
  
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    try {
      // Handle nested 'user' or 'data' object
      final data = json['user'] ?? json['data'] ?? json;
      
      return UserProfile(
        id: data['id'] as String,
        name: data['name'] as String,
        email: data['email'] as String,
        phone: data['phone'] as String?,
        address: data['address'] as String?,
        role: data['role'] as String? ?? 'USER',
        emailVerified: data['emailVerified'] as bool? ?? false,
        createdAt: data['createdAt'] != null 
            ? DateTime.tryParse(data['createdAt'] as String)
            : null,
      );
    } catch (e) {
      print('❌ Error parsing UserProfile: $e');
      rethrow;
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'role': role,
      'emailVerified': emailVerified,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

// ============================================================================
// PRODUCT MODELS
// ============================================================================

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
  final DateTime? createdAt;
  
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
    this.createdAt,
  });
  
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      sku: json['sku'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      ingredients: json['ingredients'] != null 
          ? List<String>.from(json['ingredients'] as List) 
          : null,
      stock: json['stock'] as int? ?? 0,
      vendorId: json['vendorId'] as String,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'stock': stock,
      'vendorId': vendorId,
      'createdAt': createdAt?.toIso8601String(),
    };
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
  
  Vendor({
    required this.id,
    required this.name,
    this.city,
    required this.address,
    required this.type,
    this.isAvailable,
    this.createdAt,
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
    };
  }
}

// ============================================================================
// CART MODELS
// ============================================================================

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
    // Handle nested 'data' object
    final data = json['data'] ?? json;
    
    return CartResponse(
      items: (data['items'] as List?)
          ?.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (data['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
    };
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
      sku: json['sku'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      imageUrl: json['imageUrl'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
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
      items: (data['items'] as List?)
          ?.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
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
    // Handle nested 'data' object
    final data = json['data'] ?? json;
    
    return OrderResponse(
      id: data['id'] as String,
      status: data['status'] as String? ?? 'PENDING',
      total: (data['total'] as num).toDouble(),
      paymentMethod: data['paymentMethod'] as String? ?? 'CARD',
      dropoffAddr: data['dropoffAddr'] as String? ?? '',
      items: (data['items'] as List?)
          ?.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: DateTime.parse(data['createdAt'] as String),
      vendorId: data['vendorId'] as String?,
      riderId: data['riderId'] as String?,
    );
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
  
  WalletBalance({
    required this.balance,
    this.currency,
  });
  
  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    // Handle nested 'data' object
    final data = json['data'] ?? json;
    
    return WalletBalance(
      balance: (data['balance'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency'] as String? ?? 'NGN',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'currency': currency,
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
      packageData: PackageData.fromJson(json['packageData'] as Map<String, dynamic>),
    );
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
    return {
      'name': name,
      'phone': phone,
    };
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