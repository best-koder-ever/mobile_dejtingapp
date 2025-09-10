# 🎬 Interactive Journey Demo System

## Overview

This system provides an interactive menu-driven demonstration of the complete Dating App user journeys with real-time backend API calls and Flutter app automation.

## What's Included

### 🏗️ Demo Architecture

- **Demo Services**: Running on ports 5001-5003
  - Auth Service: `http://localhost:5001`
  - User Service: `http://localhost:5002`
  - Matchmaking Service: `http://localhost:5003`
- **Demo Database**: Single MySQL container with separate demo databases
  - `auth_service_demo` - User authentication and profiles
  - `user_service_demo` - User profile management
  - `matchmaking_service_demo` - Matching and swiping data
- **Flutter App**: Linux desktop version with demo environment active

### 🎯 Available Journeys

1. **🆕 New User Journey**

   - Backend: Creates new user via API
   - Flutter: Demonstrates registration form automation
   - Shows: Registration → JWT token → Profile setup

2. **👤 Existing User Journey**

   - Backend: Authenticates demo user (Alice)
   - Flutter: Demonstrates login automation
   - Shows: Login → Profile load → Match browsing

3. **💕 Matching Journey**

   - Backend: Two users (Alice & Bob) swipe on each other
   - Flutter: Demonstrates swiping interface automation
   - Shows: Mutual likes → Match creation → Chat access

4. **🎯 Complete User Flow**

   - Runs all journeys in sequence
   - Full end-to-end demonstration

5. **🎮 Interactive Mode**
   - Step-by-step with user prompts
   - You control the pace
   - Great for live presentations

### 📊 Data & Database Views

6. **📊 Show Demo Users & Database**

   - Lists all demo users and credentials
   - Shows backend service endpoints
   - Displays database connection info
   - Shows automation tool status

7. **🗄️ Database Deep Dive**
   - Lists all databases in MySQL container
   - Shows user counts in each demo database
   - Displays sample user data with verification status
   - Table counts for each service database

## Quick Start

### Option 1: Quick Launcher

```bash
cd /home/m/development/mobile-apps/flutter/dejtingapp
./quick_demo_launch.sh
```

### Option 2: Manual Start

```bash
cd /home/m/development/mobile-apps/flutter/dejtingapp
python3 automated_journey_demo.py
```

## Demo Users

- **Alice**: demo.alice@example.com / Demo123!
- **Bob**: demo.bob@example.com / Demo123!
- **Charlie**: demo.charlie@example.com / Demo123!

## Real-Time Features

### Backend API Calls

- All API calls are shown in the terminal with:
  - Timestamp
  - Service being called
  - Response status and data
  - JWT tokens (truncated for security)
  - Match creation events

### Flutter App Automation

- Uses `xdotool` and `wmctrl` for Linux automation
- Automatically fills forms
- Simulates user interactions
- Shows visual feedback in the app

### Database Verification

- Direct MySQL queries to show data persistence
- User creation confirmation
- Match relationship verification
- Real-time data updates

## Technical Details

### Prerequisites

- Docker containers running demo services
- Flutter SDK for Linux desktop apps
- xdotool and wmctrl for app automation
- Python 3 with requests library

### Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Demo Script   │    │  Flutter App    │    │ Backend APIs    │
│  (Terminal UI)  │────│ (Linux Desktop) │────│  (Ports 5001-3) │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                                             │
         └─────────────────────────────────────────────┘
                            │
                   ┌─────────────────┐
                   │  MySQL Demo DB  │
                   │   (Port 3320)   │
                   └─────────────────┘
```

### Demo Flow

1. **Menu Selection**: Choose journey type
2. **Backend Setup**: Authenticate users, prepare data
3. **Flutter Launch**: Start and focus desktop app
4. **Automation**: Send keyboard/mouse events to app
5. **Verification**: Query database to confirm changes
6. **Reporting**: Show results in terminal

## Troubleshooting

### Demo Services Not Running

```bash
cd /home/m/development/DatingApp
docker-compose -f environments/demo/docker-compose.demo.yml up -d
```

### Flutter App Won't Start

```bash
cd /home/m/development/mobile-apps/flutter/dejtingapp
flutter clean
flutter pub get
flutter run -d linux -t lib/main_demo.dart
```

### Automation Tools Missing

```bash
sudo apt-get install xdotool wmctrl
```

### Database Connection Issues

```bash
docker exec demo-mysql mysql -uroot -pdemo_root_password -e "SHOW DATABASES;"
```

## Use Cases

### 🎯 Investor Presentations

- Run "Complete User Flow" for full demonstration
- Use "Interactive Mode" to explain each step
- Show "Database Deep Dive" to prove data persistence

### 🔧 Development Testing

- Test individual journeys during development
- Verify API endpoints are working
- Check database schema and data

### 📚 Training & Documentation

- Step through each user journey
- Show how backend and frontend interact
- Demonstrate real data flow

### 🐛 Bug Reproduction

- Automate specific user actions that cause issues
- Capture backend responses during problems
- Verify database state before/after operations

## Next Steps

1. **Extend Journeys**: Add messaging, photo upload, profile editing flows
2. **Mobile Support**: Add Android emulator automation
3. **Performance Testing**: Add timing measurements and load testing
4. **Error Scenarios**: Add demonstrations of error handling
5. **CI Integration**: Run automated tests in GitHub Actions

---

🎬 **Ready to demonstrate your Dating App MVP with confidence!**
