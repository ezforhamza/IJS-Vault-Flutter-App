# Flutter Development Setup Guide for VS Code

## ✅ Your Project Overview

- **Project Name**: IJS Vault
- **Framework**: Flutter with GetX state management
- **Features**: Firebase integration, file management, reminders, linked users
- **Current Status**: Half completed by team member in Android Studio

---

## 🚀 Complete Setup Instructions

### 1. Install Flutter SDK (In Progress)

The Flutter SDK is currently being installed via Homebrew. Once complete, verify with:

```bash
flutter --version
flutter doctor
```

### 2. Install VS Code Extensions (REQUIRED)

Open VS Code and install these essential extensions:

1. **Flutter** (by Dart Code)

   - Search: "Flutter" in Extensions (Cmd+Shift+X)
   - This includes Dart language support

2. **Dart** (by Dart Code)
   - Usually installed automatically with Flutter extension

**How to install:**

- Press `Cmd+Shift+X` to open Extensions
- Search for "Flutter"
- Click "Install" on the Flutter extension

### 3. Get Project Dependencies

After Flutter is installed, run:

```bash
cd /Users/hamza/Desktop/IJS-Vault-Flutter-App
flutter pub get
```

This downloads all packages listed in `pubspec.yaml`.

### 4. Setup Your Mobile Device

#### For iOS (iPhone):

1. Connect your iPhone via USB
2. Trust the computer on your iPhone
3. In VS Code, you'll see your device in the bottom-right status bar

#### For Android:

1. Enable **Developer Options** on your phone:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
2. Enable **USB Debugging**:
   - Settings → Developer Options → USB Debugging (ON)
3. Connect via USB and allow debugging when prompted

### 5. Configure Firebase (Already Setup)

Your project already has Firebase configured in `main.dart`. You may need:

- `google-services.json` for Android (in `android/app/`)
- `GoogleService-Info.plist` for iOS (in `ios/Runner/`)

Ask your team member for these files if missing.

---

## 🔥 Running the App with Live Reload

### Method 1: Using VS Code UI (Easiest)

1. Connect your mobile device
2. Open VS Code
3. Click the device name in the bottom-right corner
4. Select your connected device
5. Press `F5` or click "Run" → "Start Debugging"

### Method 2: Using Terminal

```bash
# List available devices
flutter devices

# Run on connected device
flutter run

# Run with specific device
flutter run -d <device-id>
```

### 🎯 Hot Reload Features

Once the app is running:

- **Hot Reload**: Press `r` in terminal or `Cmd+S` (save file) - Updates UI instantly
- **Hot Restart**: Press `R` in terminal - Full app restart
- **Quit**: Press `q` in terminal

**VS Code Shortcuts:**

- `Cmd+S` - Save & Hot Reload
- `Cmd+Shift+F5` - Hot Restart
- `Shift+F5` - Stop Debugging

---

## 📱 Live Development Workflow

### Your Daily Workflow:

1. **Open Project**: Open this folder in VS Code
2. **Connect Device**: Plug in your phone via USB
3. **Start App**: Press `F5` or run `flutter run`
4. **Make Changes**: Edit any `.dart` file in `lib/`
5. **See Changes Live**: Save file (`Cmd+S`) - changes appear instantly on your phone!

### Key Directories:

- `lib/` - All your Dart code
  - `lib/main.dart` - App entry point
  - `lib/features/` - Feature modules (vault, reminders, settings, etc.)
  - `lib/core/` - Shared code (themes, widgets, controllers)
- `assets/` - Images, fonts, SVGs
- `android/` & `ios/` - Platform-specific code

---

## 🛠️ Useful Commands

```bash
# Check Flutter installation
flutter doctor

# Get dependencies
flutter pub get

# Clean build files (if issues occur)
flutter clean
flutter pub get

# List connected devices
flutter devices

# Run app
flutter run

# Build APK for Android
flutter build apk

# Build for iOS
flutter build ios
```

---

## 🐛 Troubleshooting

### "No devices found"

- Ensure USB debugging is enabled (Android)
- Trust computer on iPhone (iOS)
- Try different USB cable/port
- Run: `flutter devices`

### "Build failed"

```bash
flutter clean
flutter pub get
flutter run
```

### "Package not found"

```bash
flutter pub get
```

### VS Code doesn't detect Flutter

- Restart VS Code after installing Flutter
- Check Flutter extension is installed
- Run: `flutter doctor` to verify installation

---

## 📚 Project Structure

```
lib/
├── main.dart                          # App entry point
├── core/
│   ├── controllers/                   # Global controllers
│   ├── themes/                        # App themes
│   └── widgets/                       # Reusable widgets
└── features/
    ├── splash/                        # Splash screen
    ├── my vault/                      # Vault feature
    ├── reminders/                     # Reminders feature
    ├── linked_users/                  # Linked users feature
    └── settings/                      # Settings feature
```

---

## 💡 Tips for Flutter Development

1. **Hot Reload is Your Friend**: Save files frequently to see instant changes
2. **Use GetX**: Your project uses GetX for state management - controllers are in `controllers/` folders
3. **Check Console**: VS Code Debug Console shows errors and print statements
4. **Widget Inspector**: Use Flutter DevTools to inspect UI (opens in browser)
5. **Format Code**: Press `Shift+Option+F` to auto-format Dart code

---

## 🎯 Next Steps

1. ✅ Wait for Flutter installation to complete
2. ✅ Install VS Code Flutter extension
3. ✅ Run `flutter pub get`
4. ✅ Connect your mobile device
5. ✅ Press `F5` to run the app
6. ✅ Start coding - changes will appear live on your phone!

---

## 📞 Need Help?

- Flutter Docs: https://docs.flutter.dev
- GetX Docs: https://pub.dev/packages/get
- Your team member's Android Studio project works the same way in VS Code!

**You're all set! VS Code is perfect for Flutter development.** 🚀
