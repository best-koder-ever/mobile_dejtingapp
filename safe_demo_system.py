#!/usr/bin/env python3
"""
🛡️ SAFE DATING APP DEMO SYSTEM 
==============================

CRITICAL SAFETY FEATURES:
- VS Code window exclusion to prevent file corruption
- Multiple validation checks before any typing
- Safe window targeting with strict patterns
- Abort mechanisms if VS Code is detected

This replaces the unsafe automation that was corrupting files.
"""

import requests
import json
import time
import os
import sys
import subprocess
import threading
from datetime import datetime
from typing import Dict, List, Optional
from safe_flutter_automator import SafeFlutterAppAutomator

class Colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

class SafeJourneyDemoOrchestrator:
    def __init__(self):
        self.base_urls = {
            'auth': 'http://localhost:5001',
            'user': 'http://localhost:5002', 
            'matchmaking': 'http://localhost:5003'
        }
        self.demo_users = {
            'alice': {'email': 'test@example.com', 'password': 'Test123!'},
            'bob': {'email': 'demo.newuser.1757590950@example.com', 'password': 'Demo123!'},
            'charlie': {'email': 'demo.charlie@example.com', 'password': 'Demo123!'}
        }
        self.tokens = {}
        # 🛡️ Use SAFE automator instead of the unsafe one
        self.flutter_automator = SafeFlutterAppAutomator()
        self.flutter_running = False
        
    def print_step(self, message: str, level: str = "INFO"):
        """Print formatted step with timestamp and color"""
        timestamp = datetime.now().strftime("%H:%M:%S")
        color_map = {
            'INFO': Colors.OKCYAN,
            'SUCCESS': Colors.OKGREEN,
            'WARNING': Colors.WARNING,
            'ERROR': Colors.FAIL,
            'BACKEND': Colors.HEADER
        }
        color = color_map.get(level, Colors.OKCYAN)
        print(f"[{timestamp}] {color}{level}{Colors.ENDC}: {message}")

    def check_service_health(self, service_name: str, url: str) -> bool:
        """Check if a service is healthy"""
        try:
            response = requests.get(f"{url}/api/health", timeout=5)
            if response.status_code == 200:
                self.print_step(f"✅ {service_name.upper()} service: Running on {url}", "SUCCESS")
                return True
            else:
                self.print_step(f"❌ {service_name.upper()} service: Not responding ({response.status_code})", "ERROR")
                return False
        except Exception as e:
            self.print_step(f"❌ {service_name.upper()} service: Connection failed - {e}", "ERROR")
            return False

    def check_all_services(self) -> bool:
        """Check if all backend services are running"""
        self.print_step("🔍 Checking backend services...")
        
        all_healthy = True
        for service, url in self.base_urls.items():
            if not self.check_service_health(service, url):
                all_healthy = False
        
        if all_healthy:
            self.print_step("✅ All backend services are running!", "SUCCESS")
        else:
            self.print_step("❌ Some backend services are not running. Please start them first.", "ERROR")
        
        return all_healthy

    def ensure_flutter_ready(self):
        """🛡️ SAFELY ensure Flutter is running and ready"""
        if self.flutter_running:
            self.print_step("🔄 Flutter already running, checking window safety...", "INFO")
            # Check if we can still safely access the window
            if self.flutter_automator.get_safe_flutter_window():
                return True
            else:
                self.print_step("⚠️ Flutter window not safely accessible, restarting...", "WARNING")
                self.flutter_running = False
        
        if not self.flutter_running:
            self.print_step("🚀 Starting Flutter app in demo mode...", "INFO")
            if self.flutter_automator.start_flutter_app():
                self.flutter_running = True
                
                # Give extra time for Flutter to fully load
                self.print_step("⏳ Waiting for Flutter window to be safely accessible...", "INFO")
                time.sleep(5)
                
                # Verify we can safely target the window
                if self.flutter_automator.get_safe_flutter_window():
                    self.print_step("✅ Flutter app started and safely accessible!", "SUCCESS")
                    return True
                else:
                    self.print_step("❌ Flutter started but window not safely accessible", "ERROR")
                    return False
            else:
                self.print_step("❌ Failed to start Flutter app", "ERROR")
                return False
        
        return True

    def register_user_backend(self, user_data: dict) -> tuple:
        """Register user via backend API"""
        register_payload = {
            "username": user_data.get('username', user_data['email'].split('@')[0]),
            "email": user_data['email'],
            "password": user_data['password'],
            "confirmPassword": user_data['password']
        }
        
        try:
            response = requests.post(
                f"{self.base_urls['auth']}/api/auth/register",
                json=register_payload,
                headers={'Content-Type': 'application/json'},
                timeout=10
            )
            
            if response.status_code == 200:
                result = response.json()
                token = result.get('token')
                self.print_step("✅ User registered successfully!", "SUCCESS")
                if token:
                    self.print_step(f"🎫 JWT Token: {token[:20]}...", "BACKEND")
                return True, token
            else:
                self.print_step(f"❌ Registration failed: {response.text}", "ERROR")
                return False, None
                
        except Exception as e:
            self.print_step(f"❌ Registration error: {e}", "ERROR")
            return False, None

    def demonstrate_new_user_journey(self):
        """🛡️ SAFE demonstration of new user registration journey"""
        self.print_step("🧹 Ensuring clean environment...", "INFO")
        
        if not self.ensure_flutter_ready():
            self.print_step("❌ Cannot safely start Flutter app", "ERROR")
            return
        
        self.print_step("🎬 Starting: NEW USER JOURNEY", "INFO")
        
        # Generate unique user data
        timestamp = int(time.time())
        user_data = {
            'firstName': 'Demo',
            'lastName': 'User', 
            'email': f'demo.newuser.{timestamp}@example.com',
            'password': 'Demo123!'
        }
        
        # Step 1: Register via backend first
        self.print_step(f"📧 Creating new user: {user_data['email']}", "BACKEND")
        success, token = self.register_user_backend(user_data)
        
        if not success:
            self.print_step("❌ Backend registration failed, aborting demo", "ERROR")
            return
        
        # Step 2: Demonstrate in Flutter app with SAFETY
        self.print_step("📱 Now demonstrating in Flutter app with SAFETY CHECKS...", "INFO")
        print("📱 Demonstrating registration flow...")
        print("   • Navigating to registration...")
        print(f"   • Entering first name: {user_data['firstName']}")
        
        # 🛡️ SAFE registration demonstration
        if self.flutter_automator.safe_registration_demo(user_data):
            self.print_step("✅ Registration flow demonstrated safely", "SUCCESS")
        else:
            self.print_step("❌ Registration demonstration failed or was aborted for safety", "ERROR")
        
        input("\\nPress Enter to return to menu...")

    def demonstrate_existing_user_journey(self):
        """🛡️ SAFE demonstration of existing user login journey"""
        self.print_step("🎬 Starting: EXISTING USER JOURNEY", "INFO")
        
        if not self.ensure_flutter_ready():
            self.print_step("❌ Cannot safely start Flutter app", "ERROR")
            return
        
        # Use predefined test user
        test_user = self.demo_users['alice']
        
        self.print_step(f"🔐 Demonstrating login with: {test_user['email']}", "INFO")
        
        # 🛡️ SAFE login demonstration
        if self.flutter_automator.safe_login_demo(test_user['email'], test_user['password']):
            self.print_step("✅ Login flow demonstrated safely", "SUCCESS")
        else:
            self.print_step("❌ Login demonstration failed or was aborted for safety", "ERROR")
        
        input("\\nPress Enter to return to menu...")

    def show_main_menu(self):
        """Display the main menu with safety warnings"""
        print("\\n" + "="*70)
        print("🛡️ SAFE DATING APP DEMO SYSTEM")
        print("   (With VS Code Protection)")
        print("="*70)
        
        if not self.check_all_services():
            print("\\n❌ Backend services not running. Please start them first.")
            print("Run: cd /home/m/development/DatingApp && docker-compose -f environments/demo/docker-compose.demo.yml up -d")
            return False
        
        print("\\n🚨 SAFETY FEATURES ENABLED:")
        print("  🛡️ VS Code window exclusion")
        print("  🔒 Pre-typing safety validation")
        print("  ✅ Safe window pattern matching")
        print("  🚫 Automatic abort on unsafe conditions")
        
        print("\\n╔═══════════════════════════════════════╗")
        print("║           SELECT DEMO JOURNEY          ║")
        print("╚═══════════════════════════════════════╝")
        
        print("\\n1. 🆕 New User Journey (SAFE Registration)")
        print("2. 👤 Existing User Journey (SAFE Login)")
        print("3. 🔍 Backend Status Check")
        print("4. 🚀 Start Flutter App Only") 
        print("5. 🛑 Stop Flutter App")
        print("6. 🪟 Test Window Safety (Debug)")
        print("0. ❌ Exit")
        
        return True

    def test_window_safety(self):
        """🛡️ Test window detection and safety features"""
        self.print_step("🔍 Testing window safety features...", "INFO")
        
        # Test window detection
        window_info = self.flutter_automator.get_safe_flutter_window()
        if window_info:
            window_id, window_desc = window_info
            print(f"✅ Safe Flutter window found: {window_desc}")
            
            # Test safe focus
            if self.flutter_automator.safe_focus_flutter_window():
                print("✅ Safe window focus successful")
                
                # Show current active window
                current = self.flutter_automator.get_active_window()
                if current:
                    print(f"📋 Current active window: {current}")
                    if self.flutter_automator.is_vscode_window(current):
                        print("🛡️ WARNING: Active window detected as VS Code!")
                    else:
                        print("✅ Active window is safe for automation")
            else:
                print("❌ Safe window focus failed")
        else:
            print("❌ No safe Flutter window found")
        
        input("\\nPress Enter to continue...")

    def run_interactive_demo(self):
        """Run the interactive demo system"""
        while True:
            if not self.show_main_menu():
                break
            
            choice = input("\\nChoose an option (0-6): ").strip()
            
            if choice == "0":
                self.print_step("👋 Exiting demo system...", "INFO")
                if self.flutter_running:
                    self.print_step("🛑 Stopping Flutter app...", "INFO")
                    self.flutter_automator.stop_flutter_app()
                break
            elif choice == "1":
                self.demonstrate_new_user_journey()
            elif choice == "2":
                self.demonstrate_existing_user_journey()
            elif choice == "3":
                self.check_all_services()
                input("\\nPress Enter to continue...")
            elif choice == "4":
                self.ensure_flutter_ready()
                input("\\nPress Enter to continue...")
            elif choice == "5":
                if self.flutter_running:
                    self.flutter_automator.stop_flutter_app()
                    self.flutter_running = False
                    self.print_step("🛑 Flutter app stopped", "SUCCESS")
                else:
                    self.print_step("ℹ️ Flutter app not running", "INFO")
                input("\\nPress Enter to continue...")
            elif choice == "6":
                self.test_window_safety()
            else:
                print("❌ Invalid option. Please try again.")

def main():
    """Main entry point"""
    print("🛡️ Initializing SAFE Demo System...")
    demo = SafeJourneyDemoOrchestrator()
    demo.run_interactive_demo()

if __name__ == "__main__":
    main()
