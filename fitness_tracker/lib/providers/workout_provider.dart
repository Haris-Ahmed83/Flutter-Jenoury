import 'package:flutter/foundation.dart';
import '../models/workout.dart';
import '../services/workout_service.dart';

class WorkoutProvider extends ChangeNotifier {
  final WorkoutService _service = WorkoutService();

  List<Workout> _workouts = [];
  List<Workout> _filteredWorkouts = [];
  WorkoutType? _filterType;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _stats = {};

  List<Workout> get workouts =>
      _filterType != null ? _filteredWorkouts : _workouts;
  WorkoutType? get filterType => _filterType;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get stats => _stats;

  int get totalWorkouts => (_stats['totalWorkouts'] as num?)?.toInt() ?? 0;
  int get totalMinutes => (_stats['totalMinutes'] as num?)?.toInt() ?? 0;
  double get totalCalories =>
      (_stats['totalCalories'] as num?)?.toDouble() ?? 0;
  double get totalDistance =>
      (_stats['totalDistance'] as num?)?.toDouble() ?? 0;

  Future<void> loadWorkouts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _workouts = await _service.getRecentWorkouts(limit: 100);
      _applyFilter();
      _stats = await _service.getStats(days: 30);
    } catch (e) {
      _error = 'Failed to load workouts: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addWorkout(Workout workout) async {
    try {
      final id = await _service.createWorkout(workout);
      final saved = workout.copyWith(id: id);
      _workouts.insert(0, saved);
      _applyFilter();
      _stats = await _service.getStats(days: 30);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to save workout: $e';
      notifyListeners();
    }
  }

  Future<void> updateWorkout(Workout workout) async {
    try {
      await _service.updateWorkout(workout);
      final index = _workouts.indexWhere((w) => w.id == workout.id);
      if (index != -1) {
        _workouts[index] = workout;
        _applyFilter();
      }
      _stats = await _service.getStats(days: 30);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update workout: $e';
      notifyListeners();
    }
  }

  Future<void> deleteWorkout(int id) async {
    try {
      await _service.deleteWorkout(id);
      _workouts.removeWhere((w) => w.id == id);
      _applyFilter();
      _stats = await _service.getStats(days: 30);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete workout: $e';
      notifyListeners();
    }
  }

  void setFilter(WorkoutType? type) {
    _filterType = type;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_filterType != null) {
      _filteredWorkouts =
          _workouts.where((w) => w.type == _filterType).toList();
    }
  }

  Future<List<Workout>> getWorkoutsForWeek(DateTime weekStart) async {
    return await _service.getWorkoutsForWeek(weekStart);
  }
}
