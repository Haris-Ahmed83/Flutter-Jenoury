import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../providers/theme_provider.dart';
import '../models/rss_source.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NewsProvider>().loadRssSources();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Appearance section
          _buildSectionHeader(theme, 'Appearance'),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: const Text('Theme'),
                subtitle: Text(_themeModeName(themeProvider.themeMode)),
                trailing: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode, size: 18),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.settings_brightness, size: 18),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode, size: 18),
                    ),
                  ],
                  selected: {themeProvider.themeMode},
                  onSelectionChanged: (modes) {
                    themeProvider.setThemeMode(modes.first);
                  },
                  showSelectedIcon: false,
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              );
            },
          ),

          const Divider(),

          // RSS Sources section
          _buildSectionHeader(theme, 'News Sources'),
          Consumer<NewsProvider>(
            builder: (context, provider, _) {
              final sources = provider.rssSources;
              if (sources.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No RSS sources configured.'),
                );
              }

              return Column(
                children: sources.map((source) {
                  return SwitchListTile(
                    title: Text(source.name),
                    subtitle: Text(
                      source.category.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    value: source.isEnabled,
                    onChanged: (_) => provider.toggleRssSource(source),
                    secondary: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () =>
                          _confirmDeleteSource(context, provider, source),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          // Add source button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: OutlinedButton.icon(
              onPressed: () => _showAddSourceDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add RSS Source'),
            ),
          ),

          const Divider(),

          // Data management
          _buildSectionHeader(theme, 'Data'),
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined),
            title: const Text('Clear old articles'),
            subtitle: const Text('Remove articles older than 7 days'),
            onTap: () async {
              final provider = context.read<NewsProvider>();
              await provider.refreshArticles();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Old articles cleaned up')),
                );
              }
            },
          ),

          const Divider(),

          // About section
          _buildSectionHeader(theme, 'About'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('NewsFlow'),
            subtitle: Text('Version 1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Data Sources'),
            subtitle: const Text(
              'BBC, ESPN, Reuters, TechCrunch, Ars Technica & more via RSS feeds',
            ),
            isThreeLine: true,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _themeModeName(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
      ThemeMode.system => 'System',
    };
  }

  void _confirmDeleteSource(
      BuildContext context, NewsProvider provider, RssSource source) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Source'),
        content: Text('Remove "${source.name}" from your sources?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              provider.removeRssSource(source);
              Navigator.pop(context);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showAddSourceDialog(BuildContext context) {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    String selectedCategory = 'general';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add RSS Source'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Source Name',
                    hintText: 'e.g., CNN News',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'RSS Feed URL',
                    hintText: 'https://example.com/feed.xml',
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'general', child: Text('General')),
                    DropdownMenuItem(
                        value: 'business', child: Text('Business')),
                    DropdownMenuItem(
                        value: 'technology', child: Text('Technology')),
                    DropdownMenuItem(
                        value: 'science', child: Text('Science')),
                    DropdownMenuItem(
                        value: 'health', child: Text('Health')),
                    DropdownMenuItem(
                        value: 'sports', child: Text('Sports')),
                    DropdownMenuItem(
                        value: 'entertainment',
                        child: Text('Entertainment')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedCategory = value ?? 'general';
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    urlController.text.isNotEmpty) {
                  final source = RssSource(
                    name: nameController.text.trim(),
                    url: urlController.text.trim(),
                    category: selectedCategory,
                  );
                  context.read<NewsProvider>().addRssSource(source);
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
