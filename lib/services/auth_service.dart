import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as app_user;

// Result classes for compatibility with existing AuthProvider
class AuthResult {
  final bool success;
  final String message;
  final app_user.User? user;

  AuthResult({required this.success, required this.message, this.user});
}

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  app_user.User? _currentUser;

  // Get current user (compatibility method)
  app_user.User? get currentUser => _currentUser;

  // Load from storage (Firebase handles this automatically)
  Future<void> loadFromStorage() async {
    firebase_auth.User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      _currentUser = await getUserData(firebaseUser.uid);
    }
  }

  // Sign in with email and password
  Future<AuthResult> login(String email, String password) async {
    try {
      firebase_auth.UserCredential result = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      firebase_auth.User? firebaseUser = result.user;

      if (firebaseUser != null) {
        _currentUser = await getUserData(firebaseUser.uid);
        return AuthResult(
          success: true,
          message: 'Login successful',
          user: _currentUser,
        );
      } else {
        return AuthResult(success: false, message: 'Login failed');
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many failed attempts. Please try again later.';
          break;
        default:
          message = 'Login failed: ${e.message}';
      }
      return AuthResult(success: false, message: message);
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'An unexpected error occurred.',
      );
    }
  }

  // Register with email and password
  Future<AuthResult> register(
    String name,
    String email,
    String password,
    app_user.UserRole role,
  ) async {
    try {
      firebase_auth.UserCredential result = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      firebase_auth.User? firebaseUser = result.user;

      if (firebaseUser != null) {
        // Update display name
        await firebaseUser.updateDisplayName(name);

        // Create user document in Firestore
        await _createUserDocument(firebaseUser.uid, name, email, role);

        // Load the created user
        _currentUser = await getUserData(firebaseUser.uid);

        return AuthResult(
          success: true,
          message: 'Registration successful',
          user: _currentUser,
        );
      } else {
        return AuthResult(success: false, message: 'Registration failed');
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          message = 'An account already exists for that email.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        default:
          message = 'Registration failed: ${e.message}';
      }
      return AuthResult(success: false, message: message);
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'An unexpected error occurred.',
      );
    }
  }

  // Sign out (renamed from signOut for compatibility)
  Future<void> logout() async {
    try {
      await _auth.signOut();
      _currentUser = null;
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Clear storage (Firebase doesn't need this, but for compatibility)
  Future<void> clearStorage() async {
    _currentUser = null;
  }

  // Forgot password
  Future<AuthResult> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult(
        success: true,
        message: 'Password reset email sent. Please check your inbox.',
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email address.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        default:
          message = e.message ?? 'Failed to send reset email.';
      }
      return AuthResult(success: false, message: message);
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'An unexpected error occurred.',
      );
    }
  }

  // Reset password (for compatibility, but Firebase handles this via email)
  Future<AuthResult> resetPassword(String token, String newPassword) async {
    // Firebase doesn't use tokens like this, password reset is handled via email
    return AuthResult(
      success: false,
      message:
          'Please use the password reset email sent to your email address.',
    );
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(
    String uid,
    String name,
    String email,
    app_user.UserRole role,
  ) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'role': role.toString().split('.').last,
        'profileImage': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        // Add default role-specific fields
        if (role == app_user.UserRole.student) ...{
          'rollNumber': '',
          'className': '',
          'section': '',
          'semester': 1,
          'department': '',
        },
        if (role == app_user.UserRole.teacher) ...{
          'employeeId': '',
          'department': '',
          'subjects': <String>[],
        },
      });
    } catch (e) {
      throw Exception('Failed to create user document: $e');
    }
  }

  // Get user data from Firestore with complete details
  Future<app_user.User?> getUserData(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (!doc.exists) {
        return null;
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String roleStr = data['role'] as String;
      app_user.UserRole role = roleStr == 'student'
          ? app_user.UserRole.student
          : roleStr == 'teacher'
          ? app_user.UserRole.teacher
          : app_user.UserRole.admin;

      if (role == app_user.UserRole.student) {
        return app_user.Student(
          id: userId,
          name: data['name'] as String,
          email: data['email'] as String,
          profileImage: data['profileImage'] as String?,
          createdAt:
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          updatedAt:
              (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          rollNumber: data['rollNumber'] as String? ?? '',
          className: data['className'] as String? ?? '',
          section: data['section'] as String? ?? '',
          semester: data['semester'] as int? ?? 1,
          department: data['department'] as String? ?? '',
        );
      } else if (role == app_user.UserRole.teacher) {
        return app_user.Teacher(
          id: userId,
          name: data['name'] as String,
          email: data['email'] as String,
          profileImage: data['profileImage'] as String?,
          createdAt:
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          updatedAt:
              (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          employeeId: data['employeeId'] as String? ?? '',
          department: data['department'] as String? ?? '',
          subjects: List<String>.from(data['subjects'] as List? ?? []),
        );
      } else {
        return app_user.User(
          id: userId,
          name: data['name'] as String,
          email: data['email'] as String,
          role: role,
          profileImage: data['profileImage'] as String?,
          createdAt:
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          updatedAt:
              (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  // Check if user is signed in
  bool get isSignedIn {
    return _auth.currentUser != null;
  }

  // Auth state changes stream
  Stream<app_user.User?> get userStream {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser != null) {
        _currentUser = await getUserData(firebaseUser.uid);
        return _currentUser;
      } else {
        _currentUser = null;
        return null;
      }
    });
  }
}
