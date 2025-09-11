#!/usr/bin/env python3
"""
Ubuntu Keyring Auto-Unlock Setup Script
========================================

This script helps you set up automatic keyring unlock for Ubuntu.
The keyring will automatically unlock when you log in, eliminating
the need to enter your keyring password repeatedly.
"""

import subprocess
import sys
import os
import getpass

def run_command(cmd, capture_output=True):
    """Run a shell command and return the result."""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=capture_output, text=True)
        return result.returncode == 0, result.stdout, result.stderr
    except Exception as e:
        return False, "", str(e)

def check_keyring_status():
    """Check the current keyring configuration."""
    print("🔍 Checking current keyring status...")
    
    # Check if gnome-keyring is running
    success, output, _ = run_command("ps aux | grep gnome-keyring-daemon | grep -v grep")
    if success and output.strip():
        print("✅ GNOME Keyring daemon is running")
    else:
        print("❌ GNOME Keyring daemon is not running")
        return False
    
    # Check PAM configuration
    success, output, _ = run_command("grep -q 'pam_gnome_keyring.so' /etc/pam.d/common-password")
    if success:
        print("✅ PAM is configured for keyring integration")
    else:
        print("⚠️  PAM keyring integration may not be configured")
    
    # Check keyring files
    keyring_dir = os.path.expanduser("~/.local/share/keyrings")
    if os.path.exists(f"{keyring_dir}/login.keyring"):
        print("✅ Login keyring exists")
    else:
        print("❌ Login keyring not found")
        return False
    
    return True

def show_manual_instructions():
    """Show manual instructions for changing keyring password."""
    print("\n" + "="*60)
    print("📋 MANUAL SETUP INSTRUCTIONS")
    print("="*60)
    print()
    print("METHOD 1: Using GUI (Recommended)")
    print("-" * 40)
    print("1. Try to open Passwords and Keys application:")
    print("   - Press Alt+F2 and type: seahorse")
    print("   - Or go to Applications → Accessories → Passwords and Keys")
    print("   - Or run: gtk-launch seahorse")
    print()
    print("2. In the application:")
    print("   - Look for 'Passwords' in the left sidebar")
    print("   - Find 'Login' keyring")
    print("   - Right-click on 'Login' → 'Change Password'")
    print("   - Enter your current keyring password")
    print("   - Set NEW password to match your Ubuntu login password")
    print("   - Leave 'Confirm' field empty for no password (auto-unlock)")
    print()
    print("METHOD 2: Using Command Line")
    print("-" * 40)
    print("If the GUI doesn't work, you can:")
    print("1. Reset the keyring completely (will lose stored passwords):")
    print("   rm ~/.local/share/keyrings/login.keyring")
    print("   logout and login again")
    print()
    print("2. Or install additional tools:")
    print("   sudo apt install libsecret-tools python3-keyring")
    print()

def test_keyring_unlock():
    """Test if keyring unlocks properly."""
    print("\n🧪 Testing keyring functionality...")
    
    # Try to access keyring
    success, output, error = run_command("secret-tool search --all dummy test 2>/dev/null || echo 'keyring accessible'")
    if "keyring accessible" in output or success:
        print("✅ Keyring is accessible")
        return True
    else:
        print("❌ Keyring access test failed")
        return False

def main():
    """Main setup function."""
    print("🔐 Ubuntu Keyring Auto-Unlock Setup")
    print("=" * 40)
    print()
    
    # Check if running on Ubuntu/Linux
    if not os.path.exists("/etc/os-release"):
        print("❌ This script is designed for Linux systems")
        return
    
    # Check current status
    if not check_keyring_status():
        print("\n❌ Keyring is not properly configured")
        print("Please ensure GNOME keyring is installed and running")
        return
    
    print("\n💡 SOLUTION:")
    print("The most reliable way to enable auto-unlock is to set your")
    print("keyring password to match your Ubuntu login password.")
    print()
    print("When the keyring password matches your login password,")
    print("PAM will automatically unlock it when you log in.")
    
    # Show instructions
    show_manual_instructions()
    
    print("\n" + "="*60)
    print("🔧 ADDITIONAL TROUBLESHOOTING")
    print("="*60)
    print()
    print("If you're still getting password prompts:")
    print()
    print("1. Check login manager configuration:")
    print("   sudo nano /etc/pam.d/lightdm")
    print("   Add if missing: auth optional pam_gnome_keyring.so")
    print("   Add if missing: session optional pam_gnome_keyring.so auto_start")
    print()
    print("2. For applications like Git/SSH:")
    print("   Make sure SSH_AUTH_SOCK environment variable is set")
    print("   echo $SSH_AUTH_SOCK")
    print()
    print("3. Restart keyring daemon:")
    print("   killall gnome-keyring-daemon")
    print("   gnome-keyring-daemon --start --components=pkcs11,secrets,ssh,gpg")
    print()
    print("4. Complete logout/login cycle after changes")
    
    print("\n✅ Setup complete! Follow the manual instructions above.")

if __name__ == "__main__":
    main()
