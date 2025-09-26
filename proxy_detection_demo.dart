// Demo Test Script for Enhanced Proxy Detection System
// This script demonstrates the new features implemented for Smart India Hackathon

import 'lib/services/attendance_service.dart';
import 'lib/services/teacher_notification_service.dart';
import 'lib/utils/logger.dart';

void main() async {
  AppLogger.demo('🎯 SMART INDIA HACKATHON - Enhanced Proxy Detection Demo');
  AppLogger.demo('=' * 60);

  final attendanceService = AttendanceService();
  final notificationService = TeacherNotificationService();

  // Test Case 1: Valid attendance within 15m proximity
  AppLogger.demo('\n📍 Test Case 1: Student within allowed proximity (10m)');
  final validResult = await attendanceService.markAttendance(
    studentId: 'student_123',
    classSessionId: 'session_cs101_morning',
    location: 'Computer Lab A',
    studentLat: 28.6139, // Close to teacher location
    studentLon: 77.2090,
  );
  AppLogger.demo('Result: ${validResult.success ? "✅ ALLOWED" : "❌ BLOCKED"}');
  AppLogger.demo('Message: ${validResult.message}');
  AppLogger.demo('Is Proxy: ${validResult.isProxy}');

  // Test Case 2: Proxy detection - student too far (50m)
  AppLogger.demo('\n📍 Test Case 2: Student outside proximity (50m) - Medium Severity');
  final proxyResult1 = await attendanceService.markAttendance(
    studentId: 'student_456',
    classSessionId: 'session_cs101_morning',
    location: 'Fake Location',
    studentLat: 28.6145, // 50m away from teacher
    studentLon: 77.2095,
  );
  AppLogger.demo('Result: ${proxyResult1.success ? "✅ ALLOWED" : "❌ PROXY DETECTED"}');
  AppLogger.demo('Message: ${proxyResult1.message}');
  AppLogger.demo('Is Proxy: ${proxyResult1.isProxy}');

  // Test Case 3: High severity proxy detection - student very far (200m)
  AppLogger.demo('\n📍 Test Case 3: Student very far (200m) - High Severity');
  final proxyResult2 = await attendanceService.markAttendance(
    studentId: 'student_789',
    classSessionId: 'session_cs101_morning',
    location: 'Home',
    studentLat: 28.6160, // 200m+ away from teacher
    studentLon: 77.2120,
  );
  AppLogger.demo('Result: ${proxyResult2.success ? "✅ ALLOWED" : "❌ PROXY DETECTED"}');
  AppLogger.demo('Message: ${proxyResult2.message}');
  AppLogger.demo('Is Proxy: ${proxyResult2.isProxy}');

  // Teacher Notification Summary
  AppLogger.demo('\n📊 Teacher Notification Summary');
  AppLogger.demo('-' * 40);
  final summary = notificationService.getNotificationSummary(
    'teacher_demo_123',
  );
  AppLogger.demo('Total Notifications: ${summary.totalNotifications}');
  AppLogger.demo('Unread Count: ${summary.unreadCount}');
  AppLogger.demo('Proxy Detections Today: ${summary.proxyDetectionsToday}');
  AppLogger.demo('High Priority Unread: ${summary.highPriorityUnread}');

  // List all notifications for teacher
  AppLogger.demo('\n📋 Recent Proxy Detection Alerts');
  AppLogger.demo('-' * 40);
  final notifications = notificationService.getNotificationsForTeacher(
    'teacher_demo_123',
  );

  for (int i = 0; i < notifications.length && i < 3; i++) {
    final notification = notifications[i];
    AppLogger.demo(
      '${i + 1}. ${notification.studentDetails?.name} (${notification.studentDetails?.rollNumber})',
    );
    AppLogger.demo(
      '   Distance: ${notification.proxyDetails?.distanceFromClassroom.toStringAsFixed(1)}m',
    );
    AppLogger.demo(
      '   Severity: ${notification.proxyDetails?.severity.name.toUpperCase()}',
    );
    AppLogger.demo('   Time: ${_formatTime(notification.timestamp)}');
    AppLogger.demo('   Status: ${notification.isRead ? "READ" : "UNREAD"}');
    AppLogger.demo('');
  }

  AppLogger.demo('🏆 ENHANCED FEATURES SUMMARY:');
  AppLogger.demo('✅ 15-meter proximity enforcement');
  AppLogger.demo('✅ Real-time teacher notifications');
  AppLogger.demo('✅ Severity-based alerts (Low/Medium/High)');
  AppLogger.demo('✅ Detailed student information in alerts');
  AppLogger.demo('✅ Professional teacher dashboard');
  AppLogger.demo('✅ Automatic proxy flagging');
  AppLogger.demo('✅ GPS-based location verification');
  AppLogger.demo('✅ Comprehensive analytics');

  AppLogger.demo('\n🎯 This Smart India Hackathon project now includes:');
  AppLogger.demo('• Advanced AI recommendation system');
  AppLogger.demo('• Facial recognition attendance');
  AppLogger.demo('• Voice command interface');
  AppLogger.demo('• Real-time proxy detection');
  AppLogger.demo('• Professional analytics dashboard');
  AppLogger.demo('• Multi-language support');
  AppLogger.demo('• Enhanced security features');
}

String _formatTime(DateTime time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}
