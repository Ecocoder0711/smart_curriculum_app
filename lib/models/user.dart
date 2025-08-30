class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profileImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
      ),
      profileImage: json['profileImage'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum UserRole { teacher, student, admin }

class Teacher extends User {
  final String department;
  final List<String> subjects;
  final String employeeId;

  Teacher({
    required super.id,
    required super.name,
    required super.email,
    super.profileImage,
    required super.createdAt,
    required super.updatedAt,
    required this.department,
    required this.subjects,
    required this.employeeId,
  }) : super(role: UserRole.teacher);

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImage: json['profileImage'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      department: json['department'],
      subjects: List<String>.from(json['subjects']),
      employeeId: json['employeeId'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'department': department,
      'subjects': subjects,
      'employeeId': employeeId,
    });
    return json;
  }
}

class Student extends User {
  final String rollNumber;
  final String className;
  final String section;
  final int semester;
  final String department;

  Student({
    required super.id,
    required super.name,
    required super.email,
    super.profileImage,
    required super.createdAt,
    required super.updatedAt,
    required this.rollNumber,
    required this.className,
    required this.section,
    required this.semester,
    required this.department,
  }) : super(role: UserRole.student);

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImage: json['profileImage'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      rollNumber: json['rollNumber'],
      className: json['className'],
      section: json['section'],
      semester: json['semester'],
      department: json['department'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'rollNumber': rollNumber,
      'className': className,
      'section': section,
      'semester': semester,
      'department': department,
    });
    return json;
  }
}
