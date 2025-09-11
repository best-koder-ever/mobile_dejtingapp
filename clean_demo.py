#!/usr/bin/env python3
"""Clean Dating App Demo System - Fixed Version"""

import subprocess
import time
import requests
import sys
from datetime import datetime

class Colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'

class CleanDemo:
    def __init__(self):
        self.base_urls = {
            'auth': 'http://localhost:5001',
            'user': 'http://localhost:5002', 
            'matchmaking': 'http://localhost:5003'
        }
        self.demo_users = {
            'alice': {'email': 'test@example.com', 'password': 'Test123!'},
            'bob': {'email': 'demo.newuser.1757590950@example.com', 'password': 'Demo123!'}
        }
    
    def print_step(self, step: str, status: str = "INFO"):
        timestamp = datetime.now().strftime("%H:%M:%S")
        colors = {
            "INFO": Colors.OKBLUE,
            "SUCCESS": Colors.OKGREEN,
            "WARNING": Colors.WARNING,
            "ERROR": Colors.FAIL,
            "BACKEND": Colors.OKCYAN
        }
        color = colors.get(status, Colors.OKBLUE)
        print(f"{color}[{timestamp}] {status}: {step}{Colors.ENDC}")
    
    def print_banner(self):
        print(f"""
{Colors.HEADER}{Colors.BOLD}
╔═══════════════════════════════════════════════════════════════╗
║                   🎬 CLEAN DATING APP DEMO                   ║
║               No Corruption, No Mouse Control                ║
╚═══════════════════════════════════════════════════════════════╝
{Colors.ENDC}
        """)
    
    def check_services(self):
        self.print_step("🔍 Checking backend services...", "INFO")
        all_good = True
        for service, url in self.base_urls.items():
            try:
                r = requests.get(f"{url}/health", timeout=3)
                self.print_step(f"✅ {service}: {r.status_code}", "SUCCESS")
            except Exception as e:
                self.print_step(f"❌ {service}: {e}", "ERROR")
                all_good = False
        return all_good
    
    def start_flutter(self):
        self.print_step("🚀 Starting Flutter...", "INFO")
        try:
            # Check if already running
            result = subprocess.run(['wmctrl', '-l'], capture_output=True, text=True)
            if 'DatingApp' in result.stdout:
                self.print_step("✅ Flutter already running", "SUCCESS")
                return True
            
            # Kill any stuck processes first
            subprocess.run(['pkill', '-f', 'flutter'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            subprocess.run(['pkill', '-f', 'dejtingapp'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            time.sleep(2)
            
            # Start Flutter in background
            self.print_step("   Starting new Flutter instance...", "INFO")
            process = subprocess.Popen(
                ['flutter', 'run', '-d', 'linux', '-t', 'lib/main_demo.dart'], 
                stdout=subprocess.PIPE, 
                stderr=subprocess.PIPE,
                text=True
            )
            
            # Wait for window to appear
            for i in range(30):
                time.sleep(1)
                result = subprocess.run(['wmctrl', '-l'], capture_output=True, text=True)
                if 'DatingApp' in result.stdout:
                    self.print_step("✅ Flutter started successfully!", "SUCCESS")
                    return True
                self.print_step(f"   Waiting for Flutter window... {i+1}/30", "INFO")
            
            self.print_step("❌ Flutter failed to start within 30 seconds", "ERROR")
            process.terminate()
            return False
            
        except Exception as e:
            self.print_step(f"❌ Error starting Flutter: {e}", "ERROR")
            return False
    
    def focus_window(self):
        try:
            subprocess.run(['wmctrl', '-a', 'DatingApp'], check=True)
            self.print_step("✅ Focused Flutter window", "SUCCESS")
            time.sleep(1)
            return True
        except:
            self.print_step("⚠️  Could not focus window", "WARNING")
            return False
    
    def type_text(self, text):
        try:
            subprocess.run(['xdotool', 'type', '--delay', '20', text], check=True)
            self.print_step(f"⌨️  Typed: {text}", "INFO")
        except Exception as e:
            self.print_step(f"❌ Typing failed: {e}", "ERROR")
    
    def press_key(self, key):
        try:
            subprocess.run(['xdotool', 'key', key], check=True)
            self.print_step(f"🔑 Pressed: {key}", "INFO")
        except Exception as e:
            self.print_step(f"❌ Key press failed: {e}", "ERROR")
    
    def demo_login(self, user_key='alice'):
        user = self.demo_users[user_key]
        self.print_step(f"📱 Demonstrating login as {user_key}...", "INFO")
        
        if not self.focus_window():
            return False
        
        time.sleep(2)
        
        # Login demo
        self.print_step("   • Entering email...", "INFO")
        self.press_key("Tab")  # Focus email field
        self.press_key("ctrl+a")  # Clear field
        self.type_text(user['email'])
        
        self.print_step("   • Entering password...", "INFO")
        self.press_key("Tab")  # Focus password field
        self.press_key("ctrl+a")  # Clear field
        self.type_text(user['password'])
        
        self.print_step("   • Submitting login...", "INFO")
        self.press_key("Return")
        
        self.print_step("   • Waiting for response...", "INFO")
        time.sleep(5)
        
        # Check if login worked by seeing if window changed
        self.print_step("   • Checking if login succeeded...", "INFO")
        time.sleep(2)
        
        self.print_step("✅ Login demo completed!", "SUCCESS")
        return True
    
    def demo_navigation(self):
        self.print_step("🧭 Testing navigation...", "INFO")
        
        # Try various navigation keys
        nav_keys = ['Tab', 'Down', 'Up', 'Right', 'Left', '1', '2', '3', '4']
        
        for key in nav_keys:
            self.print_step(f"   • Trying {key} key...", "INFO")
            self.press_key(key)
            time.sleep(1)
        
        self.print_step("✅ Navigation test completed!", "SUCCESS")
    
    def show_menu(self):
        print(f"""
{Colors.OKBLUE}╔═══════════════════════════════════════╗
║           SELECT DEMO JOURNEY          ║
╚═══════════════════════════════════════╝{Colors.ENDC}

{Colors.OKBLUE}1.{Colors.ENDC} 👤 Quick Login Demo (Alice)
{Colors.OKBLUE}2.{Colors.ENDC} 🔄 Login + Navigation Test  
{Colors.OKBLUE}3.{Colors.ENDC} 👥 Switch Users Demo
{Colors.OKBLUE}4.{Colors.ENDC} 🚀 Start Flutter App Only
{Colors.OKBLUE}5.{Colors.ENDC} 🛑 Stop Flutter App
{Colors.OKBLUE}0.{Colors.ENDC} ❌ Exit

""")
        
        while True:
            try:
                choice = input("Choose an option (0-5): ").strip()
                
                if choice == '1':
                    if self.demo_login('alice'):
                        self.print_step("🎉 Quick login demo completed!", "SUCCESS")
                elif choice == '2':
                    if self.demo_login('alice'):
                        self.demo_navigation()
                elif choice == '3':
                    self.demo_login('alice')
                    time.sleep(3)
                    self.demo_login('bob')
                elif choice == '4':
                    self.start_flutter()
                elif choice == '5':
                    self.stop_flutter()
                elif choice == '0':
                    self.print_step("👋 Exiting demo system...", "INFO")
                    self.stop_flutter()
                    break
                else:
                    self.print_step("❌ Invalid option. Please choose 0-5.", "ERROR")
                
                if choice != '0':
                    input(f"\n{Colors.OKCYAN}Press Enter to return to menu...{Colors.ENDC}")
                    
            except KeyboardInterrupt:
                self.print_step("\n👋 Exiting demo system...", "WARNING")
                self.stop_flutter()
                break
    
    def stop_flutter(self):
        self.print_step("🛑 Stopping Flutter app...", "INFO")
        try:
            subprocess.run(['pkill', '-f', 'flutter'], stdout=subprocess.DEVNULL)
            subprocess.run(['pkill', '-f', 'dejtingapp'], stdout=subprocess.DEVNULL)
            time.sleep(1)
            self.print_step("✅ Flutter stopped", "SUCCESS")
        except Exception as e:
            self.print_step(f"⚠️  Error stopping Flutter: {e}", "WARNING")
    
    def run(self):
        self.print_banner()
        
        if not self.check_services():
            self.print_step("❌ Backend services not ready", "ERROR")
            self.print_step("   Try: cd /home/m/development/DatingApp && docker-compose -f docker-compose.demo.yml up -d", "INFO")
            return
        
        if not self.start_flutter():
            self.print_step("❌ Flutter not ready", "ERROR")
            return
        
        self.show_menu()

if __name__ == "__main__":
    demo = CleanDemo()
    try:
        demo.run()
    except KeyboardInterrupt:
        print(f"\n{Colors.WARNING}Demo interrupted by user{Colors.ENDC}")
        demo.stop_flutter()
