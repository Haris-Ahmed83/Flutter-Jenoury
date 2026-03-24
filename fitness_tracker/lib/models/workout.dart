enum WorkoutType {
  running,
  cycling,
  swimming,
  weightLifting,
  yoga,
  hiit,
  walking,
  stretching,
  cardio,
  other,
}

extension WorkoutTypeExtension on WorkoutType {
  String get label {
    switch (this) {
      case WorkoutType.running:
        return 'Running';
      case WorkoutType.cycling:
        return 'Cycling';
      case WorkoutType.swimming:
        return 'Swimming';
      case WorkoutType.weightLifting:
        return 'Weight Lifting';
      case WorkoutType.yoga:
        return 'Yoga';
      case WorkoutType.hiit:
        return 'HIIT';
      case WorkoutType.walking:
        return 'Walking';
      case WorkoutType.stretching:
        return 'Stretching';
      case WorkoutType.cardio:
        return 'Cardio';
      case WorkoutType.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case WorkoutType.running:
        return '🏃';
      case WorkoutType.cycling:
        return '🚴';
      case WorkoutType.swimming:
        return '🏊';
      case WorkoutType.weightLifting:
        return '🏋️';
      case WorkoutType.yoga:
        return '🧘';
      case WorkoutType.hiit:
        return '⚡';
      case WorkoutType.walking:
        return '🚶';
      case WorkoutType.stretching:
        return '🤸';
      case WorkoutType.cardio:
        return '❤️';
      case WorkoutType.other:
        return '💪';
    }
  }
}

class Workout {
  final int? id;
  final String title;
  final WorkoutType type;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationMinutes;
  final double caloriesBurned;
  final String notes;
  final List<ExerciseSet> sets;
  final double? distanceKm;
  final int? avgHeartRate;

  const Workout({
    this.id,
    required this.title,
    required this.type,
    required this.startTime,
    this.endTime,
    required this.durationMinutes,
    required this.caloriesBurned,
    this.notes = '',
    this.sets = const [],
    this.distanceKm,
    this.avgHeartRate,
  });

  Workout copyWith({
    int? id,
    String? title,
    WorkoutType? type,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    double? caloriesBurned,
    String? notes,
    List<ExerciseSet>? sets,
    double? distanceKm,
    int? avgHeartRate,
  }) {
    return Workout(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      notes: notes ?? this.notes,
      sets: sets ?? this.sets,
      distanceKm: distanceKm ?? this.distanceKm,
      avgHeartRate: avgHeartRate ?? this.avgHeartRate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'type': type.index,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationMinutes': durationMinutes,
      'caloriesBurned': caloriesBurned,
      'notes': notes,
      'distanceKm': distanceKm,
      'avgHeartRate': avgHeartRate,
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map, {List<ExerciseSet>? sets}) {
    return Workout(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      type: WorkoutType.values[map['type'] as int? ?? 0],
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: map['endTime'] != null
          ? DateTime.parse(map['endTime'] as String)
          : null,
      durationMinutes: map['durationMinutes'] as int? ?? 0,
      caloriesBurned: (map['caloriesBurned'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes'] as String? ?? '',
      sets: sets ?? [],
      distanceKm: (map['distanceKm'] as num?)?.toDouble(),
      avgHeartRate: map['avgHeartRate'] as int?,
    );
  }

  double get caloriesPerMinute =>
      durationMinutes > 0 ? caloriesBurned / durationMinutes : 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Workout && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class ExerciseSet {
  final int? id;
  final int workoutId;
  final String exerciseName;
  final int setNumber;
  final int reps;
  final double weightKg;
  final int? durationSeconds;
  final String notes;

  const ExerciseSet({
    this.id,
    required this.workoutId,
    required this.exerciseName,
    required this.setNumber,
    required this.reps,
    required this.weightKg,
    this.durationSeconds,
    this.notes = '',
  });

  ExerciseSet copyWith({
    int? id,
    int? workoutId,
    String? exerciseName,
    int? setNumber,
    int? reps,
    double? weightKg,
    int? durationSeconds,
    String? notes,
  }) {
    return ExerciseSet(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      exerciseName: exerciseName ?? this.exerciseName,
      setNumber: setNumber ?? this.setNumber,
      reps: reps ?? this.reps,
      weightKg: weightKg ?? this.weightKg,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'workoutId': workoutId,
      'exerciseName': exerciseName,
      'setNumber': setNumber,
      'reps': reps,
      'weightKg': weightKg,
      'durationSeconds': durationSeconds,
      'notes': notes,
    };
  }

  factory ExerciseSet.fromMap(Map<String, dynamic> map) {
    return ExerciseSet(
      id: map['id'] as int?,
      workoutId: map['workoutId'] as int? ?? 0,
      exerciseName: map['exerciseName'] as String? ?? '',
      setNumber: map['setNumber'] as int? ?? 1,
      reps: map['reps'] as int? ?? 0,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0.0,
      durationSeconds: map['durationSeconds'] as int?,
      notes: map['notes'] as String? ?? '',
    );
  }

  double get totalVolume => reps * weightKg;
}
