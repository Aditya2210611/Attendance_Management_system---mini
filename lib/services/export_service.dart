import 'dart:convert';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/attendance.dart';
import '../models/course.dart';
import '../models/user.dart';
import 'attendance_service.dart';
import 'file_service.dart';

class ExportService {
  // Singleton pattern
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  final AttendanceService _attendanceService = AttendanceService();
  final FileService _fileService = FileService();

  // Export attendance to Excel
  Future<String> exportAttendanceToExcel(String courseId, DateTime date) async {
    final excel = Excel.createExcel();
    final sheet = excel['Attendance'];
    
    // Add headers
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = 'Sr. No.';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value = 'Student Name';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value = 'Class Details';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value = 'Attendance Status';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0)).value = 'Date';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0)).value = 'Time';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0)).value = 'Course Name';
    
    final course = _attendanceService.getCourseById(courseId);
    final students = _attendanceService.getStudentsByCourse(courseId);
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    
    // Get records for the specific date and course
    final allRecords = _attendanceService.getAttendanceRecordsByCourse(courseId);
    final records = allRecords.where(
      (record) => DateFormat('yyyy-MM-dd').format(record.date) == dateStr
    ).toList();
    
    // Add data rows
    for (int i = 0; i < students.length; i++) {
      final student = students[i];
      final record = records.firstWhere(
        (r) => r.studentId == student.id,
        orElse: () => AttendanceRecord(
          id: 'temp',
          courseId: courseId,
          studentId: student.id,
          date: date,
          status: AttendanceStatus.absent,
        ),
      );
      
      final statusText = record.status == AttendanceStatus.present 
          ? 'Present' 
          : record.status == AttendanceStatus.late 
              ? 'Late' 
              : 'Absent';
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1)).value = (i + 1).toString();
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1)).value = student.name;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1)).value = 'Regular';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1)).value = statusText;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1)).value = dateStr;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1)).value = DateFormat('HH:mm').format(record.date);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 1)).value = course.name;
    }
    
    // Save the Excel file
    final tempPath = await _fileService.getTempPath();
    final path = '$tempPath/attendance_${course.name}_$dateStr.xlsx';
    return await _fileService.writeFile(path, excel.encode()!, mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
  }

  // Export attendance report to PDF
  Future<String> exportAttendanceToPdf(
    String courseId, 
    DateTime startDate, 
    DateTime endDate,
    {String? studentId}
  ) async {
    final pdf = pw.Document();
    final course = _attendanceService.getCourseById(courseId);
    
    // Filter records
    List<AttendanceRecord> records;
    if (studentId != null) {
      records = _attendanceService.getAttendanceRecordsByCourseAndStudent(courseId, studentId)
        .where((record) => 
          record.date.isAfter(startDate.subtract(const Duration(days: 1))) && 
          record.date.isBefore(endDate.add(const Duration(days: 1)))
        ).toList();
    } else {
      records = _attendanceService.getAttendanceRecordsByCourse(courseId)
        .where((record) => 
          record.date.isAfter(startDate.subtract(const Duration(days: 1))) && 
          record.date.isBefore(endDate.add(const Duration(days: 1)))
        ).toList();
    }
    
    // Create PDF content
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Attendance Report'),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Course: ${course.name}'),
              pw.Text('Period: ${DateFormat('yyyy-MM-dd').format(startDate)} to ${DateFormat('yyyy-MM-dd').format(endDate)}'),
              if (studentId != null) pw.Text('Student: ${_attendanceService.getUserById(studentId).name}'),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  // Header row
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Student', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Data rows
                  ...records.map((record) {
                    final student = _attendanceService.getUserById(record.studentId);
                    final statusText = record.status == AttendanceStatus.present 
                        ? 'Present' 
                        : record.status == AttendanceStatus.late 
                            ? 'Late' 
                            : 'Absent';
                    
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(DateFormat('yyyy-MM-dd').format(record.date)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(student.name),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(statusText),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Summary:'),
              pw.SizedBox(height: 10),
              if (studentId != null) ...[
                pw.Text('Attendance Percentage: ${_attendanceService.calculateAttendancePercentage(courseId, studentId).toStringAsFixed(2)}%'),
              ] else ...[
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    // Header row
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('Student', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('Attendance %', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    // Data rows for each student
                    ..._attendanceService.getStudentsByCourse(courseId).map((student) {
                      final percentage = _attendanceService.calculateAttendancePercentage(courseId, student.id);
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(student.name),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text('${percentage.toStringAsFixed(2)}%'),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
    
    // Save the PDF file
    final tempPath = await _fileService.getTempPath();
    final reportType = studentId != null ? 'student_${_attendanceService.getUserById(studentId).name}' : 'course';
    final path = '$tempPath/attendance_report_${course.name}_$reportType.pdf';
    return await _fileService.writeFile(path, await pdf.save(), mimeType: 'application/pdf');
  }

  // Export low attendance report
  Future<String> exportLowAttendanceReport(String courseId, double threshold) async {
    final pdf = pw.Document();
    final course = _attendanceService.getCourseById(courseId);
    final lowAttendanceStudents = _attendanceService.getStudentsBelowThreshold(courseId, threshold);
    
    // Create PDF content
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Low Attendance Report'),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Course: ${course.name}'),
              pw.Text('Threshold: ${threshold.toStringAsFixed(2)}%'),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  // Header row
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Student', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Attendance %', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Data rows
                  ...lowAttendanceStudents.map((data) {
                    final student = data['student'] as User;
                    final percentage = data['percentage'] as double;
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(student.name),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('${percentage.toStringAsFixed(2)}%'),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ],
          );
        },
      ),
    );
    
    // Save the PDF file
    final tempPath = await _fileService.getTempPath();
    final path = '$tempPath/low_attendance_report_${course.name}.pdf';
    return await _fileService.writeFile(path, await pdf.save(), mimeType: 'application/pdf');
  }
}

