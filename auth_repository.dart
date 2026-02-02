import 'package:erp_sales_app/models/index.dart';
import 'package:erp_sales_app/services/api_service.dart';
import 'package:erp_sales_app/services/local_storage_service.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  Future<AuthResponse> login(String email, String password) async {
    final response = await _apiService.login(email, password);
    await LocalStorageService.setToken(response.token);
    await LocalStorageService.setUser(response.user);
    _apiService.setToken(response.token);
    return response;
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      // Ignore error
    }
    _apiService.clearToken();
    await LocalStorageService.clearAll();
  }

  Future<AuthResponse?> checkAuth() async {
    final token = LocalStorageService.getToken();
    final user = LocalStorageService.getUser();
    
    if (token != null && user != null) {
      _apiService.setToken(token);
      return AuthResponse(user: user, token: token);
    }
    return null;
  }

  Future<AuthResponse> refreshToken() async {
    final response = await _apiService.refreshToken();
    await LocalStorageService.setToken(response.token);
    await LocalStorageService.setUser(response.user);
    _apiService.setToken(response.token);
    return response;
  }

  User? getCurrentUser() {
    return LocalStorageService.getUser();
  }

  bool isLoggedIn() {
    return LocalStorageService.isLoggedIn();
  }
}
