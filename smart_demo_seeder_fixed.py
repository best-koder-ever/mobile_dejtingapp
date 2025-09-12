#!/usr/bin/env python3
"""
Smart Demo Data Seeder
Seeds real APIs with realistic test data for demo purposes
Uses the actual production APIs - no duplicate maintenance!
"""

import requests
import json
import time
from datetime import datetime, timedelta
import random

# Swedish demo users with ASCII usernames
demo_users = [
    {
        "fullName": "Erik Astrom",
        "username": "erik_astrom",
        "email": "erik.astrom@demo.com",
        "bio": "Älskar att vandra i svenska fjällen och upptäcka nya platser. Jobbar som mjukvaruingenjör och spelar gitarr på fritiden.",
        "age": 28,
        "location": "Stockholm",
        "interests": "Vandring, musik, teknik"
    },
    {
        "fullName": "Anna Lindberg",
        "username": "anna_lindberg",
        "email": "anna.lindberg@demo.com", 
        "bio": "Fotograf med passion för naturbilder och porträtt. Älskar att resa och upptäcka nya kulturer.",
        "age": 25,
        "location": "Göteborg",
        "interests": "Fotografi, resor, konst"
    },
    {
        "fullName": "Oskar Kallstrom",
        "username": "oskar_kallstrom",
        "email": "oskar.kallstrom@demo.com",
        "bio": "Kock som älskar att experimentera med nordiska ingredienser. Springer maraton och läser deckare.",
        "age": 32,
        "location": "Malmö", 
        "interests": "Matlagning, löpning, böcker"
    },
    {
        "fullName": "Sara Blomqvist",
        "username": "sara_blomqvist",
        "email": "sara.blomqvist@demo.com",
        "bio": "Veterinär som bryr sig om djur och natur. Tycker om att måla akvarell och laga vegetarisk mat.",
        "age": 29,
        "location": "Uppsala",
        "interests": "Djur, målning, vegetarisk mat"
    },
    {
        "fullName": "Magnus Ohman",
        "username": "magnus_ohman",
        "email": "magnus.ohman@demo.com",
        "bio": "Lärare i historia som fascineras av vikingatiden. Spelar ishockey och bygger modellflygplan.",
        "age": 35,
        "location": "Linköping",
        "interests": "Historia, ishockey, modellflygplan"
    }
]

class SmartDemoSeeder:
    def __init__(self):
        # Use the REAL API endpoints, not demo ones!
        self.auth_base_url = "http://localhost:8081/api"
        self.user_base_url = "http://localhost:8082/api"
        self.matching_base_url = "http://localhost:8083/api"
        self.session = requests.Session()
        self.auth_tokens = {}
        
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
    
    def check_services_health(self):
        """Check if all services are running and accessible"""
        self.print_step("🏥 Checking service health...", "HEADER")
        
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
                    self.print_step(f"✅ {service_name}: Healthy", "SUCCESS")
                else:
                    # Try without /health endpoint
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
    
    def register_users(self):
        """Register all demo users"""
        self.print_step("👥 Registering demo users...", "HEADER")
        
        for i, user_data in enumerate(demo_users, 1):
            self.print_step(f"Registering user {i}/{len(demo_users)}: {user_data['fullName']}")
            
            # Add password for registration
            user_data["password"] = "Demo123!"
            user_data["confirmPassword"] = "Demo123!"
            
            try:
                # Use REAL registration endpoint with correct field names
                response = self.session.post(f"{self.auth_base_url}/auth/register", json={
                    "username": user_data["username"],  # Use ASCII username
                    "email": user_data["email"],
                    "password": user_data["password"],
                    "confirmPassword": user_data["confirmPassword"],
                    "phoneNumber": f"+46{random.randint(700000000, 799999999)}"  # Swedish mobile number
                })
                
                if response.status_code == 200:
                    result = response.json()
                    token = result.get("token")
                    if token:
                        self.auth_tokens[user_data["username"]] = token
                        self.print_step(f"✅ Registered: {user_data['fullName']}", "SUCCESS")
                    else:
                        self.print_step(f"⚠️ Registration succeeded but no token for {user_data['fullName']}", "WARNING")
                else:
                    self.print_step(f"❌ Failed to register {user_data['fullName']}: HTTP {response.status_code}", "ERROR")
                    if response.text:
                        self.print_step(f"Error details: {response.text}", "ERROR")
                        
            except requests.exceptions.RequestException as e:
                self.print_step(f"❌ Network error registering {user_data['fullName']}: {str(e)}", "ERROR")
                
            # Small delay between registrations
            time.sleep(0.5)
    
    def create_user_profiles(self):
        """Create detailed user profiles"""
        self.print_step("📝 Creating user profiles...", "HEADER")
        
        for i, user_data in enumerate(demo_users, 1):
            username = user_data["username"]
            if username not in self.auth_tokens:
                self.print_step(f"⚠️ Skipping profile for {user_data['fullName']} - no auth token", "WARNING")
                continue
                
            self.print_step(f"Creating profile {i}/{len(demo_users)}: {user_data['fullName']}")
            
            # Calculate date of birth from age
            birth_year = datetime.now().year - user_data["age"]
            birth_date = f"{birth_year}-{random.randint(1,12):02d}-{random.randint(1,28):02d}"
            
            try:
                headers = {"Authorization": f"Bearer {self.auth_tokens[username]}"}
                
                # Format data according to CreateUserProfileDto structure
                profile_data = {
                    "name": user_data["fullName"],  # DTO expects "name"
                    "email": user_data["email"],
                    "bio": user_data["bio"],
                    "gender": random.choice(["Male", "Female"]),  # Required field
                    "preferences": random.choice(["Male", "Female", "Both"]),  # Required field
                    "dateOfBirth": f"{birth_date}T00:00:00Z",  # Required field as ISO datetime
                    "city": user_data["location"],
                    "country": "Sweden",
                    "interests": [],  # Empty array - will be populated later
                    "languages": [],  # Empty array - will be populated later
                    "occupation": random.choice([
                        "Software Engineer", "Photographer", "Chef", "Veterinarian", 
                        "Teacher", "Designer", "Entrepreneur", "Journalist", 
                        "Architect", "Researcher", "Psychologist", "Electrician"
                    ]),
                    "education": random.choice([
                        "University Degree", "Master's Degree", "High School", 
                        "PhD", "Trade School", "Bachelor's Degree"
                    ]),
                    "height": random.randint(160, 195),  # Height in cm
                    "relationshipType": "Long-term relationship",
                    "smokingStatus": random.choice(["Non-smoker", "Occasionally", "Never"]),
                    "drinkingStatus": random.choice(["Socially", "Occasionally", "Never"]),
                    "wantsChildren": random.choice([True, False]),
                    "hasChildren": random.choice([True, False])
                }
                
                # Use correct endpoint with 's' - /api/userprofiles
                response = self.session.post(f"{self.user_base_url}/userprofiles", 
                                           json=profile_data, headers=headers)
                
                if response.status_code in [200, 201]:
                    self.print_step(f"✅ Profile created: {user_data['fullName']}", "SUCCESS")
                else:
                    self.print_step(f"❌ Failed to create profile for {user_data['fullName']}: HTTP {response.status_code}", "ERROR")
                    if response.text:
                        self.print_step(f"Error details: {response.text}", "ERROR")
                        
            except requests.exceptions.RequestException as e:
                self.print_step(f"❌ Network error creating profile for {user_data['fullName']}: {str(e)}", "ERROR")
                
            # Small delay between profile creations
            time.sleep(0.5)
    
    def setup_demo_matches(self):
        """Create some demo matches between users using real MatchmakingService"""
        self.print_step("💕 Setting up demo matches...", "HEADER")
        
        registered_users = [user for user in demo_users if user["username"] in self.auth_tokens]
        
        if len(registered_users) < 2:
            self.print_step("⚠️ Need at least 2 registered users for matches", "WARNING")
            return
        
        # First, get the actual user IDs from the UserService
        user_ids = {}
        for user_data in registered_users:
            try:
                headers = {"Authorization": f"Bearer {self.auth_tokens[user_data['username']]}"}
                
                # Search for the user to get their ID
                search_data = {
                    "page": 1,
                    "pageSize": 1
                }
                response = self.session.post(f"{self.user_base_url}/userprofiles/search", 
                                           json=search_data, headers=headers)
                
                if response.status_code == 200:
                    results = response.json().get('results', [])
                    if results:
                        # Find the user by name
                        for profile in results:
                            if profile.get('name') == user_data['fullName']:
                                user_ids[user_data['username']] = profile.get('id')
                                break
                        
                        # If not found in first result, search more broadly
                        if user_data['username'] not in user_ids:
                            search_all = {
                                "page": 1,
                                "pageSize": 20
                            }
                            response = self.session.post(f"{self.user_base_url}/userprofiles/search", 
                                                       json=search_all, headers=headers)
                            if response.status_code == 200:
                                all_results = response.json().get('results', [])
                                for profile in all_results:
                                    if profile.get('name') == user_data['fullName']:
                                        user_ids[user_data['username']] = profile.get('id')
                                        break
                        
            except Exception as e:
                self.print_step(f"❌ Error getting user ID for {user_data['fullName']}: {str(e)}", "ERROR")
        
        self.print_step(f"📋 Found {len(user_ids)} user IDs: {list(user_ids.values())}", "INFO")
        
        # Create some mutual matches
        user_list = list(user_ids.items())
        for i in range(min(3, len(user_list) - 1)):
            user1_name, user1_id = user_list[i]
            user2_name, user2_id = user_list[i + 1]
            
            if user1_id and user2_id:
                self.print_step(f"Creating mutual match: {user1_name} ↔ {user2_name}")
                
                try:
                    # Create a mutual match using MatchmakingService
                    match_data = {
                        "user1Id": user1_id,
                        "user2Id": user2_id,
                        "compatibilityScore": random.uniform(75.0, 95.0),  # High compatibility for demo
                        "source": "demo_seeder"
                    }
                    
                    # Use the first user's token for authorization
                    headers = {"Authorization": f"Bearer {self.auth_tokens[user1_name]}"}
                    
                    response = self.session.post(f"{self.matching_base_url}/matchmaking/matches", 
                                               json=match_data, headers=headers)
                    
                    if response.status_code in [200, 201]:
                        self.print_step(f"✅ Created match: {user1_name} ↔ {user2_name}", "SUCCESS")
                    else:
                        self.print_step(f"⚠️ Match creation returned HTTP {response.status_code}", "WARNING")
                        if response.text:
                            self.print_step(f"Response: {response.text}", "INFO")
                        
                except Exception as e:
                    self.print_step(f"❌ Error creating match: {str(e)}", "ERROR")
                    
                # Small delay between match creations
                time.sleep(0.5)
        
        # Also test the find-matches endpoint for demonstration
        if user_ids:
            first_user = list(user_ids.items())[0]
            username, user_id = first_user
            
            self.print_step(f"🔍 Testing match suggestions for {username}...")
            
            try:
                headers = {"Authorization": f"Bearer {self.auth_tokens[username]}"}
                find_matches_data = {
                    "userId": user_id,
                    "limit": 5,
                    "minScore": 50.0
                }
                
                response = self.session.post(f"{self.matching_base_url}/matchmaking/find-matches",
                                           json=find_matches_data, headers=headers)
                
                if response.status_code == 200:
                    matches = response.json()
                    self.print_step(f"✅ Found {len(matches)} potential matches for {username}", "SUCCESS")
                else:
                    self.print_step(f"⚠️ Find matches returned HTTP {response.status_code}", "WARNING")
                    
            except Exception as e:
                self.print_step(f"❌ Error testing find matches: {str(e)}", "ERROR")
    
    def run_seeding(self):
        """Run the complete seeding process"""
        self.print_step("🚀 Starting Smart Demo Data Seeding...", "HEADER")
        
        # Check if services are running
        if not self.check_services_health():
            self.print_step("❌ Some services are not healthy. Please start all services first.", "ERROR")
            return False
            
        # Register users
        self.register_users()
        
        # Create profiles
        self.create_user_profiles()
        
        # Set up matches
        self.setup_demo_matches()
        
        self.print_step("🎉 Demo seeding completed!", "SUCCESS")
        self.print_step(f"📊 Registered {len(self.auth_tokens)} users successfully", "INFO")
        
        return True

if __name__ == "__main__":
    seeder = SmartDemoSeeder()
    seeder.run_seeding()
