class StepRecord {
  final int? id;
  final DateTime date;
  final int steps;
  final double distanceKm;
  final double caloriesBurned;
  final int activeMinutes;
  final int goal;

  const StepRecord({
    this.id,
    required this.date,
    required this.steps,
    required this.distanceKm,
    required this.caloriesBurned,
    this.activeMinutes = 0,
    this.goal = 10000,
  });

  StepRecord copyWith({
    int? id,
    DateTime? date,
    int? steps,
    double? distanceKm,
    double? caloriesBurned,
    int? activeMinutes,
    int? goal,
  }) {
    return StepRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      steps: steps ?? this.steps,
      distanceKm: distanceKm ?? this.distanceKm,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      activeMinutes: activeMinutes ?? this.activeMinutes,
      goal: goal ?? this.goal,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'date': _dateOnly(date).toIso8601String(),
      'steps': steps,
      'distanceKm': distanceKm,
      'caloriesBurned': caloriesBurned,
      'activeMinutes': activeMinutes,
      'goal': goal,
    };
  }

  factory StepRecord.fromMap(Map<String, dynamic> map) {
    return StepRecord(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      steps: map['steps'] as int? ?? 0,
      distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 0.0,
      caloriesBurned: (map['caloriesBurned'] as num?)?.toDouble() ?? 0.0,
      activeMinutes: map['activeMinutes'] as int? ?? 0,
      goal: map['goal'] as int? ?? 10000,
    );
  }

  double get progressPercent => goal > 0 ? (steps / goal).clamp(0.0, 1.0) : 0;

  bool get goalReached => steps >= goal;

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  static double estimateDistance(int steps, {double strideMeters = 0.762}) {
    return (steps * strideMeters) / 1000.0;
  }

  static double estimateCalories(int steps, {double weightKg = 70.0}) {
    return steps * 0.04 * (weightKg / 70.0);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is StepRecord && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
