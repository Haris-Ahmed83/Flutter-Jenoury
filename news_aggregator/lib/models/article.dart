class Article {
  final String id;
  final String title;
  final String description;
  final String content;
  final String url;
  final String imageUrl;
  final String source;
  final String author;
  final String category;
  final DateTime publishedAt;
  final bool isBookmarked;
  final bool isRead;
  final bool isAvailableOffline;

  const Article({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.url,
    required this.imageUrl,
    required this.source,
    required this.author,
    required this.category,
    required this.publishedAt,
    this.isBookmarked = false,
    this.isRead = false,
    this.isAvailableOffline = false,
  });

  Article copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? url,
    String? imageUrl,
    String? source,
    String? author,
    String? category,
    DateTime? publishedAt,
    bool? isBookmarked,
    bool? isRead,
    bool? isAvailableOffline,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      source: source ?? this.source,
      author: author ?? this.author,
      category: category ?? this.category,
      publishedAt: publishedAt ?? this.publishedAt,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isRead: isRead ?? this.isRead,
      isAvailableOffline: isAvailableOffline ?? this.isAvailableOffline,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'url': url,
      'imageUrl': imageUrl,
      'source': source,
      'author': author,
      'category': category,
      'publishedAt': publishedAt.toIso8601String(),
      'isBookmarked': isBookmarked ? 1 : 0,
      'isRead': isRead ? 1 : 0,
      'isAvailableOffline': isAvailableOffline ? 1 : 0,
    };
  }

  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      content: map['content'] as String? ?? '',
      url: map['url'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      source: map['source'] as String? ?? '',
      author: map['author'] as String? ?? '',
      category: map['category'] as String? ?? 'general',
      publishedAt: DateTime.tryParse(map['publishedAt'] as String? ?? '') ??
          DateTime.now(),
      isBookmarked: (map['isBookmarked'] as int?) == 1,
      isRead: (map['isRead'] as int?) == 1,
      isAvailableOffline: (map['isAvailableOffline'] as int?) == 1,
    );
  }

  factory Article.fromNewsApi(Map<String, dynamic> json, String category) {
    final source = json['source'] as Map<String, dynamic>?;
    return Article(
      id: _generateId(json['url'] as String? ?? ''),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      content: json['content'] as String? ?? '',
      url: json['url'] as String? ?? '',
      imageUrl: json['urlToImage'] as String? ?? '',
      source: source?['name'] as String? ?? 'Unknown',
      author: json['author'] as String? ?? 'Unknown',
      category: category,
      publishedAt:
          DateTime.tryParse(json['publishedAt'] as String? ?? '') ??
              DateTime.now(),
    );
  }

  factory Article.fromRss({
    required String title,
    required String description,
    required String link,
    required String imageUrl,
    required String source,
    required String author,
    required String category,
    required DateTime publishedAt,
    String content = '',
  }) {
    return Article(
      id: _generateId(link),
      title: title,
      description: description,
      content: content.isNotEmpty ? content : description,
      url: link,
      imageUrl: imageUrl,
      source: source,
      author: author,
      category: category,
      publishedAt: publishedAt,
    );
  }

  static String _generateId(String url) {
    final hash = url.hashCode.toUnsigned(32).toRadixString(16);
    return 'art_$hash';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Article && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
