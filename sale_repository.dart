import 'package:erp_sales_app/models/index.dart';
import 'package:erp_sales_app/services/api_service.dart';
import 'package:erp_sales_app/services/local_storage_service.dart';

class SaleRepository {
  final ApiService _apiService;

  SaleRepository(this._apiService);

  Future<List<Sale>> getSales({
    int? page,
    int? limit,
    String? search,
    String? status,
    String? customerId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _apiService.getSales(
      page: page,
      limit: limit,
      search: search,
      status: status,
      customerId: customerId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<Sale> getSale(String id) async {
    return await _apiService.getSale(id);
  }

  Future<Sale> createSale(CreateSaleRequest request) async {
    try {
      return await _apiService.createSale(request);
    } catch (e) {
      // Store for sync when offline
      await LocalStorageService.addOfflineData({
        'type': 'sale',
        'data': request.toJson(),
      });
      rethrow;
    }
  }

  Future<void> addPayment(String saleId, {
    required double amount,
    required String method,
    String? reference,
    String? notes,
  }) async {
    await _apiService.addPayment(
      saleId,
      amount: amount,
      method: method,
      reference: reference,
      notes: notes,
    );
  }

  Future<List<Product>> getProducts({
    int? page,
    int? limit,
    String? search,
  }) async {
    try {
      final products = await _apiService.getProducts(
        page: page,
        limit: limit,
        search: search,
      );
      
      // Cache for offline use
      if (page == 1 || page == null) {
        await LocalStorageService.cacheProducts(products);
      }
      
      return products;
    } catch (e) {
      // Return cached data if offline
      final cached = LocalStorageService.getCachedProducts();
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  Future<Product> getProduct(String id) async {
    return await _apiService.getProduct(id);
  }
}
