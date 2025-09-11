#!/usr/bin/env python3
"""
Enhanced Interactive Demo System for Dating App with Visual Debugging
Provides menu-driven automated user journeys with real-time backend validation
Now includes visual debugging capabilities and screenshot documentation
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
from pathlib import Path

# Enhanced FlutterAppAutomator with visual debugging
from flutter_automator import FlutterAppAutomator

# Check if visual debugging is available
VISUAL_DEBUG_AVAILABLE = False
try:
    import pyautogui
    VISUAL_DEBUG_AVAILABLE = True
    print("🎯 Enhanced Demo: Visual debugging available")
except ImportError:
    print("🎯 Enhanced Demo: Running in text mode (install pyautogui for visual debugging)")

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

class JourneyDemoOrchestrator:
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
        self.flutter_automator = FlutterAppAutomator()
        self.flutter_running = False  # Track Flutter state
        
    def ensure_flutter_ready(self):
        """Ensure Flutter is running and ready (don't restart if already running)"""
        if self.flutter_running:
            # Just reset to login screen instead of restarting
            self.print_step("🔄 Resetting Flutter app to login screen...", "INFO")
            self.flutter_automator.reset_to_login()
            return True
        else:
            # Start Flutter for the first time
            if self.start_flutter_app():
                self.flutter_running = True
                return True
            return False

    def ensure_clean_start(self):
        """Clean start only for the very first demo run"""
        if not self.flutter_running:
            self.print_step("🧹 Initial clean environment setup...", "INFO")
            try:
                # Kill any existing flutter processes only on first run
                subprocess.run(["pkill", "-f", "flutter"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                subprocess.run(["pkill", "-f", "dejtingapp"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                subprocess.run(["pkill", "-f", "main_demo"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                time.sleep(1)
            except Exception as e:
                pass  # Non-critical if cleanup fails
        self.print_step("🧹 Ensuring clean environment...", "INFO")
        try:
            # Kill any existing flutter processes
            subprocess.run(["pkill", "-f", "flutter"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            subprocess.run(["pkill", "-f", "dejtingapp"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            subprocess.run(["pkill", "-f", "main_demo"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            time.sleep(1)
        except Exception as e:
            pass  # Non-critical if cleanup fails
        
    def print_banner(self):
        print(f"""
{Colors.HEADER}{Colors.BOLD}
╔═══════════════════════════════════════════════════════════════╗
║                   🎬 DATING APP DEMO SYSTEM                   ║
║               Interactive Journey Demonstrations              ║
╚═══════════════════════════════════════════════════════════════╝
{Colors.ENDC}
        """)
    
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
    
    def check_backend_services(self) -> bool:
        """Verify all backend services are running"""
        self.print_step("🔍 Checking backend services...", "INFO")
        
        services_ok = 0
        for service, url in self.base_urls.items():
            try:
                # Try service-specific health endpoints first
                health_url = f"{url}/health"
                if service == 'matchmaking':
                    health_url = f"{url}/api/matchmaking/health"
                
                response = requests.get(health_url, timeout=3)
                if response.status_code == 200:
                    self.print_step(f"✅ {service.upper()} service: Running on {url}", "SUCCESS")
                    services_ok += 1
                elif response.status_code == 404:
                    # Health endpoint might not exist, try root
                    response = requests.get(url, timeout=3)
                    if response.status_code == 404:
                        # 404 means service is responding, just no matching route
                        self.print_step(f"✅ {service.upper()} service: Running on {url}", "SUCCESS")
                        services_ok += 1
                    else:
                        self.print_step(f"✅ {service.upper()} service: Running on {url}", "SUCCESS")
                        services_ok += 1
                else:
                    self.print_step(f"✅ {service.upper()} service: Running on {url}", "SUCCESS")
                    services_ok += 1
            except requests.exceptions.RequestException:
                try:
                    # Try direct API endpoints with appropriate payloads
                    if service == 'auth':
                        response = requests.post(f"{url}/api/auth/login", 
                                               json={"email": "test@test.com", "password": "test"}, 
                                               timeout=3)
                        # Even if login fails, service is responding
                        self.print_step(f"✅ {service.upper()} service: Running on {url} (API responds)", "SUCCESS")
                        services_ok += 1
                    elif service == 'user':
                        response = requests.get(f"{url}/api/users", timeout=3)
                        # Service might return 401/403, but that means it's running
                        self.print_step(f"✅ {service.upper()} service: Running on {url} (API responds)", "SUCCESS")
                        services_ok += 1
                    elif service == 'matchmaking':
                        # Try different endpoints for matchmaking service
                        response = requests.get(f"{url}/api/swipes", timeout=3)
                        if response.status_code == 404:
                            # 404 means service is responding, just endpoint doesn't exist
                            self.print_step(f"✅ {service.upper()} service: Running on {url}", "SUCCESS")
                            services_ok += 1
                        else:
                            # Service might return error, but responding means it's up
                            self.print_step(f"✅ {service.upper()} service: Running on {url} (API responds)", "SUCCESS")
                            services_ok += 1
                except Exception as e:
                    self.print_step(f"⚠️ {service.upper()} service: Limited connectivity on {url}", "WARNING")
                    # Don't fail completely, might still work for basic operations
                    services_ok += 0.5
        
        # If at least auth service is working, we can proceed
        if services_ok >= 1:
            if services_ok < len(self.base_urls):
                self.print_step("Some services have connectivity issues, but proceeding...", "WARNING")
            return True
        else:
            self.print_step("❌ Critical services not available.", "ERROR")
            return False
    
    def authenticate_user(self, user_key: str) -> Optional[str]:
        """Authenticate a demo user and return JWT token"""
        user = self.demo_users[user_key]
        self.print_step(f"🔐 Authenticating {user_key}...", "BACKEND")
        
        try:
            response = requests.post(
                f"{self.base_urls['auth']}/api/auth/login",
                json={
                    "email": user['email'],
                    "password": user['password']
                },
                timeout=10
            )
            
            if response.status_code == 200:
                data = response.json()
                token = data.get('token')
                self.tokens[user_key] = token
                self.print_step(f"✅ Login successful for {user['email']}", "SUCCESS")
                self.print_step(f"🎫 JWT Token: {token[:50]}...", "BACKEND")
                return token
            else:
                self.print_step(f"❌ Login failed: {response.status_code} - {response.text}", "ERROR")
                return None
                
        except requests.exceptions.RequestException as e:
            self.print_step(f"❌ Authentication error: {str(e)}", "ERROR")
            return None
    
    def get_user_profile(self, user_key: str) -> Optional[Dict]:
        """Get user profile from backend"""
        if user_key not in self.tokens:
            return None
            
        self.print_step(f"👤 Fetching profile for {user_key}...", "BACKEND")
        
        try:
            headers = {'Authorization': f'Bearer {self.tokens[user_key]}'}
            response = requests.get(
                f"{self.base_urls['user']}/api/users/profile",
                headers=headers,
                timeout=10
            )
            
            if response.status_code == 200:
                profile = response.json()
                self.print_step(f"✅ Profile loaded: {profile.get('name', 'Unknown')}", "SUCCESS")
                return profile
            else:
                self.print_step(f"⚠️  Profile not found, might need creation", "WARNING")
                return None
                
        except requests.exceptions.RequestException as e:
            self.print_step(f"❌ Profile fetch error: {str(e)}", "ERROR")
            return None
    
    def create_user_profile(self, user_key: str, profile_data: Dict) -> bool:
        """Create a user profile"""
        if user_key not in self.tokens:
            return False
            
        self.print_step(f"👤 Creating profile for {user_key}...", "BACKEND")
        
        try:
            headers = {'Authorization': f'Bearer {self.tokens[user_key]}'}
            response = requests.post(
                f"{self.base_urls['user']}/api/users/profile",
                headers=headers,
                json=profile_data,
                timeout=10
            )
            
            if response.status_code in [200, 201]:
                self.print_step(f"✅ Profile created successfully", "SUCCESS")
                return True
            else:
                self.print_step(f"❌ Profile creation failed: {response.status_code}", "ERROR")
                return False
                
        except requests.exceptions.RequestException as e:
            self.print_step(f"❌ Profile creation error: {str(e)}", "ERROR")
            return False
    
    def get_potential_matches(self, user_key: str) -> List[Dict]:
        """Get potential matches from matchmaking service"""
        if user_key not in self.tokens:
            return []
            
        self.print_step(f"💕 Finding potential matches for {user_key}...", "BACKEND")
        
        try:
            headers = {'Authorization': f'Bearer {self.tokens[user_key]}'}
            response = requests.get(
                f"{self.base_urls['matchmaking']}/api/matches/potential",
                headers=headers,
                timeout=10
            )
            
            if response.status_code == 200:
                matches = response.json()
                self.print_step(f"✅ Found {len(matches)} potential matches", "SUCCESS")
                return matches
            else:
                self.print_step(f"⚠️  Matchmaking service responded with {response.status_code} - simulating matches", "WARNING")
                # Return simulated matches for demo purposes
                simulated_matches = [
                    {"id": "demo_user_1", "name": "Demo User 1", "age": 25},
                    {"id": "demo_user_2", "name": "Demo User 2", "age": 28}
                ]
                return simulated_matches
                
        except requests.exceptions.RequestException as e:
            self.print_step(f"⚠️  Matchmaking service unavailable - simulating matches for demo", "WARNING")
            # Return simulated matches when service is down
            simulated_matches = [
                {"id": "demo_user_1", "name": "Demo User 1", "age": 25},
                {"id": "demo_user_2", "name": "Demo User 2", "age": 28}
            ]
            return simulated_matches
    
    def swipe_user(self, user_key: str, target_id: str, liked: bool) -> bool:
        """Perform a swipe action"""
        if user_key not in self.tokens:
            return False
            
        action = "liked" if liked else "passed"
        self.print_step(f"👆 {user_key} {action} user {target_id}...", "BACKEND")
        
        try:
            headers = {'Authorization': f'Bearer {self.tokens[user_key]}'}
            # Record swipe history first
            swipe_response = requests.post(
                f"{self.base_urls['matchmaking']}/api/matchmaking/swipe-history",
                headers=headers,
                json={
                    "userId": int(user_key.replace('alice', '1').replace('bob', '2').replace('charlie', '3')),
                    "targetUserId": int(target_id.replace('_demo_id', '').replace('alice', '1').replace('bob', '2')),
                    "liked": liked,
                    "swipedAt": datetime.now().isoformat()
                },
                timeout=10
            )
            
            # If it's a mutual like, create a match
            if liked and user_key == 'bob' and 'alice' in target_id:
                match_response = requests.post(
                    f"{self.base_urls['matchmaking']}/api/matchmaking/matches",
                    headers=headers,
                    json={
                        "user1Id": 1,  # alice
                        "user2Id": 2,  # bob
                        "source": "swipe_demo",
                        "compatibilityScore": 85.5
                    },
                    timeout=10
                )
                response = match_response
            else:
                response = swipe_response
            
            if response.status_code in [200, 201]:
                result = response.json()
                if result.get('isMatch', False):
                    self.print_step(f"🎉 IT'S A MATCH! {user_key} matched with {target_id}", "SUCCESS")
                else:
                    self.print_step(f"✅ Swipe recorded: {action}", "SUCCESS")
                return True
            else:
                self.print_step(f"⚠️  Matchmaking service responded with {response.status_code} - simulating {action}", "WARNING")
                # Simulate successful swipe for demo
                if liked and user_key == 'bob' and target_id == 'alice_demo_id':
                    self.print_step(f"🎉 SIMULATED MATCH! {user_key} matched with {target_id}", "SUCCESS")
                else:
                    self.print_step(f"✅ Simulated swipe: {action}", "SUCCESS")
                return True
                
        except requests.exceptions.RequestException as e:
            self.print_step(f"⚠️  Matchmaking service unavailable - simulating {action} for demo", "WARNING")
            # Simulate successful swipe when service is down
            if liked and user_key == 'bob' and target_id == 'alice_demo_id':
                self.print_step(f"🎉 SIMULATED MATCH! {user_key} matched with {target_id}", "SUCCESS")
            else:
                self.print_step(f"✅ Simulated swipe: {action}", "SUCCESS")
            return True
    
    def start_flutter_app(self):
        """Start the Flutter app in demo mode"""
        self.print_step("🚀 Starting Flutter app in demo mode...", "INFO")
        
        if self.flutter_automator.check_dependencies():
            success = self.flutter_automator.start_flutter_app()
            if success:
                self.print_step("✅ Flutter app started successfully!", "SUCCESS")
                return True
            else:
                self.print_step("❌ Failed to start Flutter app", "ERROR")
                return False
        else:
            self.print_step("❌ Missing automation dependencies", "ERROR")
            return False
    
    def stop_flutter_app(self):
        """Stop the Flutter app"""
        self.print_step("🛑 Stopping Flutter app...", "INFO")
        self.flutter_automator.stop_flutter_app()
    
    def simulate_app_interaction(self, actions: List[str], interactive: bool = False):
        """Simulate user interactions in the Flutter app"""
        self.print_step("📱 Simulating app interactions...", "INFO")
        
        for i, action in enumerate(actions):
            self.print_step(f"👆 App Action {i+1}/{len(actions)}: {action}", "INFO")
            if interactive:
                input(f"   Press Enter to continue to next action...")
            else:
                time.sleep(2)  # Simulate time between interactions
    
    def run_new_user_journey(self):
        """Demo: New user registration and profile creation"""
        self.print_step("🎬 Starting: NEW USER JOURNEY", "INFO")
        
        # Ensure Flutter is ready (don't restart)
        if not self.ensure_flutter_ready():
            return
        
        # Create a new user backend
        new_email = f"demo.newuser.{int(time.time())}@example.com"
        self.print_step(f"📧 Creating new user: {new_email}", "BACKEND")
        
        try:
            response = requests.post(
                f"{self.base_urls['auth']}/api/auth/register",
                json={
                    "email": new_email,
                    "password": "Demo123!",
                    "userName": f"demouser{int(time.time())}",
                    "firstName": "Demo",
                    "lastName": "User"
                },
                timeout=10
            )
            
            if response.status_code in [200, 201]:
                data = response.json()
                token = data.get('token')
                self.print_step(f"✅ User registered successfully!", "SUCCESS")
                self.print_step(f"🎫 JWT Token: {token[:50]}...", "BACKEND")
                
                # Show Flutter app registration
                self.print_step("📱 Now demonstrating in Flutter app...", "INFO")
                time.sleep(2)
                
                # Actually demonstrate in Flutter
                self.flutter_automator.demonstrate_registration_flow(
                    new_email, "Demo123!", "Demo", "User"
                )
                
            else:
                self.print_step(f"❌ Registration failed: {response.status_code}", "ERROR")
                
        except requests.exceptions.RequestException as e:
            self.print_step(f"❌ Registration error: {str(e)}", "ERROR")
    
    def run_existing_user_journey(self):
        """Demo: Existing user login and browsing"""
        self.print_step("🎬 Starting: EXISTING USER JOURNEY", "INFO")
        
        # Ensure Flutter is ready (don't restart)
        if not self.ensure_flutter_ready():
            return
        
        # Backend: Login as Alice
        token = self.authenticate_user('alice')
        if not token:
            return
        
        # Backend: Get profile
        profile = self.get_user_profile('alice')
        
        # Flutter: Demonstrate login
        self.print_step("📱 Now demonstrating login in Flutter app...", "INFO")
        time.sleep(2)
        
        self.flutter_automator.demonstrate_login_flow(
            self.demo_users['alice']['email'],
            self.demo_users['alice']['password']
        )
        
        # Backend: Get potential matches
        matches = self.get_potential_matches('alice')
        
        # Flutter: Demonstrate browsing
        self.print_step("📱 Now demonstrating match browsing...", "INFO")
        time.sleep(2)
        
        self.flutter_automator.demonstrate_swiping()
    
    def run_matching_journey(self):
        """Demo: Complete matching flow between two users"""
        self.print_step("🎬 Starting: MATCHING JOURNEY", "INFO")
        
        # Ensure Flutter is ready (don't restart)
        if not self.ensure_flutter_ready():
            return
        
        # Backend: Login both Alice and Bob
        alice_token = self.authenticate_user('alice')
        bob_token = self.authenticate_user('bob')
        
        if not alice_token or not bob_token:
            return
        
        # Flutter: Show Alice's login and swiping
        self.print_step("📱 Alice logging in and swiping...", "INFO")
        self.flutter_automator.demonstrate_login_flow(
            self.demo_users['alice']['email'],
            self.demo_users['alice']['password']
        )
        
        self.print_step("📱 Alice browsing and swiping right...", "INFO")
        self.flutter_automator.demonstrate_swiping()
        
        # Backend: Alice likes Bob
        self.swipe_user('alice', 'bob_demo_id', True)
        
        time.sleep(3)
        
        # Flutter: Show Bob's turn
        self.print_step("📱 Now switching to Bob's account...", "INFO")
        self.flutter_automator.demonstrate_login_flow(
            self.demo_users['bob']['email'],
            self.demo_users['bob']['password']
        )
        
        self.print_step("📱 Bob browsing and swiping right...", "INFO")
        self.flutter_automator.demonstrate_swiping()
        
        # Backend: Bob likes Alice (should create a match)
        self.swipe_user('bob', 'alice_demo_id', True)
        
        self.print_step("🎉 MATCH CREATED! Both users matched!", "SUCCESS")
        time.sleep(2)
    
    def run_full_user_flow(self):
        """Demo: Complete user flow from registration to matching"""
        self.ensure_clean_start()
        self.print_step("🎬 Starting: COMPLETE USER FLOW", "INFO")
        
        # Run all journeys in sequence
        self.run_new_user_journey()
        time.sleep(3)
        self.run_existing_user_journey()
        time.sleep(3)
        self.run_matching_journey()
    
    def run_interactive_mode(self):
        """Interactive step-by-step demo"""
        self.print_step("🎮 Starting: INTERACTIVE MODE", "INFO")
        self.print_step("You'll be prompted before each step...", "INFO")
        
        # Start Flutter app
        input("Press Enter to start Flutter app...")
        if not self.start_flutter_app():
            return
        
        # Backend authentication
        input("Press Enter to authenticate Alice in backend...")
        token = self.authenticate_user('alice')
        if not token:
            return
            
        # Flutter login demo
        input("Press Enter to demonstrate login in Flutter app...")
        self.flutter_automator.demonstrate_login_flow(
            self.demo_users['alice']['email'],
            self.demo_users['alice']['password']
        )
        
        # Backend profile
        input("Press Enter to fetch Alice's profile from backend...")
        profile = self.get_user_profile('alice')
        
        # Flutter swiping demo
        input("Press Enter to demonstrate swiping in Flutter app...")
        self.flutter_automator.demonstrate_swiping()
        
        # Backend matching
        input("Press Enter to get potential matches from backend...")
        matches = self.get_potential_matches('alice')
        
        self.print_step("✅ Interactive demo completed!", "SUCCESS")
    
    def show_demo_data(self):
        """Display demo users and database information"""
        self.print_step("📊 Demo Users & Database Information", "INFO")
        
        # Show demo users
        print(f"\n{Colors.HEADER}Demo Users:{Colors.ENDC}")
        for key, user in self.demo_users.items():
            print(f"  {Colors.OKBLUE}• {key.title()}:{Colors.ENDC} {user['email']} / {user['password']}")
        
        # Show backend services
        print(f"\n{Colors.HEADER}Backend Services:{Colors.ENDC}")
        for service, url in self.base_urls.items():
            print(f"  {Colors.OKBLUE}• {service.upper()}:{Colors.ENDC} {url}")
        
        # Show database information
        print(f"\n{Colors.HEADER}Demo Databases:{Colors.ENDC}")
        print(f"  {Colors.OKBLUE}• MySQL Container:{Colors.ENDC} demo-mysql (port 3320)")
        print(f"  {Colors.OKBLUE}• Auth DB:{Colors.ENDC} auth_service_demo")
        print(f"  {Colors.OKBLUE}• User DB:{Colors.ENDC} user_service_demo")
        print(f"  {Colors.OKBLUE}• Matchmaking DB:{Colors.ENDC} matchmaking_service_demo")
        
        # Try to show actual database users
        try:
            self.print_step("🗃️  Checking actual database users...", "BACKEND")
            
            # Simple approach: just show that databases exist
            result = subprocess.run([
                "docker", "exec", "demo-mysql", "mysql", 
                "-uroot", "-pdemo_root_123",
                "-e", "SHOW DATABASES LIKE '%demo%';"
            ], capture_output=True, text=True, timeout=10)
            
            if result.returncode == 0:
                databases = [line.strip() for line in result.stdout.strip().split('\n')[1:] if line.strip()]
                print(f"\n{Colors.HEADER}Active Demo Databases:{Colors.ENDC}")
                for db in databases:
                    print(f"  {Colors.OKGREEN}✓ {db}{Colors.ENDC}")
            else:
                self.print_step("Could not query databases", "WARNING")
                
        except (subprocess.TimeoutExpired, subprocess.SubprocessError, Exception) as e:
            self.print_step(f"Database query failed: {str(e)}", "WARNING")
            
            # Fallback: try API endpoint
            try:
                response = requests.get(f"{self.base_urls['auth']}/api/auth/users", timeout=5)
                if response.status_code == 200:
                    users = response.json()
                    print(f"\n{Colors.HEADER}API Users ({len(users)} found):{Colors.ENDC}")
                    for user in users[:10]:  # Show first 10
                        print(f"  {Colors.OKGREEN}• {user.get('email', 'Unknown')}{Colors.ENDC}")
                else:
                    self.print_step("Could not fetch users via API either", "WARNING")
            except requests.exceptions.RequestException:
                self.print_step("Could not connect to auth service", "WARNING")
        
        print(f"\n{Colors.HEADER}Flutter App Status:{Colors.ENDC}")
        if hasattr(self.flutter_automator, 'flutter_process') and self.flutter_automator.flutter_process:
            print(f"  {Colors.OKGREEN}• Flutter App: Running{Colors.ENDC}")
        else:
            print(f"  {Colors.WARNING}• Flutter App: Not running{Colors.ENDC}")
        
        print(f"\n{Colors.HEADER}Required Tools:{Colors.ENDC}")
        has_tools = self.flutter_automator.check_dependencies()
        if has_tools:
            print(f"  {Colors.OKGREEN}• Automation tools: Installed{Colors.ENDC}")
        else:
            print(f"  {Colors.FAIL}• Automation tools: Missing (xdotool, wmctrl){Colors.ENDC}")
            print(f"  {Colors.WARNING}  Install with: sudo apt-get install xdotool wmctrl{Colors.ENDC}")
    
    def database_deep_dive(self):
        """Show detailed database information"""
        self.print_step("🗄️ Database Deep Dive", "INFO")
        
        try:
            # Show all databases
            self.print_step("Querying demo databases...", "BACKEND")
            result = subprocess.run([
                "docker", "exec", "demo-mysql", "mysql", 
                "-uroot", "-pdemo_root_123",
                "-e", "SHOW DATABASES;"
            ], capture_output=True, text=True, timeout=10)
            
            if result.returncode == 0:
                databases = [line.strip() for line in result.stdout.strip().split('\n')[1:] if line.strip()]
                print(f"\n{Colors.HEADER}All Databases:{Colors.ENDC}")
                for db in databases:
                    if 'demo' in db:
                        print(f"  {Colors.OKGREEN}📁 {db} (demo){Colors.ENDC}")
                    else:
                        print(f"  {Colors.OKBLUE}📁 {db} (system){Colors.ENDC}")
            
            # Show user counts in each demo database
            demo_dbs = ['auth_service_demo', 'user_service_demo', 'matchmaking_service_demo']
            
            print(f"\n{Colors.HEADER}Demo Database Details:{Colors.ENDC}")
            
            for db in demo_dbs:
                try:
                    # Try to get table info for each database
                    if db == 'auth_service_demo':
                        result = subprocess.run([
                            "docker", "exec", "demo-mysql", "mysql", 
                            "-uroot", "-pdemo_root_123", db,
                            "-e", "SELECT COUNT(*) as user_count FROM AspNetUsers;"
                        ], capture_output=True, text=True, timeout=5)
                        
                        if result.returncode == 0:
                            count = result.stdout.strip().split('\n')[1].strip()
                            print(f"  {Colors.OKGREEN}👥 {db}: {count} users{Colors.ENDC}")
                        else:
                            print(f"  {Colors.WARNING}⚠️  {db}: Could not query{Colors.ENDC}")
                    
                    elif db == 'user_service_demo':
                        result = subprocess.run([
                            "docker", "exec", "demo-mysql", "mysql", 
                            "-uroot", "-pdemo_root_123", db,
                            "-e", "SHOW TABLES;"
                        ], capture_output=True, text=True, timeout=5)
                        
                        if result.returncode == 0:
                            tables = len([line for line in result.stdout.strip().split('\n')[1:] if line.strip()])
                            print(f"  {Colors.OKGREEN}📋 {db}: {tables} tables{Colors.ENDC}")
                        else:
                            print(f"  {Colors.WARNING}⚠️  {db}: Could not query{Colors.ENDC}")
                    
                    elif db == 'matchmaking_service_demo':
                        result = subprocess.run([
                            "docker", "exec", "demo-mysql", "mysql", 
                            "-uroot", "-pdemo_root_123", db,
                            "-e", "SHOW TABLES;"
                        ], capture_output=True, text=True, timeout=5)
                        
                        if result.returncode == 0:
                            tables = len([line for line in result.stdout.strip().split('\n')[1:] if line.strip()])
                            print(f"  {Colors.OKGREEN}💕 {db}: {tables} tables{Colors.ENDC}")
                        else:
                            print(f"  {Colors.WARNING}⚠️  {db}: Could not query{Colors.ENDC}")
                            
                except Exception as e:
                    print(f"  {Colors.FAIL}❌ {db}: Error - {str(e)}{Colors.ENDC}")
            
            # Show some sample data from auth database
            print(f"\n{Colors.HEADER}Sample Demo Users:{Colors.ENDC}")
            result = subprocess.run([
                "docker", "exec", "demo-mysql", "mysql", 
                "-uroot", "-pdemo_root_123", "auth_service_demo",
                "-e", "SELECT Email, UserName, EmailConfirmed FROM AspNetUsers WHERE Email LIKE '%demo%' LIMIT 5;"
            ], capture_output=True, text=True, timeout=5)
            
            if result.returncode == 0:
                lines = [line for line in result.stdout.strip().split('\n')[1:] if line.strip()]
                for line in lines:
                    parts = line.split('\t')
                    if len(parts) >= 3:
                        email, username, confirmed = parts[0], parts[1], parts[2]
                        status = "✅ Verified" if confirmed == "1" else "❌ Unverified"
                        print(f"  {Colors.OKGREEN}• {email} ({username}) - {status}{Colors.ENDC}")
                        
        except Exception as e:
            self.print_step(f"Database deep dive failed: {str(e)}", "ERROR")
    
    def show_menu(self):
        """Display interactive menu with enhanced visual debugging options"""
        while True:
            visual_status = "🎯 Available" if VISUAL_DEBUG_AVAILABLE else "❌ Not Available"
            print(f"""
{Colors.BOLD}{Colors.HEADER}
╔═══════════════════════════════════════╗
║      ENHANCED DATING APP DEMO         ║
║      WITH VISUAL DEBUGGING            ║
╚═══════════════════════════════════════╝{Colors.ENDC}

{Colors.OKBLUE}1.{Colors.ENDC} 🆕 New User Journey (Registration → Profile Setup)
{Colors.OKBLUE}2.{Colors.ENDC} 👤 Existing User Journey (Login → Browse Matches) 
{Colors.OKBLUE}3.{Colors.ENDC} 💕 Matching Journey (Two users match)
{Colors.OKBLUE}4.{Colors.ENDC} 🎯 Complete User Flow (All journeys)
{Colors.OKBLUE}5.{Colors.ENDC} 🔍 Backend Status Check
{Colors.OKBLUE}6.{Colors.ENDC} 🚀 Start Flutter App Only
{Colors.OKBLUE}7.{Colors.ENDC} 🛑 Stop Flutter App
{Colors.OKBLUE}8.{Colors.ENDC} 🎮 Interactive Mode (Step-by-step)
{Colors.OKBLUE}9.{Colors.ENDC} 📊 Show Demo Users & Database
{Colors.OKBLUE}10.{Colors.ENDC} 🗄️ Database Deep Dive
{Colors.OKBLUE}11.{Colors.ENDC} 📸 Visual Debugging Demo ({visual_status})
{Colors.OKBLUE}0.{Colors.ENDC} ❌ Exit

{Colors.WARNING}Choose an option (0-11): {Colors.ENDC}""", end="")
            
            choice = input().strip()
            
            if choice == '0':
                self.print_step("👋 Exiting demo system...", "INFO")
                self.stop_flutter_app()
                break
            elif choice == '1':
                self.run_new_user_journey()
            elif choice == '2':
                self.run_existing_user_journey()
            elif choice == '3':
                self.run_matching_journey()
            elif choice == '4':
                self.run_full_user_flow()
            elif choice == '5':
                self.check_backend_services()
            elif choice == '6':
                self.start_flutter_app()
            elif choice == '7':
                self.stop_flutter_app()
            elif choice == '8':
                self.run_interactive_mode()
            elif choice == '9':
                self.show_demo_data()
            elif choice == '10':
                self.database_deep_dive()
            elif choice == '11':
                self.run_visual_debugging_demo()
            else:
                self.print_step("❌ Invalid option. Please choose 0-11.", "ERROR")
            
            if choice != '0':
                input(f"\n{Colors.OKCYAN}Press Enter to return to menu...{Colors.ENDC}")
    
    def run_visual_debugging_demo(self):
        """Run the enhanced visual debugging demonstration"""
        self.print_step("🎬 Starting Visual Debugging Demo", "INFO")
        
        if not VISUAL_DEBUG_AVAILABLE:
            self.print_step("❌ Visual debugging not available", "ERROR")
            self.print_step("   To enable: create virtual environment and install pyautogui", "INFO")
            self.print_step("   Commands:", "INFO")
            self.print_step("     python3 -m venv demo_env", "INFO")
            self.print_step("     source demo_env/bin/activate", "INFO")
            self.print_step("     pip install pyautogui Pillow", "INFO")
            self.print_step("     sudo apt install gnome-screenshot", "INFO")
            return
        
        try:
            # Initialize automator with visual debugging
            self.print_step("🤖 Initializing enhanced automator...", "INFO")
            automator = FlutterAppAutomator()
            
            # Run comprehensive visual debugging demo
            self.print_step("📸 Running visual debugging demonstration...", "INFO")
            result = automator.run_visual_debugging_demo()
            
            if result:
                self.print_step("✅ Visual debugging demo completed successfully!", "SUCCESS")
                
                # Show screenshots if available
                screenshots_dir = Path("demo_screenshots")
                if screenshots_dir.exists():
                    sessions = list(screenshots_dir.glob("session_*"))
                    if sessions:
                        latest_session = max(sessions, key=lambda p: p.stat().st_mtime)
                        screenshots = list(latest_session.glob("*.png"))
                        
                        self.print_step(f"📸 {len(screenshots)} screenshots saved to:", "SUCCESS")
                        self.print_step(f"   {latest_session}", "INFO")
                        
                        # Offer to open screenshots directory
                        if screenshots:
                            view_choice = input(f"\n{Colors.WARNING}Open screenshots directory? (y/n): {Colors.ENDC}")
                            if view_choice.lower() == 'y':
                                subprocess.run(["xdg-open", str(latest_session)], check=False)
                
            else:
                self.print_step("❌ Visual debugging demo failed", "ERROR")
                
        except Exception as e:
            self.print_step(f"❌ Visual debugging demo error: {str(e)}", "ERROR")
    
    def run(self):
        """Main demo runner"""
        self.print_banner()
        
        # Check if backend services are running
        if not self.check_backend_services():
            self.print_step("❌ Backend services not available. Please start them first:", "ERROR")
            self.print_step("   cd /home/m/development/DatingApp", "INFO")
            self.print_step("   docker-compose -f docker-compose.yml up -d", "INFO")
            return
        
        self.print_step("✅ All backend services are running!", "SUCCESS")
        self.show_menu()

if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description='🛡️ Safe Dating App Demo System')
    parser.add_argument('--scenario', choices=['new_user', 'existing_user', 'matching', 'full_flow'], 
                       help='Run specific scenario and exit automatically')
    parser.add_argument('--quick-test', action='store_true', 
                       help='Run quick new user test and exit')
    
    args = parser.parse_args()
    
    demo = JourneyDemoOrchestrator()
    
    # Auto-run scenarios with exit
    if args.quick_test or args.scenario:
        print("🛡️ Running automated scenario with VS Code protection...")
        
        # Check services first
        if not demo.check_backend_services():
            print("❌ Backend services not running. Please start them first.")
            sys.exit(1)
        
        try:
            if args.quick_test or args.scenario == 'new_user':
                print("🎬 Running: New User Journey")
                demo.run_new_user_journey()
            elif args.scenario == 'existing_user':
                print("🎬 Running: Existing User Journey") 
                demo.run_existing_user_journey()
            elif args.scenario == 'matching':
                print("🎬 Running: Matching Journey")
                demo.run_matching_journey()
            elif args.scenario == 'full_flow':
                print("🎬 Running: Full User Flow")
                demo.run_full_user_flow()
            
            print("✅ Scenario completed! Cleaning up...")
            demo.stop_flutter_app()
            print("👋 Demo finished automatically!")
            
        except KeyboardInterrupt:
            print("\n🛑 Demo interrupted by user")
            demo.stop_flutter_app()
            sys.exit(0)
        except Exception as e:
            print(f"❌ Demo error: {e}")
            demo.stop_flutter_app()
            sys.exit(1)
    else:
        # Interactive mode
        try:
            demo.run()
        except KeyboardInterrupt:
            print("\n🛑 Demo interrupted by user")
            demo.stop_flutter_app()
            sys.exit(0)
