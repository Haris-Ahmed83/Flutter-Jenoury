import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/workout.dart';
import '../models/step_record.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'fitness_tracker.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        type INTEGER NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT,
        durationMinutes INTEGER NOT NULL DEFAULT 0,
        caloriesBurned REAL NOT NULL DEFAULT 0,
        notes TEXT DEFAULT '',
        distanceKm REAL,
        avgHeartRate INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE exercise_sets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workoutId INTEGER NOT NULL,
        exerciseName TEXT NOT NULL,
        setNumber INTEGER NOT NULL,
        reps INTEGER NOT NULL DEFAULT 0,
        weightKg REAL NOT NULL DEFAULT 0,
        durationSeconds INTEGER,
        notes TEXT DEFAULT '',
        FOREIGN KEY (workoutId) REFERENCES workouts(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE step_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        steps INTEGER NOT NULL DEFAULT 0,
        distanceKm REAL NOT NULL DEFAULT 0,
        caloriesBurned REAL NOT NULL DEFAULT 0,
        activeMinutes INTEGER NOT NULL DEFAULT 0,
        goal INTEGER NOT NULL DEFAULT 10000
      )
    ''');

    await db.execute('''
      CREATE TABLE user_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_workouts_start ON workouts(startTime DESC)');
    await db.execute(
        'CREATE INDEX idx_steps_date ON step_records(date DESC)');
    await db.execute(
        'CREATE INDEX idx_sets_workout ON exercise_sets(workoutId)');

    // Insert default settings
    await db.insert('user_settings', {'key': 'step_goal', 'value': '10000'});
    await db.insert('user_settings', {'key': 'weight_kg', 'value': '70'});
    await db.insert('user_settings', {'key': 'height_cm', 'value': '170'});
    await db.insert(
        'user_settings', {'key': 'stride_length_m', 'value': '0.762'});
  }

  // ─── Workout Operations ───

  Future<int> insertWorkout(Workout workout) async {
    final db = await database;
    final workoutId = await db.insert('workouts', workout.toMap());

    if (workout.sets.isNotEmpty) {
      final batch = db.batch();
      for (final set in workout.sets) {
        batch.insert('exercise_sets', set.copyWith(workoutId: workoutId).toMap());
      }
      await batch.commit(noResult: true);
    }

    return workoutId;
  }

  Future<int> updateWorkout(Workout workout) async {
    final db = await database;
    final result = await db.update(
      'workouts',
      workout.toMap(),
      where: 'id = ?',
      whereArgs: [workout.id],
    );

    // Replace all sets
    await db.delete('exercise_sets',
        where: 'workoutId = ?', whereArgs: [workout.id]);
    if (workout.sets.isNotEmpty) {
      final batch = db.batch();
      for (final set in workout.sets) {
        batch.insert('exercise_sets', set.copyWith(workoutId: workout.id!).toMap());
      }
      await batch.commit(noResult: true);
    }

    return result;
  }

  Future<int> deleteWorkout(int id) async {
    final db = await database;
    await db.delete('exercise_sets', where: 'workoutId = ?', whereArgs: [id]);
    return await db.delete('workouts', where: 'id = ?', whereArgs: [id]);
  }

  Future<Workout?> getWorkout(int id) async {
    final db = await database;
    final maps = await db.query('workouts', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;

    final sets = await _getSetsForWorkout(id);
    return Workout.fromMap(maps.first, sets: sets);
  }

  Future<List<Workout>> getWorkouts({
    int limit = 50,
    int offset = 0,
    WorkoutType? type,
    DateTime? from,
    DateTime? to,
  }) async {
    final db = await database;
    final conditions = <String>[];
    final args = <dynamic>[];

    if (type != null) {
      conditions.add('type = ?');
      args.add(type.index);
    }
    if (from != null) {
      conditions.add('startTime >= ?');
      args.add(from.toIso8601String());
    }
    if (to != null) {
      conditions.add('startTime <= ?');
      args.add(to.toIso8601String());
    }

    final where = conditions.isNotEmpty ? conditions.join(' AND ') : null;

    final maps = await db.query(
      'workouts',
      where: where,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'startTime DESC',
      limit: limit,
      offset: offset,
    );

    final workouts = <Workout>[];
    for (final map in maps) {
      final sets = await _getSetsForWorkout(map['id'] as int);
      workouts.add(Workout.fromMap(map, sets: sets));
    }
    return workouts;
  }

  Future<List<Workout>> getWorkoutsForDateRange(
      DateTime start, DateTime end) async {
    return getWorkouts(from: start, to: end, limit: 1000);
  }

  Future<List<ExerciseSet>> _getSetsForWorkout(int workoutId) async {
    final db = await database;
    final maps = await db.query(
      'exercise_sets',
      where: 'workoutId = ?',
      whereArgs: [workoutId],
      orderBy: 'setNumber ASC',
    );
    return maps.map((m) => ExerciseSet.fromMap(m)).toList();
  }

  // ─── Step Record Operations ───

  Future<int> upsertStepRecord(StepRecord record) async {
    final db = await database;
    return await db.insert(
      'step_records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<StepRecord?> getStepRecord(DateTime date) async {
    final db = await database;
    final dateStr = DateTime(date.year, date.month, date.day).toIso8601String();
    final maps = await db.query(
      'step_records',
      where: 'date = ?',
      whereArgs: [dateStr],
    );
    if (maps.isEmpty) return null;
    return StepRecord.fromMap(maps.first);
  }

  Future<StepRecord?> getTodaySteps() async {
    return getStepRecord(DateTime.now());
  }

  Future<List<StepRecord>> getStepRecords({
    int days = 7,
    DateTime? from,
  }) async {
    final db = await database;
    final startDate =
        from ?? DateTime.now().subtract(Duration(days: days - 1));
    final dateStr =
        DateTime(startDate.year, startDate.month, startDate.day)
            .toIso8601String();

    final maps = await db.query(
      'step_records',
      where: 'date >= ?',
      whereArgs: [dateStr],
      orderBy: 'date ASC',
    );
    return maps.map((m) => StepRecord.fromMap(m)).toList();
  }

  Future<List<StepRecord>> getStepRecordsRange(
      DateTime start, DateTime end) async {
    final db = await database;
    final startStr =
        DateTime(start.year, start.month, start.day).toIso8601String();
    final endStr = DateTime(end.year, end.month, end.day).toIso8601String();

    final maps = await db.query(
      'step_records',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startStr, endStr],
      orderBy: 'date ASC',
    );
    return maps.map((m) => StepRecord.fromMap(m)).toList();
  }

  // ─── Statistics ───

  Future<Map<String, dynamic>> getWorkoutStats({int days = 30}) async {
    final db = await database;
    final since =
        DateTime.now().subtract(Duration(days: days)).toIso8601String();

    final result = await db.rawQuery('''
      SELECT
        COUNT(*) as totalWorkouts,
        COALESCE(SUM(durationMinutes), 0) as totalMinutes,
        COALESCE(SUM(caloriesBurned), 0) as totalCalories,
        COALESCE(AVG(durationMinutes), 0) as avgDuration,
        COALESCE(SUM(distanceKm), 0) as totalDistance
      FROM workouts WHERE startTime >= ?
    ''', [since]);

    return result.first;
  }

  Future<Map<String, dynamic>> getStepStats({int days = 30}) async {
    final db = await database;
    final since = DateTime.now()
        .subtract(Duration(days: days))
        .toIso8601String()
        .substring(0, 10);

    final result = await db.rawQuery('''
      SELECT
        COALESCE(SUM(steps), 0) as totalSteps,
        COALESCE(AVG(steps), 0) as avgSteps,
        COALESCE(MAX(steps), 0) as maxSteps,
        COALESCE(SUM(distanceKm), 0) as totalDistance,
        COALESCE(SUM(caloriesBurned), 0) as totalCalories,
        COUNT(*) as daysTracked
      FROM step_records WHERE date >= ?
    ''', [since]);

    return result.first;
  }

  // ─── Settings ───

  Future<String?> getSetting(String key) async {
    final db = await database;
    final maps = await db.query(
      'user_settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isNotEmpty) return maps.first['value'] as String?;
    return null;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'user_settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
