import '../models/user.dart';
import '../models/curriculum.dart';
import '../models/activity.dart';
import '../models/attendance.dart';

class DemoDataService {
  // Singleton pattern
  static final DemoDataService _instance = DemoDataService._internal();
  factory DemoDataService() => _instance;
  DemoDataService._internal();

  // Demo Users
  static final List<User> _demoUsers = [
    Teacher(
      id: 'teacher_1',
      name: 'Dr. John Smith',
      email: 'john.smith@university.edu',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
      department: 'Computer Science',
      subjects: ['Data Structures', 'Algorithms', 'Database Systems'],
      employeeId: 'EMP001',
    ),
    Teacher(
      id: 'teacher_2',
      name: 'Prof. Sarah Wilson',
      email: 'sarah.wilson@university.edu',
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
      updatedAt: DateTime.now(),
      department: 'Mathematics',
      subjects: ['Calculus', 'Linear Algebra', 'Statistics'],
      employeeId: 'EMP002',
    ),
    Student(
      id: 'student_1',
      name: 'Alice Johnson',
      email: 'alice.johnson@student.university.edu',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now(),
      rollNumber: 'CS2021001',
      className: 'CSE',
      section: 'A',
      semester: 6,
      department: 'Computer Science',
    ),
    Student(
      id: 'student_2',
      name: 'Bob Davis',
      email: 'bob.davis@student.university.edu',
      createdAt: DateTime.now().subtract(const Duration(days: 18)),
      updatedAt: DateTime.now(),
      rollNumber: 'CS2021002',
      className: 'CSE',
      section: 'A',
      semester: 6,
      department: 'Computer Science',
    ),
  ];

  // Demo Subjects
  static final List<Subject> _demoSubjects = [
    Subject(
      id: 'subject_1',
      name: 'Data Structures and Algorithms',
      code: 'CSE301',
      description: 'Fundamental data structures and algorithmic techniques',
      credits: 4,
      department: 'Computer Science',
      semester: 6,
      topics: [
        'Arrays',
        'Linked Lists',
        'Trees',
        'Graphs',
        'Sorting',
        'Searching',
      ],
    ),
    Subject(
      id: 'subject_2',
      name: 'Database Management Systems',
      code: 'CSE302',
      description: 'Database design, implementation, and management',
      credits: 3,
      department: 'Computer Science',
      semester: 6,
      topics: ['ER Model', 'SQL', 'Normalization', 'Transactions', 'Indexing'],
    ),
    Subject(
      id: 'subject_3',
      name: 'Software Engineering',
      code: 'CSE303',
      description: 'Software development methodologies and project management',
      credits: 3,
      department: 'Computer Science',
      semester: 6,
      topics: ['SDLC', 'Agile', 'Testing', 'Version Control', 'Documentation'],
    ),
  ];

  // Demo Activities
  static final List<Activity> _demoActivities = [
    Activity(
      id: 'activity_1',
      title: 'Introduction to Binary Trees',
      description:
          'Lecture on binary tree data structure and traversal algorithms',
      type: ActivityType.lecture,
      status: ActivityStatus.completed,
      subjectId: 'subject_1',
      teacherId: 'teacher_1',
      scheduledDate: DateTime.now().subtract(const Duration(days: 1)),
      startTime: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      endTime: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
      location: 'Room 201',
      materials: ['Slides: Binary Trees', 'Reference: CLRS Chapter 12'],
      participants: ['student_1', 'student_2'],
      maxMarks: 0,
      instructions: 'Bring your laptops for coding exercises',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Activity(
      id: 'activity_2',
      title: 'Graph Algorithms Lab',
      description: 'Hands-on implementation of graph traversal algorithms',
      type: ActivityType.practical,
      status: ActivityStatus.scheduled,
      subjectId: 'subject_1',
      teacherId: 'teacher_1',
      scheduledDate: DateTime.now().add(const Duration(hours: 2)),
      location: 'Computer Lab 1',
      materials: ['Lab Manual', 'Sample Graphs Dataset'],
      participants: ['student_1', 'student_2'],
      maxMarks: 25,
      instructions: 'Complete BFS and DFS implementations',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
    ),
    Activity(
      id: 'activity_3',
      title: 'Database Design Assignment',
      description: 'Design an ER model for a library management system',
      type: ActivityType.assignment,
      status: ActivityStatus.ongoing,
      subjectId: 'subject_2',
      teacherId: 'teacher_1',
      scheduledDate: DateTime.now().add(const Duration(days: 7)),
      location: 'Online Submission',
      materials: ['Assignment Guidelines', 'Sample ER Diagrams'],
      participants: ['student_1', 'student_2'],
      maxMarks: 50,
      instructions: 'Submit both ER diagram and relational schema',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now(),
    ),
  ];

  // Demo Attendance Records
  static final List<Attendance> _demoAttendance = [
    Attendance(
      id: 'attendance_1',
      studentId: 'student_1',
      classSessionId: 'session_1',
      status: AttendanceStatus.present,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      location: 'Room 201',
      markedByTeacher: false,
    ),
    Attendance(
      id: 'attendance_2',
      studentId: 'student_2',
      classSessionId: 'session_1',
      status: AttendanceStatus.present,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      location: 'Room 201',
      markedByTeacher: false,
    ),
  ];

  // Getters for demo data
  List<User> get users => List.unmodifiable(_demoUsers);
  List<Teacher> get teachers => _demoUsers.whereType<Teacher>().toList();
  List<Student> get students => _demoUsers.whereType<Student>().toList();
  List<Subject> get subjects => List.unmodifiable(_demoSubjects);
  List<Activity> get activities => List.unmodifiable(_demoActivities);
  List<Attendance> get attendanceRecords => List.unmodifiable(_demoAttendance);

  // Authentication simulation
  User? authenticateUser(String email, String password) {
    // In a real app, this would verify against a secure backend
    // For demo purposes, find user by email
    print('DEBUG: DemoDataService authenticateUser called with email: $email');
    print(
      'DEBUG: Available demo users: ${_demoUsers.map((u) => '${u.email} (${u.role})').toList()}',
    );

    try {
      final user = _demoUsers.firstWhere(
        (user) => user.email.toLowerCase() == email.toLowerCase(),
      );
      print('DEBUG: Found user: ${user.toJson()}');
      return user;
    } catch (e) {
      print('DEBUG: User not found for email: $email');
      // Return null if user not found
      return null;
    }
  }

  // Get activities for a specific teacher
  List<Activity> getActivitiesForTeacher(String teacherId) {
    return _demoActivities
        .where((activity) => activity.teacherId == teacherId)
        .toList();
  }

  // Get activities for a specific student
  List<Activity> getActivitiesForStudent(String studentId) {
    return _demoActivities
        .where((activity) => activity.participants.contains(studentId))
        .toList();
  }

  // Get attendance stats for a student
  AttendanceStats getAttendanceStatsForStudent(
    String studentId,
    String subjectId,
  ) {
    final totalClasses = _demoActivities
        .where(
          (activity) =>
              activity.subjectId == subjectId &&
              activity.participants.contains(studentId) &&
              activity.status == ActivityStatus.completed,
        )
        .length;

    final attendedClasses = _demoAttendance
        .where(
          (attendance) =>
              attendance.studentId == studentId &&
              attendance.status == AttendanceStatus.present,
        )
        .length;

    final absentClasses = totalClasses - attendedClasses;
    final attendancePercentage = totalClasses > 0
        ? (attendedClasses / totalClasses) * 100
        : 0.0;

    return AttendanceStats(
      studentId: studentId,
      subjectId: subjectId,
      totalClasses: totalClasses,
      attendedClasses: attendedClasses,
      absentClasses: absentClasses,
      lateClasses: 0,
      excusedClasses: 0,
      attendancePercentage: attendancePercentage,
    );
  }

  // Get today's activities
  List<Activity> getTodaysActivities() {
    final today = DateTime.now();
    return _demoActivities.where((activity) {
      return activity.scheduledDate.year == today.year &&
          activity.scheduledDate.month == today.month &&
          activity.scheduledDate.day == today.day;
    }).toList();
  }

  // Get upcoming activities
  List<Activity> getUpcomingActivities({int limit = 5}) {
    final now = DateTime.now();
    return _demoActivities
        .where((activity) => activity.scheduledDate.isAfter(now))
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate))
      ..take(limit);
  }
}
