#!/usr/bin/env python3
"""
Simple Flutter App Test - just start app and show it's working
"""

import subprocess
import time
import os

def test_flutter_automation():
    """Test basic Flutter app startup and window detection"""
    print("🧪 Testing Flutter App & Automation...")
    
    # Change to Flutter directory
    flutter_dir = "/home/m/development/mobile-apps/flutter/dejtingapp"
    os.chdir(flutter_dir)
    
    # Start Flutter app
    print("🚀 Starting Flutter app...")
    flutter_process = subprocess.Popen(
        ["flutter", "run", "-d", "linux", "-t", "lib/main_demo.dart"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    
    # Wait for app to build and start
    print("⏳ Waiting for app to build and start...")
    time.sleep(12)
    
    # Check windows
    print("🔍 Checking for app window...")
    try:
        result = subprocess.run(["wmctrl", "-l"], capture_output=True, text=True, timeout=5)
        print("📋 Current windows:")
        for line in result.stdout.split('\n'):
            if line.strip():
                print(f"   {line}")
                
        # Look for Flutter app window
        flutter_window = None
        for line in result.stdout.split('\n'):
            if 'hello_world' in line.lower() or 'dejtingapp' in line.lower():
                flutter_window = line.split()[0]
                print(f"✅ Found Flutter app window: {flutter_window}")
                break
        
        if flutter_window:
            print("🎯 Testing window focus...")
            subprocess.run(["wmctrl", "-i", "-a", flutter_window], timeout=2)
            time.sleep(2)
            
            print("⌨️  Testing keyboard input...")
            subprocess.run(["xdotool", "type", "--delay", "200", "test@demo.com"], timeout=5)
            time.sleep(2)
            
            print("✅ Automation test completed!")
        else:
            print("❌ No Flutter app window found")
            
    except Exception as e:
        print(f"❌ Window detection failed: {e}")
    
    # Clean up
    print("🧹 Cleaning up...")
    flutter_process.terminate()
    time.sleep(2)
    if flutter_process.poll() is None:
        flutter_process.kill()
    
    subprocess.run(["pkill", "-f", "flutter"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    subprocess.run(["pkill", "-f", "hello_world"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    subprocess.run(["pkill", "-f", "dejtingapp"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    
    print("🏁 Test completed!")

if __name__ == "__main__":
    test_flutter_automation()
