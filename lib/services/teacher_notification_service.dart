class TeacherNotificationService {
  static final TeacherNotificationService _instance =
      TeacherNotificationService._internal();
  factory TeacherNotificationService() => _instance;
  TeacherNotificationService._internal();

  // Store notifications for demo purposes (in real app, this would be a database)
  final List<TeacherNotification> _notifications = [];

  Future<void> sendProxyDetectionAlert({
    required String teacherId,
    required String classSessionId,
    required String studentId,
    required String studentName,
    required String studentRollNumber,
    required String studentEmail,
    required double distanceFromClassroom,
    required String attemptedLocation,
  }) async {
    final notification = TeacherNotification(
      id: 'notification_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.proxyDetection,
      teacherId: teacherId,
      classSessionId: classSessionId,
      timestamp: DateTime.now(),
      title: '🚨 PROXY ATTENDANCE DETECTED',
      message: _buildProxyMessage(studentName, distanceFromClassroom),
      studentDetails: StudentDetails(
        id: studentId,
        name: studentName,
        rollNumber: studentRollNumber,
        email: studentEmail,
      ),
      proxyDetails: ProxyDetails(
        distanceFromClassroom: distanceFromClassroom,
        attemptedLocation: attemptedLocation,
        proximityRequired: 15.0,
        severity: _calculateSeverity(distanceFromClassroom),
        recommendation: _getRecommendation(distanceFromClassroom),
      ),
      priority: distanceFromClassroom > 100
          ? NotificationPriority.high
          : distanceFromClassroom > 50
          ? NotificationPriority.medium
          : NotificationPriority.low,
      isRead: false,
    );

    _notifications.add(notification);

    // In real app, these would be actual notifications
    await _sendPushNotification(notification);
    await _sendEmailAlert(notification);
    await _logToSystem(notification);

    // Simple debug output - no AppLogger
    print('📧 Teacher notification sent: ${notification.title}');
    print('👤 Student: $studentName ($studentRollNumber)');  
    print('📍 Distance: ${distanceFromClassroom.toStringAsFixed(2)}m');
    print('⚠️  Severity: ${notification.proxyDetails?.severity}');
  }

  String _buildProxyMessage(String studentName, double distance) {
    if (distance > 100) {
      return '$studentName attempted to mark attendance from ${distance.toStringAsFixed(0)}m away. This appears to be a clear proxy attempt requiring immediate attention.';
    } else if (distance > 50) {
      return '$studentName is ${distance.toStringAsFixed(0)}m from the classroom, outside the allowed 15m proximity. Please verify manually.';
    } else {
      return '$studentName is ${distance.toStringAsFixed(0)}m from classroom (allowed: 15m). Minor proximity violation detected.';
    }
  }

  ProxySeverity _calculateSeverity(double distance) {
    if (distance > 100) return ProxySeverity.high;
    if (distance > 50) return ProxySeverity.medium;
    return ProxySeverity.low;
  }

  String _getRecommendation(double distance) {
    if (distance > 100) {
      return 'IMMEDIATE ACTION REQUIRED: Student appears to be very far from classroom. Verify student location and consider disciplinary action.';
    } else if (distance > 50) {
      return 'MANUAL VERIFICATION: Student is significantly outside proximity. Please check if student is in adjacent room or corridor.';
    } else {
      return 'MINOR VIOLATION: Student might be just outside classroom door. Consider allowing with warning.';
    }
  }

  Future<void> _sendPushNotification(TeacherNotification notification) async {
    // In real app: Firebase Cloud Messaging, OneSignal, etc.
    await Future.delayed(const Duration(milliseconds: 100));
    print('📱 Push notification sent to teacher');
  }

  Future<void> _sendEmailAlert(TeacherNotification notification) async {
    // In real app: SendGrid, AWS SES, etc.
    await Future.delayed(const Duration(milliseconds: 100));
    print('📧 Email alert sent to teacher');
  }

  Future<void> _logToSystem(TeacherNotification notification) async {
    // In real app: Log to analytics, database, etc.
    await Future.delayed(const Duration(milliseconds: 100));
    print('📊 Logged to system for analytics');
  }

  List<TeacherNotification> getNotificationsForTeacher(String teacherId) {
    return _notifications
        .where((notification) => notification.teacherId == teacherId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<TeacherNotification> getUnreadNotifications(String teacherId) {
    return _notifications
        .where(
          (notification) =>
              notification.teacherId == teacherId && !notification.isRead,
        )
        .toList();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  // Get summary statistics for teacher dashboard
  NotificationSummary getNotificationSummary(String teacherId) {
    final teacherNotifications = getNotificationsForTeacher(teacherId);
    final today = DateTime.now();
    final todayNotifications = teacherNotifications
        .where((n) => _isSameDay(n.timestamp, today))
        .toList();

    final proxyToday = todayNotifications
        .where((n) => n.type == NotificationType.proxyDetection)
        .length;

    final highPriorityUnread = teacherNotifications
        .where((n) => !n.isRead && n.priority == NotificationPriority.high)
        .length;

    return NotificationSummary(
      totalNotifications: teacherNotifications.length,
      unreadCount: getUnreadNotifications(teacherId).length,
      proxyDetectionsToday: proxyToday,
      highPriorityUnread: highPriorityUnread,
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

// Data Models
class TeacherNotification {
  final String id;
  final NotificationType type;
  final String teacherId;
  final String classSessionId;
  final DateTime timestamp;
  final String title;
  final String message;
  final StudentDetails? studentDetails;
  final ProxyDetails? proxyDetails;
  final NotificationPriority priority;
  final bool isRead;

  TeacherNotification({
    required this.id,
    required this.type,
    required this.teacherId,
    required this.classSessionId,
    required this.timestamp,
    required this.title,
    required this.message,
    this.studentDetails,
    this.proxyDetails,
    required this.priority,
    required this.isRead,
  });

  TeacherNotification copyWith({
    String? id,
    NotificationType? type,
    String? teacherId,
    String? classSessionId,
    DateTime? timestamp,
    String? title,
    String? message,
    StudentDetails? studentDetails,
    ProxyDetails? proxyDetails,
    NotificationPriority? priority,
    bool? isRead,
  }) {
    return TeacherNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      teacherId: teacherId ?? this.teacherId,
      classSessionId: classSessionId ?? this.classSessionId,
      timestamp: timestamp ?? this.timestamp,
      title: title ?? this.title,
      message: message ?? this.message,
      studentDetails: studentDetails ?? this.studentDetails,
      proxyDetails: proxyDetails ?? this.proxyDetails,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
    );
  }
}

class StudentDetails {
  final String id;
  final String name;
  final String rollNumber;
  final String email;

  StudentDetails({
    required this.id,
    required this.name,
    required this.rollNumber,
    required this.email,
  });
}

class ProxyDetails {
  final double distanceFromClassroom;
  final String attemptedLocation;
  final double proximityRequired;
  final ProxySeverity severity;
  final String recommendation;

  ProxyDetails({
    required this.distanceFromClassroom,
    required this.attemptedLocation,
    required this.proximityRequired,
    required this.severity,
    required this.recommendation,
  });
}

class NotificationSummary {
  final int totalNotifications;
  final int unreadCount;
  final int proxyDetectionsToday;
  final int highPriorityUnread;

  NotificationSummary({
    required this.totalNotifications,
    required this.unreadCount,
    required this.proxyDetectionsToday,
    required this.highPriorityUnread,
  });
}

enum NotificationType { proxyDetection, attendance, general }

enum NotificationPriority { low, medium, high }

enum ProxySeverity { low, medium, high }