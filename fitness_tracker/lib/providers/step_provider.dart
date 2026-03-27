import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/step_record.dart';
import '../database/database_helper.dart';
import '../services/step_counter_service.dart';

class StepProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  final StepCounterService _stepService = StepCounterService();

  StepRecord? _todayRecord;
  List<StepRecord> _weekRecords = [];
  List<StepRecord> _monthRecords = [];
  bool _isTracking = false;
  bool _isLoading = false;
  int _stepGoal = 10000;
  double _userWeight = 70.0;
  double _strideLength = 0.762;
  Map<String, dynamic> _stats = {};

  StreamSubscription<int>? _stepSubscription;

  StepRecord? get todayRecord => _todayRecord;
  List<StepRecord> get weekRecords => _weekRecords;
  List<StepRecord> get monthRecords => _monthRecords;
  bool get isTracking => _isTracking;
  bool get isLoading => _isLoading;
  int get stepGoal => _stepGoal;
  int get currentSteps => _todayRecord?.steps ?? 0;
  double get todayDistance => _todayRecord?.distanceKm ?? 0;
  double get todayCalories => _todayRecord?.caloriesBurned ?? 0;
  double get progressPercent => _todayRecord?.progressPercent ?? 0;
  Map<String, dynamic> get stats => _stats;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load settings
      final goalStr = await _db.getSetting('step_goal');
      final weightStr = await _db.getSetting('weight_kg');
      final strideStr = await _db.getSetting('stride_length_m');

      _stepGoal = int.tryParse(goalStr ?? '') ?? 10000;
      _userWeight = double.tryParse(weightStr ?? '') ?? 70.0;
      _strideLength = double.tryParse(strideStr ?? '') ?? 0.762;

      // Load today's record
      _todayRecord = await _db.getTodaySteps();
      _todayRecord ??= StepRecord(
          date: DateTime.now(),
          steps: 0,
          distanceKm: 0,
          caloriesBurned: 0,
          goal: _stepGoal,
        );

      await _loadRecords();
      _stats = await _db.getStepStats(days: 30);
    } catch (e) {
      debugPrint('Error initializing steps: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadRecords() async {
    _weekRecords = await _db.getStepRecords(days: 7);
    _monthRecords = await _db.getStepRecords(days: 30);
  }

  void startTracking() {
    if (_isTracking) return;

    _isTracking = true;
    _stepService.startTracking(initialSteps: currentSteps);

    _stepSubscription = _stepService.stepStream.listen((steps) {
      _updateSteps(steps);
    });

    notifyListeners();
  }

  void stopTracking() {
    _isTracking = false;
    _stepService.stopTracking();
    _stepSubscription?.cancel();
    _stepSubscription = null;
    _saveToday();
    notifyListeners();
  }

  void _updateSteps(int steps) {
    final distance =
        StepRecord.estimateDistance(steps, strideMeters: _strideLength);
    final calories =
        StepRecord.estimateCalories(steps, weightKg: _userWeight);

    _todayRecord = _todayRecord?.copyWith(
          steps: steps,
          distanceKm: distance,
          caloriesBurned: calories,
        ) ??
        StepRecord(
          date: DateTime.now(),
          steps: steps,
          distanceKm: distance,
          caloriesBurned: calories,
          goal: _stepGoal,
        );

    notifyListeners();

    // Auto-save every 50 steps
    if (steps % 50 == 0) {
      _saveToday();
    }
  }

  Future<void> addManualSteps(int steps) async {
    final newTotal = currentSteps + steps;
    _updateSteps(newTotal);
    _stepService.setStepCount(newTotal);
    await _saveToday();
  }

  Future<void> _saveToday() async {
    if (_todayRecord != null) {
      await _db.upsertStepRecord(_todayRecord!);
      await _loadRecords();
    }
  }

  Future<void> setStepGoal(int goal) async {
    _stepGoal = goal;
    await _db.setSetting('step_goal', goal.toString());
    _todayRecord = _todayRecord?.copyWith(goal: goal);
    notifyListeners();
  }

  Future<void> setUserWeight(double weight) async {
    _userWeight = weight;
    await _db.setSetting('weight_kg', weight.toString());
    notifyListeners();
  }

  Future<List<StepRecord>> getRecordsForRange(
      DateTime start, DateTime end) async {
    return await _db.getStepRecordsRange(start, end);
  }

  @override
  void dispose() {
    _stepSubscription?.cancel();
    _stepService.dispose();
    super.dispose();
  }
}
