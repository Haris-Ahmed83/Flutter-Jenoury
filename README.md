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

## Getting Started

Each project folder contains its own README with setup instructions, architecture documentation, and configuration guides.

## License

[MIT License](./LICENSE)
