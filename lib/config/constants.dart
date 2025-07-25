class Constants {
  // TODO: Change back to https://calendar.andrewbrowne.org when DNS is configured
  static const String baseUrl = 'http://10.0.2.2:8000'; // Android emulator localhost
  // static const String baseUrl = 'http://localhost:8000'; // iOS simulator
  // static const String baseUrl = 'https://calendar.andrewbrowne.org'; // Production
  static const String authUrl = '$baseUrl/api/auth';
  
  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  
  // API endpoints
  static const String register = '$authUrl/register/';
  static const String login = '$authUrl/login/';
  static const String logout = '$authUrl/logout/';
  static const String profile = '$authUrl/profile/';
  static const String changePassword = '$authUrl/change-password/';
  static const String refreshToken = '$authUrl/token/refresh/';
  
  static const String calendars = '$baseUrl/api/calendars/';
  static const String events = '$baseUrl/api/events/';
  static const String goals = '$baseUrl/api/goals/';
  static const String responsibilities = '$baseUrl/api/responsibilities/';
  static const String dashboard = '$baseUrl/api/dashboard/';
}