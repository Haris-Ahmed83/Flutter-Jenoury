# NewsFlow — Flutter News Aggregator

A fully functional news aggregator built with Flutter that pulls articles from real RSS feeds and news APIs. Browse headlines across multiple categories, save articles for offline reading, and bookmark the stories that matter to you — all wrapped in a clean, modern interface with dark mode support.

---

## What It Does

NewsFlow collects news from sources like BBC, Reuters, TechCrunch, ESPN, and Ars Technica through their RSS feeds. It also taps into the GNews API for broader headline coverage. Articles are cached locally using SQLite, so you can keep reading even when you lose your internet connection.

### Core Features

- **Live RSS & API feeds** — Fetches real articles from 10+ news sources in real time
- **7 category filters** — Top Stories, Business, Technology, Science, Health, Sports, Entertainment
- **Offline reading** — Articles are cached automatically; save specific ones for guaranteed offline access
- **Bookmarks** — Tap to save, swipe to remove, always synced with your local database
- **Full-text article view** — Read content in-app with a clean reading experience, or open in your browser
- **Search** — Find articles by title, description, or source — searches both local cache and online
- **Dark mode** — System-aware theme switching with manual override
- **Share** — Send article links to any app on your device
- **Custom sources** — Add your own RSS feeds through the settings screen
- **Pull-to-refresh** — Refresh your feed anytime with a simple swipe down

---

## Architecture

The app follows a clean, provider-based architecture:

```
lib/
├── main.dart                  # App entry point
├── models/
│   ├── article.dart           # Article data model with serialization
│   ├── category.dart          # News category definitions
│   └── rss_source.dart        # RSS feed source model
├── database/
│   └── database_helper.dart   # SQLite database operations
├── services/
│   ├── news_api_service.dart  # GNews API integration
│   ├── rss_service.dart       # RSS/Atom feed parser
│   └── connectivity_service.dart # Network status monitoring
├── providers/
│   ├── news_provider.dart     # Central state management
│   └── theme_provider.dart    # Theme state management
├── screens/
│   ├── home_screen.dart       # Main feed with tabs
│   ├── article_detail_screen.dart # Full article view
│   ├── search_screen.dart     # Search functionality
│   ├── bookmarks_screen.dart  # Saved articles
│   └── settings_screen.dart   # App configuration
├── widgets/
│   ├── article_card.dart      # Reusable article card (full + compact)
│   ├── category_chips.dart    # Horizontal category filter
│   └── shimmer_loading.dart   # Loading skeleton animation
└── utils/
    ├── theme.dart             # Light/dark theme definitions
    └── time_formatter.dart    # Relative time formatting
```

### Key Design Decisions

- **Provider for state management** — Lightweight, well-suited for this scope, no boilerplate overhead
- **SQLite for persistence** — Articles, bookmarks, sources, and preferences all stored locally
- **RSS parsing from scratch** — Custom XML parser handles both RSS 2.0 and Atom feeds without heavy dependencies
- **Deduplication** — Articles from multiple sources are deduplicated by title before display
- **Graceful degradation** — If the API is unavailable, RSS feeds still work; if both fail, cached articles are shown

---

## Getting Started

### Prerequisites

- Flutter SDK 3.10 or later
- Dart 3.10 or later
- Android Studio / VS Code with Flutter extension
- An Android emulator, iOS simulator, or physical device

### Installation

```bash
# Clone the repository
git clone https://github.com/Haris-Ahmed83/Flutter-Jenoury.git
cd Flutter-Jenoury/news_aggregator

# Install dependencies
flutter pub get

# Run on your connected device or emulator
flutter run
```

### Optional: API Key

The app works out of the box with RSS feeds. For additional API coverage, you can get a free key from [GNews](https://gnews.io/) and set it in the `NewsApiService` constructor.

---

## Dependencies

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `http` | HTTP requests for feeds and APIs |
| `xml` | RSS/Atom feed XML parsing |
| `sqflite` | Local SQLite database |
| `connectivity_plus` | Network status detection |
| `cached_network_image` | Image caching and loading |
| `url_launcher` | Open articles in external browser |
| `share_plus` | Native share sheet integration |
| `shimmer` | Loading skeleton animations |
| `google_fonts` | Inter font family for clean typography |

---

## How It Works

1. **On launch**, the app loads cached articles from SQLite and displays them immediately
2. **In the background**, it fetches fresh articles from all enabled RSS sources and the GNews API
3. **New articles** are deduplicated, merged with existing data (preserving bookmark/read status), and cached
4. **Category filters** apply instantly on the local dataset — no additional network calls
5. **Connectivity changes** are monitored in real time; the app switches to offline mode automatically
6. **Old articles** (7+ days) are cleaned up automatically, unless bookmarked or saved offline

---

## License

This project is open source and available under the [MIT License](../LICENSE).
