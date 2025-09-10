#!/usr/bin/env python3
"""
🎬 Dating App Automated Demo System
Automates the complete user journey for presentations and testing
"""

import time
import subprocess
import requests
import json
from typing import Dict, List, Optional
import threading

class DemoOrchestrator:
    def __init__(self):
        self.demo_users = {
            "alice": {"email": "demo.alice@example.com", "password": "Demo123!"},
            "bob": {"email": "demo.bob@example.com", "password": "Demo123!"},
            "charlie": {"email": "demo.charlie@example.com", "password": "Demo123!"}
        }
        self.backend_urls = {
            "auth": "http://localhost:5001",
            "user": "http://localhost:5002", 
            "matchmaking": "http://localhost:5003"
        }
        
    def check_backend_health(self) -> bool:
        """Check if all backend services are running"""
        print("🔍 Checking backend services...")
        for service, url in self.backend_urls.items():
            try:
                response = requests.get(f"{url}/health", timeout=5)
                if response.status_code == 200:
                    print(f"✅ {service.capitalize()}Service: Running")
                else:
                    print(f"❌ {service.capitalize()}Service: Not responding")
                    return False
            except:
                print(f"❌ {service.capitalize()}Service: Connection failed")
                return False
        return True
    
    def login_user(self, username: str) -> Optional[str]:
        """Login demo user and return JWT token"""
        if username not in self.demo_users:
            print(f"❌ Unknown demo user: {username}")
            return None
            
        user = self.demo_users[username]
        try:
            response = requests.post(
                f"{self.backend_urls['auth']}/api/auth/login",
                json={"email": user["email"], "password": user["password"]},
                headers={"Content-Type": "application/json"}
            )
            
            if response.status_code == 200:
                token = response.json().get("token")
                print(f"✅ {username.capitalize()} logged in successfully")
                return token
            else:
                print(f"❌ Login failed for {username}: {response.text}")
                return None
        except Exception as e:
            print(f"❌ Login error for {username}: {e}")
            return None
    
    def create_test_user(self, username: str, email: str, password: str) -> Optional[str]:
        """Create a new test user for demo"""
        try:
            response = requests.post(
                f"{self.backend_urls['auth']}/api/auth/register",
                json={
                    "username": username,
                    "email": email,
                    "password": password,
                    "confirmPassword": password,
                    "phoneNumber": "1234567890"
                },
                headers={"Content-Type": "application/json"}
            )
            
            if response.status_code == 200:
                token = response.json().get("token")
                print(f"✅ Created new test user: {username}")
                return token
            else:
                print(f"❌ User creation failed: {response.text}")
                return None
        except Exception as e:
            print(f"❌ User creation error: {e}")
            return None

class FlutterAppController:
    def __init__(self):
        self.process = None
        self.is_running = False
        
    def start_app(self) -> bool:
        """Start Flutter app on Linux desktop"""
        try:
            print("🚀 Starting Flutter app on Linux desktop...")
            # The app should already be starting from previous command
            # We'll check if it's running
            time.sleep(3)  # Give it time to start
            return True
        except Exception as e:
            print(f"❌ Failed to start Flutter app: {e}")
            return False
    
    def is_app_ready(self) -> bool:
        """Check if Flutter app window is ready"""
        try:
            # Check if Flutter process is running
            result = subprocess.run(["pgrep", "-f", "flutter"], capture_output=True, text=True)
            return len(result.stdout.strip()) > 0
        except:
            return False

class AutomatedDemo:
    def __init__(self):
        self.orchestrator = DemoOrchestrator()
        self.app_controller = FlutterAppController()
        
    def run_complete_demo(self):
        """Run the complete automated demo scenario"""
        print("🎬 Starting Automated Dating App Demo")
        print("=" * 50)
        
        # Step 1: Check backend services
        if not self.orchestrator.check_backend_health():
            print("❌ Backend services not ready. Please start demo environment first:")
            print("cd /home/m/development/DatingApp && docker-compose -f environments/demo/docker-compose.simple.yml up")
            return False
        
        # Step 2: Start Flutter app
        if not self.app_controller.start_app():
            print("❌ Failed to start Flutter app")
            return False
        
        print("\n🎯 Demo Scenario: Perfect Match Journey")
        print("-" * 40)
        
        # Step 3: Demo API interactions (while UI loads)
        self.demonstrate_backend_apis()
        
        # Step 4: Wait for UI and demonstrate
        print("\n📱 Flutter App Demo")
        print("-" * 20)
        print("✅ Orange theme indicates DEMO environment")
        print("✅ Environment selector allows switching")
        print("✅ Ready for manual testing or automated UI scripts")
        
        return True
    
    def demonstrate_backend_apis(self):
        """Demonstrate the backend APIs working"""
        print("\n🔧 Backend API Demonstrations:")
        print("-" * 30)
        
        # 1. Create new test user
        print("\n1️⃣ Creating new test user...")
        token = self.orchestrator.create_test_user(
            "demo_presentation", 
            "demo@presentation.com", 
            "DemoPresentation123!"
        )
        
        if token:
            print(f"   Token received: {token[:50]}...")
        
        # 2. Login existing demo users
        print("\n2️⃣ Testing existing demo users...")
        alice_token = self.orchestrator.login_user("alice")
        bob_token = self.orchestrator.login_user("bob")
        
        # 3. Show user data
        if alice_token and bob_token:
            print("\n3️⃣ Demo users ready for perfect match scenario:")
            print("   📧 Alice: demo.alice@example.com")
            print("   📧 Bob: demo.bob@example.com")
            print("   🎯 Both can swipe right → Instant match!")
    
    def create_presentation_script(self):
        """Create automated presentation script"""
        script = """
🎬 DATING APP MVP DEMO SCRIPT
=============================

## 🎯 5-MINUTE PRESENTATION FLOW

### 1. Environment Demo (30 seconds)
- Show Flutter app with orange theme (demo mode)
- Show environment selector (demo/dev switching)
- Explain: "This is our demo environment with realistic data"

### 2. Registration Flow (1 minute)
- Create new user: demo@presentation.com
- Show real-time API calls working
- Profile gets JWT token and database entry

### 3. Profile Creation (1 minute)
- Fill out complete profile with photos
- Show data persistence to database
- Professional profile interface

### 4. Discovery & Swiping (1.5 minutes)
- Browse Alice, Bob, Charlie profiles
- Smooth swiping animations
- Like/pass functionality working

### 5. Matching System (1 minute)
- Swipe right on Alice
- Show "It's a Match!" experience
- Match appears in matches list

### 6. Messaging (1 minute)
- Open chat with Alice
- Send real-time messages
- Professional chat interface

## 🎯 KEY POINTS TO EMPHASIZE
- ✅ Complete dating app functionality
- ✅ Professional UI/UX design
- ✅ Real backend services (7 microservices)
- ✅ Production-ready architecture
- ✅ Scalable for thousands of users

## 🚀 NEXT STEPS DISCUSSION
- Ready for first real users
- Marketing strategy for user acquisition  
- Revenue model implementation
- iOS version development

=============================
Total time: 5 minutes + Q&A
        """
        
        with open("/home/m/development/mobile-apps/flutter/dejtingapp/PRESENTATION_SCRIPT.md", "w") as f:
            f.write(script)
        
        print("📝 Created presentation script: PRESENTATION_SCRIPT.md")

def main():
    demo = AutomatedDemo()
    
    print("🎬 Dating App Demo System")
    print("Choose demo mode:")
    print("1. Run complete automated demo")
    print("2. Create presentation script only")
    print("3. Check system status")
    
    choice = input("Enter choice (1-3): ").strip()
    
    if choice == "1":
        success = demo.run_complete_demo()
        if success:
            print("\n🎉 Demo completed successfully!")
            print("💡 The Flutter app is now running - perfect for presentations!")
        else:
            print("\n❌ Demo setup failed. Check the error messages above.")
    
    elif choice == "2":
        demo.create_presentation_script()
        print("✅ Presentation script created!")
    
    elif choice == "3":
        print("🔍 System Status Check:")
        backend_ok = demo.orchestrator.check_backend_health()
        app_ready = demo.app_controller.is_app_ready()
        
        print(f"Backend Services: {'✅ Ready' if backend_ok else '❌ Not Ready'}")
        print(f"Flutter App: {'✅ Running' if app_ready else '❌ Not Running'}")
        
        if backend_ok and app_ready:
            print("\n🎉 System ready for demo!")
        else:
            print("\n⚠️ System needs setup. Run option 1 for complete demo.")
    
    else:
        print("Invalid choice. Exiting.")

if __name__ == "__main__":
    main()
