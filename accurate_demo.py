#!/usr/bin/env python3
"""
Flutter App Automation - UI-Accurate Version
Based on actual screen analysis and field mapping
"""

import time
import subprocess
import sys
from flutter_automator import FlutterAppAutomator
from smart_demo_seeder import SmartDemoSeeder

class AccurateFlutterDemo:
    def __init__(self):
        self.automator = FlutterAppAutomator()
        self.demo_seeder = SmartDemoSeeder()
        
    def verify_safe_environment(self) -> bool:
        """Verify we're in a safe environment before starting demos"""
        self.print_step("🛡️  SAFETY CHECK: Verifying demo environment...", "WARNING")
        
        # Check current window
        current_window = self.automator.get_active_window()
        if current_window:
            self.print_step(f"   📱 Current active window: {current_window}", "INFO")
            
            # Block if VS Code is active
            if self.automator.is_vscode_window(current_window):
                self.print_step("🛡️  SAFETY ALERT: VS Code window is active!", "ERROR")
                self.print_step("   Please switch away from VS Code before starting demo", "ERROR")
                self.print_step("   This prevents accidental typing into your code", "WARNING")
                return False
        
        # Verify Flutter app is available
        if not self.automator.find_flutter_window_with_retries(max_retries=2, retry_delay=1.0):
            self.print_step("⚠️  Flutter app not found. Will start when needed.", "WARNING")
        else:
            self.print_step("✅ Flutter app window detected", "SUCCESS")
        
        self.print_step("✅ Environment safety check passed", "SUCCESS")
        return True
        
    def print_step(self, message, level="INFO"):
        """Print formatted step messages"""
        colors = {
            "INFO": "\033[94m",
            "SUCCESS": "\033[92m", 
            "WARNING": "\033[93m",
            "ERROR": "\033[91m",
            "ENDC": "\033[0m"
        }
        print(f"{colors.get(level, '')}{message}{colors['ENDC']}")
        
    def demonstrate_accurate_registration(self):
        """Demonstrate registration with correct field mapping"""
        # Safety check before starting
        if not self.verify_safe_environment():
            self.print_step("❌ Cannot start registration demo - safety check failed", "ERROR")
            return False
            
        self.print_step("🎯 ACCURATE REGISTRATION DEMO", "INFO")
        self.print_step("Based on actual UI analysis:", "INFO")
        
        # Test data
        full_name = "Demo User"
        email = f"demo.accurate.{int(time.time())}@example.com"
        password = "Demo123!"
        
        self.print_step(f"📝 Registration Data:", "INFO")
        self.print_step(f"   • Full Name: {full_name}", "INFO")
        self.print_step(f"   • Email: {email}", "INFO")
        self.print_step(f"   • Password: {password}", "INFO")
        
        print("\n" + "="*60)
        self.print_step("🚀 Starting Flutter app...", "INFO")
        
        # Start Flutter app
        self.automator.start_flutter_app()
        time.sleep(5)  # Wait for app to load
        
        # Take initial screenshot
        self.automator.take_screenshot("app_start", "App started")
        
        # Detect current screen
        current_screen = self.automator.detect_current_screen()
        self.print_step(f"🔍 Detected screen: {current_screen}", "INFO")
        
        # Navigate to registration if on login screen
        if current_screen == "login_screen":
            self.print_step("📱 Navigating to registration...", "INFO")
            # Look for "Register" or "Sign Up" button and click it
            # For now, let's assume there's a register button/link
            self.automator.send_key_combo("Tab")  # Navigate to register button
            self.automator.send_key_combo("Tab")  # May need multiple tabs
            self.automator.send_key_combo("Return")  # Click register
            time.sleep(2)
            
        # Take screenshot of registration screen
        self.automator.take_screenshot("registration_screen", "Registration screen")
        
        # Fill registration form with CORRECT field order
        self.print_step("📝 Filling registration form with accurate field mapping...", "SUCCESS")
        
        # Field 1: Full Name
        self.print_step(f"   ✏️  Full Name: {full_name}", "INFO")
        self.automator.send_keys(full_name)
        self.automator.send_key_combo("Tab")
        time.sleep(0.5)
        
        # Field 2: Email
        self.print_step(f"   ✏️  Email: {email}", "INFO")
        self.automator.send_keys(email)
        self.automator.send_key_combo("Tab")
        time.sleep(0.5)
        
        # Field 3: Password
        self.print_step(f"   ✏️  Password: {password}", "INFO")
        self.automator.send_keys(password)
        self.automator.send_key_combo("Tab")
        time.sleep(0.5)
        
        # Field 4: Confirm Password
        self.print_step(f"   ✏️  Confirm Password: {password}", "INFO")
        self.automator.send_keys(password)
        time.sleep(0.5)
        
        # Take screenshot of filled form
        self.automator.take_screenshot("form_filled", "Registration form filled")
        
        # Submit form
        self.print_step("📤 Submitting registration...", "WARNING")
        self.automator.send_key_combo("Return")
        time.sleep(3)
        
        # Take screenshot after submission
        self.automator.take_screenshot("registration_submitted", "Registration submitted")
        
        self.print_step("✅ Registration demo completed!", "SUCCESS")
        return True
        
    def demonstrate_accurate_login(self, email, password):
        """Demonstrate login with correct field mapping"""
        # Safety check before starting
        if not self.verify_safe_environment():
            self.print_step("❌ Cannot start login demo - safety check failed", "ERROR")
            return False
            
        self.print_step("🔐 ACCURATE LOGIN DEMO", "INFO")
        
        # Ensure we're on login screen
        current_screen = self.automator.detect_current_screen()
        if current_screen != "login_screen":
            self.print_step("🔄 Navigating to login screen...", "INFO")
            # Add navigation logic here if needed
            
        # Take screenshot of login screen
        self.automator.take_screenshot("login_screen", "Login screen")
        
        # Fill login form
        self.print_step("📝 Filling login form...", "INFO")
        
        # Field 1: Email
        self.print_step(f"   ✏️  Email: {email}", "INFO")
        self.automator.send_keys(email)
        self.automator.send_key_combo("Tab")
        time.sleep(0.5)
        
        # Field 2: Password  
        self.print_step(f"   ✏️  Password: {password}", "INFO")
        self.automator.send_keys(password)
        time.sleep(0.5)
        
        # Submit login
        self.print_step("🔑 Logging in...", "WARNING")
        self.automator.send_key_combo("Return")
        time.sleep(3)
        
        # Take screenshot after login
        self.automator.take_screenshot("login_completed", "Login completed")
        
        return True
        
    def demonstrate_main_app_navigation(self):
        """Demonstrate navigation through main app tabs"""
        self.print_step("🏠 MAIN APP NAVIGATION DEMO", "INFO")
        
        # Should be on main app after successful login
        self.automator.take_screenshot("main_app", "Main app loaded")
        
        # Navigate through tabs (bottom navigation)
        tabs = ["Discover", "Matches", "Profile", "Settings"]
        
        for i, tab in enumerate(tabs):
            self.print_step(f"📱 Navigating to {tab} tab...", "INFO")
            
            # Use arrow keys or tab navigation to switch tabs
            if i > 0:  # Don't navigate for first tab (already there)
                self.automator.send_key_combo("Right")  # Or use specific navigation
                time.sleep(1)
                
            # Take screenshot of each tab
            self.automator.take_screenshot(f"tab_{tab.lower()}", f"{tab} tab")
            time.sleep(1)
            
        self.print_step("✅ Navigation demo completed!", "SUCCESS")
        
    def demonstrate_discover_interactions(self):
        """Demonstrate swiping/interactions on discover screen"""
        self.print_step("💕 DISCOVER INTERACTIONS DEMO", "INFO")
        
        # Navigate to discover tab (tab 0)
        self.print_step("📱 Navigating to Discover tab...", "INFO")
        # Navigation logic here
        
        # Take screenshot
        self.automator.take_screenshot("discover_screen", "Discover screen")
        
        # Simulate swipe actions
        swipe_actions = [
            ("Right", "❤️ Like"),
            ("Left", "❌ Pass"), 
            ("Up", "⭐ Super Like")
        ]
        
        for key, action in swipe_actions:
            self.print_step(f"   {action}", "INFO")
            self.automator.send_key_combo(key)
            time.sleep(2)
            self.automator.take_screenshot(f"swipe_{action.split()[1].lower()}", f"After {action}")
            
        self.print_step("✅ Discover demo completed!", "SUCCESS")
        
    def run_complete_accurate_demo(self):
        """Run complete demo with accurate UI mapping"""
        self.print_step("🎬 STARTING COMPLETE ACCURATE DEMO", "SUCCESS")
        self.print_step("Based on actual Flutter UI analysis", "INFO")
        
        try:
            # Demo flow
            email = f"demo.complete.{int(time.time())}@example.com"
            password = "Demo123!"
            
            # 1. Registration
            if self.demonstrate_accurate_registration():
                self.print_step("1️⃣ Registration demo: ✅", "SUCCESS")
            else:
                self.print_step("1️⃣ Registration demo: ❌", "ERROR")
                return False
                
            time.sleep(2)
            
            # 2. Login (after registration redirects to login)
            if self.demonstrate_accurate_login(email, password):
                self.print_step("2️⃣ Login demo: ✅", "SUCCESS")
            else:
                self.print_step("2️⃣ Login demo: ❌", "ERROR")
                return False
                
            time.sleep(2)
            
            # 3. Main app navigation
            self.demonstrate_main_app_navigation()
            self.print_step("3️⃣ Navigation demo: ✅", "SUCCESS")
            
            time.sleep(2)
            
            # 4. Discover interactions
            self.demonstrate_discover_interactions()
            self.print_step("4️⃣ Discover demo: ✅", "SUCCESS")
            
            self.print_step("🎉 COMPLETE DEMO FINISHED SUCCESSFULLY!", "SUCCESS")
            
        except Exception as e:
            self.print_step(f"❌ Demo failed: {e}", "ERROR")
            return False
        finally:
            # Stop Flutter app
            self.print_step("🛑 Stopping Flutter app...", "INFO")
            self.automator.stop_flutter_app()
            
        return True

    def safe_input(self, prompt=""):
        """Safe input with EOF handling"""
        try:
            return input(prompt)
        except (EOFError, KeyboardInterrupt):
            print("\n👋 Input interrupted")
            return None
            
    def show_menu(self):
        """Display the demo menu and handle user choices"""
        
        # Initial safety check
        if not self.verify_safe_environment():
            self.print_step("❌ Safety check failed. Please fix issues before continuing.", "ERROR")
            return
        
        while True:
            print("\n" + "="*60)
            print("🎯 FLUTTER APP ACCURATE DEMO SYSTEM")
            print("Based on actual UI analysis and field mapping")
            print("🛡️  Enhanced with VS Code safety protection")
            print("="*60)
            
            print(f"""
🎬 Available Demos:

1. 📝 Registration Demo (Accurate Field Mapping)
2. 🔐 Login Demo  
3. 🏠 Main App Navigation (4 Tabs)
4. 💕 Discover Screen Interactions
5. 🎯 Complete End-to-End Demo
6. 📸 Visual Debug Test (Screenshots Only)
7. 🔄 Restart Flutter App
8. 🛑 Stop Flutter App
9. 🌱 Smart Demo Data Seeding (Real APIs)
0. ❌ Exit

Choose an option (0-9): """, end="")

            try:
                choice = self.safe_input().strip()
                if choice is None:  # EOF/Interrupted
                    break
            except:
                print("\n👋 Demo interrupted")
                break
                
            if choice == '0':
                self.print_step("👋 Exiting demo system...", "INFO")
                self.automator.stop_flutter_app()
                break
            elif choice == '1':
                self.print_step("🎬 Starting Registration Demo...", "INFO")
                self.demonstrate_accurate_registration()
            elif choice == '2':
                email = self.safe_input("Enter email (or press Enter for default): ").strip()
                if not email:
                    email = "test@example.com"
                password = self.safe_input("Enter password (or press Enter for default): ").strip()
                if not password:
                    password = "Test123!"
                self.demonstrate_accurate_login(email, password)
            elif choice == '3':
                self.print_step("🎬 Starting Navigation Demo...", "INFO")
                self.demonstrate_main_app_navigation()
            elif choice == '4':
                self.print_step("� Starting Discover Demo...", "INFO")
                self.demonstrate_discover_interactions()
            elif choice == '5':
                self.print_step("🎬 Starting Complete Demo...", "INFO")
                self.run_complete_accurate_demo()
            elif choice == '6':
                self.print_step("🎬 Starting Visual Debug Test...", "INFO")
                self.visual_debug_test()
            elif choice == '7':
                self.print_step("🔄 Restarting Flutter App...", "WARNING")
                self.automator.stop_flutter_app()
                time.sleep(2)
                self.automator.start_flutter_app()
            elif choice == '8':
                self.print_step("🛑 Stopping Flutter App...", "WARNING")
                self.automator.stop_flutter_app()
            elif choice == '9':
                self.print_step("🌱 Starting Smart Demo Data Seeding...", "INFO")
                self.run_smart_demo_seeding()
            else:
                self.print_step("❌ Invalid option. Please choose 0-9.", "ERROR")
            
            if choice != '0':
                result = self.safe_input(f"\n📱 Press Enter to return to menu...")
                if result is None:  # EOF/Interrupted
                    break
                    
    def visual_debug_test(self):
        """Simple visual debug test to check app state"""
        self.print_step("📸 VISUAL DEBUG TEST", "INFO")
        
        # Take screenshot and detect screen
        self.automator.take_screenshot("debug_test", "Debug test screenshot")
        current_screen = self.automator.detect_current_screen()
        
        self.print_step(f"🔍 Current screen detected: {current_screen}", "SUCCESS")
        self.print_step("📸 Screenshot saved for analysis", "INFO")
        
        # Show app state info
        self.print_step("📱 App State Information:", "INFO")
        self.print_step(f"   • Screen: {current_screen}", "INFO")
        self.print_step(f"   • Screenshots saved in demo_screenshots/", "INFO")
        
        return True

    def run_smart_demo_seeding(self):
        """Run smart demo data seeding using real APIs"""
        self.print_step("🌱 SMART DEMO DATA SEEDING", "INFO")
        self.print_step("Using REAL APIs with in-memory databases", "INFO")
        self.print_step("No duplicate API maintenance needed!", "SUCCESS")
        
        # Check if services are healthy first
        self.print_step("⚡ Checking if services are running...", "INFO")
        if self.demo_seeder.check_services_health():
            self.print_step("✅ All services are healthy, seeding demo data...", "SUCCESS")
            success = self.demo_seeder.seed_all_demo_data()
            
            if success:
                self.print_step("🎉 Smart demo seeding completed successfully!", "SUCCESS")
                self.print_step("💡 You now have realistic data in your REAL APIs", "INFO")
                self.print_step("🎯 Perfect for UI testing and demos", "INFO")
                self.print_step("🔄 Restart services to reset data", "INFO")
            else:
                self.print_step("⚠️  Demo seeding completed with issues", "WARNING")
                self.print_step("🔍 Check the detailed output above for specific problems", "INFO")
        else:
            self.print_step("❌ Service health check failed - some services are not responding", "ERROR")
            self.print_step("🔧 Make sure all microservices are running with DEMO_MODE=true:", "INFO")
            self.print_step("   • AuthService on port 8081", "INFO")
            self.print_step("   • UserService on port 8082", "INFO")
            self.print_step("   • MatchmakingService on port 8083", "INFO")
            self.print_step("💡 Run: cd /home/m/development/DatingApp && ./start_demo_services.sh", "INFO")
        
        return True

def main():
    """Main demo runner with menu"""
    print("�🎯 Flutter App Accurate Demo System")
    print("Based on actual UI analysis and field mapping")
    print("="*60)
    
    demo = AccurateFlutterDemo()
    
    # Check if command line arguments provided for direct execution
    if len(sys.argv) > 1:
        demo_type = sys.argv[1]
        
        if demo_type == "registration":
            demo.demonstrate_accurate_registration()
        elif demo_type == "login":
            email = sys.argv[2] if len(sys.argv) > 2 else "test@example.com"
            password = sys.argv[3] if len(sys.argv) > 3 else "Test123!"
            demo.demonstrate_accurate_login(email, password)
        elif demo_type == "navigation":
            demo.demonstrate_main_app_navigation()
        elif demo_type == "discover":
            demo.demonstrate_discover_interactions()
        elif demo_type == "complete":
            demo.run_complete_accurate_demo()
        elif demo_type == "menu":
            demo.show_menu()
        else:
            print("Usage: python3 accurate_demo.py [registration|login|navigation|discover|complete|menu]")
            print("Or run without arguments to show interactive menu")
    else:
        # Show interactive menu by default
        demo.show_menu()

if __name__ == "__main__":
    main()
