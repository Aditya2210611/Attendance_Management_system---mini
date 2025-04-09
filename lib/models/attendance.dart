enum AttendanceStatus { present, absent, late }

class AttendanceRecord {
  final String id;
  final String courseId;
  final String studentId;
  final DateTime date;
  final AttendanceStatus status;

  AttendanceRecord({
    required this.id,
    required this.courseId,
    required this.studentId,
    required this.date,
    required this.status,
  });

  AttendanceRecord copyWith({
    String? id,
    String? courseId,
    String? studentId,
    DateTime? date,
    AttendanceStatus? status,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      studentId: studentId ?? this.studentId,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'AttendanceRecord(id: $id, courseId: $courseId, studentId: $studentId, date: $date, status: $status)';
  }
}

