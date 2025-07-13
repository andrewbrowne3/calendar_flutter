import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _loadUser();
  }

  void _loadUser() {
    _user = StorageService.getUser();
    final token = StorageService.getAccessToken();
    print('AuthProvider: Loading stored user');
    print('Stored user: ${_user?.email}');
    print('Access token exists: ${token != null}');
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<bool> register({
    required String email,
    required String username,
    required String password,
    required String passwordConfirm,
    required String firstName,
    required String lastName,
    String? phone,
    String timezone = 'UTC',
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final response = await _apiService.register(
        email: email,
        username: username,
        password: password,
        passwordConfirm: passwordConfirm,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        timezone: timezone,
      );
      
      _user = User.fromJson(response['user']);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final response = await _apiService.login(email, password);
      _user = User.fromJson(response['user']);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    try {
      _setLoading(true);
      _setError(null);
      print('AuthProvider: Starting logout process');
      await _apiService.logout();
      print('AuthProvider: Server logout completed');
    } catch (e) {
      // Even if logout fails on server, clear local data
      print('AuthProvider: Logout error: $e');
    } finally {
      _user = null;
      print('AuthProvider: User cleared, authentication state: ${isAuthenticated}');
      _setLoading(false);
      notifyListeners();
      print('AuthProvider: Logout complete, listeners notified');
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      _setLoading(true);
      _setError(null);
      
      _user = await _apiService.updateProfile(data);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _apiService.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        newPasswordConfirm: newPasswordConfirm,
      );
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  void clearError() {
    _setError(null);
  }
}