import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import '../models/course.dart';
import '../models/attendance.dart';
import '../services/attendance_service.dart';
import '../utils/constants.dart';

class StudentHomeWidget extends StatefulWidget {
  final User student;

  const StudentHomeWidget({super.key, required this.student});

  @override
  State<StudentHomeWidget> createState() => _StudentHomeWidgetState();
}

class _StudentHomeWidgetState extends State<StudentHomeWidget> {
  late List<Course> _courses;
  final _attendanceService = AttendanceService();

  @override
  void initState() {
    super.initState();
    _courses = _attendanceService.getCoursesByStudent(widget.student.id);
  }

  @override
  Widget build(BuildContext context) {
    // Calculate overall attendance
    double overallAttendance = 0;
    int totalCourses = _courses.length;
    
    if (totalCourses > 0) {
      double totalPercentage = 0;
      for (final course in _courses) {
        totalPercentage += _attendanceService.calculateAttendancePercentage(
          course.id,
          widget.student.id,
        );
      }
      overallAttendance = totalPercentage / totalCourses;
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
          
          // Overall Attendance Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Overall Attendance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: kDefaultPadding),
                  Center(
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: Stack(
                        children: [
                          Center(
                            child: SizedBox(
                              width: 150,
                              height: 150,
                              child: CircularProgressIndicator(
                                value: overallAttendance / 100,
                                strokeWidth: 12,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  overallAttendance < lowAttendanceThreshold
                                      ? Colors.red
                                      : overallAttendance < 85
                                          ? Colors.orange
                                          : Colors.green,
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${overallAttendance.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text('Attendance'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: kDefaultPadding),
                  LinearProgressIndicator(
                    value: overallAttendance / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      overallAttendance < lowAttendanceThreshold
                          ? Colors.red
                          : overallAttendance < 85
                              ? Colors.orange
                              : Colors.green,
                    ),
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  const SizedBox(height: kSmallPadding),
                  Text(
                    overallAttendance < lowAttendanceThreshold
                        ? 'Warning: Your attendance is below 75%'
                        : overallAttendance < 85
                            ? 'Your attendance is good, but could be better'
                            : 'Excellent attendance!',
                    style: TextStyle(
                      color: overallAttendance < lowAttendanceThreshold
                          ? Colors.red
                          : overallAttendance < 85
                              ? Colors.orange
                              : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
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
              child: Text('You are not enrolled in any courses.'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                final course = _courses[index];
                final teacher = _attendanceService.getUserById(course.teacherId);
                final attendancePercentage = _attendanceService.calculateAttendancePercentage(
                  course.id,
                  widget.student.id,
                );
                
                return Card(
                  margin: const EdgeInsets.only(bottom: kDefaultPadding),
                  child: Padding(
                    padding: const EdgeInsets.all(kDefaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text('Teacher: ${teacher.name}'),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: attendancePercentage < lowAttendanceThreshold
                                    ? Colors.red.withOpacity(0.2)
                                    : attendancePercentage < 85
                                        ? Colors.orange.withOpacity(0.2)
                                        : Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${attendancePercentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: attendancePercentage < lowAttendanceThreshold
                                      ? Colors.red
                                      : attendancePercentage < 85
                                          ? Colors.orange
                                          : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: attendancePercentage / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            attendancePercentage < lowAttendanceThreshold
                                ? Colors.red
                                : attendancePercentage < 85
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
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

  Widget _buildRecentAttendance() {
    // Get all attendance records for this student
    final allRecords = _attendanceService.getAttendanceRecordsByStudent(widget.student.id);
    
    // Sort by date (most recent first)
    allRecords.sort((a, b) => b.date.compareTo(a.date));
    
    // Take only the most recent 10 records
    final recentRecords = allRecords.take(10).toList();
    
    if (recentRecords.isEmpty) {
      return const Center(
        child: Text('No recent attendance records.'),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentRecords.length,
      itemBuilder: (context, index) {
        final record = recentRecords[index];
        final course = _attendanceService.getCourseById(record.courseId);
        
        final statusText = record.status == AttendanceStatus.present 
            ? 'Present' 
            : record.status == AttendanceStatus.late 
                ? 'Late' 
                : 'Absent';
        
        final statusColor = record.status == AttendanceStatus.present 
            ? Colors.green 
            : record.status == AttendanceStatus.late 
                ? Colors.orange 
                : Colors.red;
        
        return Card(
          margin: const EdgeInsets.only(bottom: kSmallPadding),
          child: ListTile(
            title: Text(course.name),
            subtitle: Text(
              DateFormat('yyyy-MM-dd HH:mm').format(record.date),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

