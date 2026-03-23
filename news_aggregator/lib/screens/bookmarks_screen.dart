import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../widgets/article_card.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
      ),
      body: Consumer<NewsProvider>(
        builder: (context, provider, _) {
          final bookmarks = provider.bookmarkedArticles;

          if (bookmarks.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmark_outline,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No bookmarks yet',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Save articles you want to read later by tapping the bookmark icon.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              return Dismissible(
                key: ValueKey(bookmarks[index].id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  color: theme.colorScheme.error,
                  child: Icon(
                    Icons.bookmark_remove,
                    color: theme.colorScheme.onError,
                  ),
                ),
                onDismissed: (_) {
                  provider.toggleBookmark(bookmarks[index]);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Bookmark removed'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () {
                          provider.toggleBookmark(bookmarks[index]);
                        },
                      ),
                    ),
                  );
                },
                child: ArticleCard(
                  article: bookmarks[index],
                  isCompact: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
