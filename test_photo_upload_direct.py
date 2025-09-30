#!/usr/bin/env python3
"""
Direct Photo Upload Test Script
Tests the photo-service upload endpoint directly to verify it works
"""

import requests
import json
from PIL import Image, ImageDraw, ImageFont
import io
import tempfile
import os

# Demo credentials
DEMO_EMAIL = "erik.astrom@demo.com"
DEMO_PASSWORD = "Demo123!"

# Service URLs (adjust ports if needed)
AUTH_SERVICE_URL = "http://localhost:8081"
PHOTO_SERVICE_URL = "http://localhost:8085"

def create_test_image(width=800, height=600, color=(255, 100, 100), text="Test Image"):
    """Create a simple test image"""
    # Create a new image with the specified size and color
    image = Image.new('RGB', (width, height), color)
    
    # Draw some text on the image
    draw = ImageDraw.Draw(image)
    try:
        # Try to use a default font
        font = ImageFont.load_default()
    except:
        font = None
    
    # Calculate text position (center)
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    x = (width - text_width) // 2
    y = (height - text_height) // 2
    
    # Draw the text
    draw.text((x, y), text, fill=(255, 255, 255), font=font)
    
    return image

def login_demo_user():
    """Login with demo credentials and return auth token"""
    print("🔐 Logging in with demo credentials...")
    
    login_data = {
        "email": DEMO_EMAIL,
        "password": DEMO_PASSWORD
    }
    
    try:
        response = requests.post(
            f"{AUTH_SERVICE_URL}/api/auth/login",
            headers={"Content-Type": "application/json"},
            json=login_data,
            timeout=10
        )
        
        print(f"📥 Login response: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            if data.get('success') and data.get('token'):
                print("✅ Login successful")
                return data['token']
            else:
                print(f"❌ Login failed: {data}")
                return None
        else:
            print(f"❌ Login failed with status {response.status_code}: {response.text}")
            return None
            
    except Exception as e:
        print(f"❌ Login error: {e}")
        return None

def upload_photo(auth_token, image_file_path, description="Test photo"):
    """Upload a photo to the photo service"""
    print(f"📤 Uploading photo: {os.path.basename(image_file_path)}")
    
    headers = {
        "Authorization": f"Bearer {auth_token}"
    }
    
    # Prepare the multipart form data
    with open(image_file_path, 'rb') as f:
        files = {
            'Photo': (os.path.basename(image_file_path), f, 'image/jpeg')
        }
        
        data = {
            'IsPrimary': 'true',
            'DisplayOrder': '1',
            'Description': description
        }
        
        try:
            response = requests.post(
                f"{PHOTO_SERVICE_URL}/api/photos",
                headers=headers,
                files=files,
                data=data,
                timeout=30
            )
            
            print(f"📥 Upload response: {response.status_code}")
            print(f"📄 Response body: {response.text}")
            
            if response.status_code == 201:
                data = response.json()
                if data.get('success'):
                    photo = data.get('photo')
                    print("✅ Upload successful!")
                    print(f"   📷 Photo ID: {photo.get('id')}")
                    print(f"   📏 Dimensions: {photo.get('width')}x{photo.get('height')}")
                    print(f"   📁 File size: {photo.get('fileSizeBytes')} bytes")
                    print(f"   🔗 Full URL: {photo.get('urls', {}).get('full')}")
                    print(f"   🔗 Thumbnail URL: {photo.get('urls', {}).get('thumbnail')}")
                    return photo
                else:
                    print(f"❌ Upload failed: {data.get('errorMessage')}")
                    return None
            else:
                print(f"❌ Upload failed with status {response.status_code}: {response.text}")
                return None
                
        except Exception as e:
            print(f"❌ Upload error: {e}")
            return None

def test_photo_service_health():
    """Test if photo service is healthy"""
    print("🏥 Checking photo service health...")
    
    try:
        response = requests.get(f"{PHOTO_SERVICE_URL}/health", timeout=5)
        
        if response.status_code == 200:
            print("✅ PhotoService is healthy")
            return True
        else:
            print(f"❌ PhotoService unhealthy: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ PhotoService health check failed: {e}")
        return False

def main():
    print("🧪 Direct Photo Upload Test")
    print("=" * 50)
    
    # Check service health
    if not test_photo_service_health():
        print("❌ Photo service is not available. Please start it first.")
        return
    
    # Login to get auth token
    auth_token = login_demo_user()
    if not auth_token:
        print("❌ Could not get auth token. Please check demo login.")
        return
    
    print(f"🔑 Auth token: {auth_token[:50]}...")
    
    # Create test images
    test_images = [
        {"filename": "test_red.jpg", "size": (800, 600), "color": (255, 100, 100), "text": "Red Test Image"},
        {"filename": "test_green.jpg", "size": (600, 800), "color": (100, 255, 100), "text": "Green Test Image"},
        {"filename": "test_blue.jpg", "size": (500, 500), "color": (100, 100, 255), "text": "Blue Test Image"},
    ]
    
    uploaded_photos = []
    
    # Create temporary directory for test images
    with tempfile.TemporaryDirectory() as temp_dir:
        for i, img_config in enumerate(test_images):
            print(f"\n📸 Creating and uploading test image {i + 1}/3...")
            
            # Create test image
            image = create_test_image(
                width=img_config["size"][0],
                height=img_config["size"][1],
                color=img_config["color"],
                text=img_config["text"]
            )
            
            # Save to temporary file
            image_path = os.path.join(temp_dir, img_config["filename"])
            image.save(image_path, "JPEG", quality=85)
            
            print(f"✅ Created test image: {img_config['filename']} ({img_config['size'][0]}x{img_config['size'][1]})")
            
            # Upload the image
            photo = upload_photo(auth_token, image_path, f"Test photo {i + 1}")
            if photo:
                uploaded_photos.append(photo)
    
    print(f"\n🎉 Upload test completed!")
    print(f"📊 Successfully uploaded {len(uploaded_photos)}/{len(test_images)} photos")
    
    if uploaded_photos:
        print("\n📷 Uploaded Photos Summary:")
        for i, photo in enumerate(uploaded_photos):
            print(f"   {i + 1}. ID: {photo.get('id')} - {photo.get('originalFileName')} ({photo.get('width')}x{photo.get('height')})")

if __name__ == "__main__":
    main()
