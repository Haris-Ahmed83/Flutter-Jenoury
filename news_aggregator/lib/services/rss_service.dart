import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../models/article.dart';
import '../models/rss_source.dart';

class RssService {
  Future<List<Article>> fetchFeed(RssSource source) async {
    try {
      final response = await http.get(Uri.parse(source.url)).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        return _parseRssFeed(response.body, source);
      }
    } catch (_) {
      // Return empty on failure — caller handles fallback
    }
    return [];
  }

  Future<List<Article>> fetchAllFeeds(List<RssSource> sources) async {
    final futures = sources
        .where((s) => s.isEnabled)
        .map((source) => fetchFeed(source));

    final results = await Future.wait(futures, eagerError: false);
    final allArticles = results.expand((list) => list).toList();

    // Sort by publish date, newest first
    allArticles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return allArticles;
  }

  List<Article> _parseRssFeed(String xmlString, RssSource source) {
    try {
      final document = XmlDocument.parse(xmlString);
      final items = document.findAllElements('item');

      return items.map((item) {
        final title = _getElementText(item, 'title');
        final description = _cleanHtml(_getElementText(item, 'description'));
        final link = _getElementText(item, 'link');
        final pubDate = _getElementText(item, 'pubDate');
        final author = _getElementText(item, 'dc:creator') ??
            _getElementText(item, 'author') ??
            source.name;
        final rawContent = _getElementText(item, 'content:encoded') ??
            _getElementText(item, 'description');
        final content = rawContent ?? '';
        final imageUrl = _extractImageUrl(item);

        return Article.fromRss(
          title: title ?? 'Untitled',
          description: description,
          link: link ?? '',
          imageUrl: imageUrl,
          source: source.name,
          author: author,
          category: source.category,
          publishedAt: _parseDate(pubDate),
          content: _cleanHtml(content),
        );
      }).where((article) => article.title.isNotEmpty && article.title != 'Untitled').toList();
    } catch (_) {
      // Try Atom format
      return _parseAtomFeed(xmlString, source);
    }
  }

  List<Article> _parseAtomFeed(String xmlString, RssSource source) {
    try {
      final document = XmlDocument.parse(xmlString);
      final entries = document.findAllElements('entry');

      return entries.map((entry) {
        final title = _getElementText(entry, 'title');
        final rawSummary = _getElementText(entry, 'summary') ??
            _getElementText(entry, 'content');
        final summary = _cleanHtml(rawSummary);
        final link = entry
            .findElements('link')
            .where((e) =>
                e.getAttribute('rel') == 'alternate' ||
                e.getAttribute('rel') == null)
            .map((e) => e.getAttribute('href'))
            .firstOrNull;
        final published =
            _getElementText(entry, 'published') ??
                _getElementText(entry, 'updated');
        final author = _getElementText(
            entry.findElements('author').firstOrNull, 'name');

        return Article.fromRss(
          title: title ?? 'Untitled',
          description: summary,
          link: link ?? '',
          imageUrl: _extractImageUrl(entry),
          source: source.name,
          author: author ?? source.name,
          category: source.category,
          publishedAt: _parseDate(published),
          content: summary,
        );
      }).where((article) => article.title.isNotEmpty && article.title != 'Untitled').toList();
    } catch (_) {
      return [];
    }
  }

  String? _getElementText(XmlElement? parent, String name) {
    if (parent == null) return null;
    final elements = parent.findElements(name);
    if (elements.isEmpty) return null;
    final text = elements.first.innerText.trim();
    return text.isEmpty ? null : text;
  }

  String _extractImageUrl(XmlElement item) {
    // Try media:content
    final mediaContent = item.findElements('media:content');
    if (mediaContent.isNotEmpty) {
      final url = mediaContent.first.getAttribute('url');
      if (url != null && url.isNotEmpty) return url;
    }

    // Try media:thumbnail
    final mediaThumbnail = item.findElements('media:thumbnail');
    if (mediaThumbnail.isNotEmpty) {
      final url = mediaThumbnail.first.getAttribute('url');
      if (url != null && url.isNotEmpty) return url;
    }

    // Try enclosure
    final enclosure = item.findElements('enclosure');
    if (enclosure.isNotEmpty) {
      final type = enclosure.first.getAttribute('type') ?? '';
      if (type.startsWith('image')) {
        final url = enclosure.first.getAttribute('url');
        if (url != null && url.isNotEmpty) return url;
      }
    }

    // Try to extract from description HTML
    final desc = item.findElements('description');
    if (desc.isNotEmpty) {
      final imgMatch = RegExp(r'<img[^>]+src="([^"]+)"').firstMatch(desc.first.innerText);
      if (imgMatch != null) return imgMatch.group(1) ?? '';
    }

    return '';
  }

  DateTime _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return DateTime.now();

    try {
      return DateTime.parse(dateString);
    } catch (_) {
      // Try RFC 822 date format (common in RSS)
      try {
        return _parseRfc822Date(dateString);
      } catch (_) {
        return DateTime.now();
      }
    }
  }

  DateTime _parseRfc822Date(String dateString) {
    final months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
    };

    final cleaned = dateString.replaceAll(RegExp(r'\s+'), ' ').trim();
    final parts = cleaned.split(' ');

    if (parts.length >= 5) {
      final day = int.tryParse(parts[1]) ?? 1;
      final month = months[parts[2]] ?? 1;
      final year = int.tryParse(parts[3]) ?? DateTime.now().year;
      final timeParts = parts[4].split(':');
      final hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = timeParts.length > 1 ? int.tryParse(timeParts[1]) ?? 0 : 0;
      final second = timeParts.length > 2 ? int.tryParse(timeParts[2]) ?? 0 : 0;

      return DateTime.utc(year, month, day, hour, minute, second);
    }

    return DateTime.now();
  }

  String _cleanHtml(String? html) {
    if (html == null || html.isEmpty) return '';
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
