#!/usr/bin/env python3
"""Quick demo without the syntax errors"""

import subprocess
import time
import requests

class QuickDemo:
    def __init__(self):
        self.base_urls = {
            'auth': 'http://localhost:5001',
            'user': 'http://localhost:5002', 
            'matchmaking': 'http://localhost:5003'
        }
    
    def check_services(self):
        print("🔍 Checking backend services...")
        all_good = True
        for service, url in self.base_urls.items():
            try:
                r = requests.get(f"{url}/health", timeout=3)
                print(f"✅ {service}: {r.status_code}")
            except Exception as e:
                print(f"❌ {service}: {e}")
                all_good = False
        return all_good
    
    def start_flutter(self):
        print("🚀 Starting Flutter...")
        try:
            # Check if already running
            result = subprocess.run(['wmctrl', '-l'], capture_output=True, text=True)
            if 'DatingApp' in result.stdout:
                print("✅ Flutter already running")
                return True
            
            # Start Flutter
            subprocess.Popen(['flutter', 'run', '-d', 'linux', '-t', 'lib/main_demo.dart'], 
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            
            # Wait for window
            for i in range(20):
                time.sleep(1)
                result = subprocess.run(['wmctrl', '-l'], capture_output=True, text=True)
                if 'DatingApp' in result.stdout:
                    print("✅ Flutter started!")
                    return True
                print(f"   Waiting... {i+1}/20")
            
            print("❌ Flutter failed to start")
            return False
        except Exception as e:
            print(f"❌ Error starting Flutter: {e}")
            return False
    
    def focus_window(self):
        try:
            subprocess.run(['wmctrl', '-a', 'DatingApp'], check=True)
            print("✅ Focused Flutter window")
            return True
        except:
            print("⚠️  Could not focus window")
            return False
    
    def type_text(self, text):
        try:
            subprocess.run(['xdotool', 'type', '--delay', '20', text], check=True)
            print(f"⌨️  Typed: {text}")
        except Exception as e:
            print(f"❌ Typing failed: {e}")
    
    def press_key(self, key):
        try:
            subprocess.run(['xdotool', 'key', key], check=True)
            print(f"🔑 Pressed: {key}")
        except Exception as e:
            print(f"❌ Key press failed: {e}")
    
    def demo_login(self):
        print("📱 Demonstrating login...")
        self.focus_window()
        time.sleep(2)
        
        # Login demo
        print("   • Entering email...")
        self.press_key("Tab")  # Focus email field
        self.press_key("ctrl+a")  # Clear field
        self.type_text("test@example.com")
        
        print("   • Entering password...")
        self.press_key("Tab")  # Focus password field
        self.press_key("ctrl+a")  # Clear field
        self.type_text("Test123!")
        
        print("   • Submitting...")
        self.press_key("Return")
        
        print("   • Waiting for response...")
        time.sleep(5)
        
        print("✅ Login demo completed!")
    
    def run(self):
        print("🎬 Quick Dating App Demo")
        
        if not self.check_services():
            print("❌ Services not ready")
            return
        
        if not self.start_flutter():
            print("❌ Flutter not ready")
            return
        
        self.demo_login()
        print("🎉 Demo completed!")

if __name__ == "__main__":
    demo = QuickDemo()
    demo.run()
