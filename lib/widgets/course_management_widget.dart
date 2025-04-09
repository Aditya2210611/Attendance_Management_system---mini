import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/course.dart';
import '../services/attendance_service.dart';
import '../data/static_data.dart';
import '../utils/constants.dart';

class CourseManagementWidget extends StatefulWidget {
  final User teacher;
  final VoidCallback onCoursesChanged;

  const CourseManagementWidget({
    super.key, 
    required this.teacher,
    required this.onCoursesChanged,
  });

  @override
  State<CourseManagementWidget> createState() => _CourseManagementWidgetState();
}

class _CourseManagementWidgetState extends State<CourseManagementWidget> {
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
    widget.onCoursesChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Course Management',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _showAddCourseDialog(context);
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Course'),
              ),
            ],
          ),
          const SizedBox(height: kLargePadding),
          
          Expanded(
            child: _courses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.class_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: kDefaultPadding),
                        Text(
                          'No courses found',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: kSmallPadding),
                        const Text(
                          'Create a new course to get started',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _courses.length,
                    itemBuilder: (context, index) {
                      final course = _courses[index];
                      final studentCount = course.studentIds.length;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: kDefaultPadding),
                        child: ExpansionTile(
                          title: Text(
                            course.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('$studentCount students'),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(kDefaultPadding),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          _showEditCourseDialog(context, course);
                                        },
                                        icon: const Icon(Icons.edit),
                                        label: const Text('Edit'),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          _showManageStudentsDialog(context, course);
                                        },
                                        icon: const Icon(Icons.people),
                                        label: const Text('Manage Students'),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          _showDeleteCourseDialog(context, course);
                                        },
                                        icon: const Icon(Icons.delete),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        label: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                  if (studentCount > 0) ...[
                                    const SizedBox(height: kDefaultPadding),
                                    const Text(
                                      'Enrolled Students:',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: kSmallPadding),
                                    ...course.studentIds.map((studentId) {
                                      final student = _attendanceService.getUserById(studentId);
                                      return ListTile(
                                        leading: CircleAvatar(
                                          child: Text(student.name[0]),
                                        ),
                                        title: Text(student.name),
                                        subtitle: Text('ID: ${student.id}'),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                                          onPressed: () {
                                            _showRemoveStudentDialog(context, course, student);
                                          },
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddCourseDialog(BuildContext context) {
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Course'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Course Name',
            hintText: 'Enter course name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                final newCourse = Course(
                  id: StaticData.generateId('c'),
                  name: name,
                  teacherId: widget.teacher.id,
                  studentIds: [],
                );
                _attendanceService.addCourse(newCourse);
                _refreshCourses();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditCourseDialog(BuildContext context, Course course) {
    final nameController = TextEditingController(text: course.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Course'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Course Name',
            hintText: 'Enter course name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                final updatedCourse = Course(
                  id: course.id,
                  name: name,
                  teacherId: course.teacherId,
                  studentIds: course.studentIds,
                );
                _attendanceService.updateCourse(updatedCourse);
                _refreshCourses();
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteCourseDialog(BuildContext context, Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Are you sure you want to delete "${course.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _attendanceService.deleteCourse(course.id);
              _refreshCourses();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showManageStudentsDialog(BuildContext context, Course course) {
    // Get all students
    final allStudents = StaticData.users.where((user) => user.role == UserRole.student).toList();
    // Get enrolled students
    final enrolledStudentIds = course.studentIds;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Manage Students - ${course.name}'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: allStudents.length,
            itemBuilder: (context, index) {
              final student = allStudents[index];
              final isEnrolled = enrolledStudentIds.contains(student.id);
              
              return CheckboxListTile(
                title: Text(student.name),
                subtitle: Text('ID: ${student.id}'),
                value: isEnrolled,
                onChanged: (value) {
                  if (value == true) {
                    _attendanceService.addStudentToCourse(course.id, student.id);
                  } else {
                    _attendanceService.removeStudentFromCourse(course.id, student.id);
                  }
                  _refreshCourses();
                  Navigator.pop(context);
                  _showManageStudentsDialog(context, _attendanceService.getCourseById(course.id));
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showRemoveStudentDialog(BuildContext context, Course course, User student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Student'),
        content: Text('Are you sure you want to remove ${student.name} from ${course.name}?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _attendanceService.removeStudentFromCourse(course.id, student.id);
              _refreshCourses();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

