import '../database/database_helper.dart';
import '../models/workout.dart';

class WorkoutService {
  final DatabaseHelper _db = DatabaseHelper();

  Future<int> createWorkout(Workout workout) async {
    return await _db.insertWorkout(workout);
  }

  Future<int> updateWorkout(Workout workout) async {
    return await _db.updateWorkout(workout);
  }

  Future<int> deleteWorkout(int id) async {
    return await _db.deleteWorkout(id);
  }

  Future<Workout?> getWorkout(int id) async {
    return await _db.getWorkout(id);
  }

  Future<List<Workout>> getRecentWorkouts({int limit = 20}) async {
    return await _db.getWorkouts(limit: limit);
  }

  Future<List<Workout>> getWorkoutsByType(WorkoutType type) async {
    return await _db.getWorkouts(type: type);
  }

  Future<List<Workout>> getWorkoutsForWeek(DateTime weekStart) async {
    final weekEnd = weekStart.add(const Duration(days: 7));
    return await _db.getWorkoutsForDateRange(weekStart, weekEnd);
  }

  Future<List<Workout>> getWorkoutsForMonth(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);
    return await _db.getWorkoutsForDateRange(start, end);
  }

  Future<Map<String, dynamic>> getStats({int days = 30}) async {
    return await _db.getWorkoutStats(days: days);
  }

  /// Estimate calories burned based on workout type, duration, and user weight
  static double estimateCalories({
    required WorkoutType type,
    required int durationMinutes,
    double weightKg = 70.0,
  }) {
    // MET values for different activities
    final metValues = {
      WorkoutType.running: 9.8,
      WorkoutType.cycling: 7.5,
      WorkoutType.swimming: 8.0,
      WorkoutType.weightLifting: 6.0,
      WorkoutType.yoga: 3.0,
      WorkoutType.hiit: 10.0,
      WorkoutType.walking: 3.5,
      WorkoutType.stretching: 2.5,
      WorkoutType.cardio: 7.0,
      WorkoutType.other: 5.0,
    };

    final met = metValues[type] ?? 5.0;
    // Calories = MET × weight(kg) × duration(hours)
    return met * weightKg * (durationMinutes / 60.0);
  }
}
