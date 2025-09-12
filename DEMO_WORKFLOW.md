# 🚀 Flutter Dating App Demo Workflow

## Quick Start Guide

### 1. Start Backend Services (Demo Mode)

```bash
cd /home/m/development/DatingApp
DEMO_MODE=true docker-compose up -d auth-service user-service matchmaking-service
```

### 2. Populate Demo Data

```bash
cd /home/m/development/mobile-apps/flutter/dejtingapp
python3 smart_demo_seeder_fixed.py
```

### 3. Start Flutter App

```bash
cd /home/m/development/mobile-apps/flutter/dejtingapp
flutter run
```

## 📊 What Demo Data You Get

### Users Available for Testing:

1. **Erik Astrom** (erik_astrom) - 28, Stockholm, Software Engineer
2. **Anna Lindberg** (anna_lindberg) - 25, Göteborg, Photographer
3. **Oskar Kallstrom** (oskar_kallstrom) - 32, Malmö, Chef
4. **Sara Blomqvist** (sara_blomqvist) - 29, Uppsala, Veterinarian
5. **Magnus Ohman** (magnus_ohman) - 35, Linköping, History Teacher

### Pre-created Matches:

- Erik ↔ Anna
- Anna ↔ Oskar
- Oskar ↔ Sara

## 🔌 API Endpoints Your Flutter App Can Use

### Authentication (Port 8081)

- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login existing user
- All demo users have password: `Demo123!`

### User Profiles (Port 8082)

- `POST /api/userprofiles/search` - Search profiles
- `GET /api/userprofiles/{id}` - Get specific profile
- `PUT /api/userprofiles/{id}` - Update profile

### Matchmaking (Port 8083)

- `POST /api/matchmaking/find-matches` - Get match suggestions
- `GET /api/matchmaking/matches/{userId}` - Get user's matches
- `POST /api/matchmaking/matches` - Create mutual match

## 🧪 Testing Scenarios

### Login Flow

1. Use any demo username (e.g., `erik_astrom`)
2. Password: `Demo123!`
3. Get JWT token for API calls

### Profile Browsing

1. Login as any user
2. Call search API to see other profiles
3. Test swiping/matching logic

### Match Discovery

1. Login as Erik (`erik_astrom`)
2. Check matches - should see Anna
3. Test match suggestions API

## 🔄 Reset Demo Data

```bash
# Clear all data and start fresh
docker-compose restart auth-service user-service matchmaking-service
python3 smart_demo_seeder_fixed.py
```

## 🐛 Troubleshooting

### Services Not Responding

```bash
# Check service status
docker-compose ps
docker logs datingapp_auth-service_1
```

### Demo Data Missing

```bash
# Re-run seeder
python3 smart_demo_seeder_fixed.py
```

### Port Conflicts

```bash
# Stop all services first
docker-compose down
# Then restart with demo mode
DEMO_MODE=true docker-compose up -d auth-service user-service matchmaking-service
```
