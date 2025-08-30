import '../models/attendance.dart';
import 'demo_data_service.dart';

class AttendanceService {
  final DemoDataService _demoService = DemoDataService();

  // Singleton pattern
  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;
  AttendanceService._internal();

  Future<AttendanceResult> markAttendance({
    required String studentId,
    required String classSessionId,
    required String location,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Check if the class session exists and is active
      final isValidSession = await _validateClassSession(classSessionId);
      if (!isValidSession) {
        return AttendanceResult(
          success: false,
          message:
              'Invalid or expired class session. Please check with your teacher.',
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

      // Create new attendance record
      final attendance = Attendance(
        id: 'attendance_${DateTime.now().millisecondsSinceEpoch}',
        studentId: studentId,
        classSessionId: classSessionId,
        status: AttendanceStatus.present,
        timestamp: DateTime.now(),
        location: location,
        markedByTeacher: false,
      );

      // In a real app, this would save to a database
      // For demo, we'll just return success

      return AttendanceResult(
        success: true,
        message: 'Attendance marked successfully!',
        attendance: attendance,
      );
    } catch (e) {
      return AttendanceResult(
        success: false,
        message: 'Failed to mark attendance: $e',
      );
    }
  }

  Future<bool> _validateClassSession(String classSessionId) async {
    // In demo mode, accept any session that starts with 'session_'
    return classSessionId.startsWith('session_');
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

  // Generate QR code data for teachers
  String generateQRData(String classSessionId, String location) {
    return '$classSessionId:$location';
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

  AttendanceResult({
    required this.success,
    required this.message,
    this.attendance,
  });
}
