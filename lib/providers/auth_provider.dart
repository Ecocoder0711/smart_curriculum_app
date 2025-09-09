import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null && _isInitialized;
  bool get isTeacher => _user?.role == UserRole.teacher;
  bool get isStudent => _user?.role == UserRole.student;
  bool get isAdmin => _user?.role == UserRole.admin;
  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    _setLoading(true);
    try {
      await _authService.loadFromStorage();
      _user = _authService.currentUser;
      _isInitialized = true;
      debugPrint('DEBUG: AuthProvider initialized, user: ${_user?.toJson()}');
    } catch (e) {
      debugPrint('DEBUG: AuthProvider init error: $e');
      _user = null;
      _isInitialized = true;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('DEBUG: AuthProvider login called with email: $email');

      // Validate inputs
      if (email.trim().isEmpty) {
        _setError('Email is required');
        return false;
      }

      if (password.isEmpty) {
        _setError('Password is required');
        return false;
      }

      if (!_isValidEmail(email.trim())) {
        _setError('Please enter a valid email address');
        return false;
      }

      final result = await _authService.login(email.trim(), password);
      debugPrint(
        'DEBUG: AuthService login result: ${result.success}, message: ${result.message}',
      );

      if (result.success && result.user != null) {
        _user = result.user;
        debugPrint('DEBUG: AuthProvider set user: ${_user?.toJson()}');
        _clearError();
        notifyListeners();
        return true;
      } else {
        _setError(result.message);
        _user = null;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('DEBUG: AuthProvider login error: $e');
      _setError('Login failed. Please check your credentials and try again.');
      _user = null;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required UserRole role,
    Map<String, dynamic>? additionalData,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Validate inputs
      if (name.trim().isEmpty) {
        _setError('Name is required');
        return false;
      }

      if (email.trim().isEmpty) {
        _setError('Email is required');
        return false;
      }

      if (!_isValidEmail(email.trim())) {
        _setError('Please enter a valid email address');
        return false;
      }

      if (password.isEmpty) {
        _setError('Password is required');
        return false;
      }

      if (password.length < 6) {
        _setError('Password must be at least 6 characters long');
        return false;
      }

      if (password != confirmPassword) {
        _setError('Passwords do not match');
        return false;
      }

      final result = await _authService.register(
        name.trim(),
        email.trim(),
        password,
        role,
      );

      if (result.success) {
        _clearError();
        // Don't auto-login after registration, let user login manually
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      debugPrint('DEBUG: AuthProvider register error: $e');
      _setError('Registration failed. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.logout();
      _user = null;
      _clearError();
      notifyListeners();
    } catch (e) {
      debugPrint('DEBUG: Logout error: $e');
      _setError('Logout failed');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      if (email.trim().isEmpty) {
        _setError('Email is required');
        return false;
      }

      if (!_isValidEmail(email.trim())) {
        _setError('Please enter a valid email address');
        return false;
      }

      final result = await _authService.forgotPassword(email.trim());

      if (result.success) {
        _clearError();
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      debugPrint('DEBUG: Forgot password error: $e');
      _setError('Failed to send reset email. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Force clear all authentication data
  Future<void> forceClearAuth() async {
    _setLoading(true);
    try {
      await _authService.clearStorage();
      _user = null;
      _error = null;
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear authentication');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String token, String newPassword) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.resetPassword(token, newPassword);

      if (!result.success) {
        _setError(result.message);
      }

      return result.success;
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateUser(User updatedUser) async {
    try {
      // For now, just update locally since we're using demo data
      // In a real app, this would call an API to update the server
      _user = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update user profile');
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void clearError() {
    _clearError();
  }
}
