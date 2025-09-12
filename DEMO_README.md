# 🚀 Dating App Demo Mode

A practical demo system that automatically seeds your backend and provides a seamless testing experience.

## ✨ Features

- **🎯 One-Command Demo**: Start backend + seed data + launch app
- **🔄 Auto-Login**: Automatically logs in with demo users
- **🇸🇪 Realistic Data**: 5 Swedish dating profiles with authentic details
- **📱 Live Integration**: Real API calls to your actual backend services
- **🧪 In-Memory DB**: Clean slate every restart, no data pollution

## 🎬 Quick Start

### Option 1: Automated Demo Script (Recommended)

```bash
cd /home/m/development/mobile-apps/flutter/dejtingapp
./start_demo.sh
```

This will:

1. Start backend services with in-memory databases
2. Seed realistic demo data
3. Launch Flutter app in demo mode
4. Auto-login with demo users

### Option 2: Manual Step-by-Step

```bash
# 1. Start backend services
cd /home/m/development/DatingApp
DEMO_MODE=true docker-compose up -d auth-service user-service matchmaking-service

# 2. Seed demo data
cd /home/m/development/mobile-apps/flutter/dejtingapp
python3 smart_demo_seeder_fixed.py

# 3. Test Flutter integration
dart test_demo_connection.dart

# 4. Run Flutter app
flutter run lib/simple_demo_test.dart
```

### Option 3: Test Integration Only

```bash
cd /home/m/development/mobile-apps/flutter/dejtingapp
flutter run lib/simple_demo_test.dart
```

## 👥 Demo Users

All users have password: `Demo123!`

| Name            | Email                    | Description                                                  |
| --------------- | ------------------------ | ------------------------------------------------------------ |
| Erik Astrom     | erik.astrom@demo.com     | 28 år, Stockholm - Mjukvaruingenjör som älskar vandring      |
| Anna Lindberg   | anna.lindberg@demo.com   | 25 år, Göteborg - Fotograf med passion för resor             |
| Oskar Kallstrom | oskar.kallstrom@demo.com | 32 år, Malmö - Kock som älskar nordiska ingredienser         |
| Sara Blomqvist  | sara.blomqvist@demo.com  | 29 år, Uppsala - Veterinär som bryr sig om djur              |
| Magnus Ohman    | magnus.ohman@demo.com    | 35 år, Linköping - Historielärare fascinerad av vikingatiden |

## 🔧 Integration Files

### Core Demo System

- `lib/services/demo_service.dart` - Main demo service with API calls
- `lib/demo_startup_screen.dart` - User selection and initialization UI
- `lib/demo_app.dart` - Complete demo app with swiping interface
- `lib/simple_demo_test.dart` - Simple test to verify integration

### Helper Scripts

- `smart_demo_seeder_fixed.py` - Backend data seeder
- `test_demo_connection.dart` - API connection test
- `start_demo.sh` - One-command demo launcher

## 🎯 How to Integrate into Your App

### Option A: Use Demo Service Directly

```dart
import 'services/demo_service.dart';

// Check if demo mode
if (DemoService.isDemoMode) {
  // Initialize demo environment
  final result = await DemoService.initializeDemoEnvironment();

  if (result.success) {
    // Use result.token for API calls
    final profiles = await DemoService.getDemoProfiles(result.token!);
  }
}
```

### Option B: Replace Your Main App

Update your `lib/main.dart`:

```dart
import 'demo_app.dart';
import 'services/demo_service.dart';

Widget _getInitialScreen() {
  if (DemoService.isDemoMode) {
    return const DemoApp();  // Use demo app
  }
  // Your regular app logic
  return const YourRegularApp();
}
```

### Option C: Demo Mode Toggle

Add a demo mode toggle to your existing app:

```dart
// In your login screen
if (DemoService.isDemoMode) {
  ElevatedButton(
    onPressed: () => _startDemo(),
    child: Text('Start Demo Mode'),
  );
}
```

## 🎪 Demo Features

### In the Demo App You Can:

- ✅ **Browse Profiles**: Swipe through realistic Swedish dating profiles
- ✅ **See Matches**: View existing matches with compatibility scores
- ✅ **Switch Users**: Login as different demo users to test various scenarios
- ✅ **Real APIs**: All data comes from your actual backend services
- ✅ **Auto-Seeding**: Fresh demo data every time you restart

### Demo UI Features:

- 🧡 **Demo Banner**: Visual indicator when in demo mode
- 👥 **User Switcher**: Easy switching between demo accounts
- 📊 **Live Stats**: Shows loaded profiles, matches, API responses
- 🔄 **Auto-Refresh**: Seamless data loading and updates

## 🛠️ Technical Details

### Backend Integration

- Uses real API endpoints (localhost:8081-8083)
- In-memory databases (no data persistence)
- JWT authentication with real tokens
- All CRUD operations work normally

### Flutter Integration

- HTTP client for API calls
- Proper error handling and loading states
- Material Design with pink theme
- Responsive UI for different screen sizes

### Demo Data

- 5 realistic Swedish users with Swedish names/locations
- Authentic bios and interests in Swedish
- Age range 25-35, various professions
- Pre-configured mutual matches for testing

## 🔧 Customization

### Change Demo Users

Edit `lib/services/demo_service.dart`:

```dart
static const List<Map<String, String>> demoUsers = [
  // Add your custom demo users here
];
```

### Modify Demo Behavior

Edit `smart_demo_seeder_fixed.py`:

```python
demo_users = [
    # Customize the seeded users
]
```

### Control Demo Mode

Demo mode is enabled when `kDebugMode` is true. You can customize this in `demo_service.dart`:

```dart
static bool get isDemoMode {
  return kDebugMode; // or your custom logic
}
```

## 🎉 What This Gives You

1. **🚀 Instant Demo**: Start app → Demo ready in ~30 seconds
2. **🎯 Real Testing**: Test with actual API responses and realistic data
3. **👥 Multiple Users**: Switch between different user perspectives
4. **🔄 Clean Restarts**: Fresh data every time, no cleanup needed
5. **📱 Full App Flow**: Login → Browse → Match → Profile management
6. **🇸🇪 Authentic Feel**: Swedish users make it feel like a real dating app

Perfect for **demos**, **testing**, **development**, and **showing off your app**! 🎪✨
