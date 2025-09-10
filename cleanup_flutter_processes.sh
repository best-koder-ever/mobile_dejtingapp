#!/bin/bash

echo "🧹 Cleaning up Flutter processes..."

# Kill all Flutter-related processes
pkill -f flutter
pkill -f dejtingapp  
pkill -f main_demo

# Wait a moment for processes to terminate
sleep 2

# Check if any processes are still running
FLUTTER_PROCS=$(pgrep -f flutter | wc -l)
DEJTINGAPP_PROCS=$(pgrep -f dejtingapp | wc -l) 
DEMO_PROCS=$(pgrep -f main_demo | wc -l)

if [ $FLUTTER_PROCS -eq 0 ] && [ $DEJTINGAPP_PROCS -eq 0 ] && [ $DEMO_PROCS -eq 0 ]; then
    echo "✅ All Flutter processes cleaned up successfully!"
else
    echo "⚠️  Some processes may still be running:"
    echo "   Flutter processes: $FLUTTER_PROCS"
    echo "   DejTingApp processes: $DEJTINGAPP_PROCS"
    echo "   Demo processes: $DEMO_PROCS"
    
    if [ $FLUTTER_PROCS -gt 0 ] || [ $DEJTINGAPP_PROCS -gt 0 ] || [ $DEMO_PROCS -gt 0 ]; then
        echo ""
        echo "🔥 Force killing remaining processes..."
        pkill -9 -f flutter
        pkill -9 -f dejtingapp
        pkill -9 -f main_demo
        sleep 1
        echo "✅ Force cleanup complete!"
    fi
fi

echo ""
echo "🎬 Flutter demo system is ready for clean start!"
