import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../models/course.dart';
import '../models/attendance.dart';
import '../services/attendance_service.dart';
import '../services/export_service.dart';
import '../services/file_service.dart';
import '../utils/constants.dart';

class AttendanceScreen extends StatefulWidget {
  final Course course;
  final User teacher;

  const AttendanceScreen({
    super.key,
    required this.course,
    required this.teacher,
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late List<User> _students;
  late DateTime _selectedDate;
  final Map<String, AttendanceStatus> _attendanceStatus = {};
  bool _isLoading = false;

  final _attendanceService = AttendanceService();
  final _exportService = ExportService();

  @override
  void initState() {
    super.initState();
    _students = _attendanceService.getStudentsByCourse(widget.course.id);
    _selectedDate = DateTime.now();
    _loadAttendanceData();
  }

  void _loadAttendanceData() {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    
    // Get existing attendance records for this date and course
    final records = _attendanceService.getAttendanceRecordsByCourse(widget.course.id)
      .where((record) => DateFormat('yyyy-MM-dd').format(record.date) == dateStr)
      .toList();
    
    // Initialize attendance status
    for (final student in _students) {
      final record = records.firstWhere(
        (r) => r.studentId == student.id,
        orElse: () => AttendanceRecord(
          id: 'temp',
          courseId: widget.course.id,
          studentId: student.id,
          date: _selectedDate,
          status: AttendanceStatus.absent,
        ),
      );
      
      _attendanceStatus[student.id] = record.status;
    }
    
    setState(() {});
  }

  Future<void> _saveAttendance() async {
    setState(() {
      _isLoading = true;
    });
    
    // Save attendance records
    for (final student in _students) {
      final status = _attendanceStatus[student.id] ?? AttendanceStatus.absent;
      
      final record = AttendanceRecord(
        id: 'a${DateTime.now().millisecondsSinceEpoch}_${student.id}',
        courseId: widget.course.id,
        studentId: student.id,
        date: _selectedDate,
        status: status,
      );
      
      _attendanceService.addAttendanceRecord(record);
    }
    
    // Export to Excel
    try {
      final fileService = Provider.of<FileService>(context, listen: false);
      final excelPath = await _exportService.exportAttendanceToExcel(
        widget.course.id,
        _selectedDate,
      );
      
      if (!mounted) return;
      
      if (fileService.isWeb) {
        showSuccessSnackBar(
          context,
          'Attendance saved and Excel file downloaded',
        );
      } else {
        showSuccessSnackBar(
          context,
          'Attendance saved and exported to Excel: $excelPath',
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      showErrorSnackBar(
        context,
        'Error exporting to Excel: $e',
      );
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance - ${widget.course.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              
              if (pickedDate != null && pickedDate != _selectedDate) {
                setState(() {
                  _selectedDate = pickedDate;
                });
                _loadAttendanceData();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(kDefaultPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              // Mark all present
                              setState(() {
                                for (final student in _students) {
                                  _attendanceStatus[student.id] = AttendanceStatus.present;
                                }
                              });
                            },
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Mark All Present'),
                          ),
                          const SizedBox(width: kSmallPadding),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Mark all absent
                              setState(() {
                                for (final student in _students) {
                                  _attendanceStatus[student.id] = AttendanceStatus.absent;
                                }
                              });
                            },
                            icon: const Icon(Icons.cancel),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            label: const Text('Mark All Absent'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _students.isEmpty
                      ? const Center(
                          child: Text('No students enrolled in this course.'),
                        )
                      : ListView.builder(
                          itemCount: _students.length,
                          itemBuilder: (context, index) {
                            final student = _students[index];
                            final status = _attendanceStatus[student.id] ?? AttendanceStatus.absent;
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: kDefaultPadding, vertical: 4),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(student.name[0]),
                                ),
                                title: Text(student.name),
                                subtitle: Text('ID: ${student.id}'),
                                trailing: DropdownButton<AttendanceStatus>(
                                  value: status,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _attendanceStatus[student.id] = value;
                                      });
                                    }
                                  },
                                  items: AttendanceStatus.values.map((status) {
                                    String statusText;
                                    Color statusColor;
                                    
                                    switch (status) {
                                      case AttendanceStatus.present:
                                        statusText = 'Present';
                                        statusColor = Colors.green;
                                        break;
                                      case AttendanceStatus.late:
                                        statusText = 'Late';
                                        statusColor = Colors.orange;
                                        break;
                                      case AttendanceStatus.absent:
                                        statusText = 'Absent';
                                        statusColor = Colors.red;
                                        break;
                                    }
                                    
                                    return DropdownMenuItem<AttendanceStatus>(
                                      value: status,
                                      child: Container(
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
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding, vertical: kSmallPadding),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveAttendance,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                _isLoading ? 'Saving...' : 'Save Attendance',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

