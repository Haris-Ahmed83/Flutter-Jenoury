import 'package:flutter/foundation.dart';
import '../models/article.dart';
import '../models/category.dart';
import '../models/rss_source.dart';
import '../database/database_helper.dart';
import '../services/news_api_service.dart';
import '../services/rss_service.dart';
import '../services/connectivity_service.dart';

enum LoadingState { idle, loading, loaded, error }

class NewsProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  final NewsApiService _apiService = NewsApiService();
  final RssService _rssService = RssService();
  final ConnectivityService _connectivityService = ConnectivityService();

  List<Article> _articles = [];
  List<Article> _bookmarkedArticles = [];
  List<Article> _searchResults = [];
  List<RssSource> _rssSources = [];
  String _selectedCategory = 'general';
  LoadingState _loadingState = LoadingState.idle;
  String _errorMessage = '';
  String _searchQuery = '';
  bool _isOfflineMode = false;

  // Getters
  List<Article> get articles => _articles;
  List<Article> get bookmarkedArticles => _bookmarkedArticles;
  List<Article> get searchResults => _searchResults;
  List<RssSource> get rssSources => _rssSources;
  String get selectedCategory => _selectedCategory;
  LoadingState get loadingState => _loadingState;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get isOfflineMode => _isOfflineMode;
  bool get isConnected => _connectivityService.isConnected;
  ConnectivityService get connectivityService => _connectivityService;

  List<Article> get filteredArticles {
    if (_selectedCategory == 'all') return _articles;
    return _articles
        .where((a) => a.category == _selectedCategory)
        .toList();
  }

  NewsProvider() {
    _init();
  }

  Future<void> _init() async {
    _rssSources = await _db.getEnabledRssSources();
    _connectivityService.connectionStream.listen((connected) {
      _isOfflineMode = !connected;
      if (connected) {
        refreshArticles();
      }
      notifyListeners();
    });

    await loadArticles();
    await loadBookmarks();
  }

  Future<void> loadArticles() async {
    _loadingState = LoadingState.loading;
    notifyListeners();

    try {
      // Load cached articles from database first
      final cachedArticles = await _db.getArticles(
        category: _selectedCategory == 'all' ? null : _selectedCategory,
      );

      if (cachedArticles.isNotEmpty) {
        _articles = cachedArticles;
        notifyListeners();
      }

      // Fetch fresh articles if online
      if (_connectivityService.isConnected) {
        await refreshArticles();
      } else if (cachedArticles.isEmpty) {
        // Try offline articles
        final offlineArticles = await _db.getOfflineArticles();
        _articles = offlineArticles;
      }

      _loadingState = LoadingState.loaded;
    } catch (e) {
      _errorMessage = 'Failed to load articles. Pull down to retry.';
      _loadingState = LoadingState.error;
    }

    notifyListeners();
  }

  Future<void> refreshArticles() async {
    if (!_connectivityService.isConnected) {
      _isOfflineMode = true;
      notifyListeners();
      return;
    }

    _loadingState = LoadingState.loading;
    notifyListeners();

    try {
      final List<Article> freshArticles = [];

      // Fetch from RSS feeds
      final enabledSources = await _db.getEnabledRssSources();
      final rssArticles = await _rssService.fetchAllFeeds(enabledSources);
      freshArticles.addAll(rssArticles);

      // Also try API for the selected category
      final apiArticles = await _apiService.fetchTopHeadlines(
        category: _selectedCategory == 'all' ? 'general' : _selectedCategory,
      );
      freshArticles.addAll(apiArticles);

      // Deduplicate by title similarity
      final deduped = _deduplicateArticles(freshArticles);

      if (deduped.isNotEmpty) {
        // Preserve bookmark and read status from existing articles
        final updatedArticles = deduped.map((article) {
          final existing = _articles.where((a) => a.id == article.id);
          if (existing.isNotEmpty) {
            return article.copyWith(
              isBookmarked: existing.first.isBookmarked,
              isRead: existing.first.isRead,
              isAvailableOffline: existing.first.isAvailableOffline,
            );
          }
          return article;
        }).toList();

        // Cache to database
        await _db.insertArticles(updatedArticles);

        _articles = updatedArticles;
      }

      // Clean up old articles
      await _db.deleteOldArticles();

      _loadingState = LoadingState.loaded;
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Could not fetch latest news. Showing cached articles.';
      _loadingState = LoadingState.error;
    }

    notifyListeners();
  }

  List<Article> _deduplicateArticles(List<Article> articles) {
    final seen = <String>{};
    final deduped = <Article>[];

    for (final article in articles) {
      final key = article.title.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
      if (key.isNotEmpty && !seen.contains(key)) {
        seen.add(key);
        deduped.add(article);
      }
    }

    deduped.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return deduped;
  }

  Future<void> selectCategory(String category) async {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
    await loadArticles();
  }

  Future<void> toggleBookmark(Article article) async {
    final newState = !article.isBookmarked;
    await _db.toggleBookmark(article.id, newState);

    final index = _articles.indexWhere((a) => a.id == article.id);
    if (index != -1) {
      _articles[index] = article.copyWith(isBookmarked: newState);
    }

    await loadBookmarks();
    notifyListeners();
  }

  Future<void> loadBookmarks() async {
    _bookmarkedArticles = await _db.getBookmarkedArticles();
    notifyListeners();
  }

  Future<void> markAsRead(Article article) async {
    if (article.isRead) return;
    await _db.markAsRead(article.id);

    final index = _articles.indexWhere((a) => a.id == article.id);
    if (index != -1) {
      _articles[index] = article.copyWith(isRead: true);
    }
    notifyListeners();
  }

  Future<void> toggleOfflineAvailability(Article article) async {
    final newState = !article.isAvailableOffline;
    await _db.setOfflineAvailability(article.id, newState);

    final index = _articles.indexWhere((a) => a.id == article.id);
    if (index != -1) {
      _articles[index] = article.copyWith(isAvailableOffline: newState);
    }
    notifyListeners();
  }

  Future<void> searchArticles(String query) async {
    _searchQuery = query;
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    // Search local database first
    _searchResults = await _db.searchArticles(query);

    // Also search online if connected
    if (_connectivityService.isConnected) {
      final onlineResults = await _apiService.searchNews(query);
      // Add online results that aren't already in local results
      for (final article in onlineResults) {
        if (!_searchResults.any((a) => a.id == article.id)) {
          _searchResults.add(article);
        }
      }
    }

    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }

  // RSS Source management
  Future<void> loadRssSources() async {
    _rssSources = await _db.getRssSources();
    notifyListeners();
  }

  Future<void> addRssSource(RssSource source) async {
    await _db.insertRssSource(source);
    await loadRssSources();
  }

  Future<void> toggleRssSource(RssSource source) async {
    await _db.toggleRssSource(source.url, !source.isEnabled);
    await loadRssSources();
  }

  Future<void> removeRssSource(RssSource source) async {
    await _db.deleteRssSource(source.url);
    await loadRssSources();
  }

  List<NewsCategory> get categories => NewsCategory.defaultCategories;

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }
}
