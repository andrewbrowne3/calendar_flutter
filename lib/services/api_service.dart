import 'package:dio/dio.dart';
import '../config/constants.dart';
import '../services/storage_service.dart';
import '../models/user.dart';
import '../models/calendar.dart';
import '../models/event.dart';
import '../models/goal.dart';
import '../models/responsibility.dart';

class ApiService {
  late Dio _dio;
  
  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: Constants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add interceptor for authentication
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = StorageService.getAccessToken();
        print('Request to: ${options.path}');
        print('Token available: ${token != null}');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          print('Auth header set');
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 && 
            !error.requestOptions.path.contains('token/refresh')) {
          // Try to refresh token (but don't refresh if already refreshing)
          final refreshToken = StorageService.getRefreshToken();
          if (refreshToken != null) {
            try {
              // Create a new Dio instance to avoid interceptor loop
              final refreshDio = Dio(BaseOptions(baseUrl: Constants.baseUrl));
              final response = await refreshDio.post(
                '/api/auth/token/refresh/',
                data: {'refresh': refreshToken},
              );
              
              final newAccessToken = response.data['access'];
              await StorageService.saveTokens(newAccessToken, refreshToken);
              
              // Retry original request
              error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
              final cloneReq = await _dio.request(
                error.requestOptions.path,
                options: Options(
                  method: error.requestOptions.method,
                  headers: error.requestOptions.headers,
                ),
                data: error.requestOptions.data,
                queryParameters: error.requestOptions.queryParameters,
              );
              
              return handler.resolve(cloneReq);
            } catch (e) {
              print('Refresh token failed: $e');
              // Refresh failed, clear tokens
              await StorageService.clearAll();
            }
          } else {
            // No refresh token, clear all
            await StorageService.clearAll();
          }
        }
        handler.next(error);
      },
    ));
  }

  // Authentication methods
  Future<Map<String, dynamic>> register({
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
      final response = await _dio.post(
        Constants.register,
        data: {
          'email': email,
          'username': username,
          'password': password,
          'password_confirm': passwordConfirm,
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'timezone': timezone,
        },
      );
      
      final user = User.fromJson(response.data['user']);
      await StorageService.saveUser(user);
      await StorageService.saveTokens(
        response.data['access'],
        response.data['refresh'],
      );
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        Constants.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      
      final user = User.fromJson(response.data['user']);
      await StorageService.saveUser(user);
      await StorageService.saveTokens(
        response.data['access'],
        response.data['refresh'],
      );
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      print('ApiService: Starting logout');
      final refreshToken = StorageService.getRefreshToken();
      if (refreshToken != null) {
        print('ApiService: Sending logout request to server');
        await _dio.post(
          Constants.logout,
          data: {'refresh': refreshToken},
        );
        print('ApiService: Server logout successful');
      } else {
        print('ApiService: No refresh token found');
      }
    } catch (e) {
      print('ApiService: Logout request failed: $e');
    } finally {
      print('ApiService: Clearing all storage');
      await StorageService.clearAll();
      print('ApiService: Storage cleared');
    }
  }

  Future<User> getProfile() async {
    try {
      final response = await _dio.get(Constants.profile);
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch(Constants.profile, data: data);
      final user = User.fromJson(response.data);
      await StorageService.saveUser(user);
      return user;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    try {
      await _dio.post(
        Constants.changePassword,
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
          'new_password_confirm': newPasswordConfirm,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Calendar methods
  Future<List<Calendar>> getCalendars() async {
    try {
      final response = await _dio.get(Constants.calendars);
      
      print('Calendar API Response: ${response.statusCode}');
      print('Calendar Response data: ${response.data}');
      print('Calendar Response data type: ${response.data.runtimeType}');
      
      // Handle null or empty response
      if (response.data == null) {
        print('Calendar response data is null, returning empty list');
        return [];
      }
      
      // Handle different response formats
      if (response.data is List) {
        final List<dynamic> dataList = response.data as List;
        return dataList.map((json) => Calendar.fromJson(json)).toList();
      } else if (response.data is Map) {
        // Check if it's a paginated response
        final Map<String, dynamic> dataMap = response.data as Map<String, dynamic>;
        if (dataMap.containsKey('results')) {
          final List<dynamic> results = dataMap['results'] as List? ?? [];
          return results.map((json) => Calendar.fromJson(json)).toList();
        } else if (dataMap.containsKey('data')) {
          final List<dynamic> data = dataMap['data'] as List? ?? [];
          return data.map((json) => Calendar.fromJson(json)).toList();
        }
      }
      
      print('Unexpected calendar response format, returning empty list');
      return [];
      
    } on DioException catch (e) {
      print('DioException fetching calendars: ${e.message}');
      print('Calendar error response: ${e.response?.data}');
      print('Calendar error status code: ${e.response?.statusCode}');
      throw _handleError(e);
    } catch (e) {
      print('Unexpected error fetching calendars: $e');
      throw 'Failed to load calendars. Please try again.';
    }
  }

  Future<Calendar> createCalendar(Calendar calendar) async {
    try {
      final response = await _dio.post(
        Constants.calendars,
        data: calendar.toJson(),
      );
      return Calendar.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Calendar> updateCalendar(String calendarId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch(
        '${Constants.calendars}$calendarId/',
        data: data,
      );
      return Calendar.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteCalendar(String calendarId) async {
    try {
      await _dio.delete('${Constants.calendars}$calendarId/');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<CalendarShare>> getCalendarShares(String calendarId) async {
    try {
      final response = await _dio.get('${Constants.calendars}$calendarId/shares/');
      return (response.data as List)
          .map((json) => CalendarShare.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<CalendarShare> shareCalendar(String calendarId, String userEmail, String permission) async {
    try {
      final response = await _dio.post(
        '${Constants.calendars}$calendarId/shares/',
        data: {
          'user_email': userEmail,
          'permission': permission,
        },
      );
      return CalendarShare.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Event methods
  Future<List<Event>> getEvents({
    String? startDate,
    String? endDate,
    String? calendarId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;
      if (calendarId != null) queryParams['calendar_id'] = calendarId;

      print('Fetching events from: ${Constants.events}');
      print('Query params: $queryParams');
      
      final response = await _dio.get(
        Constants.events,
        queryParameters: queryParams,
      );
      
      print('API Response: ${response.statusCode}');
      print('Response data: ${response.data}');
      print('Response data type: ${response.data.runtimeType}');
      
      // Handle null or empty response
      if (response.data == null) {
        print('Response data is null, returning empty list');
        return [];
      }
      
      // Handle different response formats
      if (response.data is List) {
        final List<dynamic> dataList = response.data as List;
        return dataList.map((json) => Event.fromJson(json)).toList();
      } else if (response.data is Map) {
        // Check if it's a paginated response
        final Map<String, dynamic> dataMap = response.data as Map<String, dynamic>;
        if (dataMap.containsKey('results')) {
          final List<dynamic> results = dataMap['results'] as List? ?? [];
          return results.map((json) => Event.fromJson(json)).toList();
        } else if (dataMap.containsKey('data')) {
          final List<dynamic> data = dataMap['data'] as List? ?? [];
          return data.map((json) => Event.fromJson(json)).toList();
        }
      }
      
      print('Unexpected response format, returning empty list');
      return [];
      
    } on DioException catch (e) {
      print('DioException fetching events: ${e.message}');
      print('Error response: ${e.response?.data}');
      print('Error status code: ${e.response?.statusCode}');
      throw _handleError(e);
    } catch (e) {
      print('Unexpected error fetching events: $e');
      throw 'Failed to load events. Please try again.';
    }
  }

  Future<Event> createEvent(Event event, {
    List<String>? attendeeEmails,
    List<int>? reminderMinutes,
  }) async {
    try {
      final data = event.toJson();
      if (attendeeEmails != null) data['attendee_emails'] = attendeeEmails;
      if (reminderMinutes != null) data['reminder_minutes'] = reminderMinutes;

      final response = await _dio.post(Constants.events, data: data);
      return Event.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Event> updateEvent(String eventId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch(
        '${Constants.events}$eventId/',
        data: data,
      );
      return Event.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _dio.delete('${Constants.events}$eventId/');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<EventAttendee> respondToEvent(String eventId, String response) async {
    try {
      final res = await _dio.post(
        '${Constants.events}$eventId/response/',
        data: {'response': response},
      );
      return EventAttendee.fromJson(res.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<EventReminder>> getEventReminders(String eventId) async {
    try {
      final response = await _dio.get('${Constants.events}$eventId/reminders/');
      return (response.data as List)
          .map((json) => EventReminder.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<EventReminder> addEventReminder(String eventId, EventReminder reminder) async {
    try {
      final response = await _dio.post(
        '${Constants.events}$eventId/reminders/',
        data: reminder.toJson(),
      );
      return EventReminder.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Goal methods
  Future<List<Goal>> getGoals({
    String? frequency,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (frequency != null) queryParams['frequency'] = frequency;
      if (status != null) queryParams['status'] = status;

      final response = await _dio.get(
        Constants.goals,
        queryParameters: queryParams,
      );
      
      print('Goals API Response: ${response.statusCode}');
      print('Goals Response data: ${response.data}');
      print('Goals Response data type: ${response.data.runtimeType}');
      
      // Handle null or empty response
      if (response.data == null) {
        print('Goals response data is null, returning empty list');
        return [];
      }
      
      // Handle different response formats
      if (response.data is List) {
        final List<dynamic> dataList = response.data as List;
        return dataList.map((json) => Goal.fromJson(json)).toList();
      } else if (response.data is Map) {
        // Check if it's a paginated response
        final Map<String, dynamic> dataMap = response.data as Map<String, dynamic>;
        if (dataMap.containsKey('results')) {
          final List<dynamic> results = dataMap['results'] as List? ?? [];
          return results.map((json) => Goal.fromJson(json)).toList();
        } else if (dataMap.containsKey('data')) {
          final List<dynamic> data = dataMap['data'] as List? ?? [];
          return data.map((json) => Goal.fromJson(json)).toList();
        }
      }
      
      print('Unexpected goals response format, returning empty list');
      return [];
      
    } on DioException catch (e) {
      print('DioException fetching goals: ${e.message}');
      print('Goals error response: ${e.response?.data}');
      print('Goals error status code: ${e.response?.statusCode}');
      throw _handleError(e);
    } catch (e) {
      print('Unexpected error fetching goals: $e');
      throw 'Failed to load goals. Please try again.';
    }
  }

  Future<Goal> createGoal(Goal goal) async {
    try {
      final response = await _dio.post(
        Constants.goals,
        data: goal.toJson(),
      );
      return Goal.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Goal> updateGoal(String goalId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch(
        '${Constants.goals}$goalId/',
        data: data,
      );
      return Goal.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteGoal(String goalId) async {
    try {
      await _dio.delete('${Constants.goals}$goalId/');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<GoalProgress> addGoalProgress(String goalId, GoalProgress progress) async {
    try {
      final response = await _dio.post(
        '${Constants.goals}$goalId/progress/',
        data: progress.toJson(),
      );
      return GoalProgress.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Responsibility methods
  Future<List<Responsibility>> getResponsibilities({
    String? frequency,
    String? status,
    String? assigned,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (frequency != null) queryParams['frequency'] = frequency;
      if (status != null) queryParams['status'] = status;
      if (assigned != null) queryParams['assigned'] = assigned;

      final response = await _dio.get(
        Constants.responsibilities,
        queryParameters: queryParams,
      );
      
      return (response.data as List)
          .map((json) => Responsibility.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Responsibility> createResponsibility(Responsibility responsibility) async {
    try {
      final response = await _dio.post(
        Constants.responsibilities,
        data: responsibility.toJson(),
      );
      return Responsibility.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Responsibility> updateResponsibility(String responsibilityId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch(
        '${Constants.responsibilities}$responsibilityId/',
        data: data,
      );
      return Responsibility.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteResponsibility(String responsibilityId) async {
    try {
      await _dio.delete('${Constants.responsibilities}$responsibilityId/');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ResponsibilityCompletion> completeResponsibility(String responsibilityId, ResponsibilityCompletion completion) async {
    try {
      final response = await _dio.post(
        '${Constants.responsibilities}$responsibilityId/complete/',
        data: completion.toJson(),
      );
      return ResponsibilityCompletion.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Dashboard methods
  Future<Map<String, dynamic>> getDashboardSummary() async {
    try {
      final response = await _dio.get(Constants.dashboard);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Test connectivity to the API
  Future<bool> testConnection() async {
    try {
      print('Testing connection to: ${Constants.baseUrl}/api/');
      final response = await _dio.get('/api/', options: Options(
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
      ));
      print('Connection test response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  String _handleError(DioException e) {
    print('DioException details:');
    print('Type: ${e.type}');
    print('Message: ${e.message}');
    print('Response: ${e.response}');
    print('Response status: ${e.response?.statusCode}');
    print('Response data: ${e.response?.data}');
    print('Request options: ${e.requestOptions.path}');
    
    if (e.response != null) {
      final data = e.response!.data;
      final statusCode = e.response!.statusCode;
      
      // Handle specific HTTP status codes
      switch (statusCode) {
        case 401:
          return 'Authentication failed. Please login again.';
        case 403:
          return 'Access denied. You don\'t have permission to access this resource.';
        case 404:
          return 'The requested resource was not found.';
        case 500:
          return 'Server error. Please try again later.';
        case 502:
        case 503:
        case 504:
          return 'Server is temporarily unavailable. Please try again later.';
      }
      
      // Handle response data
      if (data is Map && data.containsKey('error')) {
        return data['error'];
      }
      if (data is Map && data.containsKey('detail')) {
        return data['detail'];
      }
      if (data is String) {
        return data;
      }
      
      return 'Server returned an error (${statusCode}). Please try again.';
    }
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection and try again.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please check your internet connection and try again.';
      case DioExceptionType.receiveTimeout:
        return 'Response timeout. Please check your internet connection and try again.';
      case DioExceptionType.connectionError:
        return 'Cannot connect to server. Please check your internet connection and try again.';
      case DioExceptionType.badCertificate:
        return 'SSL certificate error. Please check your connection.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.unknown:
        if (e.message?.contains('SocketException') == true) {
          return 'No internet connection. Please check your network and try again.';
        }
        return 'Network error occurred. Please check your connection and try again.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}