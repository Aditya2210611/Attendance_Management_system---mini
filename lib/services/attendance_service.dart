import 'package:intl/intl.dart';
import '../models/attendance.dart';
import '../models/course.dart';
import '../models/user.dart';
import '../data/static_data.dart';

class AttendanceService {
  // Singleton pattern
  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;
  AttendanceService._internal() {
    // Generate sample data when service is first created
    StaticData.generateSampleAttendanceData();
  }

  // Get courses by teacher ID
  List<Course> getCoursesByTeacher(String teacherId) {
    return StaticData.courses.where((course) => course.teacherId == teacherId).toList();
  }

  // Get courses by student ID
  List<Course> getCoursesByStudent(String studentId) {
    return StaticData.courses.where((course) => course.studentIds.contains(studentId)).toList();
  }

  // Get students by course ID
  List<User> getStudentsByCourse(String courseId) {
    final course = StaticData.courses.firstWhere((c) => c.id == courseId);
    return StaticData.users.where((user) => course.studentIds.contains(user.id)).toList();
  }

  // Get user by ID
  User getUserById(String userId) {
    return StaticData.users.firstWhere((user) => user.id == userId);
  }

  // Get course by ID
  Course getCourseById(String courseId) {
    return StaticData.courses.firstWhere((course) => course.id == courseId);
  }

  // Add attendance record
  void addAttendanceRecord(AttendanceRecord record) {
    // Check if record already exists
    final existingIndex = StaticData.attendanceRecords.indexWhere(
      (r) => r.courseId == record.courseId && 
             r.studentId == record.studentId && 
             DateFormat('yyyy-MM-dd').format(r.date) == DateFormat('yyyy-MM-dd').format(record.date)
    );
    
    if (existingIndex != -1) {
      // Update existing record
      StaticData.attendanceRecords[existingIndex] = record;
    } else {
      // Add new record
      StaticData.attendanceRecords.add(record);
    }
  }

  // Get attendance records by course ID
  List<AttendanceRecord> getAttendanceRecordsByCourse(String courseId) {
    return StaticData.attendanceRecords.where((record) => record.courseId == courseId).toList();
  }

  // Get attendance records by student ID
  List<AttendanceRecord> getAttendanceRecordsByStudent(String studentId) {
    return StaticData.attendanceRecords.where((record) => record.studentId == studentId).toList();
  }

  // Get attendance records by course ID and student ID
  List<AttendanceRecord> getAttendanceRecordsByCourseAndStudent(String courseId, String studentId) {
    return StaticData.attendanceRecords.where(
      (record) => record.courseId == courseId && record.studentId == studentId
    ).toList();
  }

  // Get attendance records by date range
  List<AttendanceRecord> getAttendanceRecordsByDateRange(DateTime startDate, DateTime endDate) {
    return StaticData.attendanceRecords.where(
      (record) => record.date.isAfter(startDate.subtract(const Duration(days: 1))) && 
                 record.date.isBefore(endDate.add(const Duration(days: 1)))
    ).toList();
  }

  // Calculate attendance percentage for a student in a course
  double calculateAttendancePercentage(String courseId, String studentId) {
    final records = getAttendanceRecordsByCourseAndStudent(courseId, studentId);
    if (records.isEmpty) return 0.0;
    
    final presentCount = records.where((record) => 
      record.status == AttendanceStatus.present || 
      record.status == AttendanceStatus.late
    ).length;
    
    return (presentCount / records.length) * 100;
  }

  // Get students with attendance below threshold
  List<Map<String, dynamic>> getStudentsBelowThreshold(String courseId, double threshold) {
    final course = getCourseById(courseId);
    final result = <Map<String, dynamic>>[];
    
    for (final studentId in course.studentIds) {
      final percentage = calculateAttendancePercentage(courseId, studentId);
      if (percentage < threshold) {
        final student = getUserById(studentId);
        result.add({
          'student': student,
          'percentage': percentage,
        });
      }
    }
    
    return result;
  }

  // Add a new course
  void addCourse(Course course) {
    StaticData.courses.add(course);
  }

  // Update a course
  void updateCourse(Course updatedCourse) {
    final index = StaticData.courses.indexWhere((course) => course.id == updatedCourse.id);
    if (index != -1) {
      StaticData.courses[index] = updatedCourse;
    }
  }

  // Delete a course
  void deleteCourse(String courseId) {
    StaticData.courses.removeWhere((course) => course.id == courseId);
    // Also remove related attendance records
    StaticData.attendanceRecords.removeWhere((record) => record.courseId == courseId);
  }

  // Add a student to a course
  void addStudentToCourse(String courseId, String studentId) {
    final index = StaticData.courses.indexWhere((course) => course.id == courseId);
    if (index != -1 && !StaticData.courses[index].studentIds.contains(studentId)) {
      final updatedStudentIds = List<String>.from(StaticData.courses[index].studentIds)..add(studentId);
      StaticData.courses[index] = Course(
        id: StaticData.courses[index].id,
        name: StaticData.courses[index].name,
        teacherId: StaticData.courses[index].teacherId,
        studentIds: updatedStudentIds,
      );
    }
  }

  // Remove a student from a course
  void removeStudentFromCourse(String courseId, String studentId) {
    final index = StaticData.courses.indexWhere((course) => course.id == courseId);
    if (index != -1 && StaticData.courses[index].studentIds.contains(studentId)) {
      final updatedStudentIds = List<String>.from(StaticData.courses[index].studentIds)..remove(studentId);
      StaticData.courses[index] = Course(
        id: StaticData.courses[index].id,
        name: StaticData.courses[index].name,
        teacherId: StaticData.courses[index].teacherId,
        studentIds: updatedStudentIds,
      );
      
      // Also remove related attendance records
      StaticData.attendanceRecords.removeWhere(
        (record) => record.courseId == courseId && record.studentId == studentId
      );
    }
  }

  // Add a new student
  void addStudent(User student) {
    if (student.role != UserRole.student) return;
    StaticData.users.add(student);
  }
}

