import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import '../models/course.dart';
import '../models/attendance.dart';
import '../services/attendance_service.dart';
import '../screens/attendance_screen.dart';
import '../utils/constants.dart';

class TeacherHomeWidget extends StatefulWidget {
  final User teacher;
  final VoidCallback onCoursesChanged;

  const TeacherHomeWidget({
    super.key,
    required this.teacher,
    required this.onCoursesChanged,
  });

  @override
  State<TeacherHomeWidget> createState() => _TeacherHomeWidgetState();
}

class _TeacherHomeWidgetState extends State<TeacherHomeWidget> {
  late List<Course> _courses;
  final _attendanceService = AttendanceService();

  @override
  void initState() {
    super.initState();
    _courses = _attendanceService.getCoursesByTeacher(widget.teacher.id);
  }

  @override
  Widget build(BuildContext context) {
    // Calculate statistics
    int totalStudents = 0;
    int totalClasses = _courses.length;
    int totalAttendanceRecords = 0;

    for (final course in _courses) {
      totalStudents += course.studentIds.length;
      totalAttendanceRecords += _attendanceService.getAttendanceRecordsByCourse(course.id).length;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: kLargePadding),

          // Statistics Cards
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: kDefaultPadding,
            mainAxisSpacing: kDefaultPadding,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStatCard(context, 'Total Courses', totalClasses.toString(), Icons.class_),
              _buildStatCard(context, 'Total Students', totalStudents.toString(), Icons.people),
              _buildStatCard(context, 'Attendance Records', totalAttendanceRecords.toString(), Icons.assignment_turned_in),
              _buildStatCard(context, 'Upcoming Classes', _courses.length.toString(), Icons.event),
            ],
          ),

          const SizedBox(height: kLargePadding),
          Text(
            'Your Courses',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: kDefaultPadding),

          // Course List
          if (_courses.isEmpty)
            const Center(
              child: Text('No courses found. Create a new course to get started.'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                final course = _courses[index];
                final studentCount = course.studentIds.length;

                return Card(
                  margin: const EdgeInsets.only(bottom: kDefaultPadding),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(kDefaultPadding),
                    title: Text(
                      course.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('$studentCount students'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AttendanceScreen(
                              course: course,
                              teacher: widget.teacher,
                            ),
                          ),
                        ).then((_) {
                          setState(() {
                            // Refresh data when returning from attendance screen
                          });
                        });
                      },
                      child: const Text('Take Attendance'),
                    ),
                  ),
                );
              },
            ),

          const SizedBox(height: kLargePadding),
          Text(
            'Recent Attendance',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: kDefaultPadding),

          // Recent Attendance
          _buildRecentAttendance(),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: kSmallPadding),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAttendance() {
    final allRecords = <AttendanceRecord>[];
    for (final course in _courses) {
      allRecords.addAll(_attendanceService.getAttendanceRecordsByCourse(course.id));
    }
    allRecords.sort((a, b) => b.date.compareTo(a.date));
    final recentRecords = allRecords.take(10).toList();

    if (recentRecords.isEmpty) {
      return const Center(child: Text('No recent attendance records.'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentRecords.length,
      itemBuilder: (context, index) {
        final record = recentRecords[index];
        final student = _attendanceService.getUserById(record.studentId);
        final course = _attendanceService.getCourseById(record.courseId);
        final statusText = record.status == AttendanceStatus.present ? 'Present' : record.status == AttendanceStatus.late ? 'Late' : 'Absent';
        final statusColor = record.status == AttendanceStatus.present ? Colors.green : record.status == AttendanceStatus.late ? Colors.orange : Colors.red;

        return Card(
          margin: const EdgeInsets.only(bottom: kSmallPadding),
          child: ListTile(
            leading: CircleAvatar(child: Text(student.name[0])),
            title: Text(student.name),
            subtitle: Text('${course.name} - ${DateFormat('yyyy-MM-dd HH:mm').format(record.date)}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      },
    );
  }
}
