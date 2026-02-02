import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:erp_sales_app/models/index.dart';
import 'package:erp_sales_app/services/local_storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  String? _token;

  static const String baseUrl = 'https://your-api-url.com/api';
  // For local development
  // static const String baseUrl = 'http://10.0.2.2:5001/api';

  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token
        _token ??= LocalStorageService.getToken();
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired, clear and redirect to login
          await LocalStorageService.clearAll();
        }
        return handler.next(error);
      },
    ));
  }

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  // Auth APIs
  Future<AuthResponse> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return AuthResponse.fromJson(response.data['data']);
  }

  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }

  Future<AuthResponse> refreshToken() async {
    final response = await _dio.post('/auth/refresh');
    return AuthResponse.fromJson(response.data['data']);
  }

  // Dashboard APIs
  Future<DashboardStats> getDashboardStats({String? period}) async {
    final response = await _dio.get('/dashboard/stats', queryParameters: {
      if (period != null) 'period': period,
    });
    return DashboardStats.fromJson(response.data['data']);
  }

  Future<List<SalesChartData>> getSalesChart({int? days}) async {
    final response = await _dio.get('/dashboard/charts/sales', queryParameters: {
      if (days != null) 'days': days,
    });
    return (response.data['data'] as List)
        .map((e) => SalesChartData.fromJson(e))
        .toList();
  }

  Future<List<TopProduct>> getTopProducts({int? limit, String? period}) async {
    final response = await _dio.get('/dashboard/top-products', queryParameters: {
      if (limit != null) 'limit': limit,
      if (period != null) 'period': period,
    });
    return (response.data['data'] as List)
        .map((e) => TopProduct.fromJson(e))
        .toList();
  }

  Future<List<NotificationModel>> getNotifications({
    bool? unreadOnly,
    int? limit,
  }) async {
    final response = await _dio.get('/dashboard/notifications', queryParameters: {
      if (unreadOnly != null) 'unreadOnly': unreadOnly,
      if (limit != null) 'limit': limit,
    });
    return (response.data['data']['notifications'] as List)
        .map((e) => NotificationModel.fromJson(e))
        .toList();
  }

  Future<void> markNotificationRead(String id) async {
    await _dio.patch('/dashboard/notifications/$id/read');
  }

  // Customer APIs
  Future<List<Customer>> getCustomers({
    int? page,
    int? limit,
    String? search,
    String? type,
    String? status,
  }) async {
    final response = await _dio.get('/customers', queryParameters: {
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
      if (search != null) 'search': search,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
    });
    return (response.data['data']['customers'] as List)
        .map((e) => Customer.fromJson(e))
        .toList();
  }

  Future<Customer> getCustomer(String id) async {
    final response = await _dio.get('/customers/$id');
    return Customer.fromJson(response.data['data']);
  }

  Future<Customer> createCustomer(Map<String, dynamic> data) async {
    final response = await _dio.post('/customers', data: data);
    return Customer.fromJson(response.data['data']);
  }

  Future<Customer> updateCustomer(String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/customers/$id', data: data);
    return Customer.fromJson(response.data['data']);
  }

  Future<void> deleteCustomer(String id) async {
    await _dio.delete('/customers/$id');
  }

  Future<dynamic> getCustomerStatement(String id, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _dio.get('/customers/$id/statement', queryParameters: {
      if (startDate != null) 'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate.toIso8601String(),
    });
    return response.data['data'];
  }

  // Product APIs
  Future<List<Product>> getProducts({
    int? page,
    int? limit,
    String? search,
    String? categoryId,
    String? status,
    bool? lowStock,
  }) async {
    final response = await _dio.get('/products', queryParameters: {
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
      if (search != null) 'search': search,
      if (categoryId != null) 'categoryId': categoryId,
      if (status != null) 'status': status,
      if (lowStock != null) 'lowStock': lowStock,
    });
    return (response.data['data']['products'] as List)
        .map((e) => Product.fromJson(e))
        .toList();
  }

  Future<Product> getProduct(String id) async {
    final response = await _dio.get('/products/$id');
    return Product.fromJson(response.data['data']);
  }

  // Sale APIs
  Future<List<Sale>> getSales({
    int? page,
    int? limit,
    String? search,
    String? status,
    String? customerId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _dio.get('/sales', queryParameters: {
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
      if (search != null) 'search': search,
      if (status != null) 'status': status,
      if (customerId != null) 'customerId': customerId,
      if (startDate != null) 'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate.toIso8601String(),
    });
    return (response.data['data']['sales'] as List)
        .map((e) => Sale.fromJson(e))
        .toList();
  }

  Future<Sale> getSale(String id) async {
    final response = await _dio.get('/sales/$id');
    return Sale.fromJson(response.data['data']);
  }

  Future<Sale> createSale(CreateSaleRequest request) async {
    final response = await _dio.post('/sales', data: request.toJson());
    return Sale.fromJson(response.data['data']);
  }

  Future<void> addPayment(String saleId, {
    required double amount,
    required String method,
    String? reference,
    String? notes,
  }) async {
    await _dio.post('/sales/$saleId/payments', data: {
      'amount': amount,
      'method': method,
      if (reference != null) 'reference': reference,
      if (notes != null) 'notes': notes,
    });
  }

  // Visit APIs
  Future<List<SalesVisit>> getVisits({
    int? page,
    int? limit,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _dio.get('/sales-visits', queryParameters: {
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
      if (status != null) 'status': status,
      if (startDate != null) 'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate.toIso8601String(),
    });
    return (response.data['data']['visits'] as List)
        .map((e) => SalesVisit.fromJson(e))
        .toList();
  }

  Future<SalesVisit> getVisit(String id) async {
    final response = await _dio.get('/sales-visits/$id');
    return SalesVisit.fromJson(response.data['data']);
  }

  Future<SalesVisit> createVisit(CreateVisitRequest request) async {
    final response = await _dio.post('/sales-visits', data: request.toJson());
    return SalesVisit.fromJson(response.data['data']);
  }

  Future<SalesVisit> updateVisit(String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/sales-visits/$id', data: data);
    return SalesVisit.fromJson(response.data['data']);
  }

  Future<void> checkIn(String id, CheckInRequest request) async {
    await _dio.post('/sales-visits/$id/check-in', data: request.toJson());
  }

  Future<void> checkOut(String id, CheckOutRequest request) async {
    await _dio.post('/sales-visits/$id/check-out', data: request.toJson());
  }

  Future<void> deleteVisit(String id) async {
    await _dio.delete('/sales-visits/$id');
  }

  Future<List<SalesRoute>> getRoutes() async {
    final response = await _dio.get('/sales-visits/routes/list');
    return (response.data['data'] as List)
        .map((e) => SalesRoute.fromJson(e))
        .toList();
  }

  Future<dynamic> getVisitPerformance({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _dio.get('/sales-visits/reports/performance', queryParameters: {
      if (startDate != null) 'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate.toIso8601String(),
    });
    return response.data['data'];
  }

  // Upload file
  Future<String> uploadFile(File file, String path) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
    });
    final response = await _dio.post('/upload/$path', data: formData);
    return response.data['data']['url'];
  }
}
