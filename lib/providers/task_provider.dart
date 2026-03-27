import 'package:flutter/material.dart';
import 'package:flutter_jenoury/models/task_model.dart';
import 'package:flutter_jenoury/services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<Task> get allTasks => _taskService.tasks;

  List<Task> get todoTasks => _taskService.getTasksByStatus(TaskStatus.todo);
  List<Task> get inProgressTasks =>
      _taskService.getTasksByStatus(TaskStatus.inProgress);
  List<Task> get doneTasks => _taskService.getTasksByStatus(TaskStatus.done);

  int get totalTasks => _taskService.getTaskCount();
  int get completedTasks => _taskService.getCompletedTaskCount();
  double get completionPercentage =>
      totalTasks == 0 ? 0 : (completedTasks / totalTasks) * 100;

  void addTask(Task task) {
    _taskService.addTask(task);
    notifyListeners();
  }

  void updateTask(Task task) {
    _taskService.updateTask(task);
    notifyListeners();
  }

  void deleteTask(String taskId) {
    _taskService.deleteTask(taskId);
    notifyListeners();
  }

  void moveTaskToStatus(String taskId, TaskStatus newStatus) {
    _taskService.moveTask(taskId, newStatus);
    notifyListeners();
  }

  Task? getTaskById(String id) {
    return _taskService.getTaskById(id);
  }

  void updateTaskStatus(String taskId, TaskStatus newStatus) {
    final task = _taskService.getTaskById(taskId);
    if (task != null) {
      final updatedTask = task.copyWith(status: newStatus);
      updateTask(updatedTask);
    }
  }
}
