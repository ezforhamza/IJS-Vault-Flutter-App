# 🚀 Quick Start - Flutter in VS Code

## First Time Setup (Do Once)

### 1. Install VS Code Flutter Extension

- Press `Cmd+Shift+X`
- Search "Flutter"
- Install "Flutter" extension

### 2. Get Dependencies

```bash
flutter pub get
```

### 3. Connect Your Phone

**Android:**

- Settings → About → Tap "Build Number" 7 times
- Settings → Developer Options → USB Debugging ON
- Connect USB cable

**iOS:**

- Connect USB cable
- Trust computer on iPhone

---

## Running Your App (Every Day)

### Option 1: VS Code (Recommended)

1. Open this folder in VS Code
2. Connect phone via USB
3. Press `F5` (or click Run → Start Debugging)
4. Wait for app to launch on your phone

### Option 2: Terminal

```bash
flutter run
```

---

## Making Changes & Seeing Them Live

1. **Edit any file** in `lib/` folder
2. **Save** (`Cmd+S`)
3. **Changes appear instantly** on your phone! 🎉

### Hot Reload Controls:

- `r` in terminal = Reload UI
- `R` in terminal = Restart app
- `q` in terminal = Quit

---

## Common Commands

```bash
# Check everything is working
flutter doctor

# Get packages after pulling code
flutter pub get

# Fix build issues
flutter clean && flutter pub get

# See connected devices
flutter devices
```

---

## Your Project Structure

```
lib/
├── main.dart              ← App starts here
├── features/
│   ├── my vault/          ← Vault feature
│   ├── reminders/         ← Reminders
│   ├── linked_users/      ← Linked users
│   ├── settings/          ← Settings
│   └── splash/            ← Splash screen
└── core/
    ├── controllers/       ← Global state
    ├── themes/            ← Colors & styles
    └── widgets/           ← Reusable UI
```

---

## 💡 Pro Tips

- **Save often** - Each save triggers hot reload
- **Check Debug Console** in VS Code for errors
- **Use `print()`** statements to debug
- **Restart app** if hot reload doesn't work (press `R`)

---

## Need Help?

Check `SETUP_GUIDE.md` for detailed instructions.

**You're ready to code!** 🎯
