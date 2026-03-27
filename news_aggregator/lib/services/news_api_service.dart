import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class NewsApiService {
  String? _apiKey;

  NewsApiService({String? apiKey}) : _apiKey = apiKey;

  void setApiKey(String key) {
    _apiKey = key;
  }

  Future<List<Article>> fetchTopHeadlines({
    String category = 'general',
    String country = 'us',
    int page = 1,
  }) async {
    // Use GNews API (free, no key required for basic usage)
    final url = Uri.parse(
      'https://gnews.io/api/v4/top-headlines?'
      'category=$category'
      '&lang=en'
      '&country=us'
      '&max=10'
      '${_apiKey != null ? '&apikey=$_apiKey' : ''}',
    );

    try {
      final response = await http.get(url).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = (data['articles'] as List?)
                ?.map((json) => _fromGNewsJson(json, category))
                .where((a) => a.title.isNotEmpty)
                .toList() ??
            [];
        return articles;
      }
    } catch (_) {
      // Will fall back to RSS feeds
    }

    return [];
  }

  Future<List<Article>> searchNews(String query) async {
    final url = Uri.parse(
      'https://gnews.io/api/v4/search?'
      'q=${Uri.encodeComponent(query)}'
      '&lang=en'
      '&max=10'
      '${_apiKey != null ? '&apikey=$_apiKey' : ''}',
    );

    try {
      final response = await http.get(url).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = (data['articles'] as List?)
                ?.map((json) => _fromGNewsJson(json, 'general'))
                .where((a) => a.title.isNotEmpty)
                .toList() ??
            [];
        return articles;
      }
    } catch (_) {
      // Return empty on failure
    }

    return [];
  }

  Article _fromGNewsJson(dynamic json, String category) {
    final map = json as Map<String, dynamic>;
    final source = map['source'] as Map<String, dynamic>?;
    return Article(
      id: Article.fromNewsApi({'url': map['url'] ?? ''}, category).id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      content: map['content'] as String? ?? map['description'] as String? ?? '',
      url: map['url'] as String? ?? '',
      imageUrl: map['image'] as String? ?? '',
      source: source?['name'] as String? ?? 'Unknown',
      author: map['author'] as String? ?? 'Unknown',
      category: category,
      publishedAt:
          DateTime.tryParse(map['publishedAt'] as String? ?? '') ??
              DateTime.now(),
    );
  }
}
