class Course {
  final String id;
  final String name;
  final String teacherId;
  final List<String> studentIds;

  Course({
    required this.id,
    required this.name,
    required this.teacherId,
    required this.studentIds,
  });

  Course copyWith({
    String? id,
    String? name,
    String? teacherId,
    List<String>? studentIds,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      teacherId: teacherId ?? this.teacherId,
      studentIds: studentIds ?? this.studentIds,
    );
  }

  @override
  String toString() {
    return 'Course(id: $id, name: $name, teacherId: $teacherId, studentIds: $studentIds)';
  }
}

