import 'package:flutter/material.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import 'login_screen.dart';
import '../widgets/student_home_widget.dart';
import '../widgets/student_attendance_widget.dart';

class StudentDashboard extends StatefulWidget {
  final User student;

  const StudentDashboard({super.key, required this.student});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      StudentHomeWidget(student: widget.student),
      StudentAttendanceWidget(student: widget.student),
    ];
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.student.name}'),
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
            icon: Icon(Icons.assessment),
            label: 'Attendance',
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

