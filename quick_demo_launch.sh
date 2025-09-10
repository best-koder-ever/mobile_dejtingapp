#!/bin/bash

# Quick Demo Launcher
echo "🎬 Starting Dating App Interactive Demo System"
echo "=============================================="

cd /home/m/development/mobile-apps/flutter/dejtingapp

# Check if demo services are running
if ! docker ps | grep -q "demo-auth"; then
    echo "❌ Demo services not running!"
    echo "Starting demo services..."
    cd /home/m/development/DatingApp
    docker-compose -f environments/demo/docker-compose.demo.yml up -d
    echo "✅ Demo services started"
    sleep 5
    cd /home/m/development/mobile-apps/flutter/dejtingapp
fi

echo "✅ Demo services are running"
echo "🚀 Launching interactive demo..."
echo ""

python3 automated_journey_demo.py
