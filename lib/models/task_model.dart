import 'package:uuid/uuid.dart';

enum TaskStatus { todo, inProgress, done }

class Task {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime? dueDate;
  final String assignedTo;
  final int priority; // 1: Low, 2: Medium, 3: High
  final List<String> tags;

  Task({
    String? id,
    required this.title,
    required this.description,
    this.status = TaskStatus.todo,
    DateTime? createdAt,
    this.dueDate,
    this.assignedTo = 'Unassigned',
    this.priority = 2,
    this.tags = const [],
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? dueDate,
    String? assignedTo,
    int? priority,
    List<String>? tags,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      assignedTo: assignedTo ?? this.assignedTo,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'assignedTo': assignedTo,
      'priority': priority,
      'tags': tags,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: _parseStatus(map['status']),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      dueDate: map['dueDate'] != null ? DateTime.tryParse(map['dueDate']) : null,
      assignedTo: map['assignedTo'] ?? 'Unassigned',
      priority: map['priority'] ?? 2,
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  static TaskStatus _parseStatus(String? status) {
    switch (status) {
      case 'inProgress':
        return TaskStatus.inProgress;
      case 'done':
        return TaskStatus.done;
      default:
        return TaskStatus.todo;
    }
  }
}
