import 'dart:convert';
import '../models/user.dart';
import '../data/static_data.dart';
import 'file_service.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  final FileService _fileService = FileService();

  User? get currentUser => _currentUser;

  // Authenticate user
  Future<User?> login(String username, String password) async {
    try {
      final user = StaticData.users.firstWhere(
        (user) => user.username == username && user.password == password,
      );
      
      _currentUser = user;
      return user;
    } catch (e) {
      return null;
    }
  }

  // Logout
  void logout() {
    _currentUser = null;
  }

  // Generate credentials file
  Future<String> generateCredentialsFile() async {
    final buffer = StringBuffer();
    
    buffer.writeln('ATTENDANCE MANAGEMENT SYSTEM CREDENTIALS');
    buffer.writeln('=======================================');
    buffer.writeln();
    
    buffer.writeln('TEACHER ACCOUNTS:');
    buffer.writeln('----------------');
    for (final user in StaticData.users.where((u) => u.role == UserRole.teacher)) {
      buffer.writeln('Username: ${user.username}');
      buffer.writeln('Password: ${user.password}');
      buffer.writeln('Name: ${user.name}');
      buffer.writeln();
    }
    
    buffer.writeln('STUDENT ACCOUNTS:');
    buffer.writeln('----------------');
    for (final user in StaticData.users.where((u) => u.role == UserRole.student)) {
      buffer.writeln('Username: ${user.username}');
      buffer.writeln('Password: ${user.password}');
      buffer.writeln('Name: ${user.name}');
      buffer.writeln();
    }
    
    // Save the text file
    final documentsPath = await _fileService.getDocumentsPath();
    final path = '$documentsPath/credentials.txt';
    return await _fileService.writeTextFile(path, buffer.toString());
  }
}

