import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/article.dart';
import '../models/category.dart';
import '../providers/news_provider.dart';
import '../screens/article_detail_screen.dart';
import '../utils/time_formatter.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  final bool isCompact;

  const ArticleCard({
    super.key,
    required this.article,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = NewsCategory.fromId(article.category);

    if (isCompact) {
      return _buildCompactCard(context, theme, category);
    }
    return _buildFullCard(context, theme, category);
  }

  Widget _buildFullCard(
      BuildContext context, ThemeData theme, NewsCategory category) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: () => _openArticle(context),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (article.imageUrl.isNotEmpty)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: article.imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 200,
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 200,
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  // Category badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: category.color,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        category.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // Bookmark button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _buildBookmarkButton(context),
                  ),
                ],
              ),
            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    article.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Description
                  if (article.description.isNotEmpty)
                    Text(
                      article.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 10),
                  // Meta row
                  _buildMetaRow(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCard(
      BuildContext context, ThemeData theme, NewsCategory category) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => _openArticle(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              if (article.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: article.imageUrl,
                    width: 100,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 100,
                      height: 80,
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 100,
                      height: 80,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.image_not_supported, size: 24),
                    ),
                  ),
                ),
              if (article.imageUrl.isNotEmpty) const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    _buildMetaRow(theme),
                  ],
                ),
              ),
              // Bookmark
              _buildBookmarkButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.source_outlined,
          size: 14,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            article.source,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        Icon(
          Icons.access_time,
          size: 14,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          TimeFormatter.timeAgo(article.publishedAt),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (article.isRead) ...[
          const SizedBox(width: 8),
          Icon(
            Icons.check_circle,
            size: 14,
            color: theme.colorScheme.primary.withValues(alpha: 0.6),
          ),
        ],
      ],
    );
  }

  Widget _buildBookmarkButton(BuildContext context) {
    return Consumer<NewsProvider>(
      builder: (context, provider, _) {
        return Material(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: () => provider.toggleBookmark(article),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                article.isBookmarked
                    ? Icons.bookmark
                    : Icons.bookmark_border,
                color: article.isBookmarked
                    ? Colors.amber
                    : Colors.white,
                size: 20,
              ),
            ),
          ),
        );
      },
    );
  }

  void _openArticle(BuildContext context) {
    final provider = context.read<NewsProvider>();
    provider.markAsRead(article);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetailScreen(article: article),
      ),
    );
  }
}
