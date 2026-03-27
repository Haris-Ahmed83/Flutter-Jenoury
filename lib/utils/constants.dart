import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color accent = Color(0xFFFF9800);
  static const Color textDark = Color(0xFF212121);
  static const Color textGrey = Color(0xFF757575);
  static const Color background = Color(0xFFFAFAFA);
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFFC107);
}

class AppDimensions {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double borderRadius = 12.0;
  static const double elevation = 4.0;
}

class AppStrings {
  static const String appTitle = 'Task Manager';
  static const String appSubtitle = 'Professional Kanban Board';

  // Status labels
  static const String todoStatus = 'To Do';
  static const String inProgressStatus = 'In Progress';
  static const String doneStatus = 'Done';

  // Action labels
  static const String addTask = 'Add Task';
  static const String editTask = 'Edit Task';
  static const String deleteTask = 'Delete Task';
  static const String saveTask = 'Save Task';
  static const String cancelAction = 'Cancel';

  // Validation messages
  static const String titleRequired = 'Task title is required';
  static const String descriptionRequired = 'Task description is required';
}
