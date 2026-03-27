import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout.dart';
import '../providers/workout_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/workout_card.dart';
import 'add_workout_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
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
                const Expanded(
                    child: Text('History', style: AppTextStyles.heading1)),
              ],
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search workouts...',
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.textLight),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          // Results
          Expanded(
            child: Consumer<WorkoutProvider>(
              builder: (context, provider, _) {
                var workouts = provider.workouts;

                if (_searchQuery.isNotEmpty) {
                  workouts = workouts.where((w) {
                    return w.title.toLowerCase().contains(_searchQuery) ||
                        w.type.label.toLowerCase().contains(_searchQuery) ||
                        w.notes.toLowerCase().contains(_searchQuery);
                  }).toList();
                }

                if (workouts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off_rounded,
                            size: 48, color: AppColors.textLight),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No results for "$_searchQuery"'
                              : 'No workout history',
                          style: AppTextStyles.bodySecondary,
                        ),
                      ],
                    ),
                  );
                }

                // Group by date
                final grouped = _groupByDate(workouts);

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: grouped.length,
                  itemBuilder: (context, index) {
                    final entry = grouped[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Text(
                                Formatters.relativeDate(entry.date),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Divider(
                                    color: AppColors.textLight
                                        .withValues(alpha: 0.3)),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${entry.workouts.length} workout${entry.workouts.length > 1 ? 's' : ''}',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                        ...entry.workouts.map(
                          (workout) => WorkoutCard(
                            workout: workout,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddWorkoutScreen(
                                      editWorkout: workout),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  List<_DateGroup> _groupByDate(List<Workout> workouts) {
    final map = <String, List<Workout>>{};
    for (final w in workouts) {
      final key =
          '${w.startTime.year}-${w.startTime.month}-${w.startTime.day}';
      map.putIfAbsent(key, () => []).add(w);
    }

    return map.entries.map((e) {
      final date = e.value.first.startTime;
      return _DateGroup(date: date, workouts: e.value);
    }).toList();
  }
}

class _DateGroup {
  final DateTime date;
  final List<Workout> workouts;

  _DateGroup({required this.date, required this.workouts});
}
