import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../providers/step_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/stat_card.dart';
import '../widgets/workout_card.dart';
import '../widgets/circular_progress.dart';
import 'step_counter_screen.dart';
import 'workout_log_screen.dart';
import 'add_workout_screen.dart';
import 'progress_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _screens = const [
    _HomeTab(),
    StepCounterScreen(),
    SizedBox(), // Placeholder for FAB
    ProgressScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex == 2 ? 0 : _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddWorkoutScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: AppColors.surface,
        elevation: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isSelected: _currentIndex == 0,
                onTap: () => setState(() => _currentIndex = 0),
              ),
              _NavItem(
                icon: Icons.directions_walk_rounded,
                label: 'Steps',
                isSelected: _currentIndex == 1,
                onTap: () => setState(() => _currentIndex = 1),
              ),
              const SizedBox(width: 48), // Space for FAB
              _NavItem(
                icon: Icons.bar_chart_rounded,
                label: 'Progress',
                isSelected: _currentIndex == 3,
                onTap: () => setState(() => _currentIndex = 3),
              ),
              _NavItem(
                icon: Icons.history_rounded,
                label: 'History',
                isSelected: _currentIndex == 4,
                onTap: () => setState(() => _currentIndex = 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textLight,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await context.read<WorkoutProvider>().loadWorkouts();
          await context.read<StepProvider>().initialize();
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: _buildStepProgress(context)),
            SliverToBoxAdapter(child: _buildQuickStats(context)),
            SliverToBoxAdapter(child: _buildRecentWorkouts(context)),
            const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final now = DateTime.now();
    String greeting;
    if (now.hour < 12) {
      greeting = 'Good Morning';
    } else if (now.hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: AppTextStyles.bodySecondary),
              const SizedBox(height: 4),
              Text(Formatters.dateFull(now), style: AppTextStyles.heading2),
            ],
          ),
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
            icon: const Icon(Icons.settings_outlined,
                color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildStepProgress(BuildContext context) {
    final stepProvider = context.watch<StepProvider>();

    return GestureDetector(
      onTap: () {
        // Navigate to steps tab handled by parent
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.gradientPrimary,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            CircularProgress(
              progress: stepProvider.progressPercent,
              size: 100,
              strokeWidth: 8,
              progressColor: Colors.white,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    Formatters.steps(stepProvider.currentSteps),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'of ${Formatters.steps(stepProvider.stepGoal)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Steps",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _StepDetailRow(
                    icon: Icons.local_fire_department,
                    label: '${Formatters.calories(stepProvider.todayCalories)} cal burned',
                  ),
                  const SizedBox(height: 6),
                  _StepDetailRow(
                    icon: Icons.straighten,
                    label: Formatters.distance(stepProvider.todayDistance),
                  ),
                  const SizedBox(height: 6),
                  _StepDetailRow(
                    icon: Icons.flag,
                    label: stepProvider.progressPercent >= 1.0
                        ? 'Goal reached!'
                        : '${Formatters.percentage(stepProvider.progressPercent)} complete',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('This Month', style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Workouts',
                  value: workoutProvider.totalWorkouts.toString(),
                  icon: Icons.fitness_center_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'Minutes',
                  value: Formatters.duration(workoutProvider.totalMinutes),
                  icon: Icons.timer_rounded,
                  color: AppColors.durationColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Calories',
                  value: Formatters.calories(workoutProvider.totalCalories),
                  icon: Icons.local_fire_department_rounded,
                  color: AppColors.caloriesColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'Distance',
                  value: Formatters.distance(workoutProvider.totalDistance),
                  icon: Icons.map_rounded,
                  color: AppColors.distanceColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentWorkouts(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();
    final recentWorkouts = workoutProvider.workouts.take(5).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Workouts', style: AppTextStyles.heading3),
              if (recentWorkouts.isNotEmpty)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const WorkoutLogScreen()),
                    );
                  },
                  child: const Text('View All'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (workoutProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (recentWorkouts.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadius),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.fitness_center_outlined,
                        size: 48, color: AppColors.textLight),
                    SizedBox(height: 12),
                    Text('No workouts yet',
                        style: AppTextStyles.bodySecondary),
                    SizedBox(height: 4),
                    Text('Tap + to log your first workout',
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
            )
          else
            ...recentWorkouts.map(
              (workout) => WorkoutCard(
                workout: workout,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkoutLogScreen(
                          highlightWorkoutId: workout.id),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _StepDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StepDetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 16),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}
