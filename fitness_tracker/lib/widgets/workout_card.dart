import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class WorkoutCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const WorkoutCard({
    super.key,
    required this.workout,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      workout.type.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.title,
                        style: AppTextStyles.heading3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${workout.type.label} • ${Formatters.relativeDate(workout.startTime)} at ${Formatters.timeOfDay(workout.startTime)}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.textLight, size: 20),
                    onPressed: onDelete,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatChip(
                  icon: Icons.timer_outlined,
                  label: Formatters.duration(workout.durationMinutes),
                  color: AppColors.durationColor,
                ),
                const SizedBox(width: 12),
                _StatChip(
                  icon: Icons.local_fire_department_outlined,
                  label: '${Formatters.calories(workout.caloriesBurned)} cal',
                  color: AppColors.caloriesColor,
                ),
                if (workout.distanceKm != null && workout.distanceKm! > 0) ...[
                  const SizedBox(width: 12),
                  _StatChip(
                    icon: Icons.straighten_outlined,
                    label: Formatters.distance(workout.distanceKm!),
                    color: AppColors.distanceColor,
                  ),
                ],
                if (workout.sets.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  _StatChip(
                    icon: Icons.fitness_center_outlined,
                    label: '${workout.sets.length} sets',
                    color: AppColors.primary,
                  ),
                ],
              ],
            ),
            if (workout.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                workout.notes,
                style: AppTextStyles.bodySecondary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
