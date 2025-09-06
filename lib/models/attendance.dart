enum AttendanceStatus { present, absent, late, excused }

class Attendance {
  final String id;
  final String studentId;
  final String classSessionId;
  final AttendanceStatus status;
  final DateTime timestamp;
  final String? remarks;
  final String? location;
  final bool markedByTeacher;
  final bool isProxy;
  final Map<String, double>? locationCoordinates;

  Attendance({
    required this.id,
    required this.studentId,
    required this.classSessionId,
    required this.status,
    required this.timestamp,
    this.remarks,
    this.location,
    required this.markedByTeacher,
    this.isProxy = false,
    this.locationCoordinates,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      studentId: json['studentId'],
      classSessionId: json['classSessionId'],
      status: AttendanceStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      timestamp: DateTime.parse(json['timestamp']),
      remarks: json['remarks'],
      location: json['location'],
      markedByTeacher: json['markedByTeacher'],
      isProxy: json['isProxy'] ?? false,
      locationCoordinates: json['locationCoordinates'] != null
          ? Map<String, double>.from(json['locationCoordinates'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'classSessionId': classSessionId,
      'status': status.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'remarks': remarks,
      'location': location,
      'markedByTeacher': markedByTeacher,
      'isProxy': isProxy,
      'locationCoordinates': locationCoordinates,
    };
  }

  Attendance copyWith({
    String? id,
    String? studentId,
    String? classSessionId,
    AttendanceStatus? status,
    DateTime? timestamp,
    String? remarks,
    String? location,
    bool? markedByTeacher,
    bool? isProxy,
    Map<String, double>? locationCoordinates,
  }) {
    return Attendance(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      classSessionId: classSessionId ?? this.classSessionId,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      remarks: remarks ?? this.remarks,
      location: location ?? this.location,
      markedByTeacher: markedByTeacher ?? this.markedByTeacher,
      isProxy: isProxy ?? this.isProxy,
      locationCoordinates: locationCoordinates ?? this.locationCoordinates,
    );
  }
}

class AttendanceStats {
  final String studentId;
  final String subjectId;
  final int totalClasses;
  final int attendedClasses;
  final int absentClasses;
  final int lateClasses;
  final int excusedClasses;
  final double attendancePercentage;

  AttendanceStats({
    required this.studentId,
    required this.subjectId,
    required this.totalClasses,
    required this.attendedClasses,
    required this.absentClasses,
    required this.lateClasses,
    required this.excusedClasses,
    required this.attendancePercentage,
  });

  factory AttendanceStats.fromJson(Map<String, dynamic> json) {
    return AttendanceStats(
      studentId: json['studentId'],
      subjectId: json['subjectId'],
      totalClasses: json['totalClasses'],
      attendedClasses: json['attendedClasses'],
      absentClasses: json['absentClasses'],
      lateClasses: json['lateClasses'],
      excusedClasses: json['excusedClasses'],
      attendancePercentage: json['attendancePercentage'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'subjectId': subjectId,
      'totalClasses': totalClasses,
      'attendedClasses': attendedClasses,
      'absentClasses': absentClasses,
      'lateClasses': lateClasses,
      'excusedClasses': excusedClasses,
      'attendancePercentage': attendancePercentage,
    };
  }

  bool get isShortAttendance => attendancePercentage < 75.0;
  bool get isGoodAttendance => attendancePercentage >= 90.0;
}
