import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/step_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/circular_progress.dart';
import '../widgets/bar_chart.dart';

class StepCounterScreen extends StatelessWidget {
  const StepCounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<StepProvider>(
        builder: (context, stepProvider, _) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: _buildStepCounter(context, stepProvider)),
              SliverToBoxAdapter(child: _buildTodayStats(stepProvider)),
              SliverToBoxAdapter(child: _buildWeeklyChart(stepProvider)),
              SliverToBoxAdapter(child: _buildManualEntry(context, stepProvider)),
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text('Step Counter', style: AppTextStyles.heading1),
    );
  }

  Widget _buildStepCounter(BuildContext context, StepProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.stepsColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          CircularProgress(
            progress: provider.progressPercent,
            size: 220,
            strokeWidth: 14,
            progressColor: provider.progressPercent >= 1.0
                ? AppColors.success
                : AppColors.stepsColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  provider.progressPercent >= 1.0
                      ? Icons.emoji_events_rounded
                      : Icons.directions_walk_rounded,
                  color: provider.progressPercent >= 1.0
                      ? AppColors.success
                      : AppColors.stepsColor,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  provider.currentSteps.toString(),
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'of ${Formatters.steps(provider.stepGoal)} steps',
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                if (provider.isTracking) {
                  provider.stopTracking();
                } else {
                  provider.startTracking();
                }
              },
              icon: Icon(
                provider.isTracking ? Icons.pause_rounded : Icons.play_arrow_rounded,
              ),
              label: Text(
                provider.isTracking ? 'Stop Tracking' : 'Start Tracking',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    provider.isTracking ? AppColors.error : AppColors.stepsColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
          if (provider.isTracking)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Tracking active — move your device to count steps',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTodayStats(StepProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _MiniStatCard(
              icon: Icons.local_fire_department_rounded,
              label: 'Calories',
              value: '${Formatters.calories(provider.todayCalories)} cal',
              color: AppColors.caloriesColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MiniStatCard(
              icon: Icons.straighten_rounded,
              label: 'Distance',
              value: Formatters.distance(provider.todayDistance),
              color: AppColors.distanceColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MiniStatCard(
              icon: Icons.flag_rounded,
              label: 'Progress',
              value: Formatters.percentage(provider.progressPercent),
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(StepProvider provider) {
    final records = provider.weekRecords;
    final now = DateTime.now();

    // Build 7-day data with gaps filled
    final chartData = <BarChartData>[];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateOnly = DateTime(date.year, date.month, date.day);
      final record = records.where((r) {
        final rDate = DateTime(r.date.year, r.date.month, r.date.day);
        return rDate == dateOnly;
      }).firstOrNull;

      chartData.add(BarChartData(
        label: Formatters.dayOfWeek(date),
        value: (record?.steps ?? 0).toDouble(),
        color: record != null && record.goalReached
            ? AppColors.success
            : AppColors.stepsColor,
      ));
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('This Week', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          SimpleBarChart(
            data: chartData,
            height: 180,
            defaultColor: AppColors.stepsColor,
          ),
        ],
      ),
    );
  }

  Widget _buildManualEntry(BuildContext context, StepProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit_rounded, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Steps Manually',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                Text('Did you forget to track?',
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showManualEntryDialog(context, provider),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              foregroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showManualEntryDialog(BuildContext context, StepProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Steps'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter number of steps',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.directions_walk),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final steps = int.tryParse(controller.text);
              if (steps != null && steps > 0) {
                provider.addManualSteps(steps);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added $steps steps'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MiniStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
