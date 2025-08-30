class Subject {
  final String id;
  final String name;
  final String code;
  final String description;
  final int credits;
  final String department;
  final int semester;
  final List<String> topics;

  Subject({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.credits,
    required this.department,
    required this.semester,
    required this.topics,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      description: json['description'],
      credits: json['credits'],
      department: json['department'],
      semester: json['semester'],
      topics: List<String>.from(json['topics']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'credits': credits,
      'department': department,
      'semester': semester,
      'topics': topics,
    };
  }

  Subject copyWith({
    String? id,
    String? name,
    String? code,
    String? description,
    int? credits,
    String? department,
    int? semester,
    List<String>? topics,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      credits: credits ?? this.credits,
      department: department ?? this.department,
      semester: semester ?? this.semester,
      topics: topics ?? this.topics,
    );
  }
}

class Curriculum {
  final String id;
  final String name;
  final String department;
  final int totalSemesters;
  final List<Subject> subjects;
  final DateTime createdAt;
  final DateTime updatedAt;

  Curriculum({
    required this.id,
    required this.name,
    required this.department,
    required this.totalSemesters,
    required this.subjects,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Curriculum.fromJson(Map<String, dynamic> json) {
    return Curriculum(
      id: json['id'],
      name: json['name'],
      department: json['department'],
      totalSemesters: json['totalSemesters'],
      subjects: (json['subjects'] as List)
          .map((subject) => Subject.fromJson(subject))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'department': department,
      'totalSemesters': totalSemesters,
      'subjects': subjects.map((subject) => subject.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  List<Subject> getSubjectsBySemester(int semester) {
    return subjects.where((subject) => subject.semester == semester).toList();
  }

  int getTotalCredits() {
    return subjects.fold(0, (total, subject) => total + subject.credits);
  }

  int getCreditsBySemester(int semester) {
    return getSubjectsBySemester(
      semester,
    ).fold(0, (total, subject) => total + subject.credits);
  }
}
