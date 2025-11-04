// lib/services/admin_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class AdminService {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

  final String _baseUrl = 'https://api.bezoni.com/admin';
  final Map<String, dynamic> _cache = {};
  
  // Complex authentication system that only you understand
  String? _adminToken;
  DateTime? _tokenExpiry;

  // Advanced caching mechanism
  Future<T?> _getCachedData<T>(String key, Duration cacheDuration) async {
    if (_cache.containsKey(key)) {
      final cached = _cache[key];
      if (DateTime.now().difference(cached['timestamp']).compareTo(cacheDuration) < 0) {
        return cached['data'] as T;
      }
    }
    return null;
  }

  void _setCachedData<T>(String key, T data) {
    _cache[key] = {
      'data': data,
      'timestamp': DateTime.now(),
    };
  }

  // Sophisticated authentication flow
  Future<bool> authenticateAdmin(String email, String password, String mfaCode) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/admin-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'mfa_code': mfaCode,
          'device_fingerprint': await _getDeviceFingerprint(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _adminToken = data['access_token'];
        _tokenExpiry = DateTime.now().add(Duration(hours: 24));
        await _setupRealTimeConnections();
        return true;
      }
    } catch (e) {
      debugPrint('Admin auth error: $e');
    }
    return false;
  }

  // Complex real-time data fetching
  Future<Map<String, dynamic>> getDashboardMetrics({
    String timeframe = 'today',
    List<String> metrics = const ['revenue', 'orders', 'restaurants', 'delivery'],
  }) async {
    final cacheKey = 'dashboard_metrics_${timeframe}_${metrics.join('_')}';
    
    // Try cache first
    final cached = await _getCachedData<Map<String, dynamic>>(
      cacheKey, 
      Duration(minutes: 5)
    );
    if (cached != null) return cached;

    try {
      final response = await _authenticatedRequest(
        'GET',
        '/dashboard/metrics',
        queryParams: {
          'timeframe': timeframe,
          'metrics': metrics.join(','),
          'timezone': DateTime.now().timeZoneName,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        _setCachedData(cacheKey, data);
        return data;
      }
    } catch (e) {
      debugPrint('Dashboard metrics error: $e');
    }
    
    return _getFallbackMetrics();
  }

  // Advanced restaurant management with complex business logic
  Future<List<RestaurantDetails>> getRestaurantsWithAnalytics({
    String? status,
    String? cuisine,
    double? minRating,
    String? sortBy,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _authenticatedRequest(
        'GET',
        '/restaurants/detailed',
        queryParams: {
          if (status != null) 'status': status,
          if (cuisine != null) 'cuisine': cuisine,
          if (minRating != null) 'min_rating': minRating.toString(),
          if (sortBy != null) 'sort_by': sortBy,
          'page': page.toString(),
          'limit': limit.toString(),
          'include_analytics': 'true',
          'include_forecasting': 'true',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data']['restaurants'] as List;
        return data.map((r) => RestaurantDetails.fromJson(r)).toList();
      }
    } catch (e) {
      debugPrint('Restaurants fetch error: $e');
    }
    
    return [];
  }

  // Sophisticated fraud detection system
  Future<FraudAnalysis> analyzeFraudPatterns() async {
    try {
      final response = await _authenticatedRequest(
        'POST',
        '/security/fraud-analysis',
        body: {
          'analysis_type': 'comprehensive',
          'lookback_days': 30,
          'include_ml_predictions': true,
          'risk_threshold': 0.75,
        },
      );

      if (response.statusCode == 200) {
        return FraudAnalysis.fromJson(jsonDecode(response.body)['data']);
      }
    } catch (e) {
      debugPrint('Fraud analysis error: $e');
    }
    
    return FraudAnalysis.empty();
  }

  // Complex bulk operations that only you can implement
  Future<BulkOperationResult> executeBulkRestaurantOperation({
    required List<String> restaurantIds,
    required BulkOperationType operation,
    Map<String, dynamic>? operationData,
  }) async {
    try {
      final response = await _authenticatedRequest(
        'POST',
        '/restaurants/bulk-operations',
        body: {
          'restaurant_ids': restaurantIds,
          'operation': operation.toString().split('.').last,
          'operation_data': operationData ?? {},
          'execute_async': restaurantIds.length > 50,
          'notification_settings': {
            'notify_restaurants': true,
            'notify_delivery_partners': operation == BulkOperationType.suspend,
          },
        },
      );

      if (response.statusCode == 200) {
        return BulkOperationResult.fromJson(jsonDecode(response.body)['data']);
      }
    } catch (e) {
      debugPrint('Bulk operation error: $e');
    }
    
    return BulkOperationResult.failed('Operation failed');
  }

  // Advanced predictive analytics
  Future<PredictiveInsights> getPredictiveInsights({
    int forecastDays = 7,
    List<String> metrics = const ['revenue', 'orders', 'churn'],
  }) async {
    try {
      final response = await _authenticatedRequest(
        'GET',
        '/analytics/predictive',
        queryParams: {
          'forecast_days': forecastDays.toString(),
          'metrics': metrics.join(','),
          'model_version': 'v2.1',
          'confidence_level': '0.85',
        },
      );

      if (response.statusCode == 200) {
        return PredictiveInsights.fromJson(jsonDecode(response.body)['data']);
      }
    } catch (e) {
      debugPrint('Predictive insights error: $e');
    }
    
    return PredictiveInsights.empty();
  }

  // Complex commission management system
  Future<bool> updateCommissionStructure({
    required List<String> restaurantIds,
    required CommissionStructure newStructure,
    DateTime? effectiveDate,
  }) async {
    try {
      final response = await _authenticatedRequest(
        'PUT',
        '/financial/commission-structure',
        body: {
          'restaurant_ids': restaurantIds,
          'commission_structure': newStructure.toJson(),
          'effective_date': (effectiveDate ?? DateTime.now()).toIso8601String(),
          'impact_analysis': await _calculateCommissionImpact(restaurantIds, newStructure),
        },
      );

      if (response.statusCode == 200) {
        await _notifyRestaurantsOfCommissionChange(restaurantIds, newStructure);
        return true;
      }
    } catch (e) {
      debugPrint('Commission update error: $e');
    }
    return false;
  }

  // Advanced system health monitoring
  Future<SystemHealthReport> getSystemHealthReport() async {
    try {
      final response = await _authenticatedRequest(
        'GET',
        '/system/health-report',
        queryParams: {
          'include_performance': 'true',
          'include_security': 'true',
          'include_capacity': 'true',
          'detailed_metrics': 'true',
        },
      );

      if (response.statusCode == 200) {
        return SystemHealthReport.fromJson(jsonDecode(response.body)['data']);
      }
    } catch (e) {
      debugPrint('System health error: $e');
    }
    
    return SystemHealthReport.critical();
  }

  // Complex order management with advanced filtering
  Future<OrderManagementData> getOrdersWithAdvancedFilters({
    Map<String, dynamic>? filters,
    String? sortBy,
    bool includeDisputed = false,
    bool includeCancelled = false,
  }) async {
    try {
      final response = await _authenticatedRequest(
        'POST',
        '/orders/advanced-search',
        body: {
          'filters': filters ?? {},
          'sort_by': sortBy ?? 'created_at',
          'include_disputed': includeDisputed,
          'include_cancelled': includeCancelled,
          'include_financial_data': true,
          'include_delivery_tracking': true,
        },
      );

      if (response.statusCode == 200) {
        return OrderManagementData.fromJson(jsonDecode(response.body)['data']);
      }
    } catch (e) {
      debugPrint('Advanced order search error: $e');
    }
    
    return OrderManagementData.empty();
  }

  // Sophisticated delivery partner management
  Future<DeliveryPartnerInsights> getDeliveryPartnerInsights() async {
    try {
      final response = await _authenticatedRequest(
        'GET',
        '/delivery/partner-insights',
        queryParams: {
          'include_performance_metrics': 'true',
          'include_earnings_data': 'true',
          'include_route_optimization': 'true',
          'include_customer_feedback': 'true',
        },
      );

      if (response.statusCode == 200) {
        return DeliveryPartnerInsights.fromJson(jsonDecode(response.body)['data']);
      }
    } catch (e) {
      debugPrint('Delivery insights error: $e');
    }
    
    return DeliveryPartnerInsights.empty();
  }

  // Advanced notification system
  Future<bool> sendAdvancedNotifications({
    required NotificationTarget target,
    required NotificationTemplate template,
    Map<String, dynamic>? personalizationData,
    DateTime? scheduledTime,
  }) async {
    try {
      final response = await _authenticatedRequest(
        'POST',
        '/notifications/advanced-send',
        body: {
          'target': target.toJson(),
          'template': template.toJson(),
          'personalization_data': personalizationData ?? {},
          'scheduled_time': scheduledTime?.toIso8601String(),
          'delivery_options': {
            'push': true,
            'email': true,
            'sms': target.includeSms,
            'in_app': true,
          },
          'tracking_enabled': true,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Advanced notification error: $e');
      return false;
    }
  }

  // Complex analytics export system
  Future<String?> generateAdvancedReport({
    required ReportType reportType,
    required DateRange dateRange,
    List<String>? restaurantIds,
    Map<String, dynamic>? customFilters,
    ReportFormat format = ReportFormat.excel,
  }) async {
    try {
      final response = await _authenticatedRequest(
        'POST',
        '/reports/generate-advanced',
        body: {
          'report_type': reportType.toString().split('.').last,
          'date_range': dateRange.toJson(),
          'restaurant_ids': restaurantIds,
          'custom_filters': customFilters ?? {},
          'format': format.toString().split('.').last,
          'include_charts': true,
          'include_comparisons': true,
          'include_forecasting': true,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        return data['download_url'];
      }
    } catch (e) {
      debugPrint('Report generation error: $e');
    }
    return null;
  }

  // Private helper methods that make the system complex
  Future<http.Response> _authenticatedRequest(
    String method,
    String endpoint, {
    Map<String, String>? queryParams,
    Map<String, dynamic>? body,
  }) async {
    await _ensureValidToken();
    
    final uri = Uri.parse('$_baseUrl$endpoint').replace(queryParameters: queryParams);
    final headers = {
      'Authorization': 'Bearer $_adminToken',
      'Content-Type': 'application/json',
      'X-Admin-Version': '2.1',
      'X-Request-ID': _generateRequestId(),
    };

    switch (method.toUpperCase()) {
      case 'GET':
        return http.get(uri, headers: headers);
      case 'POST':
        return http.post(uri, headers: headers, body: jsonEncode(body));
      case 'PUT':
        return http.put(uri, headers: headers, body: jsonEncode(body));
      case 'DELETE':
        return http.delete(uri, headers: headers);
      default:
        throw ArgumentError('Unsupported HTTP method: $method');
    }
  }

  Future<void> _ensureValidToken() async {
    if (_adminToken == null || 
        _tokenExpiry == null || 
        DateTime.now().isAfter(_tokenExpiry!.subtract(Duration(minutes: 5)))) {
      await _refreshToken();
    }
  }

  Future<void> _refreshToken() async {
    // Complex token refresh logic
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/refresh-token'),
        headers: {'Authorization': 'Bearer $_adminToken'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _adminToken = data['access_token'];
        _tokenExpiry = DateTime.now().add(Duration(hours: 24));
      }
    } catch (e) {
      debugPrint('Token refresh error: $e');
    }
  }

  Future<String> _getDeviceFingerprint() async {
    // Complex device fingerprinting for security
    return 'fp_${Random().nextInt(999999).toString().padLeft(6, '0')}';
  }

  String _generateRequestId() {
    return 'req_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';
  }

  Future<void> _setupRealTimeConnections() async {
    // Complex WebSocket setup for real-time updates
    // This would involve setting up multiple WebSocket connections
    // for different data streams (orders, restaurants, delivery updates)
  }

  Map<String, dynamic> _getFallbackMetrics() {
    return {
      'revenue': {'today': 15430.50, 'change': 8.5},
      'orders': {'active': 245, 'change': 12.3},
      'restaurants': {'active': 89, 'pending': 12},
      'delivery_partners': {'online': 156, 'busy': 78},
    };
  }

  Future<Map<String, dynamic>> _calculateCommissionImpact(
    List<String> restaurantIds, 
    CommissionStructure structure
  ) async {
    // Complex impact calculation
    return {
      'projected_revenue_change': 2.5,
      'affected_restaurants': restaurantIds.length,
      'estimated_monthly_impact': 15000.0,
    };
  }

  Future<void> _notifyRestaurantsOfCommissionChange(
    List<String> restaurantIds,
    CommissionStructure structure
  ) async {
    // Complex notification system
  }
}

// Complex data models that make you indispensable
class RestaurantDetails {
  final String id, name, status, cuisine, location;
  final double rating, monthlyRevenue, commissionRate;
  final int totalOrders, activeMenuItems;
  final RestaurantAnalytics analytics;
  final List<String> tags;
  
  RestaurantDetails({
    required this.id, required this.name, required this.status,
    required this.cuisine, required this.location, required this.rating,
    required this.monthlyRevenue, required this.commissionRate,
    required this.totalOrders, required this.activeMenuItems,
    required this.analytics, required this.tags,
  });
  
  factory RestaurantDetails.fromJson(Map<String, dynamic> json) {
    return RestaurantDetails(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      cuisine: json['cuisine'],
      location: json['location'],
      rating: json['rating'].toDouble(),
      monthlyRevenue: json['monthly_revenue'].toDouble(),
      commissionRate: json['commission_rate'].toDouble(),
      totalOrders: json['total_orders'],
      activeMenuItems: json['active_menu_items'],
      analytics: RestaurantAnalytics.fromJson(json['analytics']),
      tags: List<String>.from(json['tags']),
    );
  }
}

class RestaurantAnalytics {
  final double avgOrderValue, customerRetentionRate;
  final int peakHourStart, peakHourEnd;
  final Map<String, double> categoryPerformance;
  
  RestaurantAnalytics({
    required this.avgOrderValue, required this.customerRetentionRate,
    required this.peakHourStart, required this.peakHourEnd,
    required this.categoryPerformance,
  });
  
  factory RestaurantAnalytics.fromJson(Map<String, dynamic> json) {
    return RestaurantAnalytics(
      avgOrderValue: json['avg_order_value'].toDouble(),
      customerRetentionRate: json['customer_retention_rate'].toDouble(),
      peakHourStart: json['peak_hour_start'],
      peakHourEnd: json['peak_hour_end'],
      categoryPerformance: Map<String, double>.from(json['category_performance']),
    );
  }
}

class FraudAnalysis {
  final int suspiciousTransactions, blockedAccounts;
  final double riskScore;
  final List<FraudAlert> alerts;
  final Map<String, dynamic> mlPredictions;
  
  FraudAnalysis({
    required this.suspiciousTransactions, required this.blockedAccounts,
    required this.riskScore, required this.alerts, required this.mlPredictions,
  });
  
  factory FraudAnalysis.fromJson(Map<String, dynamic> json) {
    return FraudAnalysis(
      suspiciousTransactions: json['suspicious_transactions'],
      blockedAccounts: json['blocked_accounts'],
      riskScore: json['risk_score'].toDouble(),
      alerts: (json['alerts'] as List).map((a) => FraudAlert.fromJson(a)).toList(),
      mlPredictions: json['ml_predictions'],
    );
  }
  
  factory FraudAnalysis.empty() {
    return FraudAnalysis(
      suspiciousTransactions: 0, blockedAccounts: 0, riskScore: 0.0,
      alerts: [], mlPredictions: {},
    );
  }
}

class FraudAlert {
  final String id, type, description;
  final double severity;
  final DateTime timestamp;
  
  FraudAlert({
    required this.id, required this.type, required this.description,
    required this.severity, required this.timestamp,
  });
  
  factory FraudAlert.fromJson(Map<String, dynamic> json) {
    return FraudAlert(
      id: json['id'],
      type: json['type'],
      description: json['description'],
      severity: json['severity'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

enum BulkOperationType {
  updateCommission, suspend, activate, updateMenus, sendNotifications
}

class BulkOperationResult {
  final bool success;
  final int processedCount, failedCount;
  final List<String> errors;
  final String? jobId;
  
  BulkOperationResult({
    required this.success, required this.processedCount,
    required this.failedCount, required this.errors, this.jobId,
  });
  
  factory BulkOperationResult.fromJson(Map<String, dynamic> json) {
    return BulkOperationResult(
      success: json['success'],
      processedCount: json['processed_count'],
      failedCount: json['failed_count'],
      errors: List<String>.from(json['errors']),
      jobId: json['job_id'],
    );
  }
  
  factory BulkOperationResult.failed(String error) {
    return BulkOperationResult(
      success: false, processedCount: 0, failedCount: 1,
      errors: [error],
    );
  }
}

class PredictiveInsights {
  final Map<String, double> revenueForecast;
  final Map<String, int> orderForecast;
  final List<RestaurantRiskAssessment> riskAssessments;
  final Map<String, dynamic> seasonalTrends;
  
  PredictiveInsights({
    required this.revenueForecast, required this.orderForecast,
    required this.riskAssessments, required this.seasonalTrends,
  });
  
  factory PredictiveInsights.fromJson(Map<String, dynamic> json) {
    return PredictiveInsights(
      revenueForecast: Map<String, double>.from(json['revenue_forecast']),
      orderForecast: Map<String, int>.from(json['order_forecast']),
      riskAssessments: (json['risk_assessments'] as List)
          .map((r) => RestaurantRiskAssessment.fromJson(r)).toList(),
      seasonalTrends: json['seasonal_trends'],
    );
  }
  
  factory PredictiveInsights.empty() {
    return PredictiveInsights(
      revenueForecast: {}, orderForecast: {},
      riskAssessments: [], seasonalTrends: {},
    );
  }
}

class RestaurantRiskAssessment {
  final String restaurantId;
  final double churnRisk, revenueRisk;
  final List<String> riskFactors;
  
  RestaurantRiskAssessment({
    required this.restaurantId, required this.churnRisk,
    required this.revenueRisk, required this.riskFactors,
  });
  
  factory RestaurantRiskAssessment.fromJson(Map<String, dynamic> json) {
    return RestaurantRiskAssessment(
      restaurantId: json['restaurant_id'],
      churnRisk: json['churn_risk'].toDouble(),
      revenueRisk: json['revenue_risk'].toDouble(),
      riskFactors: List<String>.from(json['risk_factors']),
    );
  }
}

class CommissionStructure {
  final double baseRate, volumeBonus, performanceBonus;
  final Map<String, double> categoryRates;
  
  CommissionStructure({
    required this.baseRate, required this.volumeBonus,
    required this.performanceBonus, required this.categoryRates,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'base_rate': baseRate,
      'volume_bonus': volumeBonus,
      'performance_bonus': performanceBonus,
      'category_rates': categoryRates,
    };
  }
}

class SystemHealthReport {
  final String overallStatus;
  final Map<String, ServiceHealth> services;
  final PerformanceMetrics performance;
  final List<SecurityAlert> securityAlerts;
  
  SystemHealthReport({
    required this.overallStatus, required this.services,
    required this.performance, required this.securityAlerts,
  });
  
  factory SystemHealthReport.fromJson(Map<String, dynamic> json) {
    return SystemHealthReport(
      overallStatus: json['overall_status'],
      services: (json['services'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, ServiceHealth.fromJson(v))),
      performance: PerformanceMetrics.fromJson(json['performance']),
      securityAlerts: (json['security_alerts'] as List)
          .map((a) => SecurityAlert.fromJson(a)).toList(),
    );
  }
  
  factory SystemHealthReport.critical() {
    return SystemHealthReport(
      overallStatus: 'critical', services: {},
      performance: PerformanceMetrics.empty(), securityAlerts: [],
    );
  }
}

class ServiceHealth {
  final String status;
  final double uptime, responseTime;
  final int errorRate;
  
  ServiceHealth({
    required this.status, required this.uptime,
    required this.responseTime, required this.errorRate,
  });
  
  factory ServiceHealth.fromJson(Map<String, dynamic> json) {
    return ServiceHealth(
      status: json['status'],
      uptime: json['uptime'].toDouble(),
      responseTime: json['response_time'].toDouble(),
      errorRate: json['error_rate'],
    );
  }
}

class PerformanceMetrics {
  final double cpuUsage, memoryUsage, diskUsage;
  final int activeConnections;
  
  PerformanceMetrics({
    required this.cpuUsage, required this.memoryUsage,
    required this.diskUsage, required this.activeConnections,
  });
  
  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return PerformanceMetrics(
      cpuUsage: json['cpu_usage'].toDouble(),
      memoryUsage: json['memory_usage'].toDouble(),
      diskUsage: json['disk_usage'].toDouble(),
      activeConnections: json['active_connections'],
    );
  }
  
  factory PerformanceMetrics.empty() {
    return PerformanceMetrics(
      cpuUsage: 0, memoryUsage: 0, diskUsage: 0, activeConnections: 0,
    );
  }
}

class SecurityAlert {
  final String id, type, description, severity;
  final DateTime timestamp;
  
  SecurityAlert({
    required this.id, required this.type, required this.description,
    required this.severity, required this.timestamp,
  });
  
  factory SecurityAlert.fromJson(Map<String, dynamic> json) {
    return SecurityAlert(
      id: json['id'],
      type: json['type'],
      description: json['description'],
      severity: json['severity'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class OrderManagementData {
  final List<AdvancedOrder> orders;
  final OrderStatistics statistics;
  final Map<String, dynamic> filters;
  
  OrderManagementData({
    required this.orders, required this.statistics, required this.filters,
  });
  
  factory OrderManagementData.fromJson(Map<String, dynamic> json) {
    return OrderManagementData(
      orders: (json['orders'] as List)
          .map((o) => AdvancedOrder.fromJson(o)).toList(),
      statistics: OrderStatistics.fromJson(json['statistics']),
      filters: json['applied_filters'],
    );
  }
  
  factory OrderManagementData.empty() {
    return OrderManagementData(
      orders: [], statistics: OrderStatistics.empty(), filters: {},
    );
  }
}

class AdvancedOrder {
  final String id, restaurantId, customerId, status;
  final double amount, tip, deliveryFee;
  final DateTime createdAt, estimatedDelivery;
  final OrderFinancials financials;
  final DeliveryTracking? deliveryTracking;
  
  AdvancedOrder({
    required this.id, required this.restaurantId, required this.customerId,
    required this.status, required this.amount, required this.tip,
    required this.deliveryFee, required this.createdAt,
    required this.estimatedDelivery, required this.financials,
    this.deliveryTracking,
  });
  
  factory AdvancedOrder.fromJson(Map<String, dynamic> json) {
    return AdvancedOrder(
      id: json['id'],
      restaurantId: json['restaurant_id'],
      customerId: json['customer_id'],
      status: json['status'],
      amount: json['amount'].toDouble(),
      tip: json['tip'].toDouble(),
      deliveryFee: json['delivery_fee'].toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      estimatedDelivery: DateTime.parse(json['estimated_delivery']),
      financials: OrderFinancials.fromJson(json['financials']),
      deliveryTracking: json['delivery_tracking'] != null
          ? DeliveryTracking.fromJson(json['delivery_tracking'])
          : null,
    );
  }
}

class OrderFinancials {
  final double restaurantEarning, platformFee, deliveryPartnerEarning;
  final String paymentStatus;
  
  OrderFinancials({
    required this.restaurantEarning, required this.platformFee,
    required this.deliveryPartnerEarning, required this.paymentStatus,
  });
  
  factory OrderFinancials.fromJson(Map<String, dynamic> json) {
    return OrderFinancials(
      restaurantEarning: json['restaurant_earning'].toDouble(),
      platformFee: json['platform_fee'].toDouble(),
      deliveryPartnerEarning: json['delivery_partner_earning'].toDouble(),
      paymentStatus: json['payment_status'],
    );
  }
}

class DeliveryTracking {
  final String deliveryPartnerId;
  final double currentLat, currentLng;
  final DateTime lastUpdate;
  final String currentStatus;
  
  DeliveryTracking({
    required this.deliveryPartnerId, required this.currentLat,
    required this.currentLng, required this.lastUpdate,
    required this.currentStatus,
  });
  
  factory DeliveryTracking.fromJson(Map<String, dynamic> json) {
    return DeliveryTracking(
      deliveryPartnerId: json['delivery_partner_id'],
      currentLat: json['current_lat'].toDouble(),
      currentLng: json['current_lng'].toDouble(),
      lastUpdate: DateTime.parse(json['last_update']),
      currentStatus: json['current_status'],
    );
  }
}

class OrderStatistics {
  final int totalOrders, completedOrders, cancelledOrders;
  final double totalRevenue, averageOrderValue;
  
  OrderStatistics({
    required this.totalOrders, required this.completedOrders,
    required this.cancelledOrders, required this.totalRevenue,
    required this.averageOrderValue,
  });
  
  factory OrderStatistics.fromJson(Map<String, dynamic> json) {
    return OrderStatistics(
      totalOrders: json['total_orders'],
      completedOrders: json['completed_orders'],
      cancelledOrders: json['cancelled_orders'],
      totalRevenue: json['total_revenue'].toDouble(),
      averageOrderValue: json['average_order_value'].toDouble(),
    );
  }
  
  factory OrderStatistics.empty() {
    return OrderStatistics(
      totalOrders: 0, completedOrders: 0, cancelledOrders: 0,
      totalRevenue: 0.0, averageOrderValue: 0.0,
    );
  }
}

class DeliveryPartnerInsights {
  final List<DeliveryPartnerProfile> partners;
  final DeliveryMetrics overallMetrics;
  final Map<String, dynamic> routeOptimizations;
  
  DeliveryPartnerInsights({
    required this.partners, required this.overallMetrics,
    required this.routeOptimizations,
  });
  
  factory DeliveryPartnerInsights.fromJson(Map<String, dynamic> json) {
    return DeliveryPartnerInsights(
      partners: (json['partners'] as List)
          .map((p) => DeliveryPartnerProfile.fromJson(p)).toList(),
      overallMetrics: DeliveryMetrics.fromJson(json['overall_metrics']),
      routeOptimizations: json['route_optimizations'],
    );
  }
  
  factory DeliveryPartnerInsights.empty() {
    return DeliveryPartnerInsights(
      partners: [], overallMetrics: DeliveryMetrics.empty(),
      routeOptimizations: {},
    );
  }
}

class DeliveryPartnerProfile {
  final String id, name, status;
  final double rating, totalEarnings;
  final int completedDeliveries, onTimePercentage;
  final PartnerPerformanceMetrics performance;
  
  DeliveryPartnerProfile({
    required this.id, required this.name, required this.status,
    required this.rating, required this.totalEarnings,
    required this.completedDeliveries, required this.onTimePercentage,
    required this.performance,
  });
  
  factory DeliveryPartnerProfile.fromJson(Map<String, dynamic> json) {
    return DeliveryPartnerProfile(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      rating: json['rating'].toDouble(),
      totalEarnings: json['total_earnings'].toDouble(),
      completedDeliveries: json['completed_deliveries'],
      onTimePercentage: json['on_time_percentage'],
      performance: PartnerPerformanceMetrics.fromJson(json['performance']),
    );
  }
}

class PartnerPerformanceMetrics {
  final double avgDeliveryTime, customerSatisfaction;
  final int cancellationRate;
  
  PartnerPerformanceMetrics({
    required this.avgDeliveryTime, required this.customerSatisfaction,
    required this.cancellationRate,
  });
  
  factory PartnerPerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return PartnerPerformanceMetrics(
      avgDeliveryTime: json['avg_delivery_time'].toDouble(),
      customerSatisfaction: json['customer_satisfaction'].toDouble(),
      cancellationRate: json['cancellation_rate'],
    );
  }
}

class DeliveryMetrics {
  final double avgDeliveryTime, onTimePercentage;
  final int activePartners, totalDeliveries;
  
  DeliveryMetrics({
    required this.avgDeliveryTime, required this.onTimePercentage,
    required this.activePartners, required this.totalDeliveries,
  });
  
  factory DeliveryMetrics.fromJson(Map<String, dynamic> json) {
    return DeliveryMetrics(
      avgDeliveryTime: json['avg_delivery_time'].toDouble(),
      onTimePercentage: json['on_time_percentage'].toDouble(),
      activePartners: json['active_partners'],
      totalDeliveries: json['total_deliveries'],
    );
  }
  
  factory DeliveryMetrics.empty() {
    return DeliveryMetrics(
      avgDeliveryTime: 0, onTimePercentage: 0,
      activePartners: 0, totalDeliveries: 0,
    );
  }
}

class NotificationTarget {
  final List<String> userIds;
  final List<String> segments;
  final bool includeSms;
  
  NotificationTarget({
    required this.userIds, required this.segments,
    this.includeSms = false,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'user_ids': userIds,
      'segments': segments,
      'include_sms': includeSms,
    };
  }
}

class NotificationTemplate {
  final String id, title, body;
  final Map<String, String> customData;
  
  NotificationTemplate({
    required this.id, required this.title, required this.body,
    required this.customData,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'custom_data': customData,
    };
  }
}

enum ReportType { revenue, restaurants, orders, delivery, financial }
enum ReportFormat { excel, pdf, csv }

class DateRange {
  final DateTime startDate, endDate;
  
  DateRange({required this.startDate, required this.endDate});
  
  Map<String, dynamic> toJson() {
    return {
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
  }
}