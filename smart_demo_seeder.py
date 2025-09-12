#!/usr/bin/env python3
"""
Smart Demo Data Seeder
Seeds real APIs with realistic test data for demo purposes
Uses the actual production APIs -                # Use REAL registration endpoint with correct field names
                response = self.session.post(f"{self.auth_base_url}/auth/register", json={
                    "username": user_data["fullName"],  # RegisterDto expects Username
                    "email": user_data["email"],
                    "password": user_data["password"],
                    "confirmPassword": user_data["confirmPassword"],
                    "phoneNumber": f"+46{random.randint(700000000, 799999999)}"  # Swedish mobile number
                })licate maintenance!
"""

import requests
import json
import time
from datetime import datetime, timedelta
import random

class SmartDemoSeeder:
    def __init__(self):
        # Use the REAL API endpoints, not demo ones!
        self.auth_base_url = "http://localhost:5001/api"
        self.user_base_url = "http://localhost:5002/api"
        self.matching_base_url = "http://localhost:5003/api"
        self.session = requests.Session()
        self.demo_users = []
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
    
    def generate_demo_users_data(self):
        """Generate realistic demo user data"""
        first_names = [
            "Emma", "Sofia", "Isabella", "Olivia", "Ava", "Mia", "Amelia", "Charlotte", "Luna", "Harper",
            "Evelyn", "Abigail", "Emily", "Elizabeth", "Avery", "Ella", "Scarlett", "Grace", "Aria", "Chloe",
            "Liam", "Oliver", "William", "Elijah", "James", "Benjamin", "Lucas", "Henry", "Alexander", "Mason"
        ]
        
        last_names = [
            "Andersson", "Johansson", "Karlsson", "Nilsson", "Eriksson", "Larsson", "Olsson", "Persson",
            "Svensson", "Gustafsson", "Pettersson", "Jonsson", "Jansson", "Hansson", "Bengtsson", "Jönsson"
        ]
        
        cities = [
            "Stockholm", "Gothenburg", "Malmö", "Uppsala", "Västerås", "Örebro", "Linköping", 
            "Helsingborg", "Jönköping", "Norrköping", "Lund", "Umeå", "Gävle", "Borås", "Eskilstuna"
        ]
        
        bios = [
            "Love hiking and photography 📸 Always exploring new places!",
            "Yoga instructor & coffee enthusiast ☕ Living life mindfully",
            "Chef who loves to cook for friends 👩‍🍳 Food is love!",
            "Adventure seeker and book lover 📚 Next trip: Japan!",
            "Dog mom and travel addict ✈️ Passport always ready",
            "Artist and music lover 🎨 Creating beautiful moments",
            "Fitness enthusiast and foodie 🏃‍♀️ Balance is everything",
            "Nature lover and weekend explorer 🌲 Mountains calling",
            "Dancer and life enjoyer 💃 Every day is a celebration",
            "Entrepreneur with wanderlust 🌍 Building dreams, seeing world"
        ]
        
        interests_sets = [
            ["Photography", "Hiking", "Travel", "Coffee"],
            ["Yoga", "Meditation", "Art", "Reading"],
            ["Cooking", "Wine", "Music", "Dancing"],
            ["Reading", "Movies", "Adventure", "Photography"],
            ["Dogs", "Travel", "Beaches", "Surfing"],
            ["Art", "Music", "Concerts", "Museums"],
            ["Fitness", "Running", "Food", "Nutrition"],
            ["Nature", "Camping", "Outdoors", "Hiking"],
            ["Dancing", "Parties", "Music", "Social"],
            ["Business", "Travel", "Innovation", "Tech"]
        ]
        
        demo_users = []
        for i in range(20):  # Create 20 demo users
            first_name = random.choice(first_names)
            last_name = random.choice(last_names)
            full_name = f"{first_name} {last_name}"
            email = f"{first_name.lower()}.{last_name.lower()}@demo.com"
            
            user_data = {
                "fullName": full_name,
                "email": email,
                "password": "Demo123!",
                "confirmPassword": "Demo123!",
                "age": random.randint(22, 36),
                "city": random.choice(cities),
                "bio": random.choice(bios),
                "interests": random.choice(interests_sets),
                "gender": "Female" if i % 2 == 0 else "Male"
            }
            demo_users.append(user_data)
            
        return demo_users
    
    def register_demo_users(self):
        """Register demo users using real registration API"""
        self.print_step("👥 Registering demo users...", "HEADER")
        
        demo_users_data = self.generate_demo_users_data()
        registered_users = []
        
        for i, user_data in enumerate(demo_users_data):
            try:
                # Use REAL registration endpoint
                response = self.session.post(f"{self.auth_base_url}/auth/register", json={
                    "username": user_data["fullName"],
                    "email": user_data["email"],
                    "password": user_data["password"],
                    "confirmPassword": user_data["confirmPassword"]
                })
                
                if response.status_code == 200:
                    auth_data = response.json()
                    user_id = auth_data.get('userId')
                    token = auth_data.get('token')
                    
                    if user_id and token:
                        # Store auth info
                        self.auth_tokens[user_id] = token
                        
                        # Add additional user data for profile creation
                        user_data['userId'] = user_id
                        user_data['token'] = token
                        registered_users.append(user_data)
                        
                        self.print_step(f"✅ Registered {user_data['fullName']} (ID: {user_id})", "SUCCESS")
                else:
                    self.print_step(f"❌ Failed to register {user_data['fullName']}: {response.status_code}", "ERROR")
                    
            except Exception as e:
                self.print_step(f"❌ Error registering {user_data['fullName']}: {str(e)}", "ERROR")
        
        self.demo_users = registered_users
        self.print_step(f"🎉 Successfully registered {len(registered_users)} demo users", "SUCCESS")
        return registered_users
    
    def create_user_profiles(self):
        """Create detailed user profiles using real user API"""
        self.print_step("📝 Creating detailed user profiles...", "HEADER")
        
        occupations = [
            "Software Engineer", "Designer", "Teacher", "Nurse", "Marketing Manager",
            "Data Scientist", "Photographer", "Architect", "Consultant", "Student",
            "Doctor", "Lawyer", "Artist", "Writer", "Chef"
        ]
        
        for user in self.demo_users:
            try:
                # Use REAL profile creation endpoint with correct CreateUserProfileDto fields
                profile_data = {
                    "name": user["fullName"],  # CreateUserProfileDto expects Name
                    "email": user["email"],
                    "bio": user["bio"],
                    "gender": user["gender"],
                    "preferences": "Everyone" if user["gender"] == "Female" else "Women",  # Required field
                    "dateOfBirth": (datetime.now() - timedelta(days=365 * user["age"])).isoformat(),  # Required field
                    "city": user["city"],
                    "state": "Stockholm County",
                    "country": "Sweden",
                    "latitude": 59.3293 + random.uniform(-0.1, 0.1),  # Stockholm area
                    "longitude": 18.0686 + random.uniform(-0.1, 0.1),
                    "occupation": random.choice(occupations),
                    "education": "University Graduate",
                    "interests": user["interests"],
                    "languages": ["Swedish", "English"],
                    "height": random.randint(160, 190),
                    "religion": "Not specified",
                    "smokingStatus": "Non-smoker",
                    "drinkingStatus": "Social drinker",
                    "wantsChildren": random.choice([True, False]),
                    "hasChildren": False,
                    "relationshipType": "Long-term relationship"
                }
                
                headers = {"Authorization": f"Bearer {user['token']}"}
                response = self.session.post(
                    f"{self.user_base_url}/userprofiles", 
                    json=profile_data,
                    headers=headers
                )
                
                if response.status_code in [200, 201]:
                    self.print_step(f"✅ Created profile for {user['fullName']}", "SUCCESS")
                else:
                    self.print_step(f"⚠️  Profile creation for {user['fullName']}: {response.status_code}", "WARNING")
                    
            except Exception as e:
                self.print_step(f"❌ Error creating profile for {user['fullName']}: {str(e)}", "ERROR")
    
    def create_sample_matches(self):
        """Create sample matches and conversations using real matching API"""
        self.print_step("💕 Creating sample matches...", "HEADER")
        
        # Create some matches between users
        for i in range(min(5, len(self.demo_users) // 2)):
            try:
                user1 = self.demo_users[i * 2]
                user2 = self.demo_users[i * 2 + 1]
                
                # Simulate mutual likes using real API
                headers1 = {"Authorization": f"Bearer {user1['token']}"}
                headers2 = {"Authorization": f"Bearer {user2['token']}"}
                
                # User1 likes User2
                response1 = self.session.post(
                    f"{self.matching_base_url}/matches/like",
                    json={"targetUserId": user2['userId']},
                    headers=headers1
                )
                
                # User2 likes User1 (creating mutual match)
                response2 = self.session.post(
                    f"{self.matching_base_url}/matches/like", 
                    json={"targetUserId": user1['userId']},
                    headers=headers2
                )
                
                if response1.status_code == 200 and response2.status_code == 200:
                    self.print_step(f"💕 Created match: {user1['fullName']} ↔ {user2['fullName']}", "SUCCESS")
                    
            except Exception as e:
                self.print_step(f"❌ Error creating match: {str(e)}", "ERROR")
    
    def seed_all_demo_data(self):
        """Run complete demo data seeding process"""
        self.print_step("🌱 Starting Smart Demo Data Seeding", "HEADER")
        self.print_step("Using REAL APIs with in-memory databases", "INFO")
        print("="*80)
        
        # Check service health
        if not self.check_services_health():
            self.print_step("❌ Some services are not healthy. Cannot proceed with seeding.", "ERROR")
            return False
        
        print()
        
        # Register demo users
        registered_users = self.register_demo_users()
        if not registered_users:
            self.print_step("❌ No users were registered. Cannot proceed.", "ERROR")
            return False
        
        print()
        
        # Create detailed profiles
        self.create_user_profiles()
        
        print()
        
        # Create sample matches
        self.create_sample_matches()
        
        print("\n" + "="*80)
        self.print_step("🎉 Smart demo data seeding completed!", "SUCCESS")
        self.print_step(f"📊 {len(self.demo_users)} users registered with realistic data", "INFO")
        self.print_step("🎯 You can now test the real APIs with demo data", "INFO")
        self.print_step("💡 All data is in-memory - restart services to reset", "INFO")
        
        return True

def main():
    """Main function for standalone execution"""
    print("🌱 Smart Demo Data Seeder")
    print("Seeds REAL APIs with realistic test data")
    print("="*60)
    
    seeder = SmartDemoSeeder()
    
    while True:
        print(f"""
🌱 Smart Demo Seeding Options:

1. 🏥 Quick Health Check
2. 🌱 Seed All Demo Data (Full Process)
3. 👥 Register Demo Users Only
4. 📝 Create User Profiles Only
5. 💕 Create Sample Matches Only
0. ❌ Exit

Choose an option (0-5): """, end="")

        try:
            choice = input().strip()
        except (EOFError, KeyboardInterrupt):
            print("\n👋 Seeding interrupted")
            break
            
        if choice == '0':
            print("👋 Exiting smart demo seeder...")
            break
        elif choice == '1':
            seeder.check_services_health()
        elif choice == '2':
            seeder.seed_all_demo_data()
        elif choice == '3':
            seeder.register_demo_users()
        elif choice == '4':
            if seeder.demo_users:
                seeder.create_user_profiles()
            else:
                print("❌ No demo users loaded. Run option 3 first.")
        elif choice == '5':
            if seeder.demo_users:
                seeder.create_sample_matches()
            else:
                print("❌ No demo users loaded. Run option 3 first.")
        else:
            print("❌ Invalid option. Please choose 0-5.")
        
        if choice != '0':
            input(f"\n📱 Press Enter to return to menu...")

if __name__ == "__main__":
    main()
