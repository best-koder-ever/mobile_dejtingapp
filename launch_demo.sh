#!/bin/bash

# Launch Flutter app in DEMO mode
# This connects to your demo backend (localhost:5001, 5002, 5003)

echo "🎬 Starting Dating App in DEMO mode..."
echo "Connecting to demo backend:"
echo "  - AuthService: http://localhost:5001" 
echo "  - UserService: http://localhost:5002"
echo "  - MatchmakingService: http://localhost:5003"
echo ""
echo "Make sure your demo environment is running:"
echo "cd /home/m/development/DatingApp && docker-compose -f environments/demo/docker-compose.simple.yml up"
echo ""

cd "$(dirname "$0")"

# Check if demo backend is running
if ! curl -s http://localhost:5001/health > /dev/null 2>&1; then
    echo "⚠️  Warning: Demo backend might not be running!"
    echo "Start it with: cd /home/m/development/DatingApp && docker-compose -f environments/demo/docker-compose.simple.yml up"
    echo ""
fi

# Launch Flutter app with demo configuration
flutter run -t lib/main_demo.dart
