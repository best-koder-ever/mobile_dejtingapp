#!/usr/bin/env python3
"""
Ubuntu Keyring Password Sync Script
===================================

This script helps you change your keyring password to match your Ubuntu
login password, which will eliminate password prompts on startup.
"""

import subprocess
import os
import getpass

def run_cmd(cmd):
    """Run a command and return success status and output."""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        return result.returncode == 0, result.stdout.strip(), result.stderr.strip()
    except Exception as e:
        return False, "", str(e)

def main():
    print("🔐 Ubuntu Keyring Password Sync")
    print("=" * 40)
    print()
    print("This will help you change your keyring password to match")
    print("your Ubuntu login password for automatic unlock.")
    print()
    
    # Method 1: Try using secret-tool (if available)
    success, _, _ = run_cmd("which secret-tool")
    if success:
        print("✅ secret-tool is available")
        print()
        print("OPTION 1: Using secret-tool (Command Line)")
        print("-" * 45)
        print("Run this command to change your keyring password:")
        print()
        print("secret-tool lock --collection=login")
        print()
        print("Then when prompted, set the new password to match")
        print("your Ubuntu login password.")
        print()
    
    # Method 2: Manual reset (most reliable)
    print("OPTION 2: Reset Method (Most Reliable)")
    print("-" * 45)
    print("1. Run the reset script we created:")
    print("   ./reset_keyring.sh")
    print()
    print("2. When it asks, type 'y' to confirm")
    print("3. Log out completely (not just lock screen)")
    print("4. Log back in")
    print("5. When Ubuntu asks for keyring password:")
    print("   - Enter your Ubuntu LOGIN password")
    print("   - This makes them the same, enabling auto-unlock")
    print()
    
    # Method 3: GUI method (if working)
    print("OPTION 3: Try GUI Method")
    print("-" * 45)
    print("If you can get the GUI working:")
    print()
    print("1. Open terminal and run:")
    print("   unset SNAP_CONTEXT && /usr/bin/seahorse")
    print()
    print("2. Or try:")
    print("   env -u SNAP_CONTEXT /usr/bin/seahorse")
    print()
    print("3. In the GUI:")
    print("   - Find 'Login' keyring")
    print("   - Right-click → Change Password")
    print("   - Set new password = your Ubuntu login password")
    print()
    
    # Method 4: Alternative approach
    print("OPTION 4: Alternative Tools")
    print("-" * 45)
    print("Install additional keyring tools:")
    print("sudo apt install python3-keyring libsecret-tools")
    print()
    print("Then use Python keyring module:")
    print("python3 -c \"import keyring; keyring.get_password('test', 'test')\"")
    print()
    
    print("🎯 RECOMMENDED APPROACH:")
    print("=" * 40)
    print("Use OPTION 2 (Reset Method) - it's the most reliable!")
    print("Just run: ./reset_keyring.sh")
    print()
    print("After reset, when you log back in, use your Ubuntu")
    print("login password for the keyring. This syncs them up.")

if __name__ == "__main__":
    main()
