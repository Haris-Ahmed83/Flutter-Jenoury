# FitTrack — Fitness Tracker App

A full-featured fitness tracking application built with Flutter that helps you stay on top of your health goals. Log workouts, count your steps using your device's accelerometer, and visualize your progress with beautiful, interactive graphs.

This isn't a demo or a mockup — it's a fully functional app that stores your data locally, tracks real movement through hardware sensors, and gives you meaningful insights into your fitness journey.

---

## What It Does

### Workout Logging
Create detailed workout entries with support for 10 different activity types — running, cycling, swimming, weight lifting, yoga, HIIT, walking, stretching, cardio, and more. Each workout captures duration, calories burned (auto-calculated using MET values and your body weight), distance, and optional notes. For strength training, you can log individual exercise sets with reps and weight.

### Step Counter
The app reads your device's accelerometer sensor in real-time using a peak-detection algorithm to count steps as you walk or run. It estimates distance based on your stride length and calculates calories burned relative to your body weight. You can also add steps manually if you forgot to track a walk.

### Progress Graphs
Track your trends over time with daily bar charts, weekly averages, and line graph trends. Three dedicated tabs break down your steps, workouts, and calorie burn so you can see where you're improving and where you might want to push harder.

### Offline-First Storage
All your data lives on your device in a local SQLite database. No account needed, no internet required, no data sent anywhere. Your fitness data stays private.

---

## Screenshots

| Home Dashboard | Step Counter | Progress Charts |
|:-:|:-:|:-:|
| Overview with today's steps, monthly stats, and recent workouts | Real-time step tracking with circular progress and weekly chart | Steps, workout, and calorie trends with bar and line charts |

| Log Workout | Workout History | Settings |
|:-:|:-:|:-:|
| Full workout entry form with type selection and exercise sets | Searchable history grouped by date | Customize step goal, body weight, and quick goal presets |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.38+ |
| Language | Dart 3.10+ |
| State Management | Provider |
| Local Database | SQLite via sqflite |
| Sensor Access | sensors_plus (accelerometer) |
| Architecture | Service-Repository pattern with ChangeNotifier |

---

## Project Structure

```
lib/
├── main.dart                  # App entry point and theme configuration
├── models/
│   ├── workout.dart           # Workout and ExerciseSet data models
│   ├── step_record.dart       # Daily step record model
│   └── weekly_summary.dart    # Aggregated weekly stats
├── database/
│   └── database_helper.dart   # SQLite database operations
├── services/
│   ├── step_counter_service.dart  # Accelerometer-based step detection
│   └── workout_service.dart       # Workout business logic & calorie estimation
├── providers/
│   ├── workout_provider.dart  # Workout state management
│   └── step_provider.dart     # Step counter state management
├── screens/
│   ├── home_screen.dart       # Main dashboard with bottom navigation
│   ├── step_counter_screen.dart   # Step tracking interface
│   ├── add_workout_screen.dart    # Workout creation/editing form
│   ├── workout_log_screen.dart    # Filterable workout list
│   ├── progress_screen.dart       # Charts and analytics (3 tabs)
│   ├── history_screen.dart        # Searchable workout history
│   └── settings_screen.dart       # User preferences
├── widgets/
│   ├── stat_card.dart         # Reusable stat display card
│   ├── circular_progress.dart # Custom circular progress indicator
│   ├── workout_card.dart      # Workout list item card
│   ├── bar_chart.dart         # Custom bar chart widget
│   └── line_chart.dart        # Custom line chart with bezier curves
└── utils/
    ├── constants.dart         # Colors, text styles, dimensions
    └── formatters.dart        # Number, date, and time formatting
```

---

## Getting Started

### Prerequisites
- Flutter SDK 3.10 or higher
- Android Studio (for Android) or Xcode (for iOS)
- A physical device is recommended for step counting (accelerometer needed)

### Installation

```bash
# Clone the repository
git clone https://github.com/Haris-Ahmed83/Flutter-Jenoury.git
cd Flutter-Jenoury/fitness_tracker

# Install dependencies
flutter pub get

# Run on a connected device
flutter run
```

### Running on Different Platforms

```bash
# Android (physical device or emulator)
flutter run -d android

# iOS (requires macOS and Xcode)
flutter run -d ios

# Windows desktop
flutter run -d windows

# Chrome (step sensor won't work, but UI is fully functional)
flutter run -d chrome
```

---

## How the Step Counter Works

The step detection uses the device's accelerometer rather than a dedicated pedometer API. Here's the approach:

1. **Acceleration sampling** — Reads accelerometer data at 50Hz (every 20ms)
2. **Magnitude calculation** — Computes the vector magnitude: `√(x² + y² + z²)`
3. **Peak detection** — Identifies steps when the magnitude crosses a threshold (12.0 m/s²) and then drops, indicating the impact of a footstep
4. **Debouncing** — Enforces a minimum 250ms gap between steps to filter noise

This approach works across Android and iOS without requiring any special permissions beyond sensor access.

---

## Calorie Calculation

Workout calories are estimated using the MET (Metabolic Equivalent of Task) method:

```
Calories = MET × Weight(kg) × Duration(hours)
```

Each workout type has a research-based MET value:
- Running: 9.8 | Cycling: 7.5 | Swimming: 8.0
- Weight Lifting: 6.0 | HIIT: 10.0 | Yoga: 3.0
- Walking: 3.5 | Cardio: 7.0

Step calories use a simplified model: `steps × 0.04 × (weight / 70)`

---

## Features at a Glance

- 10 workout types with auto-calorie estimation
- Real-time accelerometer step counting
- Manual step entry for missed tracking
- Exercise set logging (reps × weight) for strength workouts
- Daily, weekly, and monthly progress charts
- Custom bar and line chart widgets (no chart library dependency)
- Searchable workout history grouped by date
- Workout type filtering
- Configurable daily step goal with quick presets
- Body weight setting for accurate calorie math
- Clean, modern Material Design 3 UI
- Fully offline — all data stored locally in SQLite
- Zero third-party analytics or tracking

---

## License

This project is open source and available under the [MIT License](../LICENSE).
