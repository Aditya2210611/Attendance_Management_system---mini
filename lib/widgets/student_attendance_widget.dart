import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import '../models/course.dart';
import '../models/attendance.dart';
import '../services/attendance_service.dart';
import '../utils/constants.dart';

class StudentAttendanceWidget extends StatefulWidget {
  final User student;

  const StudentAttendanceWidget({super.key, required this.student});

  @override
  State<StudentAttendanceWidget> createState() => _StudentAttendanceWidgetState();
}

class _StudentAttendanceWidgetState extends State<StudentAttendanceWidget> {
  late List<Course> _courses;
  Course? _selectedCourse;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  final _attendanceService = AttendanceService();

  @override
  void initState() {
    super.initState();
    _courses = _attendanceService.getCoursesByStudent(widget.student.id);
    if (_courses.isNotEmpty) {
      _selectedCourse = _courses.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attendance Details',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: kLargePadding),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'View Attendance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: kDefaultPadding),
                  
                  // Course Selection
                  DropdownButtonFormField<Course>(
                    decoration: const InputDecoration(
                      labelText: 'Select Course',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedCourse,
                    items: _courses.map((course) {
                      return DropdownMenuItem<Course>(
                        value: course,
                        child: Text(course.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCourse = value;
                      });
                    },
                  ),
                  const SizedBox(height: kDefaultPadding),
                  
                  // Date Range
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Start Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          controller: TextEditingController(
                            text: DateFormat('yyyy-MM-dd').format(_startDate),
                          ),
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: _startDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            
                            if (pickedDate != null) {
                              setState(() {
                                _startDate = pickedDate;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: kDefaultPadding),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'End Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          controller: TextEditingController(
                            text: DateFormat('yyyy-MM-dd').format(_endDate),
                          ),
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: _endDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            
                            if (pickedDate != null) {
                              setState(() {
                                _endDate = pickedDate;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: kLargePadding),
          
          // Attendance Summary
          if (_selectedCourse != null) ...[
            Text(
              'Attendance Summary - ${_selectedCourse!.name}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: kDefaultPadding),
            
            _buildAttendanceSummary(),
            
            const SizedBox(height: kLargePadding),
            
            Text(
              'Attendance Records - ${_selectedCourse!.name}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: kDefaultPadding),
            
            _buildAttendanceRecords(),
          ],
        ],
      ),
    );
  }

  Widget _buildAttendanceSummary() {
    if (_selectedCourse == null) return const SizedBox.shrink();
    
    final percentage = _attendanceService.calculateAttendancePercentage(
      _selectedCourse!.id,
      widget.student.id,
    );
    
    final color = percentage < lowAttendanceThreshold
        ? Colors.red
        : percentage < 85
            ? Colors.orange
            : Colors.green;
    
    final records = _attendanceService.getAttendanceRecordsByCourseAndStudent(
      _selectedCourse!.id,
      widget.student.id,
    );
    
    final totalClasses = records.length;
    final presentClasses = records.where((record) => 
      record.status == AttendanceStatus.present || 
      record.status == AttendanceStatus.late
    ).length;
    final absentClasses = totalClasses - presentClasses;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Attendance Percentage:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: kSmallPadding),
                      Text(
                        '${percentage.toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: kSmallPadding),
                      Text(
                        percentage < lowAttendanceThreshold
                            ? 'Warning: Your attendance is below 75%'
                            : percentage < 85
                                ? 'Your attendance is good, but could be better'
                                : 'Excellent attendance!',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatColumn(
                            'Total Classes',
                            totalClasses.toString(),
                            Colors.blue,
                          ),
                          _buildStatColumn(
                            'Present',
                            presentClasses.toString(),
                            Colors.green,
                          ),
                          _buildStatColumn(
                            'Absent',
                            absentClasses.toString(),
                            Colors.red,
                          ),
                        ],
                      ),
                      const SizedBox(height: kDefaultPadding),
                      LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceRecords() {
    if (_selectedCourse == null) return const SizedBox.shrink();
    
    // Get filtered records
    final records = _attendanceService.getAttendanceRecordsByCourseAndStudent(
      _selectedCourse!.id,
      widget.student.id,
    ).where(
      (record) => record.date.isAfter(_startDate.subtract(const Duration(days: 1))) && 
                 record.date.isBefore(_endDate.add(const Duration(days: 1)))
    ).toList();
    
    // Sort by date (most recent first)
    records.sort((a, b) => b.date.compareTo(a.date));
    
    if (records.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(kDefaultPadding),
          child: Center(
            child: Text('No attendance records found for the selected period.'),
          ),
        ),
      );
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            
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
            
            return ListTile(
              title: Text(
                DateFormat('EEEE, MMMM d, yyyy').format(record.date),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(DateFormat('HH:mm').format(record.date)),
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
            );
          },
        ),
      ),
    );
  }
}

