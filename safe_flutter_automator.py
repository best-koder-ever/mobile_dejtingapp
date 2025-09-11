#!/usr/bin/env python3
"""
🛡️ SAFE FLUTTER APP AUTOMATION HELPER
====================================

Enhanced Flutter automation with strict safeguards to prevent VS Code corruption:
- VS Code window exclusion filters
- Window validation before any typing
- Safe window pattern matching
- Multiple confirmation checks
"""

import time
import subprocess
import os
from typing import List, Optional, Tuple

class SafeFlutterAppAutomator:
    def __init__(self):
        self.flutter_process = None
        self.app_window = None
        self.typing_delay = 0.02  # 20ms between keystrokes
        
        # 🛡️ SAFETY: VS Code window patterns to NEVER touch
        self.vscode_patterns = [
            'visual studio code',
            'vs code',
            'vscode',
            'code.exe',
            '.py -',
            '.js -',
            '.ts -',
            'workspace',
            'copilot',
            'github copilot'
        ]
        
        # ✅ SAFE: Flutter window patterns we want to target
        self.flutter_patterns = [
            'DatingApp (Demo)',
            'dejtingapp',
            'flutter app',
            'dating app demo'
        ]
    
    def is_vscode_window(self, window_line: str) -> bool:
        """🛡️ SAFETY CHECK: Detect VS Code windows to avoid"""
        window_lower = window_line.lower()
        for pattern in self.vscode_patterns:
            if pattern in window_lower:
                return True
        return False
    
    def is_flutter_window(self, window_line: str) -> bool:
        """✅ VALIDATION: Detect legitimate Flutter windows"""
        window_lower = window_line.lower()
        
        # First check: Must NOT be a VS Code window
        if self.is_vscode_window(window_line):
            return False
        
        # Second check: Must match Flutter patterns
        for pattern in self.flutter_patterns:
            if pattern in window_lower:
                return True
        return False
    
    def get_safe_flutter_window(self) -> Optional[Tuple[str, str]]:
        """🔍 Find Flutter window with safety validation"""
        try:
            result = subprocess.run(
                ["wmctrl", "-l"],
                capture_output=True,
                text=True,
                timeout=5
            )
            
            candidate_windows = []
            
            print("🔍 Scanning for Flutter windows (excluding VS Code)...")
            for line in result.stdout.split('\\n'):
                if line.strip():
                    print(f"  📋 Window: {line.strip()}")
                    
                    if self.is_vscode_window(line):
                        print(f"  🛡️ BLOCKED: VS Code window detected - {line.strip()}")
                        continue
                    
                    if self.is_flutter_window(line):
                        window_id = line.split()[0]
                        candidate_windows.append((window_id, line.strip()))
                        print(f"  ✅ SAFE: Flutter window candidate - {line.strip()}")
            
            if candidate_windows:
                # Return the first safe Flutter window
                window_id, window_desc = candidate_windows[0]
                print(f"🎯 Selected Flutter window: {window_desc}")
                return window_id, window_desc
            else:
                print("❌ No safe Flutter windows found")
                return None
                
        except Exception as e:
            print(f"❌ Failed to scan windows: {e}")
            return None
    
    def safe_focus_flutter_window(self) -> bool:
        """🛡️ SAFELY focus Flutter window with validation"""
        print("🔒 Starting SAFE window focus procedure...")
        
        # Step 1: Find safe Flutter window
        window_info = self.get_safe_flutter_window()
        if not window_info:
            print("❌ No safe Flutter window found")
            return False
        
        window_id, window_desc = window_info
        
        # Step 2: Double-check it's not VS Code
        if self.is_vscode_window(window_desc):
            print(f"🛡️ SAFETY ABORT: Window appears to be VS Code: {window_desc}")
            return False
        
        # Step 3: Focus the window using window ID (more precise)
        try:
            subprocess.run(['wmctrl', '-i', '-a', window_id], check=True)
            time.sleep(1)  # Wait for focus change
            
            # Step 4: Verify the focus worked and it's still safe
            current_window = self.get_active_window()
            if current_window and self.is_vscode_window(current_window):
                print(f"🛡️ SAFETY ABORT: Active window is VS Code: {current_window}")
                return False
            
            print(f"✅ SAFELY focused Flutter window: {window_desc}")
            self.app_window = window_id
            return True
            
        except subprocess.CalledProcessError as e:
            print(f"❌ Failed to focus window: {e}")
            return False
    
    def get_active_window(self) -> Optional[str]:
        """Get the currently active window name"""
        try:
            result = subprocess.run(
                ['xdotool', 'getactivewindow', 'getwindowname'], 
                capture_output=True, text=True, timeout=5
            )
            return result.stdout.strip()
        except:
            return None
    
    def safe_type_text(self, text: str, field_name: str = "") -> bool:
        """🛡️ SAFELY type text with pre-typing validation"""
        print(f"🔒 SAFE TYPE: Preparing to type {field_name}: '{text}'")
        
        # Step 1: Verify we still have a safe window
        current_window = self.get_active_window()
        if not current_window:
            print("❌ SAFETY ABORT: Cannot determine active window")
            return False
        
        if self.is_vscode_window(current_window):
            print(f"🛡️ SAFETY ABORT: Active window is VS Code: {current_window}")
            print("🛡️ Will NOT type to avoid file corruption!")
            return False
        
        print(f"✅ SAFE: Active window verified as non-VS Code: {current_window}")
        
        # Step 2: Clear existing content safely
        try:
            subprocess.run(['xdotool', 'key', 'ctrl+a'], check=True)
            time.sleep(0.2)
        except Exception as e:
            print(f"❌ Failed to select all: {e}")
            return False
        
        # Step 3: Type the text character by character with delay
        try:
            for char in text:
                # Quick safety check every few characters
                if len(text) > 10:  # For long texts, do extra checks
                    current_check = self.get_active_window()
                    if current_check and self.is_vscode_window(current_check):
                        print("🛡️ SAFETY ABORT: VS Code detected during typing!")
                        return False
                
                subprocess.run(['xdotool', 'type', '--delay', str(int(self.typing_delay * 1000)), char])
            
            print(f"✅ SAFELY typed: '{text}' in {field_name}")
            return True
            
        except Exception as e:
            print(f"❌ Failed to type text: {e}")
            return False
    
    def safe_send_key(self, key: str, action_name: str = "") -> bool:
        """🛡️ SAFELY send key with validation"""
        print(f"🔒 SAFE KEY: {action_name}: {key}")
        
        # Safety check before key press
        current_window = self.get_active_window()
        if current_window and self.is_vscode_window(current_window):
            print(f"🛡️ SAFETY ABORT: Active window is VS Code: {current_window}")
            return False
        
        try:
            subprocess.run(['xdotool', 'key', key], check=True)
            time.sleep(0.3)  # Wait for UI response
            print(f"✅ SAFE KEY sent: {key}")
            return True
            
        except subprocess.CalledProcessError as e:
            print(f"❌ Failed to send key: {e}")
            return False
    
    def cleanup_existing_processes(self):
        """Kill any existing Flutter processes to prevent conflicts"""
        try:
            subprocess.run(["pkill", "-f", "flutter"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            subprocess.run(["pkill", "-f", "dejtingapp"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            subprocess.run(["pkill", "-f", "main_demo"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            time.sleep(2)
            print("🧹 Cleaned up existing Flutter processes")
        except Exception as e:
            print(f"⚠️ Process cleanup warning: {str(e)}")

    def start_flutter_app(self) -> bool:
        """Start the Flutter app and return success status"""
        try:
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
            
            return True
            
        except Exception as e:
            print(f"❌ Failed to start Flutter app: {str(e)}")
            return False

    def safe_registration_demo(self, user_data: dict) -> bool:
        """🛡️ SAFE registration demo with multiple safety checks"""
        print("🔒 Starting SAFE registration demonstration...")
        
        # Step 1: Ensure safe window focus
        if not self.safe_focus_flutter_window():
            print("❌ Cannot safely focus Flutter window - aborting")
            return False
        
        # Step 2: Fill first name
        if 'firstName' in user_data:
            if not self.safe_type_text(user_data['firstName'], "First Name"):
                return False
            if not self.safe_send_key("Tab", "Move to Last Name"):
                return False
        
        # Step 3: Fill last name
        if 'lastName' in user_data:
            if not self.safe_type_text(user_data['lastName'], "Last Name"):
                return False
            if not self.safe_send_key("Tab", "Move to Email"):
                return False
        
        # Step 4: Fill email
        if 'email' in user_data:
            if not self.safe_type_text(user_data['email'], "Email"):
                return False
            if not self.safe_send_key("Tab", "Move to Password"):
                return False
        
        # Step 5: Fill password
        if 'password' in user_data:
            if not self.safe_type_text(user_data['password'], "Password"):
                return False
        
        # Step 6: Submit form
        if not self.safe_send_key("Return", "Submit Registration"):
            return False
        
        print("✅ SAFE registration demonstration completed!")
        return True

    def safe_login_demo(self, email: str, password: str) -> bool:
        """🛡️ SAFE login demo with safety checks"""
        print("🔒 Starting SAFE login demonstration...")
        
        if not self.safe_focus_flutter_window():
            print("❌ Cannot safely focus Flutter window - aborting")
            return False
        
        # Fill email
        if not self.safe_type_text(email, "Email"):
            return False
        if not self.safe_send_key("Tab", "Move to Password"):
            return False
        
        # Fill password
        if not self.safe_type_text(password, "Password"):
            return False
        
        # Submit
        if not self.safe_send_key("Return", "Submit Login"):
            return False
        
        print("✅ SAFE login demonstration completed!")
        return True

    def stop_flutter_app(self):
        """Stop the Flutter app if running"""
        if self.flutter_process:
            self.flutter_process.terminate()
            self.flutter_process = None
            time.sleep(2)
        
        self.cleanup_existing_processes()
        print("🛑 Flutter app stopped")

# Example usage
if __name__ == "__main__":
    automator = SafeFlutterAppAutomator()
    
    # Test window detection
    window_info = automator.get_safe_flutter_window()
    if window_info:
        print(f"✅ Safe Flutter window found: {window_info[1]}")
        
        # Test safe focus
        if automator.safe_focus_flutter_window():
            print("✅ Safe focus successful")
        else:
            print("❌ Safe focus failed")
    else:
        print("❌ No safe Flutter window found")
