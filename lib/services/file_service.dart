import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;

class FileService {
  // Singleton pattern
  static final FileService _instance = FileService._internal();
  factory FileService() => _instance;
  FileService._internal();

  // Check if running on web
  bool get isWeb => kIsWeb;

  // Get a temporary directory path that works on both web and mobile
  Future<String> getTempPath() async {
    if (isWeb) {
      return 'temp';
    } else {
      final directory = await getTemporaryDirectory();
      return directory.path;
    }
  }

  // Get an application documents directory path that works on both web and mobile
  Future<String> getDocumentsPath() async {
    if (isWeb) {
      return 'documents';
    } else {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  // Write a file that works on both web and mobile
  Future<String> writeFile(String path, List<int> bytes, {String? mimeType}) async {
    if (isWeb) {
      // On web, we'll use browser's download capability
      final blob = html.Blob([bytes], mimeType ?? 'application/octet-stream');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', path.split('/').last)
        ..click();
      html.Url.revokeObjectUrl(url);
      return path;
    } else {
      // On mobile, write to the file system
      final file = io.File(path);
      await file.writeAsBytes(bytes);
      return file.path;
    }
  }

  // Write a text file that works on both web and mobile
  Future<String> writeTextFile(String path, String text) async {
    return writeFile(path, utf8.encode(text), mimeType: 'text/plain');
  }

  // Read a file that works on both web and mobile
  Future<Uint8List> readFile(String path) async {
    if (isWeb) {
      throw UnsupportedError('Reading files is not supported on web');
    } else {
      final file = io.File(path);
      return await file.readAsBytes();
    }
  }

  // Read a text file that works on both web and mobile
  Future<String> readTextFile(String path) async {
    if (isWeb) {
      throw UnsupportedError('Reading files is not supported on web');
    } else {
      final file = io.File(path);
      return await file.readAsString();
    }
  }

  // Check if a file exists
  Future<bool> fileExists(String path) async {
    if (isWeb) {
      return false;
    } else {
      final file = io.File(path);
      return await file.exists();
    }
  }
}

