# Task Manager - Professional Kanban Board

A modern, feature-rich task management application built with Flutter. This is a professional-grade Kanban board that allows teams to collaborate efficiently with drag-and-drop functionality, task prioritization, and team assignments.

## 🎯 Features

### Core Functionality
- **Kanban Board**: Three-column layout (To Do, In Progress, Done) for visual task management
- **Task Management**: Create, read, update, and delete tasks with ease
- **Task Status**: Drag and drop tasks between different status columns
- **Priority Levels**: Set tasks as Low, Medium, or High priority with visual indicators
- **Due Dates**: Assign due dates to tasks with date picker
- **Team Assignment**: Assign tasks to team members
- **Tags & Labels**: Organize tasks with custom tags
- **Progress Tracking**: Real-time progress visualization showing task completion percentage

### User Interface
- **Professional Design**: Modern Material Design 3 interface with intuitive navigation
- **Real-time Updates**: Instant UI updates when tasks are modified
- **Responsive Layout**: Optimized for different screen sizes
- **Visual Feedback**: Color-coded priority levels and status indicators

### Data Management
- **Local Storage**: In-memory data management with singleton pattern
- **Persistent State**: Maintains application state during session
- **Data Validation**: Input validation for all task fields
- **Serialization**: JSON-compatible data format for future backend integration

## 📁 Project Structure

```
lib/
├── main.dart                 # Application entry point
├── models/
│   ├── task_model.dart      # Task data model
│   └── user_model.dart      # User data model
├── screens/
│   ├── dashboard_screen.dart # Main Kanban board
│   ├── add_task_screen.dart  # Task creation/editing
│   └── task_detail_screen.dart # Task details
├── widgets/
│   ├── task_card.dart       # Task card widget
│   └── task_column.dart     # Kanban column
├── services/
│   └── task_service.dart    # Data management
├── providers/
│   └── task_provider.dart   # State management
└── utils/
    └── constants.dart       # App constants
```

## 🚀 Getting Started

### Prerequisites
- Flutter 3.10.7 or higher
- Dart SDK
- Git

### Installation

```bash
# Clone repository
git clone https://github.com/yourusername/flutter_jenoury.git
cd flutter_jenoury

# Install dependencies
flutter pub get

# Run application
flutter run
```

## 📦 Dependencies

- **provider**: ^6.0.0 - State management
- **firebase_core**: ^2.24.0 - Firebase setup (ready)
- **firebase_database**: ^10.0.0 - Real-time database (ready)
- **firebase_auth**: ^4.10.0 - Authentication (ready)
- **intl**: ^0.19.0 - Date formatting
- **uuid**: ^4.0.0 - Unique IDs
- **flutter_slidable**: ^3.0.0 - Swipe actions
- **smooth_page_indicator**: ^1.1.0 - Page indicators

## 💻 Usage

### Creating a Task
1. Click the "+" button or "Add Task"
2. Fill in task details (title, description required)
3. Set priority, due date, tags
4. Assign to team member
5. Save

### Managing Tasks
- **View Details**: Click task card
- **Change Status**: Use task menu (⋮)
- **Edit**: Click edit icon in detail screen
- **Delete**: Click delete icon
- **Progress**: Check overall completion in header

## 🎨 Customization

Edit `lib/utils/constants.dart` to customize:
- Colors and theme
- Text labels
- Spacing and dimensions

## 🔄 Architecture

- **Models**: Data structures with serialization
- **Services**: Business logic layer
- **Providers**: State management using Provider pattern
- **Screens**: UI screens
- **Widgets**: Reusable components

## 📝 License

MIT License - See LICENSE file

## 🚀 Future Enhancements

- Firebase Realtime Database integration
- User authentication
- Team collaboration
- Task comments
- File attachments
- Offline support
- Dark mode
- Multi-language support

## 🤝 Contributing

1. Fork repository
2. Create feature branch
3. Commit changes
4. Push and create Pull Request

## 📧 Support

Open an issue on GitHub for support and questions.

---

**Version**: 1.0.0  
**Created**: March 2026  
**Platform**: Flutter (Android, iOS, Web, Windows, macOS, Linux)
