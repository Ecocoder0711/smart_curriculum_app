import 'dart:convert';
import 'dart:math';
import '../models/attendance.dart';
import '../utils/logger.dart';
import 'demo_data_service.dart';
import 'teacher_notification_service.dart';

class AttendanceService {
  final DemoDataService _demoService = DemoDataService();
  final TeacherNotificationService _notificationService =
      TeacherNotificationService();

  // Singleton pattern
  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;
  AttendanceService._internal();

  Future<AttendanceResult> markAttendance({
    required String studentId,
    required String classSessionId,
    required String location,
    double? studentLat,
    double? studentLon,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Check if the class session exists and is active
      final sessionValidation = await _validateClassSession(classSessionId);
      if (!sessionValidation['isValid']) {
        return AttendanceResult(
          success: false,
          message: sessionValidation['message'],
        );
      }

      // Check if attendance already marked
      final existingAttendance = await _getExistingAttendance(
        studentId,
        classSessionId,
      );
      if (existingAttendance != null) {
        return AttendanceResult(
          success: false,
          message: 'Attendance already marked for this class.',
          attendance: existingAttendance,
        );
      }

      // Enhanced Proxy Detection with 15-meter proximity check
      AttendanceStatus status = AttendanceStatus.present;
      String statusMessage = 'Attendance marked successfully!';
      bool isProxy = false;

      if (studentLat != null && studentLon != null) {
        final proxyCheck = await _checkProximityToTeacher(
          classSessionId: classSessionId,
          studentLat: studentLat,
          studentLon: studentLon,
        );

        if (proxyCheck['isProxy']) {
          status = AttendanceStatus.absent; // Mark as absent for proxy
          statusMessage =
              'PROXY DETECTED: You are not within classroom proximity (15m). Attendance marked as proxy.';
          isProxy = true;

          // Send immediate notification to teacher
          await _notifyTeacherOfProxy(
            classSessionId: classSessionId,
            studentId: studentId,
            studentLocation: location,
            distance: proxyCheck['distance'],
          );
        }
      }

      // Create new attendance record
      final attendance = Attendance(
        id: 'attendance_${DateTime.now().millisecondsSinceEpoch}',
        studentId: studentId,
        classSessionId: classSessionId,
        status: status,
        timestamp: DateTime.now(),
        location: location,
        markedByTeacher: false,
        isProxy: isProxy,
        locationCoordinates: studentLat != null && studentLon != null
            ? {'lat': studentLat, 'lon': studentLon}
            : null,
      );

      return AttendanceResult(
        success: !isProxy,
        message: statusMessage,
        attendance: attendance,
        isProxy: isProxy,
      );
    } catch (e) {
      return AttendanceResult(
        success: false,
        message: 'Failed to mark attendance: $e',
      );
    }
  }

  Future<Map<String, dynamic>> _validateClassSession(
    String classSessionId,
  ) async {
    // In demo mode, accept any session that starts with 'session_'
    if (classSessionId.startsWith('session_')) {
      return {'isValid': true, 'message': 'Valid session'};
    }
    return {
      'isValid': false,
      'message':
          'Invalid or expired class session. Please check with your teacher.',
    };
  }

  Future<Map<String, dynamic>> _checkProximityToTeacher({
    required String classSessionId,
    required double studentLat,
    required double studentLon,
  }) async {
    // Get teacher's location for this class session
    final teacherLocation = await _getTeacherLocationForSession(classSessionId);

    if (teacherLocation == null) {
      // If no teacher location found, allow attendance (fallback)
      return {'isProxy': false, 'distance': 0.0};
    }

    final distance = _calculateDistance(
      studentLat,
      studentLon,
      teacherLocation['lat']!,
      teacherLocation['lon']!,
    );

    // 15-meter proximity requirement as specified by user
    const double proximityRequirement = 15.0;

    return {
      'isProxy': distance > proximityRequirement,
      'distance': distance,
      'teacherLocation': teacherLocation,
    };
  }

  Future<Map<String, double>?> _getTeacherLocationForSession(
    String classSessionId,
  ) async {
    // In demo mode, simulate teacher location
    // In real app, this would fetch from database
    return {
      'lat': 28.6139, // Example: Delhi coordinates
      'lon': 77.2090,
    };
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // Earth radius in meters

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (pi / 180);
  }

  Future<void> _notifyTeacherOfProxy({
    required String classSessionId,
    required String studentId,
    required String studentLocation,
    required double distance,
  }) async {
    // Get student details for notification
    final studentDetails = await _getStudentDetails(studentId);

    // Get teacher ID for this class session
    final teacherId = await _getTeacherForSession(classSessionId);

    // Send comprehensive notification using the notification service
    await _notificationService.sendProxyDetectionAlert(
      teacherId: teacherId,
      classSessionId: classSessionId,
      studentId: studentId,
      studentName: studentDetails['name'] ?? 'Unknown Student',
      studentRollNumber: studentDetails['rollNumber'] ?? 'N/A',
      studentEmail: studentDetails['email'] ?? 'N/A',
      distanceFromClassroom: distance,
      attemptedLocation: studentLocation,
    );

    // Legacy logging for debugging
    AppLogger.debug(
      '🚨 PROXY ALERT: ${studentDetails['name']} attempted proxy attendance',
    );
    AppLogger.debug('Distance: ${distance.toStringAsFixed(2)}m from classroom');
  }

  Future<Map<String, String>> _getStudentDetails(String studentId) async {
    // In demo mode, return sample student data
    return {
      'name': 'Demo Student',
      'rollNumber': 'CS2024001',
      'email': 'student@example.com',
    };
  }

  Future<String> _getTeacherForSession(String classSessionId) async {
    // In demo mode, return sample teacher ID
    // In real app, this would fetch from database based on class session
    return 'teacher_demo_123';
  }

  Future<Attendance?> _getExistingAttendance(
    String studentId,
    String classSessionId,
  ) async {
    // In demo mode, simulate no existing attendance for simplicity
    // In a real app, this would check the database
    return null;
  }

  Future<List<Attendance>> getStudentAttendance(String studentId) async {
    // Return demo attendance data
    return _demoService.attendanceRecords
        .where((attendance) => attendance.studentId == studentId)
        .toList();
  }

  Future<List<Attendance>> getClassAttendance(String classSessionId) async {
    // Return demo attendance data for a class
    return _demoService.attendanceRecords
        .where((attendance) => attendance.classSessionId == classSessionId)
        .toList();
  }

  Future<AttendanceStats> getAttendanceStats(
    String studentId,
    String subjectId,
  ) async {
    return _demoService.getAttendanceStatsForStudent(studentId, subjectId);
  }

  // Generate QR code data for teachers with location
  String generateQRDataWithLocation({
    required String classSessionId,
    required String location,
    required double teacherLat,
    required double teacherLon,
    double radiusMeters = 50.0,
  }) {
    final qrData = {
      'classSessionId': classSessionId,
      'location': location,
      'teacherLat': teacherLat,
      'teacherLon': teacherLon,
      'radiusMeters': radiusMeters,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    return jsonEncode(qrData);
  }

  // Legacy QR code generation (for backward compatibility)
  String generateQRData(String classSessionId, String location) {
    return '$classSessionId:$location';
  }

  /// Two-step verification attendance marking with face recognition + QR code
  Future<AttendanceResult> markAttendanceWithQR({
    required String studentId,
    required String qrData,
    required bool faceVerified,
    required String verificationMethod,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Ensure face verification was completed
      if (!faceVerified) {
        return AttendanceResult(
          success: false,
          message: 'Face verification required before QR scanning',
        );
      }

      // Parse QR data to extract session information
      final sessionData = _parseQRDataInternal(qrData);
      if (sessionData == null) {
        return AttendanceResult(
          success: false,
          message: 'Invalid QR code format',
        );
      }

      final classSessionId = sessionData['sessionId'] ?? '';

      if (classSessionId.isEmpty) {
        return AttendanceResult(
          success: false,
          message: 'Invalid session ID in QR code',
        );
      }

      // Validate session exists and is active
      final sessionValidation = await _validateClassSession(classSessionId);
      if (!sessionValidation['isValid']) {
        return AttendanceResult(
          success: false,
          message: sessionValidation['message'],
        );
      }

      // Check if attendance already marked
      final existingAttendance = await _getExistingAttendance(
        studentId,
        classSessionId,
      );
      if (existingAttendance != null) {
        return AttendanceResult(
          success: false,
          message: 'Attendance already marked for this class.',
          attendance: existingAttendance,
        );
      }

      // Create attendance record with enhanced security
      final attendance = Attendance(
        id: 'att_${DateTime.now().millisecondsSinceEpoch}',
        studentId: studentId,
        classSessionId: classSessionId,
        timestamp: DateTime.now(),
        status: AttendanceStatus.present,
        location: 'Verified with $verificationMethod',
        markedByTeacher: false, // Student self-marked with verification
        isProxy: false, // Cannot be proxy with face verification
        remarks: 'Two-step verification: Face + QR code',
      );

      // Notify teacher about successful verification (simplified)
      try {
        AppLogger.debug(
          'INFO: Student $studentId marked attendance with verified identity',
        );
        AppLogger.debug('Session: $classSessionId, Method: $verificationMethod');
      } catch (e) {
        // Continue even if logging fails
        AppLogger.debug('Warning: Failed to log attendance: $e');
      }

      return AttendanceResult(
        success: true,
        message: 'Attendance marked successfully with verified identity',
        attendance: attendance,
        isProxy: false,
      );
    } catch (e) {
      return AttendanceResult(
        success: false,
        message: 'Error marking attendance: ${e.toString()}',
      );
    }
  }

  /// Parse QR code data to extract session information for two-step verification
  Map<String, String>? _parseQRDataInternal(String qrData) {
    try {
      // Handle different QR code formats
      if (qrData.startsWith('{') && qrData.endsWith('}')) {
        // JSON format
        final data = json.decode(qrData) as Map<String, dynamic>;
        return {
          'sessionId': data['sessionId']?.toString() ?? '',
          'teacherId': data['teacherId']?.toString() ?? '',
          'classId': data['classId']?.toString() ?? '',
        };
      } else if (qrData.contains('|')) {
        // Pipe-separated format: sessionId|teacherId|classId
        final parts = qrData.split('|');
        if (parts.length >= 2) {
          return {
            'sessionId': parts[0],
            'teacherId': parts[1],
            'classId': parts.length > 2 ? parts[2] : '',
          };
        }
      } else {
        // Simple session ID format
        return {
          'sessionId': qrData,
          'teacherId': 'teacher_1', // Default for demo
          'classId': 'class_1',
        };
      }
    } catch (e) {
      // Invalid format
      return null;
    }
    return null;
  }

  // Parse QR code data
  Map<String, String>? parseQRData(String qrData) {
    final parts = qrData.split(':');
    if (parts.length != 2) return null;

    return {'classSessionId': parts[0], 'location': parts[1]};
  }
}

class AttendanceResult {
  final bool success;
  final String message;
  final Attendance? attendance;
  final bool isProxy;

  AttendanceResult({
    required this.success,
    required this.message,
    this.attendance,
    this.isProxy = false,
  });
}
