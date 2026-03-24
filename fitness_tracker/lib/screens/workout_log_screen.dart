import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout.dart';
import '../providers/workout_provider.dart';
import '../utils/constants.dart';
import '../widgets/workout_card.dart';
import 'add_workout_screen.dart';

class WorkoutLogScreen extends StatelessWidget {
  final int? highlightWorkoutId;

  const WorkoutLogScreen({super.key, this.highlightWorkoutId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Workout Log'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          PopupMenuButton<WorkoutType?>(
            icon: const Icon(Icons.filter_list_rounded),
            onSelected: (type) {
              context.read<WorkoutProvider>().setFilter(type);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: null,
                child: Text('All Types'),
              ),
              ...WorkoutType.values.map(
                (type) => PopupMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Text(type.icon),
                      const SizedBox(width: 8),
                      Text(type.label),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<WorkoutProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final workouts = provider.workouts;

          if (workouts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.fitness_center_outlined,
                      size: 64, color: AppColors.textLight),
                  const SizedBox(height: 16),
                  Text(
                    provider.filterType != null
                        ? 'No ${provider.filterType!.label} workouts'
                        : 'No workouts logged yet',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 8),
                  const Text('Start by logging your first workout!',
                      style: AppTextStyles.bodySecondary),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final workout = workouts[index];
              return WorkoutCard(
                workout: workout,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AddWorkoutScreen(editWorkout: workout),
                    ),
                  );
                },
                onDelete: () => _confirmDelete(context, provider, workout),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddWorkoutScreen()));
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WorkoutProvider provider, Workout workout) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Workout'),
        content: Text('Delete "${workout.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteWorkout(workout.id!);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
