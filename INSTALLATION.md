# Installation Guide

Complete step-by-step installation and setup guide for Task Manager Kanban Board.

## System Requirements

### Minimum Requirements
- **OS**: Windows 10+, macOS 10.14+, Linux (Ubuntu 16.04+)
- **RAM**: 4GB minimum (8GB recommended)
- **Disk Space**: 10GB free space
- **Internet**: Required for initial setup

### Flutter Requirements
- **Flutter SDK**: Version 3.10.7 or higher
- **Dart SDK**: Version 3.10.7 or higher (comes with Flutter)
- **Git**: For cloning repository

## Step 1: Install Flutter

### Windows
1. Download Flutter SDK from [flutter.dev](https://flutter.dev/docs/get-started/install/windows)
2. Extract to `C:\src\flutter` or desired location
3. Add Flutter to PATH:
   - Right-click "This PC" → Properties
   - Advanced system settings → Environment Variables
   - Add `C:\src\flutter\bin` to System PATH
4. Restart terminal

### macOS
```bash
brew install flutter
```

### Linux (Ubuntu)
```bash
sudo snap install flutter --classic
```

## Step 2: Install Android Studio / Xcode

### For Android Development
1. Download [Android Studio](https://developer.android.com/studio)
2. Install Android SDK (minimum API 21)
3. Set ANDROID_HOME environment variable

### For iOS Development (macOS only)
```bash
sudo xcode-select --switch /Applications/Xcode.app/xcode-select
sudo xcodebuild -runFirstLaunch
```

## Step 3: Verify Flutter Installation

```bash
flutter doctor
```

Should show:
- Flutter ✓
- Dart SDK ✓
- Android toolchain ✓ (for Android)
- Xcode ✓ (for iOS on macOS)
- Chrome ✓ (for web)

## Step 4: Clone Repository

```bash
git clone https://github.com/yourusername/flutter_jenoury.git
cd flutter_jenoury
```

## Step 5: Install Project Dependencies

```bash
flutter pub get
```

This downloads all required packages listed in pubspec.yaml.

## Step 6: Run Application

### Android Device/Emulator
```bash
flutter emulators --launch Pixel_4_API_30
flutter run
```

### iOS Simulator (macOS)
```bash
open -a Simulator
flutter run
```

### Physical Device
1. Enable Developer Mode on device
2. Connect via USB
3. Run: `flutter run`

### Web
```bash
flutter run -d chrome
```

## Step 7: Verify Installation

After running, you should see:
1. ✅ App loads on your device/emulator
2. ✅ Dashboard with 3 columns (To Do, In Progress, Done)
3. ✅ Sample tasks displayed
4. ✅ FAB button works for adding tasks

## Troubleshooting

### Issue: Flutter not found in PATH
**Solution**: Add Flutter bin to environment PATH and restart terminal

### Issue: Android SDK not found
**Solution**: 
```bash
flutter config --android-sdk-path=/path/to/android/sdk
```

### Issue: CocoaPods error (iOS)
**Solution**:
```bash
cd ios
rm -rf Pods Podfile.lock
cd ..
flutter pub get
flutter run
```

### Issue: Port already in use
**Solution**: Kill process or use different port:
```bash
flutter run --debug-port 12345
```

### Issue: Build cache issues
**Solution**: Clean and rebuild:
```bash
flutter clean
flutter pub get
flutter run
```

## Firebase Setup (Optional - Future Enhancement)

To enable Firebase features:

1. Create Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Configure Android:
   - Download `google-services.json`
   - Place in `android/app/`
3. Configure iOS:
   - Download `GoogleService-Info.plist`
   - Add to Xcode project

## VSCode Setup

1. Install Flutter extension
2. Install Dart extension
3. Open project in VSCode
4. Run: `flutter run`

## Android Studio Setup

1. Open project in Android Studio
2. Tools → Flutter → Flutter Doctor
3. Create emulator or connect device
4. Run → Run 'main.dart'

## Development Tips

### Hot Reload
Press 'r' in terminal while app is running to reload changes instantly.

### Hot Restart
Press 'R' for full app restart.

### Debug Mode
Default mode. Slower but has full debugging.

### Release Mode
```bash
flutter run --release
```

### Profile Mode
```bash
flutter run --profile
```

## Next Steps

1. Review project structure in README.md
2. Explore the code in `lib/` directory
3. Modify tasks in `lib/services/task_service.dart`
4. Run tests: `flutter test`

## Getting Help

- Official Docs: https://flutter.dev/docs
- Stack Overflow: Tag with 'flutter'
- GitHub Issues: Open in project repository
- Discord Community: Flutter Discord server

---

**Happy Coding! 🚀**
