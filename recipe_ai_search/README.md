# Recipe AI Search

A professional Flutter application that helps users discover delicious recipes by searching with ingredients they have on hand. Powered by AI, this app provides comprehensive nutritional information, detailed cooking instructions, and favorites synchronization.

## Features

✨ **AI-Powered Recipe Search**
- Search recipes by ingredients using advanced AI
- Filter by cuisine, meal type, and dietary restrictions
- Get personalized recipe recommendations

📊 **Detailed Recipe Information**
- Step-by-step cooking instructions
- Nutritional information per serving (calories, protein, carbs, fat, fiber, sodium)
- Prep time and cooking time estimates
- Servings information
- User ratings and reviews

❤️ **Favorites Management**
- Save your favorite recipes locally
- Access saved recipes instantly
- Sync favorites across sessions

🎨 **Beautiful User Interface**
- Modern, intuitive design
- Smooth animations and transitions
- Dark and light theme support
- Responsive layout for all screen sizes

## Tech Stack

- **Flutter 3.10+** - Cross-platform mobile framework
- **Provider** - State management
- **Google Generative AI** - AI-powered recipe recommendations
- **Shared Preferences** - Local data persistence
- **HTTP/DIO** - Network requests
- **Google Fonts** - Typography

## Project Structure

```
recipe_ai_search/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/
│   │   └── recipe_model.dart    # Recipe and NutritionInfo models
│   ├── views/
│   │   └── home_screen.dart     # Main app screen
│   ├── controllers/
│   │   ├── recipe_controller.dart       # Recipe search logic
│   │   └── favorites_controller.dart    # Favorites management
│   ├── services/
│   │   └── ai_service.dart      # AI recipe search service
│   ├── widgets/
│   │   ├── search_widget.dart          # Search interface
│   │   ├── recipe_card.dart            # Recipe display card
│   │   └── recipe_detail_sheet.dart    # Recipe details view
│   ├── constants/
│   │   └── theme_constants.dart # Design system & colors
│   └── utils/
├── pubspec.yaml                  # Dependencies
└── README.md                      # Documentation
```

## Getting Started

### Prerequisites

- Flutter SDK 3.10.0 or higher
- Dart 3.0.0 or higher
- Android Studio / Xcode (for mobile development)
- Google API Key (for AI features)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/recipe-ai-search.git
   cd recipe_ai_search
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up your Google API Key**
   - Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Create a new API key
   - Replace `YOUR_GOOGLE_API_KEY_HERE` in `lib/services/ai_service.dart`

4. **Run the app**
   ```bash
   flutter run
   ```

## Usage

### Search for Recipes

1. Open the app and navigate to the **Discover** tab
2. Add ingredients using the input field (press Enter or tap the add button)
3. Optionally filter by:
   - **Cuisine** (Italian, Asian, Mexican, Indian, Mediterranean, American)
   - **Meal Type** (Breakfast, Lunch, Dinner, Snack)
   - **Dietary Preference** (Vegetarian, Vegan, Gluten-Free, Keto, Paleo)
4. Tap **Search Recipes** to get AI-powered recommendations

### View Recipe Details

1. Tap on any recipe card to open the full recipe details
2. View:
   - Complete ingredient list
   - Step-by-step instructions
   - Nutritional information
   - Ratings and reviews

### Save Favorites

1. Tap the heart icon on any recipe card or in the details view
2. Access your saved recipes in the **Favorites** tab
3. Saved recipes persist across app sessions

## Features in Detail

### AI-Powered Search
The app uses Google's Generative AI to understand your ingredients and generate creative recipe suggestions. Results include:
- Relevant recipes that use your ingredients
- Diverse cuisine options
- Dietary accommodation options

### Nutritional Information
Every recipe includes detailed nutritional data:
- Calories per serving
- Macronutrients (protein, carbs, fat)
- Fiber and sodium content
- Vitamin information (where available)

### Local Persistence
Favorites are stored locally using `shared_preferences`, ensuring:
- Instant access to saved recipes
- No internet required for viewing favorites
- Data persists between app sessions

## Configuration

### Theme Customization

Edit `lib/constants/theme_constants.dart` to customize:
- Color palette
- Typography
- Spacing and radius
- Shadow effects
- Animation durations

### API Configuration

Update the API key in `lib/services/ai_service.dart`:

```dart
static const String _apiKey = 'YOUR_GOOGLE_API_KEY_HERE';
```

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| provider | ^6.1.0 | State management |
| http | ^1.1.0 | HTTP requests |
| dio | ^5.4.0 | Advanced HTTP client |
| hive | ^2.2.3 | Local database |
| shared_preferences | ^2.2.2 | Simple key-value storage |
| google_fonts | ^6.2.0 | Google Fonts integration |
| flutter_rating_bar | ^4.0.1 | Rating display |
| shimmer | ^3.0.0 | Loading shimmer effect |
| google_generative_ai | ^0.4.7 | AI recipe recommendations |
| intl | ^0.19.0 | Internationalization |
| uuid | ^4.0.0 | Unique ID generation |
| connectivity_plus | ^5.0.2 | Network connectivity |
| lottie | ^3.0.0 | Animations |

## Architecture

This app follows **MVVM (Model-View-ViewModel)** pattern:

- **Models** - Data structures representing recipes and nutrition info
- **Views** - UI screens and widgets
- **Controllers** - Business logic and state management using Provider

## Code Quality

- Clean, modular code structure
- Comprehensive error handling
- Type-safe Dart implementation
- Following Flutter best practices

## Performance Optimizations

- Lazy loading of recipe lists
- Efficient state management with Provider
- Cached AI responses
- Optimized widget rebuilds
- Local storage for offline access

## Future Enhancements

- [ ] Multi-language support
- [ ] Advanced filtering (allergies, macros)
- [ ] Recipe sharing functionality
- [ ] Meal planning features
- [ ] Shopping list generation
- [ ] User authentication and cloud sync
- [ ] Offline recipe database

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For issues, questions, or suggestions, please open an issue on GitHub or contact the maintainers.

---

**Built with ❤️ using Flutter and AI**
