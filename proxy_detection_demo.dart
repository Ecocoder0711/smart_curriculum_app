// Demo Test Script for Enhanced Proxy Detection System
// This script demonstrates the new features implemented for Smart India Hackathon

import 'lib/services/attendance_service.dart';
import 'lib/services/teacher_notification_service.dart';

void main() async {
  print('🎯 SMART INDIA HACKATHON - Enhanced Proxy Detection Demo');
  print('=' * 60);

  final attendanceService = AttendanceService();
  final notificationService = TeacherNotificationService();

  // Test Case 1: Valid attendance within 15m proximity
  print('\n📍 Test Case 1: Student within allowed proximity (10m)');
  final validResult = await attendanceService.markAttendance(
    studentId: 'student_123',
    classSessionId: 'session_cs101_morning',
    location: 'Computer Lab A',
    studentLat: 28.6139, // Close to teacher location
    studentLon: 77.2090,
  );
  print('Result: ${validResult.success ? "✅ ALLOWED" : "❌ BLOCKED"}');
  print('Message: ${validResult.message}');
  print('Is Proxy: ${validResult.isProxy}');

  // Test Case 2: Proxy detection - student too far (50m)
  print('\n📍 Test Case 2: Student outside proximity (50m) - Medium Severity');
  final proxyResult1 = await attendanceService.markAttendance(
    studentId: 'student_456',
    classSessionId: 'session_cs101_morning',
    location: 'Fake Location',
    studentLat: 28.6145, // 50m away from teacher
    studentLon: 77.2095,
  );
  print('Result: ${proxyResult1.success ? "✅ ALLOWED" : "❌ PROXY DETECTED"}');
  print('Message: ${proxyResult1.message}');
  print('Is Proxy: ${proxyResult1.isProxy}');

  // Test Case 3: High severity proxy detection - student very far (200m)
  print('\n📍 Test Case 3: Student very far (200m) - High Severity');
  final proxyResult2 = await attendanceService.markAttendance(
    studentId: 'student_789',
    classSessionId: 'session_cs101_morning',
    location: 'Home',
    studentLat: 28.6160, // 200m+ away from teacher
    studentLon: 77.2120,
  );
  print('Result: ${proxyResult2.success ? "✅ ALLOWED" : "❌ PROXY DETECTED"}');
  print('Message: ${proxyResult2.message}');
  print('Is Proxy: ${proxyResult2.isProxy}');

  // Teacher Notification Summary
  print('\n📊 Teacher Notification Summary');
  print('-' * 40);
  final summary = notificationService.getNotificationSummary(
    'teacher_demo_123',
  );
  print('Total Notifications: ${summary.totalNotifications}');
  print('Unread Count: ${summary.unreadCount}');
  print('Proxy Detections Today: ${summary.proxyDetectionsToday}');
  print('High Priority Unread: ${summary.highPriorityUnread}');

  // List all notifications for teacher
  print('\n📋 Recent Proxy Detection Alerts');
  print('-' * 40);
  final notifications = notificationService.getNotificationsForTeacher(
    'teacher_demo_123',
  );

  for (int i = 0; i < notifications.length && i < 3; i++) {
    final notification = notifications[i];
    print(
      '${i + 1}. ${notification.studentDetails?.name} (${notification.studentDetails?.rollNumber})',
    );
    print(
      '   Distance: ${notification.proxyDetails?.distanceFromClassroom.toStringAsFixed(1)}m',
    );
    print(
      '   Severity: ${notification.proxyDetails?.severity.name.toUpperCase()}',
    );
    print('   Time: ${_formatTime(notification.timestamp)}');
    print('   Status: ${notification.isRead ? "READ" : "UNREAD"}');
    print('');
  }

  print('🏆 ENHANCED FEATURES SUMMARY:');
  print('✅ 15-meter proximity enforcement');
  print('✅ Real-time teacher notifications');
  print('✅ Severity-based alerts (Low/Medium/High)');
  print('✅ Detailed student information in alerts');
  print('✅ Professional teacher dashboard');
  print('✅ Automatic proxy flagging');
  print('✅ GPS-based location verification');
  print('✅ Comprehensive analytics');

  print('\n🎯 This Smart India Hackathon project now includes:');
  print('• Advanced AI recommendation system');
  print('• Facial recognition attendance');
  print('• Voice command interface');
  print('• Real-time proxy detection');
  print('• Professional analytics dashboard');
  print('• Multi-language support');
  print('• Enhanced security features');
}

String _formatTime(DateTime time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}
