class RssSource {
  final String name;
  final String url;
  final String category;
  final bool isEnabled;

  const RssSource({
    required this.name,
    required this.url,
    required this.category,
    this.isEnabled = true,
  });

  RssSource copyWith({
    String? name,
    String? url,
    String? category,
    bool? isEnabled,
  }) {
    return RssSource(
      name: name ?? this.name,
      url: url ?? this.url,
      category: category ?? this.category,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'url': url,
      'category': category,
      'isEnabled': isEnabled ? 1 : 0,
    };
  }

  factory RssSource.fromMap(Map<String, dynamic> map) {
    return RssSource(
      name: map['name'] as String? ?? '',
      url: map['url'] as String? ?? '',
      category: map['category'] as String? ?? 'general',
      isEnabled: (map['isEnabled'] as int?) == 1,
    );
  }

  static const List<RssSource> defaultSources = [
    RssSource(
      name: 'BBC News',
      url: 'https://feeds.bbci.co.uk/news/rss.xml',
      category: 'general',
    ),
    RssSource(
      name: 'BBC Technology',
      url: 'https://feeds.bbci.co.uk/news/technology/rss.xml',
      category: 'technology',
    ),
    RssSource(
      name: 'BBC Business',
      url: 'https://feeds.bbci.co.uk/news/business/rss.xml',
      category: 'business',
    ),
    RssSource(
      name: 'BBC Science',
      url: 'https://feeds.bbci.co.uk/news/science_and_environment/rss.xml',
      category: 'science',
    ),
    RssSource(
      name: 'BBC Health',
      url: 'https://feeds.bbci.co.uk/news/health/rss.xml',
      category: 'health',
    ),
    RssSource(
      name: 'BBC Entertainment',
      url: 'https://feeds.bbci.co.uk/news/entertainment_and_arts/rss.xml',
      category: 'entertainment',
    ),
    RssSource(
      name: 'ESPN Sports',
      url: 'https://www.espn.com/espn/rss/news',
      category: 'sports',
    ),
    RssSource(
      name: 'Reuters World',
      url: 'https://feeds.reuters.com/reuters/topNews',
      category: 'general',
    ),
    RssSource(
      name: 'TechCrunch',
      url: 'https://techcrunch.com/feed/',
      category: 'technology',
    ),
    RssSource(
      name: 'Ars Technica',
      url: 'https://feeds.arstechnica.com/arstechnica/index',
      category: 'technology',
    ),
  ];
}
