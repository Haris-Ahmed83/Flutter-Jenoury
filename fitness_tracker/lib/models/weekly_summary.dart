class WeeklySummary {
  final DateTime weekStart;
  final int totalSteps;
  final double totalDistanceKm;
  final double totalCalories;
  final int totalWorkouts;
  final int totalWorkoutMinutes;
  final int daysActive;
  final int goalsReached;

  const WeeklySummary({
    required this.weekStart,
    required this.totalSteps,
    required this.totalDistanceKm,
    required this.totalCalories,
    required this.totalWorkouts,
    required this.totalWorkoutMinutes,
    required this.daysActive,
    required this.goalsReached,
  });

  double get avgStepsPerDay => daysActive > 0 ? totalSteps / 7 : 0;
  double get avgCaloriesPerDay => totalCalories / 7;
  double get avgWorkoutMinutesPerDay =>
      daysActive > 0 ? totalWorkoutMinutes / daysActive : 0;
}
