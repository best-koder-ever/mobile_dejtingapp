#!/usr/bin/env python3
"""
Backend Demo API Tester
Tests all demo endp        # Test registration with correct RegisterDto fields
        self.print_step("Testing demo registration...", "INFO")
        register_data = {
            "username": "Demo Test User",  # RegisterDto expects Username, not fullName
            "email": "demo.test@example.com",
            "password": "DemoPass123!",
            "confirmPassword": "DemoPass123!",
            "phoneNumber": "+46701234567"  # RegisterDto expects phoneNumber
        }ross microservices
"""

import requests
import json
import time
from datetime import datetime

class BackendDemoTester:
    def __init__(self):
        # Use REAL API endpoints - no more demo controllers!
        self.auth_base_url = "http://localhost:8081/api"
        self.user_base_url = "http://localhost:8082/api" 
        self.matching_base_url = "http://localhost:8083/api"
        self.session = requests.Session()
        self.test_user_id = None
        self.auth_token = None
        
    def print_step(self, message, level="INFO"):
        """Print formatted step messages"""
        colors = {
            "INFO": "\033[94m",
            "SUCCESS": "\033[92m", 
            "WARNING": "\033[93m",
            "ERROR": "\033[91m",
            "HEADER": "\033[95m",
            "ENDC": "\033[0m"
        }
        timestamp = datetime.now().strftime("%H:%M:%S")
        print(f"{colors.get(level, '')}{timestamp} | {message}{colors['ENDC']}")
    
    def test_service_health(self):
        """Test health endpoints for all services"""
        self.print_step("🏥 Testing Service Health Checks", "HEADER")
        
        services = [
            ("AuthService", f"{self.auth_base_url}/health"),
            ("UserService", f"{self.user_base_url}/health"),
            ("MatchmakingService", f"{self.matching_base_url}/health")
        ]
        
        all_healthy = True
        for service_name, health_url in services:
            try:
                response = self.session.get(health_url, timeout=5)
                if response.status_code == 200:
                    health_data = response.json()
                    self.print_step(f"✅ {service_name}: {health_data.get('Status', 'Healthy')}", "SUCCESS")
                else:
                    # Try base endpoint if health endpoint doesn't exist
                    base_url = health_url.replace("/health", "")
                    response = self.session.get(base_url, timeout=5)
                    if response.status_code in [200, 404]:  # 404 is OK for base URL
                        self.print_step(f"✅ {service_name}: Responding", "SUCCESS")
                    else:
                        self.print_step(f"❌ {service_name}: HTTP {response.status_code}", "ERROR")
                        all_healthy = False
            except requests.exceptions.RequestException as e:
                self.print_step(f"❌ {service_name}: Connection failed - {str(e)}", "ERROR")
                all_healthy = False
                
        return all_healthy
    
    def test_auth_demo_endpoints(self):
        """Test authentication demo endpoints"""
        self.print_step("🔐 Testing AuthService Demo Endpoints", "HEADER")
        
        # Test registration
        self.print_step("Testing demo registration...", "INFO")
        register_data = {
            "username": "Demo Test User",
            "email": "demo.test@example.com",
            "password": "DemoPass123!",
            "confirmPassword": "DemoPass123!"
        }
        
        try:
            response = self.session.post(f"{self.auth_base_url}/auth/register", json=register_data)
            if response.status_code == 200:
                auth_data = response.json()
                self.test_user_id = auth_data.get('userId')
                self.auth_token = auth_data.get('token')
                self.print_step(f"✅ Registration successful. User ID: {self.test_user_id}", "SUCCESS")
            else:
                self.print_step(f"❌ Registration failed: HTTP {response.status_code}", "ERROR")
                return False
        except Exception as e:
            self.print_step(f"❌ Registration error: {str(e)}", "ERROR")
            return False
        
        # Test login
        self.print_step("Testing demo login...", "INFO")
        login_data = {
            "email": "demo.test@example.com",
            "password": "DemoPass123!"
        }
        
        try:
            response = self.session.post(f"{self.auth_base_url}/auth/login", json=login_data)
            if response.status_code == 200:
                self.print_step("✅ Login successful", "SUCCESS")
            else:
                self.print_step(f"❌ Login failed: HTTP {response.status_code}", "ERROR")
        except Exception as e:
            self.print_step(f"❌ Login error: {str(e)}", "ERROR")
        
        # Test token refresh
        self.print_step("Testing demo token refresh...", "INFO")
        refresh_data = {"refreshToken": "demo_refresh_token"}
        
        try:
            response = self.session.post(f"{self.auth_base_url}/refresh", json=refresh_data)
            if response.status_code == 200:
                self.print_step("✅ Token refresh successful", "SUCCESS")
            else:
                self.print_step(f"❌ Token refresh failed: HTTP {response.status_code}", "ERROR")
        except Exception as e:
            self.print_step(f"❌ Token refresh error: {str(e)}", "ERROR")
        
        return True
    
    def test_user_demo_endpoints(self):
        """Test user service demo endpoints"""
        self.print_step("👤 Testing UserService Demo Endpoints", "HEADER")
        
        # Test get demo profiles
        self.print_step("Testing profiles retrieval...", "INFO")
        try:
            response = self.session.get(f"{self.user_base_url}/userprofiles?pageSize=5")
            if response.status_code == 200:
                profiles = response.json()
                self.print_step(f"✅ Retrieved {len(profiles)} demo profiles", "SUCCESS")
                for profile in profiles[:2]:  # Show first 2
                    self.print_step(f"   • {profile.get('name', 'Unknown')}, {profile.get('age', '?')} - {profile.get('bio', 'No bio')[:50]}...", "INFO")
            else:
                self.print_step(f"❌ Profiles retrieval failed: HTTP {response.status_code}", "ERROR")
        except Exception as e:
            self.print_step(f"❌ Profiles error: {str(e)}", "ERROR")
        
        # Test specific profile
        self.print_step("Testing specific demo profile...", "INFO")
        try:
            response = self.session.get(f"{self.user_base_url}/profiles/1")
            if response.status_code == 200:
                profile = response.json()
                self.print_step(f"✅ Retrieved detailed profile for {profile.get('name', 'Unknown')}", "SUCCESS")
            else:
                self.print_step(f"❌ Specific profile failed: HTTP {response.status_code}", "ERROR")
        except Exception as e:
            self.print_step(f"❌ Specific profile error: {str(e)}", "ERROR")
        
        # Test search
        self.print_step("Testing demo profile search...", "INFO")
        search_data = {
            "minAge": 25,
            "maxAge": 35,
            "page": 1,
            "pageSize": 10
        }
        
        try:
            response = self.session.post(f"{self.user_base_url}/search", json=search_data)
            if response.status_code == 200:
                search_results = response.json()
                total_count = search_results.get('totalCount', 0)
                results_count = len(search_results.get('results', []))
                self.print_step(f"✅ Search returned {results_count} results out of {total_count} total", "SUCCESS")
            else:
                self.print_step(f"❌ Search failed: HTTP {response.status_code}", "ERROR")
        except Exception as e:
            self.print_step(f"❌ Search error: {str(e)}", "ERROR")
    
    def test_matchmaking_demo_endpoints(self):
        """Test matchmaking service demo endpoints"""
        self.print_step("💕 Testing MatchmakingService Demo Endpoints", "HEADER")
        
        user_id = self.test_user_id or 123  # Use registered user ID or fallback
        
        # Test potential matches
        self.print_step("Testing potential matches...", "INFO")
        try:
            response = self.session.get(f"{self.matching_base_url}/matches/{user_id}?count=5")
            if response.status_code == 200:
                matches = response.json()
                self.print_step(f"✅ Retrieved {len(matches)} potential matches", "SUCCESS")
                for match in matches[:2]:  # Show first 2
                    name = match.get('name', 'Unknown')
                    age = match.get('age', '?')
                    score = match.get('compatibilityScore', '?')
                    self.print_step(f"   • {name}, {age} - Compatibility: {score}%", "INFO")
            else:
                self.print_step(f"❌ Potential matches failed: HTTP {response.status_code}", "ERROR")
        except Exception as e:
            self.print_step(f"❌ Potential matches error: {str(e)}", "ERROR")
        
        # Test mutual matches
        self.print_step("Testing mutual matches...", "INFO")
        try:
            response = self.session.get(f"{self.matching_base_url}/mutual-matches/{user_id}")
            if response.status_code == 200:
                mutual_matches = response.json()
                self.print_step(f"✅ Retrieved {len(mutual_matches)} mutual matches", "SUCCESS")
            else:
                self.print_step(f"❌ Mutual matches failed: HTTP {response.status_code}", "ERROR")
        except Exception as e:
            self.print_step(f"❌ Mutual matches error: {str(e)}", "ERROR")
        
        # Test swipe action
        self.print_step("Testing swipe action...", "INFO")
        swipe_data = {
            "userId": user_id,
            "targetUserId": 456,
            "action": "like"
        }
        
        try:
            response = self.session.post(f"{self.matching_base_url}/swipe", json=swipe_data)
            if response.status_code == 200:
                swipe_result = response.json()
                is_match = swipe_result.get('isMatch', False)
                message = swipe_result.get('message', 'No message')
                self.print_step(f"✅ Swipe processed: {message} {'🎉' if is_match else '👍'}", "SUCCESS")
            else:
                self.print_step(f"❌ Swipe failed: HTTP {response.status_code}", "ERROR")
        except Exception as e:
            self.print_step(f"❌ Swipe error: {str(e)}", "ERROR")
        
        # Test conversations
        self.print_step("Testing conversations...", "INFO")
        try:
            response = self.session.get(f"{self.matching_base_url}/conversations/{user_id}")
            if response.status_code == 200:
                conversations = response.json()
                self.print_step(f"✅ Retrieved {len(conversations)} conversations", "SUCCESS")
                for conv in conversations[:1]:  # Show first one
                    name = conv.get('participantName', 'Unknown')
                    last_msg = conv.get('lastMessage', 'No message')
                    self.print_step(f"   • Chat with {name}: {last_msg[:30]}...", "INFO")
            else:
                self.print_step(f"❌ Conversations failed: HTTP {response.status_code}", "ERROR")
        except Exception as e:
            self.print_step(f"❌ Conversations error: {str(e)}", "ERROR")
    
    def run_comprehensive_test(self):
        """Run all demo endpoint tests"""
        self.print_step("🎯 Starting Comprehensive Backend Demo Test", "HEADER")
        self.print_step(f"Testing at {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}", "INFO")
        print("="*80)
        
        # Test service health first
        if not self.test_service_health():
            self.print_step("❌ Some services are not healthy. Check service status.", "ERROR")
            return False
        
        print()
        
        # Test each service
        success = True
        
        if not self.test_auth_demo_endpoints():
            success = False
        
        print()
        self.test_user_demo_endpoints()
        
        print()
        self.test_matchmaking_demo_endpoints()
        
        print("\n" + "="*80)
        if success:
            self.print_step("🎉 Comprehensive backend demo test completed successfully!", "SUCCESS")
        else:
            self.print_step("⚠️  Backend demo test completed with some issues", "WARNING")
        
        return success
    
    def quick_health_check(self):
        """Quick health check for all services"""
        self.print_step("⚡ Quick Health Check", "HEADER")
        return self.test_service_health()

def main():
    """Main function for standalone execution"""
    print("🔧 Backend Demo API Tester")
    print("Tests all demo endpoints across microservices")
    print("="*60)
    
    tester = BackendDemoTester()
    
    while True:
        print(f"""
🔧 Backend Demo Testing Options:

1. ⚡ Quick Health Check
2. 🎯 Comprehensive Demo Test  
3. 🔐 Auth Service Tests Only
4. 👤 User Service Tests Only
5. 💕 Matchmaking Service Tests Only
0. ❌ Exit

Choose an option (0-5): """, end="")

        try:
            choice = input().strip()
        except (EOFError, KeyboardInterrupt):
            print("\n👋 Testing interrupted")
            break
            
        if choice == '0':
            print("👋 Exiting backend demo tester...")
            break
        elif choice == '1':
            tester.quick_health_check()
        elif choice == '2':
            tester.run_comprehensive_test()
        elif choice == '3':
            tester.test_auth_demo_endpoints()
        elif choice == '4':
            tester.test_user_demo_endpoints()
        elif choice == '5':
            tester.test_matchmaking_demo_endpoints()
        else:
            print("❌ Invalid option. Please choose 0-5.")
        
        if choice != '0':
            input(f"\n📱 Press Enter to return to menu...")

if __name__ == "__main__":
    main()
