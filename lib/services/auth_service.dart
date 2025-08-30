import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'demo_data_service.dart';

class AuthService {
  static const String baseUrl =
      'https://api.smartcurriculum.com'; // Replace with actual API URL
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Use demo mode for development
  static const bool _isDemoMode = true;
  final DemoDataService _demoService = DemoDataService();

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _token;
  User? _currentUser;

  String? get token => _token;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _token != null && _currentUser != null;

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(tokenKey);
    final userData = prefs.getString(userKey);

    if (userData != null) {
      try {
        final userJson = jsonDecode(userData);

        // Properly deserialize based on user role
        final role = userJson['role'];
        if (role == 'teacher') {
          _currentUser = Teacher.fromJson(userJson);
        } else if (role == 'student') {
          _currentUser = Student.fromJson(userJson);
        } else {
          _currentUser = User.fromJson(userJson);
        }
      } catch (e) {
        // Clear invalid data
        await clearStorage();
      }
    }
  }

  Future<void> saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();

    if (_token != null) {
      await prefs.setString(tokenKey, _token!);
    }

    if (_currentUser != null) {
      await prefs.setString(userKey, jsonEncode(_currentUser!.toJson()));
    }
  }

  Future<void> clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userKey);
    _token = null;
    _currentUser = null;
  }

  Future<AuthResult> login(String email, String password) async {
    try {
      print('DEBUG: AuthService login called with email: $email');

      // Use demo authentication
      if (_isDemoMode) {
        print('DEBUG: Using demo mode authentication');
        final user = _demoService.authenticateUser(email, password);
        print('DEBUG: DemoService returned user: ${user?.toJson()}');

        if (user != null) {
          _token = 'demo_token_${DateTime.now().millisecondsSinceEpoch}';
          _currentUser = user;
          print(
            'DEBUG: Set current user in AuthService: ${_currentUser?.toJson()}',
          );

          await saveToStorage();

          return AuthResult(success: true, message: 'Login successful');
        } else {
          print('DEBUG: Authentication failed - user is null');
          return AuthResult(success: false, message: 'Invalid credentials');
        }
      }

      // Real API authentication (for production)
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _currentUser = User.fromJson(data['user']);

        await saveToStorage();

        return AuthResult(success: true, message: 'Login successful');
      } else {
        final error = jsonDecode(response.body);
        return AuthResult(
          success: false,
          message: error['message'] ?? 'Login failed',
        );
      }
    } catch (e) {
      return AuthResult(success: false, message: 'Network error: $e');
    }
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Use demo registration
      if (_isDemoMode) {
        // In demo mode, just return success
        return AuthResult(
          success: true,
          message: 'Registration successful! You can now login.',
        );
      }

      // Real API registration (for production)
      final body = {
        'name': name,
        'email': email,
        'password': password,
        'role': role.toString().split('.').last,
        ...?additionalData,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return AuthResult(
          success: true,
          message: data['message'] ?? 'Registration successful',
        );
      } else {
        final error = jsonDecode(response.body);
        return AuthResult(
          success: false,
          message: error['message'] ?? 'Registration failed',
        );
      }
    } catch (e) {
      return AuthResult(success: false, message: 'Network error: $e');
    }
  }

  Future<void> logout() async {
    try {
      if (_token != null) {
        await http.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        );
      }
    } catch (e) {
      // Continue with logout even if API call fails
    }

    await clearStorage();
  }

  Future<AuthResult> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AuthResult(
          success: true,
          message: data['message'] ?? 'Reset email sent',
        );
      } else {
        final error = jsonDecode(response.body);
        return AuthResult(
          success: false,
          message: error['message'] ?? 'Failed to send reset email',
        );
      }
    } catch (e) {
      return AuthResult(success: false, message: 'Network error: $e');
    }
  }

  Future<AuthResult> resetPassword(String token, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token, 'password': newPassword}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AuthResult(
          success: true,
          message: data['message'] ?? 'Password reset successful',
        );
      } else {
        final error = jsonDecode(response.body);
        return AuthResult(
          success: false,
          message: error['message'] ?? 'Password reset failed',
        );
      }
    } catch (e) {
      return AuthResult(success: false, message: 'Network error: $e');
    }
  }

  Map<String, String> get authHeaders {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }
}

class AuthResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  AuthResult({required this.success, required this.message, this.data});
}
