import 'attendance.dart';

enum ActivityType {
  lecture,
  practical,
  assignment,
  quiz,
  exam,
  presentation,
  fieldWork,
  workshop,
  seminar,
}

enum ActivityStatus { scheduled, ongoing, completed, cancelled, postponed }

class Activity {
  final String id;
  final String title;
  final String description;
  final ActivityType type;
  final ActivityStatus status;
  final String subjectId;
  final String teacherId;
  final DateTime scheduledDate;
  final DateTime? startTime;
  final DateTime? endTime;
  final String location;
  final List<String> materials;
  final List<String> participants;
  final int maxMarks;
  final String? instructions;
  final DateTime createdAt;
  final DateTime updatedAt;

  Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.subjectId,
    required this.teacherId,
    required this.scheduledDate,
    this.startTime,
    this.endTime,
    required this.location,
    required this.materials,
    required this.participants,
    required this.maxMarks,
    this.instructions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: ActivityType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      status: ActivityStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      subjectId: json['subjectId'],
      teacherId: json['teacherId'],
      scheduledDate: DateTime.parse(json['scheduledDate']),
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      location: json['location'],
      materials: List<String>.from(json['materials']),
      participants: List<String>.from(json['participants']),
      maxMarks: json['maxMarks'],
      instructions: json['instructions'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'subjectId': subjectId,
      'teacherId': teacherId,
      'scheduledDate': scheduledDate.toIso8601String(),
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'location': location,
      'materials': materials,
      'participants': participants,
      'maxMarks': maxMarks,
      'instructions': instructions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Activity copyWith({
    String? id,
    String? title,
    String? description,
    ActivityType? type,
    ActivityStatus? status,
    String? subjectId,
    String? teacherId,
    DateTime? scheduledDate,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    List<String>? materials,
    List<String>? participants,
    int? maxMarks,
    String? instructions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      subjectId: subjectId ?? this.subjectId,
      teacherId: teacherId ?? this.teacherId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      materials: materials ?? this.materials,
      participants: participants ?? this.participants,
      maxMarks: maxMarks ?? this.maxMarks,
      instructions: instructions ?? this.instructions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Duration? get duration {
    if (startTime != null && endTime != null) {
      return endTime!.difference(startTime!);
    }
    return null;
  }

  bool get isToday {
    final now = DateTime.now();
    return scheduledDate.year == now.year &&
        scheduledDate.month == now.month &&
        scheduledDate.day == now.day;
  }

  bool get isUpcoming {
    return scheduledDate.isAfter(DateTime.now());
  }

  bool get isPast {
    return scheduledDate.isBefore(DateTime.now());
  }
}

class ClassSession {
  final String id;
  final String activityId;
  final DateTime startTime;
  final DateTime? endTime;
  final String qrCode;
  final String location;
  final List<Attendance> attendanceRecords;
  final bool isActive;

  ClassSession({
    required this.id,
    required this.activityId,
    required this.startTime,
    this.endTime,
    required this.qrCode,
    required this.location,
    required this.attendanceRecords,
    required this.isActive,
  });

  factory ClassSession.fromJson(Map<String, dynamic> json) {
    return ClassSession(
      id: json['id'],
      activityId: json['activityId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      qrCode: json['qrCode'],
      location: json['location'],
      attendanceRecords: (json['attendanceRecords'] as List)
          .map((record) => Attendance.fromJson(record))
          .toList(),
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activityId': activityId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'qrCode': qrCode,
      'location': location,
      'attendanceRecords': attendanceRecords
          .map((record) => record.toJson())
          .toList(),
      'isActive': isActive,
    };
  }

  int get totalStudents => attendanceRecords.length;
  int get presentStudents => attendanceRecords
      .where((record) => record.status == AttendanceStatus.present)
      .length;
  int get absentStudents => attendanceRecords
      .where((record) => record.status == AttendanceStatus.absent)
      .length;
  double get attendancePercentage =>
      totalStudents > 0 ? (presentStudents / totalStudents) * 100 : 0.0;
}
