#!/usr/bin/env python3
"""
🛡️ QUICK SAFE DEMO TEST
======================

Runs a single demo scenario with VS Code protection and exits automatically.
Perfect for testing without manual interaction.
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from safe_demo_system import SafeJourneyDemoOrchestrator

def quick_demo_test():
    """Run a quick demo test and exit"""
    print("🛡️ Starting Quick Safe Demo Test...")
    
    demo = SafeJourneyDemoOrchestrator()
    
    # Check services first
    if not demo.check_all_services():
        print("❌ Backend services not running. Please start them first.")
        return False
    
    # Test window safety first
    print("\n🔍 Testing window safety...")
    demo.test_window_safety()
    
    # Run new user journey demo
    print("\n🎬 Running New User Journey Demo...")
    demo.demonstrate_new_user_journey()
    
    # Clean exit
    print("\n✅ Demo completed! Cleaning up...")
    if demo.flutter_running:
        demo.flutter_automator.stop_flutter_app()
    
    print("👋 Quick demo test finished!")
    return True

if __name__ == "__main__":
    quick_demo_test()
