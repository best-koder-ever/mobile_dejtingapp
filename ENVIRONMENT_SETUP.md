# 🔧 Environment Configuration System

This Flutter app now supports multiple environments to make development and testing much easier!

## 🎯 Available Environments

### 1. 🎬 **DEMO Environment** (Recommended for Testing)

- **Purpose**: Stable demo with realistic data
- **Backend Ports**: 5001, 5002, 5003
- **Data**: Pre-populated with Alice, Bob, Charlie users
- **Best for**: Showing the app to others, testing complete user journeys

### 2. 🔧 **DEVELOPMENT Environment**

- **Purpose**: Active development and debugging
- **Backend Ports**: 8081, 8082, 8083
- **Data**: Your working development data
- **Best for**: Code development, testing new features

### 3. 🚀 **PRODUCTION Environment** (Future)

- **Purpose**: Live app (not implemented yet)
- **Backend**: Cloud URLs
- **Best for**: Real users (when ready)

## 🚀 Quick Start Options

### Option 1: Use Launch Scripts (Easiest)

```bash
# Launch in demo mode (connects to demo backend)
./launch_demo.sh

# Launch in development mode (connects to dev backend)
./launch_dev.sh
```

### Option 2: Use Environment Selector in App

1. Start the app: `flutter run`
2. On the login screen, use the Environment Selector widget
3. Switch between Demo/Development with one tap
4. App automatically connects to the right backend

### Option 3: Manual Flutter Commands

```bash
# Demo mode
flutter run -t lib/main_demo.dart

# Development mode
flutter run -t lib/main_dev.dart

# Default mode (currently demo)
flutter run
```

## 🔄 Easy Environment Switching

### In-App Switching (Debug Mode Only)

- The login screen shows an Environment Selector widget
- Tap "Demo" or "Development" to switch instantly
- The app shows which environment you're using

### Visual Environment Indicators

- **Demo**: Orange theme, shows "DEMO" badge
- **Development**: Blue theme, shows "DEVELOPMENT" badge
- **Production**: Red theme (future)

## 🛠️ Backend Requirements

### For Demo Environment:

```bash
cd /home/m/development/DatingApp
docker-compose -f environments/demo/docker-compose.simple.yml up
```

**Services running on**: localhost:5001, 5002, 5003

### For Development Environment:

```bash
cd /home/m/development/DatingApp
docker-compose up
```

**Services running on**: localhost:8081, 8082, 8083

## 💡 Benefits

### ✅ **No More Manual URL Changes**

- Switch environments without touching code
- No more forgetting to change URLs back

### ✅ **Clear Visual Feedback**

- Always know which environment you're using
- Different colors for different modes

### ✅ **MVP Validation Ready**

- Demo mode perfect for showing stakeholders
- Development mode perfect for coding

### ✅ **Future-Proof**

- Production environment ready when needed
- Easy to add new environments

## 🎯 Recommended Workflow

1. **Daily Development**: Use `./launch_dev.sh`
2. **Testing Features**: Use `./launch_demo.sh`
3. **Showing Others**: Use `./launch_demo.sh`
4. **Quick Tests**: Use environment selector in app

## 🔍 Troubleshooting

### "Connection Failed" Errors

1. Check which environment you're using (look at app theme color)
2. Verify the corresponding backend is running:
   - Demo: `docker-compose -f environments/demo/docker-compose.simple.yml ps`
   - Dev: `docker-compose ps`
3. Use the environment selector to switch if needed

### Backend Not Responding

```bash
# Check demo backend
curl http://localhost:5001/health

# Check development backend
curl http://localhost:8081/health
```

## 📱 Next Steps

With this system in place, you can now:

1. **Test complete user journeys** using demo environment
2. **Develop new features** using development environment
3. **Show the app to others** confidently using demo mode
4. **Switch environments instantly** without code changes

Perfect for your MVP validation phase! 🚀
