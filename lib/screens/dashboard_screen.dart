import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_jenoury/models/task_model.dart';
import 'package:flutter_jenoury/providers/task_provider.dart';
import 'package:flutter_jenoury/screens/add_task_screen.dart';
import 'package:flutter_jenoury/screens/task_detail_screen.dart';
import 'package:flutter_jenoury/utils/constants.dart';
import 'package:flutter_jenoury/widgets/task_column.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.appTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              AppStrings.appSubtitle,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          Consumer<TaskProvider>(
            builder: (context, taskProvider, child) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${taskProvider.completedTasks}/${taskProvider.totalTasks}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        'Completed',
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.primary.withOpacity(0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: taskProvider.completionPercentage / 100,
                        minHeight: 8,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.success.withOpacity(0.8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Overall Progress: ${taskProvider.completionPercentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      TaskColumn(
                        title: AppStrings.todoStatus,
                        count: taskProvider.todoTasks.length,
                        tasks: taskProvider.todoTasks,
                        status: TaskStatus.todo,
                        onTaskStatusChanged: (task, newStatus) {
                          taskProvider.updateTaskStatus(task.id, newStatus);
                        },
                        onAddTask: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddTaskScreen(),
                            ),
                          );
                        },
                        onTaskTapped: (task) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TaskDetailScreen(task: task),
                            ),
                          );
                        },
                        onTaskDeleted: (taskId) {
                          taskProvider.deleteTask(taskId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Task deleted'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      TaskColumn(
                        title: AppStrings.inProgressStatus,
                        count: taskProvider.inProgressTasks.length,
                        tasks: taskProvider.inProgressTasks,
                        status: TaskStatus.inProgress,
                        onTaskStatusChanged: (task, newStatus) {
                          taskProvider.updateTaskStatus(task.id, newStatus);
                        },
                        onAddTask: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddTaskScreen(),
                            ),
                          );
                        },
                        onTaskTapped: (task) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TaskDetailScreen(task: task),
                            ),
                          );
                        },
                        onTaskDeleted: (taskId) {
                          taskProvider.deleteTask(taskId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Task deleted'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      TaskColumn(
                        title: AppStrings.doneStatus,
                        count: taskProvider.doneTasks.length,
                        tasks: taskProvider.doneTasks,
                        status: TaskStatus.done,
                        onTaskStatusChanged: (task, newStatus) {
                          taskProvider.updateTaskStatus(task.id, newStatus);
                        },
                        onAddTask: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddTaskScreen(),
                            ),
                          );
                        },
                        onTaskTapped: (task) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TaskDetailScreen(task: task),
                            ),
                          );
                        },
                        onTaskDeleted: (taskId) {
                          taskProvider.deleteTask(taskId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Task deleted'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTaskScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
