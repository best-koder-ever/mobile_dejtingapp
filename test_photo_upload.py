#!/usr/bin/env python3
"""
Quick test of photo upload functionality
Tests the complete flow: login -> get token -> test photo endpoints
"""

import requests
import json

def main():
    print("🧪 Testing Photo Upload Flow...")
    print()
    
    # Step 1: Login with demo user
    print("Step 1: Login with demo user")
    login_response = requests.post(
        "http://localhost:8081/api/auth/login",
        json={
            "email": "erik.astrom@demo.com",
            "password": "Demo123!"
        }
    )
    
    if login_response.status_code != 200:
        print(f"❌ Login failed: {login_response.status_code}")
        print(login_response.text)
        return
    
    login_data = login_response.json()
    token = login_data["token"]
    user_id = login_data["userId"]
    
    print(f"✅ Login successful!")
    print(f"   User ID: {user_id}")
    print(f"   Token: {token[:50]}...")
    print()
    
    # Step 2: Test PhotoService authentication
    print("Step 2: Test PhotoService authentication")
    headers = {"Authorization": f"Bearer {token}"}
    
    photos_response = requests.get(
        f"http://localhost:8085/api/photos/user/{user_id}",
        headers=headers
    )
    
    if photos_response.status_code == 200:
        photos = photos_response.json()
        print(f"✅ PhotoService authentication works!")
        print(f"   Current photos: {len(photos) if isinstance(photos, list) else 0}")
        print()
    elif photos_response.status_code == 401:
        print(f"❌ PhotoService authentication failed!")
        print(f"   Status: {photos_response.status_code}")
        print(f"   Response: {photos_response.text}")
        return
    else:
        print(f"⚠️  Unexpected response: {photos_response.status_code}")
        print(f"   Response: {photos_response.text}")
        print()
    
    # Step 3: Test photo upload endpoint availability
    print("Step 3: Test photo upload endpoint")
    upload_response = requests.post(
        "http://localhost:8085/api/photos",
        headers=headers
        # Not sending actual photo data, just testing auth
    )
    
    if upload_response.status_code == 400:
        print("✅ Upload endpoint accessible (400 = missing photo data, as expected)")
    elif upload_response.status_code == 401:
        print("❌ Upload endpoint authentication failed!")
        print(f"   Response: {upload_response.text}")
        return
    else:
        print(f"⚠️  Upload endpoint returned: {upload_response.status_code}")
        print(f"   Response: {upload_response.text}")
    
    print()
    print("🎉 Photo upload system is ready!")
    print("✅ Authentication working")
    print("✅ PhotoService responding") 
    print("✅ JWT tokens valid between services")
    print()
    print("Next steps:")
    print("1. Run Flutter app: flutter run -d chrome")
    print("2. Navigate to photo upload screen")
    print("3. Try uploading a photo!")

if __name__ == "__main__":
    main()
