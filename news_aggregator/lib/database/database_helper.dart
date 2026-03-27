import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/article.dart';
import '../models/rss_source.dart';

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
    final path = join(dbPath, 'news_aggregator.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE articles (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        content TEXT,
        url TEXT NOT NULL,
        imageUrl TEXT,
        source TEXT,
        author TEXT,
        category TEXT DEFAULT 'general',
        publishedAt TEXT NOT NULL,
        isBookmarked INTEGER DEFAULT 0,
        isRead INTEGER DEFAULT 0,
        isAvailableOffline INTEGER DEFAULT 0,
        cachedAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE rss_sources (
        url TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT DEFAULT 'general',
        isEnabled INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE user_preferences (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_articles_category ON articles(category)',
    );
    await db.execute(
      'CREATE INDEX idx_articles_bookmarked ON articles(isBookmarked)',
    );
    await db.execute(
      'CREATE INDEX idx_articles_published ON articles(publishedAt DESC)',
    );

    // Insert default RSS sources
    for (final source in RssSource.defaultSources) {
      await db.insert('rss_sources', source.toMap());
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE articles ADD COLUMN cachedAt TEXT',
      );
    }
  }

  // Article operations
  Future<int> insertArticle(Article article) async {
    final db = await database;
    return await db.insert(
      'articles',
      {...article.toMap(), 'cachedAt': DateTime.now().toIso8601String()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertArticles(List<Article> articles) async {
    final db = await database;
    final batch = db.batch();
    for (final article in articles) {
      batch.insert(
        'articles',
        {...article.toMap(), 'cachedAt': DateTime.now().toIso8601String()},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Article>> getArticles({
    String? category,
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await database;
    final where = category != null && category != 'all' ? 'category = ?' : null;
    final whereArgs = category != null && category != 'all' ? [category] : null;

    final maps = await db.query(
      'articles',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'publishedAt DESC',
      limit: limit,
      offset: offset,
    );

    return maps.map((map) => Article.fromMap(map)).toList();
  }

  Future<List<Article>> getBookmarkedArticles() async {
    final db = await database;
    final maps = await db.query(
      'articles',
      where: 'isBookmarked = 1',
      orderBy: 'publishedAt DESC',
    );
    return maps.map((map) => Article.fromMap(map)).toList();
  }

  Future<List<Article>> getOfflineArticles() async {
    final db = await database;
    final maps = await db.query(
      'articles',
      where: 'isAvailableOffline = 1',
      orderBy: 'publishedAt DESC',
    );
    return maps.map((map) => Article.fromMap(map)).toList();
  }

  Future<List<Article>> searchArticles(String query) async {
    final db = await database;
    final maps = await db.query(
      'articles',
      where: 'title LIKE ? OR description LIKE ? OR source LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'publishedAt DESC',
      limit: 50,
    );
    return maps.map((map) => Article.fromMap(map)).toList();
  }

  Future<int> toggleBookmark(String articleId, bool isBookmarked) async {
    final db = await database;
    return await db.update(
      'articles',
      {'isBookmarked': isBookmarked ? 1 : 0},
      where: 'id = ?',
      whereArgs: [articleId],
    );
  }

  Future<int> markAsRead(String articleId) async {
    final db = await database;
    return await db.update(
      'articles',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [articleId],
    );
  }

  Future<int> setOfflineAvailability(
      String articleId, bool isAvailable) async {
    final db = await database;
    return await db.update(
      'articles',
      {'isAvailableOffline': isAvailable ? 1 : 0},
      where: 'id = ?',
      whereArgs: [articleId],
    );
  }

  Future<void> deleteOldArticles({int daysOld = 7}) async {
    final db = await database;
    final cutoff =
        DateTime.now().subtract(Duration(days: daysOld)).toIso8601String();
    await db.delete(
      'articles',
      where:
          'publishedAt < ? AND isBookmarked = 0 AND isAvailableOffline = 0',
      whereArgs: [cutoff],
    );
  }

  // RSS Source operations
  Future<List<RssSource>> getRssSources() async {
    final db = await database;
    final maps = await db.query('rss_sources');
    return maps.map((map) => RssSource.fromMap(map)).toList();
  }

  Future<List<RssSource>> getEnabledRssSources() async {
    final db = await database;
    final maps = await db.query(
      'rss_sources',
      where: 'isEnabled = 1',
    );
    return maps.map((map) => RssSource.fromMap(map)).toList();
  }

  Future<int> insertRssSource(RssSource source) async {
    final db = await database;
    return await db.insert(
      'rss_sources',
      source.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> toggleRssSource(String url, bool isEnabled) async {
    final db = await database;
    return await db.update(
      'rss_sources',
      {'isEnabled': isEnabled ? 1 : 0},
      where: 'url = ?',
      whereArgs: [url],
    );
  }

  Future<int> deleteRssSource(String url) async {
    final db = await database;
    return await db.delete(
      'rss_sources',
      where: 'url = ?',
      whereArgs: [url],
    );
  }

  // Preferences
  Future<void> setPreference(String key, String value) async {
    final db = await database;
    await db.insert(
      'user_preferences',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getPreference(String key) async {
    final db = await database;
    final maps = await db.query(
      'user_preferences',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isNotEmpty) {
      return maps.first['value'] as String?;
    }
    return null;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
