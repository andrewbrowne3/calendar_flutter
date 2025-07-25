import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../models/user.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token management
  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _prefs.setString(Constants.accessTokenKey, accessToken);
    await _prefs.setString(Constants.refreshTokenKey, refreshToken);
  }

  static String? getAccessToken() {
    return _prefs.getString(Constants.accessTokenKey);
  }

  static String? getRefreshToken() {
    return _prefs.getString(Constants.refreshTokenKey);
  }

  static Future<void> clearTokens() async {
    await _prefs.remove(Constants.accessTokenKey);
    await _prefs.remove(Constants.refreshTokenKey);
  }

  // User management
  static Future<void> saveUser(User user) async {
    await _prefs.setString(Constants.userKey, jsonEncode(user.toJson()));
  }

  static User? getUser() {
    final userString = _prefs.getString(Constants.userKey);
    if (userString != null) {
      return User.fromJson(jsonDecode(userString));
    }
    return null;
  }

  static Future<void> clearUser() async {
    await _prefs.remove(Constants.userKey);
  }

  // Clear all data
  static Future<void> clearAll() async {
    await _prefs.clear();
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    return getAccessToken() != null;
  }

  // Remember Me functionality
  static Future<void> saveCredentials(String email, String password) async {
    await _prefs.setString('saved_email', email);
    await _prefs.setString('saved_password', password);
  }

  static String? getSavedEmail() {
    return _prefs.getString('saved_email');
  }

  static String? getSavedPassword() {
    return _prefs.getString('saved_password');
  }

  static Future<void> clearCredentials() async {
    await _prefs.remove('saved_email');
    await _prefs.remove('saved_password');
  }

  static Future<void> setRememberMe(bool value) async {
    await _prefs.setBool('remember_me', value);
  }

  static bool getRememberMe() {
    return _prefs.getBool('remember_me') ?? false;
  }
}