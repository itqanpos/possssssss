import 'package:erp_sales_app/models/index.dart';
import 'package:erp_sales_app/services/api_service.dart';
import 'package:erp_sales_app/services/local_storage_service.dart';

class CustomerRepository {
  final ApiService _apiService;

  CustomerRepository(this._apiService);

  Future<List<Customer>> getCustomers({
    int? page,
    int? limit,
    String? search,
    String? type,
    String? status,
  }) async {
    try {
      final customers = await _apiService.getCustomers(
        page: page,
        limit: limit,
        search: search,
        type: type,
        status: status,
      );
      
      // Cache for offline use
      if (page == 1 || page == null) {
        await LocalStorageService.cacheCustomers(customers);
      }
      
      return customers;
    } catch (e) {
      // Return cached data if offline
      final cached = LocalStorageService.getCachedCustomers();
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  Future<Customer> getCustomer(String id) async {
    return await _apiService.getCustomer(id);
  }

  Future<Customer> createCustomer(Map<String, dynamic> data) async {
    return await _apiService.createCustomer(data);
  }

  Future<Customer> updateCustomer(String id, Map<String, dynamic> data) async {
    return await _apiService.updateCustomer(id, data);
  }

  Future<void> deleteCustomer(String id) async {
    await _apiService.deleteCustomer(id);
  }

  Future<dynamic> getCustomerStatement(String id, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _apiService.getCustomerStatement(
      id,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
