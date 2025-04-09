import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/course.dart';
import '../services/attendance_service.dart';
import 'login_screen.dart';
import '../widgets/teacher_home_widget.dart';
import '../widgets/course_management_widget.dart';
import '../widgets/reports_widget.dart';

class TeacherDashboard extends StatefulWidget {
  final User teacher;

  const TeacherDashboard({super.key, required this.teacher});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _selectedIndex = 0;
  late List<Course> _courses;
  final _attendanceService = AttendanceService();

  @override
  void initState() {
    super.initState();
    _courses = _attendanceService.getCoursesByTeacher(widget.teacher.id);
  }

  void _refreshCourses() {
    setState(() {
      _courses = _attendanceService.getCoursesByTeacher(widget.teacher.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      TeacherHomeWidget(teacher: widget.teacher, onCoursesChanged: _refreshCourses),
      CourseManagementWidget(teacher: widget.teacher, onCoursesChanged: _refreshCourses),
      ReportsWidget(teacher: widget.teacher),
    ];
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.teacher.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.class_),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Reports',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

