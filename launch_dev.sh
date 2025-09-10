#!/bin/bash

# Launch Flutter app in DEVELOPMENT mode  
# This connects to your development backend (localhost:8081, 8082, 8083)

echo "🔧 Starting Dating App in DEVELOPMENT mode..."
echo "Connecting to development backend:"
echo "  - AuthService: http://localhost:8081"
echo "  - UserService: http://localhost:8082" 
echo "  - MatchmakingService: http://localhost:8083"
echo ""
echo "Make sure your development environment is running:"
echo "cd /home/m/development/DatingApp && docker-compose up"
echo ""

cd "$(dirname "$0")"

# Check if development backend is running
if ! curl -s http://localhost:8081/health > /dev/null 2>&1; then
    echo "⚠️  Warning: Development backend might not be running!"
    echo "Start it with: cd /home/m/development/DatingApp && docker-compose up"
    echo ""
fi

# Launch Flutter app with development configuration
flutter run -t lib/main_dev.dart
