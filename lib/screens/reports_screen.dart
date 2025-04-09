import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import '../models/course.dart';
import '../services/attendance_service.dart';
import '../services/export_service.dart';
import '../utils/constants.dart';

class ReportsScreen extends StatefulWidget {
  final User teacher;

  const ReportsScreen({super.key, required this.teacher});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late List<Course> _courses;
  Course? _selectedCourse;
  String? _selectedStudentId;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _reportType = 'course'; // 'course' or 'student'
  bool _isLoading = false;
  
  final _attendanceService = AttendanceService();
  final _exportService = ExportService();
  
  @override
  void initState() {
    super.initState();
    _courses = _attendanceService.getCoursesByTeacher(widget.teacher.id);
    if (_courses.isNotEmpty) {
      _selectedCourse = _courses.first;
    }
  }
  
  Future<void> _generateReport() async {
    if (_selectedCourse == null) {
      showErrorSnackBar(context, 'Please select a course');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      String pdfPath;
      
      if (_reportType == 'student' && _selectedStudentId != null) {
        // Generate student report
        pdfPath = await _exportService.exportAttendanceToPdf(
          _selectedCourse!.id,
          _startDate,
          _endDate,
          studentId: _selectedStudentId,
        );
      } else {
        // Generate course report
        pdfPath = await _exportService.exportAttendanceToPdf(
          _selectedCourse!.id,
          _startDate,
          _endDate,
        );
      }
      
      if (!mounted) return;
      
      showSuccessSnackBar(context, 'Report generated: $pdfPath');
    } catch (e) {
      if (!mounted) return;
      
      showErrorSnackBar(context, 'Error generating report: $e');
    }
    
    setState(() {
      _isLoading = false;
    });
  }
  
  Future<void> _generateLowAttendanceReport() async {
    if (_selectedCourse == null) {
      showErrorSnackBar(context, 'Please select a course');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final pdfPath = await _exportService.exportLowAttendanceReport(
        _selectedCourse!.id,
        lowAttendanceThreshold,
      );
      
      if (!mounted) return;
      
      showSuccessSnackBar(context, 'Low attendance report generated: $pdfPath');
    } catch (e) {
      if (!mounted) return;
      
      showErrorSnackBar(context, 'Error generating report: $e');
    }
    
    setState(() {
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final students = _selectedCourse != null
        ? _attendanceService.getStudentsByCourse(_selectedCourse!.id)
        : <User>[];
    
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attendance Reports',
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
                          'Generate Report',
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
                              _selectedStudentId = null;
                            });
                          },
                        ),
                        const SizedBox(height: kDefaultPadding),
                        
                        // Report Type
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Course Report'),
                                value: 'course',
                                groupValue: _reportType,
                                onChanged: (value) {
                                  setState(() {
                                    _reportType = value!;
                                    _selectedStudentId = null;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Student Report'),
                                value: 'student',
                                groupValue: _reportType,
                                onChanged: (value) {
                                  setState(() {
                                    _reportType = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: kDefaultPadding),
                        
                        // Student Selection (if student report)
                        if (_reportType == 'student') ...[
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Select Student',
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedStudentId,
                            items: students.map((student) {
                              return DropdownMenuItem<String>(
                                value: student.id,
                                child: Text(student.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedStudentId = value;
                              });
                            },
                          ),
                          const SizedBox(height: kDefaultPadding),
                        ],
                        
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
                        const SizedBox(height: kLargePadding),
                        
                        // Generate Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _generateReport,
                            icon: const Icon(Icons.assessment),
                            label: const Text('Generate Report'),
                          ),
                        ),
                      ],
                    ),
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
                          'Low Attendance Report',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: kDefaultPadding),
                        const Text(
                          'Generate a report of students with attendance below 75%',
                        ),
                        const SizedBox(height: kDefaultPadding),
                        
                        // Generate Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _generateLowAttendanceReport,
                            icon: const Icon(Icons.warning),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                            label: const Text('Generate Low Attendance Report'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: kLargePadding),
                
                // Attendance Statistics
                if (_selectedCourse != null) ...[
                  Text(
                    'Attendance Statistics - ${_selectedCourse!.name}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: kDefaultPadding),
                  
                  _buildAttendanceStatistics(),
                ],
              ],
            ),
          );
  }
  
  Widget _buildAttendanceStatistics() {
    if (_selectedCourse == null) return const SizedBox.shrink();
    
    final students = _attendanceService.getStudentsByCourse(_selectedCourse!.id);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          children: [
            for (final student in students) ...[
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(student.name),
                  ),
                  Expanded(
                    flex: 7,
                    child: _buildAttendanceProgressBar(
                      _attendanceService.calculateAttendancePercentage(_selectedCourse!.id, student.id),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: kSmallPadding),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildAttendanceProgressBar(double percentage) {
    final color = percentage < lowAttendanceThreshold
        ? Colors.red
        : percentage < 85
            ? Colors.orange
            : Colors.green;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
        const SizedBox(height: 4),
        Text(
          '${percentage.toStringAsFixed(2)}%',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

