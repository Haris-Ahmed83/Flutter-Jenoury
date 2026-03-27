import 'package:flutter_jenoury/models/task_model.dart';

/// Local task service for managing tasks in-memory
/// In production, this would connect to Firebase Realtime Database
class TaskService {
  static final TaskService _instance = TaskService._internal();

  factory TaskService() {
    return _instance;
  }

  TaskService._internal();

  final List<Task> _tasks = [
    Task(
      id: 'task-1',
      title: 'Design Dashboard UI',
      description: 'Create mockups and wireframes for the dashboard',
      status: TaskStatus.done,
      assignedTo: 'John Doe',
      priority: 3,
      tags: ['Design', 'Frontend'],
    ),
    Task(
      id: 'task-2',
      title: 'Setup Firebase Database',
      description: 'Configure Firebase Realtime Database and authentication',
      status: TaskStatus.inProgress,
      assignedTo: 'Jane Smith',
      priority: 3,
      tags: ['Backend', 'Firebase'],
    ),
    Task(
      id: 'task-3',
      title: 'Implement Drag & Drop',
      description: 'Add drag and drop functionality for task cards',
      status: TaskStatus.todo,
      assignedTo: 'Bob Wilson',
      priority: 2,
      tags: ['Frontend', 'Feature'],
    ),
  ];

  List<Task> get tasks => List.unmodifiable(_tasks);

  List<Task> getTasksByStatus(TaskStatus status) {
    return _tasks.where((task) => task.status == status).toList();
  }

  void addTask(Task task) {
    _tasks.add(task);
  }

  void updateTask(Task task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    }
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((task) => task.id == taskId);
  }

  void moveTask(String taskId, TaskStatus newStatus) {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      _tasks[taskIndex] = task.copyWith(status: newStatus);
    }
  }

  Task? getTaskById(String id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  int getTaskCount() => _tasks.length;

  int getCompletedTaskCount() =>
      _tasks.where((task) => task.status == TaskStatus.done).length;
}
