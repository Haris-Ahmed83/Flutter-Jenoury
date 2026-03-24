import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../providers/step_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/line_chart.dart';
import '../widgets/bar_chart.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                const Text('Progress', style: AppTextStyles.heading1),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Steps'),
                Tab(text: 'Workouts'),
                Tab(text: 'Calories'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _StepsProgressTab(),
                _WorkoutsProgressTab(),
                _CaloriesProgressTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepsProgressTab extends StatelessWidget {
  const _StepsProgressTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StepProvider>();
    final monthRecords = provider.monthRecords;

    // Weekly averages for line chart
    final weeklyData = <LineChartPoint>[];
    for (int week = 3; week >= 0; week--) {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1 + week * 7));
      final weekEnd = weekStart.add(const Duration(days: 6));
      final weekRecords = monthRecords.where((r) {
        return !r.date.isBefore(weekStart) && !r.date.isAfter(weekEnd);
      });
      final avg = weekRecords.isNotEmpty
          ? weekRecords.fold<int>(0, (s, r) => s + r.steps) /
              weekRecords.length
          : 0.0;
      weeklyData.add(LineChartPoint(
        label: 'W${4 - week}',
        value: avg,
      ));
    }

    // Daily data for bar chart (last 7 days)
    final dailyData = <BarChartData>[];
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateOnly = DateTime(date.year, date.month, date.day);
      final record = provider.weekRecords.where((r) {
        final rDate = DateTime(r.date.year, r.date.month, r.date.day);
        return rDate == dateOnly;
      }).firstOrNull;

      dailyData.add(BarChartData(
        label: Formatters.dayOfWeek(date),
        value: (record?.steps ?? 0).toDouble(),
      ));
    }

    final totalSteps = (provider.stats['totalSteps'] as num?)?.toInt() ?? 0;
    final avgSteps = (provider.stats['avgSteps'] as num?)?.toInt() ?? 0;
    final maxSteps = (provider.stats['maxSteps'] as num?)?.toInt() ?? 0;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Summary Cards
        Row(
          children: [
            _SummaryCard(
                label: '30-Day Total',
                value: Formatters.steps(totalSteps),
                color: AppColors.stepsColor),
            const SizedBox(width: 12),
            _SummaryCard(
                label: 'Daily Avg',
                value: Formatters.steps(avgSteps),
                color: AppColors.primary),
            const SizedBox(width: 12),
            _SummaryCard(
                label: 'Best Day',
                value: Formatters.steps(maxSteps),
                color: AppColors.success),
          ],
        ),
        const SizedBox(height: 20),

        // Daily Bar Chart
        _ChartCard(
          title: 'Daily Steps (This Week)',
          child: SimpleBarChart(
            data: dailyData,
            height: 200,
            defaultColor: AppColors.stepsColor,
          ),
        ),
        const SizedBox(height: 16),

        // Weekly Trend
        _ChartCard(
          title: 'Weekly Average Trend',
          child: SimpleLineChart(
            data: weeklyData,
            height: 180,
            lineColor: AppColors.stepsColor,
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}

class _WorkoutsProgressTab extends StatelessWidget {
  const _WorkoutsProgressTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    final workouts = provider.workouts;

    // Workouts per day (last 7 days)
    final now = DateTime.now();
    final dailyWorkouts = <BarChartData>[];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateOnly = DateTime(date.year, date.month, date.day);
      final count = workouts.where((w) {
        final wDate =
            DateTime(w.startTime.year, w.startTime.month, w.startTime.day);
        return wDate == dateOnly;
      }).length;

      dailyWorkouts.add(BarChartData(
        label: Formatters.dayOfWeek(date),
        value: count.toDouble(),
      ));
    }

    // Duration trend (last 4 weeks)
    final weeklyDuration = <LineChartPoint>[];
    for (int week = 3; week >= 0; week--) {
      final weekStart =
          now.subtract(Duration(days: now.weekday - 1 + week * 7));
      final weekEnd = weekStart.add(const Duration(days: 6));
      final weekWorkouts = workouts.where((w) {
        return !w.startTime.isBefore(weekStart) &&
            !w.startTime.isAfter(weekEnd);
      });
      final totalMin =
          weekWorkouts.fold<int>(0, (s, w) => s + w.durationMinutes);
      weeklyDuration.add(LineChartPoint(
        label: 'W${4 - week}',
        value: totalMin.toDouble(),
      ));
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            _SummaryCard(
              label: 'Total',
              value: provider.totalWorkouts.toString(),
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            _SummaryCard(
              label: 'Total Time',
              value: Formatters.duration(provider.totalMinutes),
              color: AppColors.durationColor,
            ),
            const SizedBox(width: 12),
            _SummaryCard(
              label: 'Distance',
              value: Formatters.distance(provider.totalDistance),
              color: AppColors.distanceColor,
            ),
          ],
        ),
        const SizedBox(height: 20),

        _ChartCard(
          title: 'Workouts This Week',
          child: SimpleBarChart(
            data: dailyWorkouts,
            height: 180,
            defaultColor: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),

        _ChartCard(
          title: 'Weekly Duration Trend (min)',
          child: SimpleLineChart(
            data: weeklyDuration,
            height: 180,
            lineColor: AppColors.durationColor,
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}

class _CaloriesProgressTab extends StatelessWidget {
  const _CaloriesProgressTab();

  @override
  Widget build(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();
    final stepProvider = context.watch<StepProvider>();
    final workouts = workoutProvider.workouts;
    final now = DateTime.now();

    // Daily calories from workouts
    final dailyCalories = <BarChartData>[];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateOnly = DateTime(date.year, date.month, date.day);

      final workoutCal = workouts.where((w) {
        final wDate =
            DateTime(w.startTime.year, w.startTime.month, w.startTime.day);
        return wDate == dateOnly;
      }).fold<double>(0, (s, w) => s + w.caloriesBurned);

      final stepRecord = stepProvider.weekRecords.where((r) {
        final rDate = DateTime(r.date.year, r.date.month, r.date.day);
        return rDate == dateOnly;
      }).firstOrNull;

      final totalCal = workoutCal + (stepRecord?.caloriesBurned ?? 0);

      dailyCalories.add(BarChartData(
        label: Formatters.dayOfWeek(date),
        value: totalCal,
        color: totalCal > 500 ? AppColors.success : AppColors.caloriesColor,
      ));
    }

    // Weekly calorie trend
    final weeklyCalories = <LineChartPoint>[];
    for (int week = 3; week >= 0; week--) {
      final weekStart =
          now.subtract(Duration(days: now.weekday - 1 + week * 7));
      final weekEnd = weekStart.add(const Duration(days: 6));

      final cal = workouts.where((w) {
        return !w.startTime.isBefore(weekStart) &&
            !w.startTime.isAfter(weekEnd);
      }).fold<double>(0, (s, w) => s + w.caloriesBurned);

      weeklyCalories
          .add(LineChartPoint(label: 'W${4 - week}', value: cal));
    }

    final totalCalories = workoutProvider.totalCalories +
        ((stepProvider.stats['totalCalories'] as num?)?.toDouble() ?? 0);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            _SummaryCard(
              label: '30-Day Burn',
              value: '${Formatters.calories(totalCalories)} cal',
              color: AppColors.caloriesColor,
            ),
            const SizedBox(width: 12),
            _SummaryCard(
              label: 'Workout Cal',
              value: Formatters.calories(workoutProvider.totalCalories),
              color: AppColors.durationColor,
            ),
            const SizedBox(width: 12),
            _SummaryCard(
              label: 'Step Cal',
              value: Formatters.calories(
                  (stepProvider.stats['totalCalories'] as num?)?.toDouble() ??
                      0),
              color: AppColors.stepsColor,
            ),
          ],
        ),
        const SizedBox(height: 20),

        _ChartCard(
          title: 'Daily Calories Burned',
          child: SimpleBarChart(
            data: dailyCalories,
            height: 200,
            defaultColor: AppColors.caloriesColor,
          ),
        ),
        const SizedBox(height: 16),

        _ChartCard(
          title: 'Weekly Calorie Trend',
          child: SimpleLineChart(
            data: weeklyCalories,
            height: 180,
            lineColor: AppColors.caloriesColor,
            fillColor: AppColors.caloriesColor.withValues(alpha: 0.15),
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(title, style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
