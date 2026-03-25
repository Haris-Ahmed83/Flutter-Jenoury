# Flutter-Jenoury

A collection of production-quality Flutter projects built with clean architecture and real-world integrations.

## Projects

### [E-Commerce App](./ecommerce_app/)

A fully functional mobile shopping application with:

- Live product catalog with search, filtering, and sorting
- Persistent shopping cart with quantity management
- Stripe payment integration (real PaymentIntents + native payment sheet)
- Complete order history with status tracking
- User authentication with profile management
- Clean Provider-based state management

**Tech:** Flutter 3.2+ | Provider | Stripe | cached_network_image | SharedPreferences

[View Project Details](./ecommerce_app/README.md)

---

### [News Aggregator](./news_aggregator/)

A professional news aggregator that pulls real articles from RSS feeds and news APIs:

- Live RSS feeds from BBC, Reuters, TechCrunch, ESPN, Ars Technica, and more
- 7 category filters — Top Stories, Business, Technology, Science, Health, Sports, Entertainment
- Offline reading with SQLite caching and manual save-for-offline
- Bookmarks with swipe-to-dismiss management
- Full-text article view with share and open-in-browser support
- Real-time search across local cache and online sources
- Dark mode with system-aware theme switching
- Custom RSS source management through settings

**Tech:** Flutter 3.10+ | Provider | SQLite | RSS/Atom XML Parsing | connectivity_plus | cached_network_image | Google Fonts

[View Project Details](./news_aggregator/README.md)

---

### [Chat App Firebase](./chat_app_firebase/)

Real-time messaging application powered by Firebase:

- Firebase Authentication & Firestore integration
- Real-time message synchronization
- User presence tracking and typing indicators
- Responsive Material Design UI
- Message history persistence

**Tech:** Flutter 3.2+ | Firebase | Cloud Firestore | Provider

[View Project Details](./chat_app_firebase/README.md)

---

### [Fitness Tracker](./fitness_tracker/)

Comprehensive fitness tracking with sensor integration:

- Step counter using device sensors
- Workout logging and tracking
- Daily goal management
- Progress visualization with circular charts
- Calorie and distance calculations
- Settings for personalization

**Tech:** Flutter 3.10+ | sensors_plus | SQLite | Provider

[View Project Details](./fitness_tracker/README.md)

---

### [Expense Tracker](./expense_tracker/)

Smart financial management application:

- Income and expense categorization
- Monthly and yearly reports
- Data visualization with charts
- Local database persistence
- Category-based filtering

**Tech:** Flutter 3.0+ | SQLite | Provider

[View Project Details](./expense_tracker/README.md)

---

### [Recipe AI Search](./recipe_ai_search/)

AI-powered recipe discovery and management:

- Search recipes by ingredients
- Google Generative AI integration
- Nutrition information display
- Favorites management
- Advanced filtering and sorting
- Lottie animations

**Tech:** Flutter 3.10+ | Google Generative AI | Hive | Provider | Lottie

[View Project Details](./recipe_ai_search/README.md)

---

## 📊 Project Statistics

| Metric | Value |
|--------|-------|
| Total Projects | 6 |
| Total Screens | 50+ |
| Total Widgets | 100+ |
| Lines of Code | 10,000+ |
| Dependencies | 50+ |
| Linting Issues | 0 ✅ |
| Null Safety | 100% ✅ |
| Status | Production Ready ✅ |

## 🏗️ Architecture Highlights

All projects follow best practices:

- **State Management:** Provider pattern
- **Code Organization:** Feature-based architecture
- **Networking:** Dio/HTTP with error handling
- **Local Storage:** SQLite, SharedPreferences, Hive
- **UI Components:** Reusable widgets, custom themes
- **Performance:** Const optimization, lazy loading
- **Error Handling:** Comprehensive error management

## 🚀 Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/Flutter-Jenoury.git
   cd Flutter-Jenoury
   ```

2. **Select a project:**
   ```bash
   cd [project_name]
   ```

3. **Install dependencies:**
   ```bash
   flutter pub get
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

Each project folder contains its own README with detailed setup instructions, architecture documentation, and configuration guides.

## ✅ Quality Assurance

- ✅ 0 Analyzer issues across all projects
- ✅ Full null-safety compliance
- ✅ Const optimization throughout
- ✅ Material Design compliance
- ✅ Performance optimized
- ✅ Cross-platform ready (iOS, Android, Web)

## 📄 License

[MIT License](./LICENSE)

---

**Last Updated:** March 2026 | **Status:** ✅ Production Ready
