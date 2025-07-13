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
}