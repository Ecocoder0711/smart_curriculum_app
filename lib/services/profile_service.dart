import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart';
import '../utils/logger.dart';

class ProfileService {
  // Singleton pattern
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  // Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _teacherStatsCollection =>
      _firestore.collection('teacherStats');
  CollectionReference get _studentStatsCollection =>
      _firestore.collection('studentStats');
  CollectionReference get _settingsCollection =>
      _firestore.collection('userSettings');

  // Profile picture management (temporarily disabled - requires billing)
  Future<String?> uploadProfilePicture(File imageFile) async {
    try {
      // TODO: Enable this when Firebase Storage billing is set up

      // For now, return a placeholder or skip upload
      AppLogger.debug(
        'Storage upload temporarily disabled - requires Firebase billing setup',
      );

      // You can use a default avatar URL for now
      String defaultAvatar =
          'https://via.placeholder.com/150/4CAF50/FFFFFF?text=User';

      // Get current user ID
      String? userId = _auth.currentUser?.uid;

      // Update user document in Firestore with default avatar
      await _usersCollection.doc(userId).update({
        'profileImage': defaultAvatar,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return defaultAvatar;
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  // Update user profile
  Future<bool> updateProfile(User user, Map<String, dynamic> updates) async {
    try {
      // Add timestamp to updates
      updates['updatedAt'] = FieldValue.serverTimestamp();

      // Update user document
      await _usersCollection.doc(user.id).update(updates);

      // If name is being updated, also update Firebase Auth display name
      if (updates.containsKey('name')) {
        await _auth.currentUser?.updateDisplayName(updates['name']);
      }

      return true;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Get user statistics
  Future<UserStats> getUserStats(String userId, UserRole role) async {
    try {
      if (role == UserRole.teacher) {
        DocumentSnapshot doc = await _teacherStatsCollection.doc(userId).get();

        // If document doesn't exist, create default stats
        if (!doc.exists) {
          await _teacherStatsCollection.doc(userId).set({
            'totalClasses': 0,
            'totalStudents': 0,
            'totalActivities': 0,
            'averageAttendance': 0.0,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          return TeacherStats(
            totalClasses: 0,
            totalStudents: 0,
            totalActivities: 0,
            averageAttendance: 0.0,
          );
        }

        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        return TeacherStats(
          totalClasses: data['totalClasses'] ?? 0,
          totalStudents: data['totalStudents'] ?? 0,
          totalActivities: data['totalActivities'] ?? 0,
          averageAttendance: (data['averageAttendance'] ?? 0).toDouble(),
        );
      } else if (role == UserRole.student) {
        DocumentSnapshot doc = await _studentStatsCollection.doc(userId).get();

        // If document doesn't exist, create default stats
        if (!doc.exists) {
          await _studentStatsCollection.doc(userId).set({
            'overallAttendance': 0.0,
            'currentCGPA': 0.0,
            'totalSubjects': 0,
            'pendingAssignments': 0,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          return StudentStats(
            overallAttendance: 0.0,
            currentCGPA: 0.0,
            totalSubjects: 0,
            pendingAssignments: 0,
          );
        }

        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        return StudentStats(
          overallAttendance: (data['overallAttendance'] ?? 0).toDouble(),
          currentCGPA: (data['currentCGPA'] ?? 0).toDouble(),
          totalSubjects: data['totalSubjects'] ?? 0,
          pendingAssignments: data['pendingAssignments'] ?? 0,
        );
      }

      return UserStats();
    } catch (e) {
      throw Exception('Failed to get user stats: $e');
    }
  }

  // Change password
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      // Get current user
      firebase_auth.User? user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('No authenticated user found');
      }

      // Create credential with current password
      firebase_auth.AuthCredential credential =
          firebase_auth.EmailAuthProvider.credential(
            email: user.email!,
            password: currentPassword,
          );

      // Re-authenticate user
      await user.reauthenticateWithCredential(credential);

      // Change password
      await user.updatePassword(newPassword);

      return true;
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  // Update notification preferences
  Future<bool> updateNotificationPreferences(
    Map<String, bool> preferences,
  ) async {
    try {
      String? userId = _auth.currentUser?.uid;

      await _settingsCollection.doc(userId).set({
        'notifications': preferences,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      throw Exception('Failed to update notification preferences: $e');
    }
  }

  // Get notification preferences
  Future<Map<String, bool>> getNotificationPreferences(String userId) async {
    try {
      DocumentSnapshot doc = await _settingsCollection.doc(userId).get();

      // If document doesn't exist or doesn't have notifications field
      if (!doc.exists ||
          !(doc.data() as Map<String, dynamic>).containsKey('notifications')) {
        // Return default preferences
        Map<String, bool> defaultPrefs = {
          'attendance_reminders': true,
          'assignment_notifications': true,
          'grade_updates': true,
          'general_announcements': false,
          'push_notifications': true,
        };

        // Save defaults to Firestore
        await _settingsCollection.doc(userId).set({
          'notifications': defaultPrefs,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        return defaultPrefs;
      }

      // Return existing preferences
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      Map<String, dynamic> notificationsData =
          data['notifications'] as Map<String, dynamic>;

      // Convert to Map<String, bool>
      Map<String, bool> notifications = {};
      notificationsData.forEach((key, value) {
        notifications[key] = value as bool;
      });

      return notifications;
    } catch (e) {
      throw Exception('Failed to get notification preferences: $e');
    }
  }

  // Update privacy settings
  Future<bool> updatePrivacySettings(Map<String, dynamic> settings) async {
    try {
      String? userId = _auth.currentUser?.uid;

      await _settingsCollection.doc(userId).set({
        'privacy': settings,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      throw Exception('Failed to update privacy settings: $e');
    }
  }

  // Get privacy settings
  Future<Map<String, dynamic>> getPrivacySettings(String userId) async {
    try {
      DocumentSnapshot doc = await _settingsCollection.doc(userId).get();

      // If document doesn't exist or doesn't have privacy field
      if (!doc.exists ||
          !(doc.data() as Map<String, dynamic>).containsKey('privacy')) {
        // Return default settings
        Map<String, dynamic> defaultSettings = {
          'profile_visibility': 'public',
          'show_attendance': true,
          'show_grades': false,
          'allow_messages': true,
          'biometric_enabled': false,
        };

        // Save defaults to Firestore
        await _settingsCollection.doc(userId).set({
          'privacy': defaultSettings,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        return defaultSettings;
      }

      // Return existing settings
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return data['privacy'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get privacy settings: $e');
    }
  }

  // Create or update user data in Firestore
  Future<void> createOrUpdateUserData(User user) async {
    try {
      Map<String, dynamic> userData = {
        'name': user.name,
        'email': user.email,
        'role': user.role.toString().split('.').last,
        'profileImage': user.profileImage,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add role-specific fields
      if (user.role == UserRole.student) {
        Student student = user as Student;
        userData.addAll({
          'rollNumber': student.rollNumber,
          'className': student.className,
          'section': student.section,
          'semester': student.semester,
          'department': student.department,
        });
      } else if (user.role == UserRole.teacher) {
        Teacher teacher = user as Teacher;
        userData.addAll({
          'employeeId': teacher.employeeId,
          'department': teacher.department,
          'subjects': teacher.subjects,
        });
      }

      await _usersCollection
          .doc(user.id)
          .set(userData, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to create or update user data: $e');
    }
  }
}

// Base class for user statistics
class UserStats {
  UserStats();
}

// Teacher-specific statistics
class TeacherStats extends UserStats {
  final int totalClasses;
  final int totalStudents;
  final int totalActivities;
  final double averageAttendance;

  TeacherStats({
    required this.totalClasses,
    required this.totalStudents,
    required this.totalActivities,
    required this.averageAttendance,
  });
}

// Student-specific statistics
class StudentStats extends UserStats {
  final double overallAttendance;
  final double currentCGPA;
  final int totalSubjects;
  final int pendingAssignments;

  StudentStats({
    required this.overallAttendance,
    required this.currentCGPA,
    required this.totalSubjects,
    required this.pendingAssignments,
  });
}
