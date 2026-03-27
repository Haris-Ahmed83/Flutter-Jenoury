import 'package:flutter/material.dart';
import 'package:flutter_jenoury/models/task_model.dart';
import 'package:flutter_jenoury/utils/constants.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final Function(TaskStatus)? onStatusChange;
  final VoidCallback? onDelete;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onTap,
    this.onStatusChange,
    this.onDelete,
  }) : super(key: key);

  Color _getPriorityColor() {
    switch (task.priority) {
      case 3:
        return Colors.red;
      case 2:
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  String _getPriorityLabel() {
    switch (task.priority) {
      case 3:
        return 'High';
      case 2:
        return 'Medium';
      default:
        return 'Low';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.dueDate != null && task.dueDate!.isBefore(DateTime.now());

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getPriorityColor().withOpacity(0.3),
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getPriorityColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getPriorityLabel(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getPriorityColor(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  task.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textGrey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (task.assignedTo != 'Unassigned')
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                'Assigned: ${task.assignedTo}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ),
                          if (task.dueDate != null)
                            Text(
                              'Due: ${DateFormat('MMM dd').format(task.dueDate!)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isOverdue ? Colors.red : AppColors.textGrey,
                                fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                        ],
                      ),
                    ),
                    PopupMenuButton<TaskStatus>(
                      onSelected: (status) {
                        onStatusChange?.call(status);
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: TaskStatus.todo,
                          child: Row(
                            children: [
                              Icon(Icons.circle_outlined,
                                  size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              const Text('To Do'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: TaskStatus.inProgress,
                          child: Row(
                            children: [
                              Icon(Icons.timelapse,
                                  size: 16, color: Colors.blue[600]),
                              const SizedBox(width: 8),
                              const Text('In Progress'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: TaskStatus.done,
                          child: Row(
                            children: [
                              Icon(Icons.check_circle,
                                  size: 16, color: Colors.green[600]),
                              const SizedBox(width: 8),
                              const Text('Done'),
                            ],
                          ),
                        ),
                      ],
                      child: Icon(
                        Icons.more_vert,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (task.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    children: task.tags
                        .map((tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
