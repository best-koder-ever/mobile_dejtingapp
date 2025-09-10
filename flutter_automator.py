#!/usr/bin/env python3
"""
Flutter App Automation Helper
Uses keyboard shortcuts and window management to demonstrate Flutter app interactions
"""

import time
import subprocess
import os
from typing import List

class FlutterAppAutomator:
    def __init__(self):
        self.flutter_process = None
        self.app_window = None
    
    def cleanup_existing_processes(self):
        """Kill any existing Flutter processes to prevent conflicts"""
        try:
            # Kill any existing flutter processes
            subprocess.run(["pkill", "-f", "flutter"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            subprocess.run(["pkill", "-f", "dejtingapp"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            subprocess.run(["pkill", "-f", "main_demo"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            time.sleep(2)  # Give processes time to terminate
            print("🧹 Cleaned up existing Flutter processes")
        except Exception as e:
            print(f"⚠️  Process cleanup warning: {str(e)}")

    def start_flutter_app(self) -> bool:
        """Start the Flutter app and return success status"""
        try:
            # Clean up any existing processes first
            self.cleanup_existing_processes()
            
            flutter_dir = "/home/m/development/mobile-apps/flutter/dejtingapp"
            os.chdir(flutter_dir)
            
            print("🚀 Starting Flutter app...")
            self.flutter_process = subprocess.Popen(
                ["flutter", "run", "-d", "linux", "-t", "lib/main_demo.dart"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )
            
            print("✅ Flutter app starting... (waiting for window)")
            time.sleep(8)  # Give Flutter time to build and show window
            
            # Try to find the Flutter app window
            try:
                result = subprocess.run(
                    ["wmctrl", "-l"],
                    capture_output=True,
                    text=True,
                    timeout=5
                )
                
                for line in result.stdout.split('\n'):
                    # Look for DatingApp window specifically, avoid VS Code
                    if (('datingapp' in line.lower() or 'dejtingapp' in line.lower()) and 
                        'visual studio code' not in line.lower()):
                        self.app_window = line.split()[0]
                        print(f"✅ Found Flutter app window: {self.app_window}")
                        print(f"   Window: {line.strip()}")
                        break
                    elif 'hello_world' in line.lower() and 'visual studio code' not in line.lower():
                        # Fallback for old window title
                        self.app_window = line.split()[0]
                        print(f"✅ Found Flutter app window (fallback): {self.app_window}")
                        print(f"   Window: {line.strip()}")
                        break
                        
            except subprocess.TimeoutExpired:
                print("⚠️  Could not detect Flutter window automatically")
            
            return True
            
        except Exception as e:
            print(f"❌ Failed to start Flutter app: {str(e)}")
            return False
    
    def focus_flutter_window(self):
        """Bring Flutter app window to focus"""
        if self.app_window:
            try:
                # Try to activate by window ID first
                subprocess.run(["wmctrl", "-i", "-a", self.app_window], timeout=2)
                # Also try to raise the window to front
                subprocess.run(["wmctrl", "-i", "-r", self.app_window, "-e", "0,-1,-1,-1,-1"], timeout=2)
                time.sleep(1.0)  # Give more time for window to focus
                print(f"🎯 Focused window: {self.app_window}")
            except Exception as e:
                print(f"⚠️  Window focus failed: {e}")
                try:
                    # Fallback: try to activate by partial name
                    subprocess.run(["wmctrl", "-a", "dejtingapp"], timeout=2)
                    time.sleep(0.5)
                except:
                    pass
    
    def send_keys(self, keys: str, delay: float = 2.0):
        """Send keyboard input to the focused Flutter app"""
        try:
            # Focus the Flutter window first
            self.focus_flutter_window()
            
            # Clear any existing content first
            subprocess.run(["xdotool", "key", "ctrl+a"], timeout=2)
            time.sleep(0.3)
            
            # Type the text with more delay between characters for visibility
            subprocess.run(["xdotool", "type", "--delay", "200", keys], timeout=10)
            time.sleep(delay)
            print(f"⌨️  Typed: '{keys}'")
            
        except Exception as e:
            print(f"⚠️  Could not send keys '{keys}': {str(e)}")
    
    def send_key_combo(self, combo: str, delay: float = 1.5):
        """Send key combination (like Tab, Enter, etc.)"""
        try:
            self.focus_flutter_window()
            subprocess.run(["xdotool", "key", combo], timeout=5)
            time.sleep(delay)
            print(f"🔑 Key: {combo}")
        except Exception as e:
            print(f"⚠️  Could not send key combo '{combo}': {str(e)}")
    
    def click_position(self, x: int, y: int, delay: float = 1.0):
        """Click at specific coordinates"""
        try:
            self.focus_flutter_window()
            subprocess.run(["xdotool", "mousemove", str(x), str(y)], timeout=2)
            subprocess.run(["xdotool", "click", "1"], timeout=2)
            time.sleep(delay)
        except Exception as e:
            print(f"⚠️  Could not click at position ({x}, {y}): {str(e)}")
    
    def demonstrate_login_flow(self, email: str, password: str):
        """Demonstrate login process in Flutter app"""
        print("📱 Demonstrating login flow...")
        
        # Focus and ensure app is ready
        self.focus_flutter_window()
        print("   • App focused, starting login...")
        time.sleep(3)
        
        # Click into the first input field (email)
        print(f"   • Entering email: {email}")
        self.send_key_combo("Tab")  # Focus first field
        self.send_keys(email)
        
        # Move to password field
        print("   • Moving to password field...")
        self.send_key_combo("Tab")
        time.sleep(1)
        
        # Enter password
        print("   • Entering password...")
        self.send_keys(password)
        
        # Submit form
        print("   • Submitting login form...")
        time.sleep(2)
        self.send_key_combo("Return")
        
        print("✅ Login flow demonstrated")
        time.sleep(4)
    
    def demonstrate_registration_flow(self, email: str, password: str, first_name: str, last_name: str):
        """Demonstrate registration process"""
        print("📱 Demonstrating registration flow...")
        
        print("   • Navigating to registration...")
        time.sleep(2)
        
        # Fill registration form
        print(f"   • Entering first name: {first_name}")
        self.send_keys(first_name)
        self.send_key_combo("Tab")
        
        print(f"   • Entering last name: {last_name}")
        self.send_keys(last_name)
        self.send_key_combo("Tab")
        
        print(f"   • Entering email: {email}")
        self.send_keys(email)
        self.send_key_combo("Tab")
        
        print("   • Entering password...")
        self.send_keys(password)
        
        print("   • Submitting registration...")
        self.send_key_combo("Return")
        
        print("✅ Registration flow demonstrated")
        time.sleep(3)
    
    def demonstrate_swiping(self):
        """Demonstrate swiping on potential matches"""
        print("📱 Demonstrating swiping interface...")
        
        # Simulate navigation to swiping screen
        print("   • Navigating to match browsing...")
        time.sleep(2)
        
        # Simulate swipe actions using arrow keys or clicks
        print("   • Viewing first potential match...")
        time.sleep(2)
        
        print("   • Swiping right (like)...")
        self.send_key_combo("Right")  # or click right side
        time.sleep(2)
        
        print("   • Viewing next match...")
        time.sleep(1)
        
        print("   • Swiping left (pass)...")
        self.send_key_combo("Left")  # or click left side
        time.sleep(2)
        
        print("✅ Swiping flow demonstrated")
    
    def demonstrate_profile_setup(self):
        """Demonstrate profile creation/editing"""
        print("📱 Demonstrating profile setup...")
        
        print("   • Opening profile editor...")
        time.sleep(2)
        
        print("   • Adding bio information...")
        self.send_keys("I love hiking, coffee, and good conversations!")
        self.send_key_combo("Tab")
        
        print("   • Setting age...")
        self.send_keys("28")
        self.send_key_combo("Tab")
        
        print("   • Saving profile...")
        self.send_key_combo("Return")
        
        print("✅ Profile setup demonstrated")
        time.sleep(2)
    
    def stop_flutter_app(self):
        """Stop the Flutter app and clean up all processes"""
        print("🛑 Stopping Flutter app...")
        
        # Stop the process we started
        if self.flutter_process:
            self.flutter_process.terminate()
            time.sleep(2)
            if self.flutter_process.poll() is None:
                self.flutter_process.kill()
            self.flutter_process = None
        
        # Additional cleanup to ensure no lingering processes
        self.cleanup_existing_processes()
    
    def check_dependencies(self) -> bool:
        """Check if required tools are installed"""
        tools = ['xdotool', 'wmctrl']
        missing = []
        
        for tool in tools:
            try:
                subprocess.run([tool, "--version"], 
                             stdout=subprocess.DEVNULL, 
                             stderr=subprocess.DEVNULL,
                             timeout=2)
            except (subprocess.TimeoutExpired, FileNotFoundError):
                missing.append(tool)
        
        if missing:
            print(f"❌ Missing required tools: {', '.join(missing)}")
            print("   Install with: sudo apt-get install xdotool wmctrl")
            return False
        
        return True

# Helper functions for the main demo
def install_automation_tools():
    """Install required tools for Flutter automation"""
    print("🔧 Installing automation tools...")
    try:
        subprocess.run([
            "sudo", "apt-get", "update", "&&", 
            "sudo", "apt-get", "install", "-y", "xdotool", "wmctrl"
        ], shell=True, timeout=60)
        print("✅ Automation tools installed")
        return True
    except Exception as e:
        print(f"❌ Failed to install tools: {str(e)}")
        return False

if __name__ == "__main__":
    automator = FlutterAppAutomator()
    
    if not automator.check_dependencies():
        install_automation_tools()
    
    try:
        if automator.start_flutter_app():
            print("🎬 Starting automated demo...")
            time.sleep(3)
            
            # Demo login
            automator.demonstrate_login_flow("demo.alice@example.com", "Demo123!")
            
            # Demo swiping
            automator.demonstrate_swiping()
            
    except KeyboardInterrupt:
        print("\n⚠️  Demo interrupted")
    finally:
        automator.stop_flutter_app()
