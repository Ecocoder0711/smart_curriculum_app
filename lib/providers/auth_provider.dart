import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isTeacher => _user?.role == UserRole.teacher;
  bool get isStudent => _user?.role == UserRole.student;
  bool get isAdmin => _user?.role == UserRole.admin;

  Future<void> init() async {
    _setLoading(true);
    await _authService.loadFromStorage();
    _user = _authService.currentUser;
    _setLoading(false);
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('DEBUG: AuthProvider login called with email: $email');
      final result = await _authService.login(email, password);
      debugPrint(
        'DEBUG: AuthService login result: ${result.success}, message: ${result.message}',
      );

      if (result.success) {
        _user = _authService.currentUser;
        debugPrint('DEBUG: AuthProvider set user: ${_user?.toJson()}');
        notifyListeners();
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      debugPrint('DEBUG: AuthProvider login error: $e');
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    Map<String, dynamic>? additionalData,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.register(name, email, password, role);

      if (result.success) {
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
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
      notifyListeners();
    } catch (e) {
      _setError('Logout failed');
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

  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.forgotPassword(email);

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

  void clearError() {
    _clearError();
  }
}
