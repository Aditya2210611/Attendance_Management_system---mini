import 'package:flutter/material.dart';

// App Constants
const String appName = 'Attendance Management System';
const String appVersion = '1.0.0';

// Padding
const double kDefaultPadding = 16.0;
const double kSmallPadding = 8.0;
const double kLargePadding = 24.0;

// Border Radius
const double kDefaultBorderRadius = 8.0;
const double kCardBorderRadius = 12.0;

// Animation Durations
const Duration kFastAnimationDuration = Duration(milliseconds: 300);
const Duration kNormalAnimationDuration = Duration(milliseconds: 500);

// Attendance Threshold
const double lowAttendanceThreshold = 75.0;

// Snackbar Utilities
void showSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

void showInfoSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

