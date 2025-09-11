#!/usr/bin/env python3
"""
🎬 ENHANCED FLUTTER AUTOMATOR WITH VISUAL DEBUGGING
=================================================

Enhanced version of flutter_automator.py with screenshot capabilities:
- Screenshot capture at each step
- Visual verification of UI state
- Better error debugging with visual context
- Integration with pyautogui for screenshots
"""

import time
import subprocess
import os
import pyautogui
from datetime import datetime
from pathlib import Path
from typing import Optional, Tuple

class VisualFlutterAutomator:
    def __init__(self, app_name: str = "DatingApp", debug_mode: bool = True):
        self.app_name = app_name
        self.debug_mode = debug_mode
        self.typing_delay = 0.02  # 20ms between keystrokes
        
        # Screenshot setup
        self.screenshots_dir = Path(__file__).parent / 'flutter_screenshots'
        self.screenshots_dir.mkdir(exist_ok=True)
        
        self.session_id = datetime.now().strftime("%Y%m%d_%H%M%S")
        self.session_dir = self.screenshots_dir / f"session_{self.session_id}"
        self.session_dir.mkdir(exist_ok=True)
        
        self.step_counter = 0
        
        # Disable pyautogui fail-safe (moving mouse to corner stops program)
        pyautogui.FAILSAFE = False
        
        if self.debug_mode:
            print(f"🎬 Visual Flutter Automator initialized")
            print(f"📸 Screenshots: {self.session_dir}")

    def log(self, message: str, level: str = "INFO"):
        """Enhanced logging with timestamps"""
        if self.debug_mode:
            timestamp = datetime.now().strftime("%H:%M:%S")
            colors = {
                'INFO': '\033[36m',      # Cyan
                'SUCCESS': '\033[92m',   # Green
                'ERROR': '\033[91m',     # Red
                'WARNING': '\033[93m',   # Yellow
            }
            reset = '\033[0m'
            color = colors.get(level, '')
            print(f"[{timestamp}] {color}{level}{reset}: {message}")

    def take_screenshot(self, step_name: str, description: str = "") -> str:
        """Take a screenshot of the current screen state"""
        self.step_counter += 1
        filename = f"{self.step_counter:02d}_{step_name}.png"
        filepath = self.session_dir / filename
        
        try:
            # Take screenshot using pyautogui
            screenshot = pyautogui.screenshot()
            screenshot.save(str(filepath))
            
            if description:
                self.log(f"📸 Screenshot: {step_name} - {description}")
            else:
                self.log(f"📸 Screenshot: {step_name}")
            
            return str(filepath)
        except Exception as e:
            self.log(f"❌ Failed to take screenshot: {e}", "ERROR")
            return ""

    def get_window_info(self, window_name: str) -> Optional[Tuple[int, int, int, int]]:
        """Get window position and size using wmctrl"""
        try:
            result = subprocess.run(['wmctrl', '-l', '-G'], capture_output=True, text=True)
            lines = result.stdout.strip().split('\\n')
            
            for line in lines:
                if window_name.lower() in line.lower():
                    parts = line.split()
                    if len(parts) >= 6:
                        # Format: window_id desktop x y width height window_name
                        x, y, width, height = map(int, parts[2:6])
                        return (x, y, width, height)
            return None
        except Exception as e:
            self.log(f"❌ Failed to get window info: {e}", "ERROR")
            return None

    def focus_window(self, window_name: str = None) -> bool:
        """Focus on the specified window with visual verification"""
        target_window = window_name or self.app_name
        
        try:
            # Take before screenshot
            self.take_screenshot("before_focus", f"Before focusing {target_window}")
            
            # Focus the window
            subprocess.run(['wmctrl', '-a', target_window], check=True)
            time.sleep(0.5)  # Wait for focus change
            
            # Take after screenshot
            self.take_screenshot("after_focus", f"After focusing {target_window}")
            
            # Verify focus worked
            active_window = self.get_active_window()
            if active_window and target_window.lower() in active_window.lower():
                self.log(f"✅ Focused window: {active_window}", "SUCCESS")
                return True
            else:
                self.log(f"⚠️ Focus may have failed. Active: {active_window}", "WARNING")
                return False
                
        except subprocess.CalledProcessError:
            self.log(f"❌ Failed to focus window: {target_window}", "ERROR")
            return False

    def get_active_window(self) -> Optional[str]:
        """Get the currently active window name"""
        try:
            result = subprocess.run(['xdotool', 'getactivewindow', 'getwindowname'], 
                                  capture_output=True, text=True)
            return result.stdout.strip()
        except:
            return None

    def type_text(self, text: str, step_name: str = "") -> bool:
        """Type text with visual verification"""
        if not step_name:
            step_name = f"type_text_{text[:20]}"
        
        try:
            # Screenshot before typing
            self.take_screenshot(f"{step_name}_before", f"Before typing: {text}")
            
            # Type the text
            for char in text:
                subprocess.run(['xdotool', 'type', '--delay', str(int(self.typing_delay * 1000)), char])
            
            # Short delay after typing
            time.sleep(0.3)
            
            # Screenshot after typing
            self.take_screenshot(f"{step_name}_after", f"After typing: {text}")
            
            self.log(f"⌨️ Typed: '{text}'", "SUCCESS")
            return True
            
        except Exception as e:
            self.log(f"❌ Failed to type text: {e}", "ERROR")
            return False

    def send_key(self, key: str, step_name: str = "") -> bool:
        """Send a key press with visual verification"""
        if not step_name:
            step_name = f"key_{key}"
        
        try:
            # Screenshot before key press
            self.take_screenshot(f"{step_name}_before", f"Before key: {key}")
            
            subprocess.run(['xdotool', 'key', key], check=True)
            time.sleep(0.3)  # Wait for UI response
            
            # Screenshot after key press
            self.take_screenshot(f"{step_name}_after", f"After key: {key}")
            
            self.log(f"🔑 Key: {key}", "SUCCESS")
            return True
            
        except subprocess.CalledProcessError:
            self.log(f"❌ Failed to send key: {key}", "ERROR")
            return False

    def clear_field_and_type(self, text: str, step_name: str = "") -> bool:
        """Clear a field and type new text with visual verification"""
        if not step_name:
            step_name = f"clear_and_type_{text[:20]}"
        
        # Take initial screenshot
        self.take_screenshot(f"{step_name}_initial", f"Before clear and type: {text}")
        
        # Clear field (Ctrl+A, then type)
        if self.send_key("ctrl+a", f"{step_name}_select_all"):
            return self.type_text(text, f"{step_name}_type")
        return False

    def navigate_registration_flow(self, user_data: dict) -> bool:
        """Navigate through registration flow with visual debugging"""
        self.log("🚀 Starting registration flow with visual debugging")
        
        # Step 1: Focus window
        if not self.focus_window():
            return False
        
        # Step 2: Fill first name
        if 'firstName' in user_data:
            self.log(f"📝 Entering first name: {user_data['firstName']}")
            if not self.clear_field_and_type(user_data['firstName'], "first_name"):
                return False
            
            # Move to next field
            if not self.send_key("Tab", "tab_to_last_name"):
                return False
        
        # Step 3: Fill last name
        if 'lastName' in user_data:
            self.log(f"📝 Entering last name: {user_data['lastName']}")
            if not self.clear_field_and_type(user_data['lastName'], "last_name"):
                return False
            
            if not self.send_key("Tab", "tab_to_email"):
                return False
        
        # Step 4: Fill email
        if 'email' in user_data:
            self.log(f"📧 Entering email: {user_data['email']}")
            if not self.clear_field_and_type(user_data['email'], "email"):
                return False
            
            if not self.send_key("Tab", "tab_to_password"):
                return False
        
        # Step 5: Fill password
        if 'password' in user_data:
            self.log(f"🔐 Entering password")
            if not self.clear_field_and_type(user_data['password'], "password"):
                return False
        
        # Step 6: Submit form
        self.log("📤 Submitting registration form")
        if not self.send_key("Return", "submit_registration"):
            return False
        
        # Step 7: Wait for response and take final screenshot
        self.log("⏳ Waiting for registration response...")
        time.sleep(3)
        self.take_screenshot("registration_complete", "Registration process completed")
        
        self.log("✅ Registration flow completed with visual documentation", "SUCCESS")
        return True

    def demonstrate_login_flow(self, email: str, password: str) -> bool:
        """Demonstrate login flow with visual debugging"""
        self.log("🔐 Starting login flow with visual debugging")
        
        if not self.focus_window():
            return False
        
        # Fill email
        self.log(f"📧 Entering email: {email}")
        if not self.clear_field_and_type(email, "login_email"):
            return False
        
        if not self.send_key("Tab", "tab_to_password"):
            return False
        
        # Fill password
        self.log("🔐 Entering password")
        if not self.clear_field_and_type(password, "login_password"):
            return False
        
        # Submit
        self.log("📤 Submitting login")
        if not self.send_key("Return", "submit_login"):
            return False
        
        # Wait and document result
        time.sleep(3)
        self.take_screenshot("login_complete", "Login process completed")
        
        self.log("✅ Login flow completed with visual documentation", "SUCCESS")
        return True

    def check_flutter_window(self) -> bool:
        """Check if Flutter window is visible and responsive"""
        self.log("🔍 Checking Flutter window status")
        
        # Take screenshot of current state
        self.take_screenshot("window_check", "Checking Flutter window status")
        
        # Check if window exists
        window_info = self.get_window_info(self.app_name)
        if window_info:
            x, y, width, height = window_info
            self.log(f"✅ Flutter window found: {width}x{height} at ({x}, {y})", "SUCCESS")
            return True
        else:
            self.log("❌ Flutter window not found", "ERROR")
            return False

    def cleanup_and_show_results(self):
        """Show demo results and cleanup"""
        self.log("📊 Demo Results Summary:")
        
        screenshots = list(self.session_dir.glob("*.png"))
        if screenshots:
            print(f"  📸 {len(screenshots)} screenshots captured:")
            for shot in sorted(screenshots):
                print(f"    • {shot.name}")
            print(f"  📁 Location: {self.session_dir}")
            
            # Optionally open the screenshots directory
            try:
                subprocess.Popen(['xdg-open', str(self.session_dir)])
                self.log("📁 Opening screenshots directory", "SUCCESS")
            except:
                pass
        else:
            self.log("📸 No screenshots captured", "WARNING")


# Example usage
if __name__ == "__main__":
    # Create visual automator
    automator = VisualFlutterAutomator(debug_mode=True)
    
    # Check if Flutter window is available
    if automator.check_flutter_window():
        # Demo registration
        test_user = {
            'firstName': 'Demo',
            'lastName': 'User',
            'email': f'demo.visual.{int(time.time())}@example.com',
            'password': 'Demo123!'
        }
        
        automator.navigate_registration_flow(test_user)
    else:
        print("❌ Flutter window not found. Please start the app first.")
    
    # Show results
    automator.cleanup_and_show_results()
