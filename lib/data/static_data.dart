import '../models/user.dart';
import '../models/course.dart';
import '../models/attendance.dart';

class StaticData {
  // Users
  static List<User> users = [
    // Teachers
    User(id: 't1', username: 'teacher1', password: 'pass123', name: 'John Smith', role: UserRole.teacher),
    User(id: 't2', username: 'teacher2', password: 'pass123', name: 'Emily Johnson', role: UserRole.teacher),
    User(id: 't3', username: 'teacher3', password: 'pass123', name: 'Michael Brown', role: UserRole.teacher),
    
    // Students
    User(id: 's1', username: 'student1', password: 'pass123', name: 'Alice Williams', role: UserRole.student),
    User(id: 's2', username: 'student2', password: 'pass123', name: 'Bob Jones', role: UserRole.student),
    User(id: 's3', username: 'student3', password: 'pass123', name: 'Charlie Davis', role: UserRole.student),
    User(id: 's4', username: 'student4', password: 'pass123', name: 'Diana Miller', role: UserRole.student),
    User(id: 's5', username: 'student5', password: 'pass123', name: 'Edward Wilson', role: UserRole.student),
    User(id: 's6', username: 'student6', password: 'pass123', name: 'Fiona Moore', role: UserRole.student),
    User(id: 's7', username: 'student7', password: 'pass123', name: 'George Taylor', role: UserRole.student),
    User(id: 's8', username: 'student8', password: 'pass123', name: 'Hannah Anderson', role: UserRole.student),
    User(id: 's9', username: 'student9', password: 'pass123', name: 'Ian Thomas', role: UserRole.student),
    User(id: 's10', username: 'student10', password: 'pass123', name: 'Julia Jackson', role: UserRole.student),
    User(id: 's11', username: 'student11', password: 'pass123', name: 'Kevin White', role: UserRole.student),
    User(id: 's12', username: 'student12', password: 'pass123', name: 'Laura Harris', role: UserRole.student),
    User(id: 's13', username: 'student13', password: 'pass123', name: 'Mark Martin', role: UserRole.student),
    User(id: 's14', username: 'student14', password: 'pass123', name: 'Nancy Thompson', role: UserRole.student),
    User(id: 's15', username: 'student15', password: 'pass123', name: 'Oliver Garcia', role: UserRole.student),
    User(id: 's16', username: 'student16', password: 'pass123', name: 'Patricia Martinez', role: UserRole.student),
    User(id: 's17', username: 'student17', password: 'pass123', name: 'Quincy Robinson', role: UserRole.student),
    User(id: 's18', username: 'student18', password: 'pass123', name: 'Rachel Clark', role: UserRole.student),
    User(id: 's19', username: 'student19', password: 'pass123', name: 'Samuel Rodriguez', role: UserRole.student),
    User(id: 's20', username: 'student20', password: 'pass123', name: 'Tina Lewis', role: UserRole.student),
  ];

  // Courses
  static List<Course> courses = [
    Course(
      id: 'c1',
      name: 'Mathematics',
      teacherId: 't1',
      studentIds: ['s1', 's2', 's3', 's4', 's5', 's6', 's7'],
    ),
    Course(
      id: 'c2',
      name: 'Physics',
      teacherId: 't2',
      studentIds: ['s3', 's4', 's5', 's8', 's9', 's10', 's11'],
    ),
    Course(
      id: 'c3',
      name: 'Computer Science',
      teacherId: 't3',
      studentIds: ['s1', 's5', 's9', 's12', 's13', 's14', 's15'],
    ),
    Course(
      id: 'c4',
      name: 'Chemistry',
      teacherId: 't1',
      studentIds: ['s2', 's6', 's10', 's14', 's16', 's17', 's18'],
    ),
    Course(
      id: 'c5',
      name: 'Biology',
      teacherId: 't2',
      studentIds: ['s7', 's11', 's15', 's16', 's19', 's20'],
    ),
  ];

  // Attendance Records (initially empty)
  static List<AttendanceRecord> attendanceRecords = [];

  // Generate sample attendance data for the past month
  static void generateSampleAttendanceData() {
    if (attendanceRecords.isNotEmpty) return; // Only generate once
    
    final now = DateTime.now();
    final oneMonthAgo = DateTime(now.year, now.month - 1, now.day);
    
    // For each course
    for (final course in courses) {
      // For each student in the course
      for (final studentId in course.studentIds) {
        // Generate attendance for each day in the past month
        for (var day = oneMonthAgo; day.isBefore(now); day = day.add(const Duration(days: 1))) {
          // Skip weekends
          if (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) {
            continue;
          }
          
          // Random attendance status (80% chance of being present)
          final random = day.millisecondsSinceEpoch % 10;
          final status = random < 8 
              ? AttendanceStatus.present 
              : random == 8 
                  ? AttendanceStatus.late 
                  : AttendanceStatus.absent;
          
          attendanceRecords.add(
            AttendanceRecord(
              id: 'a${attendanceRecords.length + 1}',
              courseId: course.id,
              studentId: studentId,
              date: DateTime(day.year, day.month, day.day, 9, 0), // 9:00 AM
              status: status,
            ),
          );
        }
      }
    }
  }

  // Generate a unique ID
  static String generateId(String prefix) {
    return '$prefix${DateTime.now().millisecondsSinceEpoch}';
  }
}

