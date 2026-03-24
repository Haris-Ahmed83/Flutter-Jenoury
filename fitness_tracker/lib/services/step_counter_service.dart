import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';

class StepCounterService {
  static final StepCounterService _instance = StepCounterService._internal();
  factory StepCounterService() => _instance;
  StepCounterService._internal();

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  final _stepController = StreamController<int>.broadcast();

  int _stepCount = 0;
  int _sessionSteps = 0;
  bool _isTracking = false;

  // Step detection parameters
  static const double _threshold = 12.0;
  static const int _minStepIntervalMs = 250;

  double _lastMagnitude = 0;
  bool _isPeak = false;
  DateTime _lastStepTime = DateTime.now();

  Stream<int> get stepStream => _stepController.stream;
  int get currentSteps => _stepCount;
  int get sessionSteps => _sessionSteps;
  bool get isTracking => _isTracking;

  void startTracking({int initialSteps = 0}) {
    if (_isTracking) return;

    _stepCount = initialSteps;
    _sessionSteps = 0;
    _isTracking = true;
    _lastStepTime = DateTime.now();

    _accelerometerSubscription = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 20),
    ).listen(_onAccelerometerEvent);
  }

  void stopTracking() {
    _isTracking = false;
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    // Calculate magnitude of acceleration vector
    final magnitude =
        sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

    final now = DateTime.now();
    final timeSinceLastStep =
        now.difference(_lastStepTime).inMilliseconds;

    // Peak detection algorithm
    if (_lastMagnitude > _threshold && magnitude < _lastMagnitude && _isPeak) {
      if (timeSinceLastStep > _minStepIntervalMs) {
        _stepCount++;
        _sessionSteps++;
        _lastStepTime = now;
        _stepController.add(_stepCount);
      }
      _isPeak = false;
    }

    if (magnitude > _threshold && magnitude > _lastMagnitude) {
      _isPeak = true;
    }

    _lastMagnitude = magnitude;
  }

  void resetSession() {
    _sessionSteps = 0;
  }

  void setStepCount(int steps) {
    _stepCount = steps;
  }

  void dispose() {
    stopTracking();
    _stepController.close();
  }
}
