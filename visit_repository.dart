import 'package:erp_sales_app/models/index.dart';
import 'package:erp_sales_app/services/api_service.dart';
import 'package:erp_sales_app/services/location_service.dart';

class VisitRepository {
  final ApiService _apiService;

  VisitRepository(this._apiService);

  Future<List<SalesVisit>> getVisits({
    int? page,
    int? limit,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _apiService.getVisits(
      page: page,
      limit: limit,
      status: status,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<SalesVisit> getVisit(String id) async {
    return await _apiService.getVisit(id);
  }

  Future<SalesVisit> createVisit(CreateVisitRequest request) async {
    return await _apiService.createVisit(request);
  }

  Future<SalesVisit> updateVisit(String id, Map<String, dynamic> data) async {
    return await _apiService.updateVisit(id, data);
  }

  Future<void> deleteVisit(String id) async {
    await _apiService.deleteVisit(id);
  }

  Future<void> checkIn(String id, {String? notes}) async {
    final location = await LocationService.getCurrentLocation();
    if (location == null) {
      throw Exception('Could not get current location');
    }
    
    await _apiService.checkIn(
      id,
      CheckInRequest(location: location, notes: notes),
    );
  }

  Future<void> checkOut(String id, {
    String? outcome,
    String? notes,
    String? orderId,
    double? orderAmount,
  }) async {
    final location = await LocationService.getCurrentLocation();
    if (location == null) {
      throw Exception('Could not get current location');
    }
    
    await _apiService.checkOut(
      id,
      CheckOutRequest(
        location: location,
        outcome: outcome,
        notes: notes,
        orderId: orderId,
        orderAmount: orderAmount,
      ),
    );
  }

  Future<List<SalesRoute>> getRoutes() async {
    return await _apiService.getRoutes();
  }

  Future<dynamic> getVisitPerformance({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _apiService.getVisitPerformance(
      startDate: startDate,
      endDate: endDate,
    );
  }
}
