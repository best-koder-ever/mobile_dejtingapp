#!/usr/bin/env python3
"""
🎬 VISUAL DATING APP DEMO SYSTEM WITH PLAYWRIGHT
==============================================

Advanced demo system with visual debugging capabilities:
- Screenshot capture at each step
- Video recording of entire demo
- Browser-based automation (more reliable than xdotool)
- Real-time visual feedback
- Integration with existing Playwright infrastructure
"""

import os
import sys
import time
import json
import asyncio
import subprocess
import requests
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple

# Add e2e-tests directory to path for imports
sys.path.append(str(Path(__file__).parent / 'e2e-tests'))

class VisualDemoSystem:
    def __init__(self):
        self.demo_dir = Path(__file__).parent
        self.e2e_dir = self.demo_dir / 'e2e-tests'
        self.screenshots_dir = self.demo_dir / 'demo_screenshots'
        self.videos_dir = self.demo_dir / 'demo_videos'
        
        # Create directories
        self.screenshots_dir.mkdir(exist_ok=True)
        self.videos_dir.mkdir(exist_ok=True)
        
        # Demo session info
        self.session_id = datetime.now().strftime("%Y%m%d_%H%M%S")
        self.session_dir = self.screenshots_dir / f"session_{self.session_id}"
        self.session_dir.mkdir(exist_ok=True)
        
        self.step_counter = 0
        
        # Backend services
        self.services = {
            'auth': 'http://localhost:5001',
            'user': 'http://localhost:5002', 
            'matchmaking': 'http://localhost:5003'
        }
        
        print(f"🎬 Visual Demo System Initialized")
        print(f"📁 Session: {self.session_id}")
        print(f"📸 Screenshots: {self.session_dir}")
        print(f"🎥 Videos: {self.videos_dir}")

    def log(self, level: str, message: str):
        """Consistent logging with timestamps"""
        timestamp = datetime.now().strftime("%H:%M:%S")
        colors = {
            'INFO': '\033[36m',      # Cyan
            'SUCCESS': '\033[92m',   # Green
            'ERROR': '\033[91m',     # Red
            'WARNING': '\033[93m',   # Yellow
            'BACKEND': '\033[95m',   # Magenta
        }
        reset = '\033[0m'
        color = colors.get(level, '')
        print(f"[{timestamp}] {color}{level}{reset}: {message}")

    def check_backend_services(self) -> bool:
        """Check if all backend services are running"""
        self.log("INFO", "🔍 Checking backend services...")
        
        all_running = True
        for service_name, url in self.services.items():
            try:
                response = requests.get(f"{url}/api/health", timeout=5)
                if response.status_code == 200:
                    self.log("SUCCESS", f"✅ {service_name.upper()} service: Running on {url}")
                else:
                    self.log("ERROR", f"❌ {service_name.upper()} service: Not responding ({response.status_code})")
                    all_running = False
            except Exception as e:
                self.log("ERROR", f"❌ {service_name.upper()} service: Connection failed - {e}")
                all_running = False
        
        if all_running:
            self.log("SUCCESS", "✅ All backend services are running!")
        else:
            self.log("ERROR", "❌ Some backend services are not running. Please start them first.")
        
        return all_running

    def check_playwright_setup(self) -> bool:
        """Check if Playwright is properly set up"""
        self.log("INFO", "🔍 Checking Playwright setup...")
        
        # Check if e2e-tests directory exists
        if not self.e2e_dir.exists():
            self.log("ERROR", f"❌ E2E tests directory not found: {self.e2e_dir}")
            return False
        
        # Check if package.json exists
        package_json = self.e2e_dir / 'package.json'
        if not package_json.exists():
            self.log("ERROR", "❌ package.json not found in e2e-tests directory")
            return False
        
        # Check if node_modules exists (Playwright installed)
        node_modules = self.e2e_dir / 'node_modules'
        if not node_modules.exists():
            self.log("WARNING", "⚠️ Node modules not found. Installing Playwright...")
            try:
                subprocess.run(['npm', 'install'], cwd=self.e2e_dir, check=True)
                self.log("SUCCESS", "✅ Playwright dependencies installed")
            except subprocess.CalledProcessError:
                self.log("ERROR", "❌ Failed to install Playwright dependencies")
                return False
        
        self.log("SUCCESS", "✅ Playwright setup is ready")
        return True

    async def run_visual_demo(self, demo_type: str = "new_user"):
        """Run a visual demo with Playwright"""
        self.log("INFO", f"🎬 Starting visual demo: {demo_type}")
        
        # Create Playwright test script for the demo
        demo_script = self.create_demo_script(demo_type)
        demo_file = self.e2e_dir / f"demo_{demo_type}_{self.session_id}.spec.ts"
        
        with open(demo_file, 'w') as f:
            f.write(demo_script)
        
        self.log("SUCCESS", f"✅ Created demo script: {demo_file.name}")
        
        # Run the Playwright demo with visual options
        try:
            cmd = [
                'npx', 'playwright', 'test', str(demo_file),
                '--headed',  # Show browser window
                '--video=on',  # Record video
                '--screenshot=on',  # Take screenshots
                '--trace=on',  # Enable trace for debugging
                '--reporter=html',  # HTML report
            ]
            
            self.log("INFO", "🚀 Running Playwright visual demo...")
            process = subprocess.run(cmd, cwd=self.e2e_dir, capture_output=True, text=True)
            
            if process.returncode == 0:
                self.log("SUCCESS", "✅ Visual demo completed successfully!")
            else:
                self.log("WARNING", f"⚠️ Demo completed with warnings/errors: {process.stderr}")
            
            # Show where results are stored
            self.show_demo_results()
            
        except Exception as e:
            self.log("ERROR", f"❌ Failed to run visual demo: {e}")
        finally:
            # Clean up demo script
            if demo_file.exists():
                demo_file.unlink()

    def create_demo_script(self, demo_type: str) -> str:
        """Create a Playwright test script for the specified demo type"""
        
        if demo_type == "new_user":
            return f'''
import {{ test, expect }} from '@playwright/test';

test('Visual Demo - New User Registration Journey', async ({{ page }}) => {{
    // Configure for visual debugging
    await page.setViewportSize({{ width: 1280, height: 720 }});
    
    console.log('🎬 Starting New User Registration Demo');
    
    // Step 1: Navigate to app
    console.log('📱 Step 1: Opening DatingApp...');
    await page.goto('http://localhost:3001');
    await page.waitForTimeout(2000);
    await page.screenshot({{ path: '{self.session_dir}/01_app_opened.png' }});
    
    // Step 2: Navigate to registration
    console.log('📱 Step 2: Going to registration...');
    const registerButton = page.locator('button:has-text("Register"), button:has-text("Sign Up"), a:has-text("Register")');
    if (await registerButton.isVisible()) {{
        await registerButton.click();
        await page.waitForTimeout(1000);
    }}
    await page.screenshot({{ path: '{self.session_dir}/02_registration_screen.png' }});
    
    // Step 3: Fill registration form
    console.log('📱 Step 3: Filling registration form...');
    
    // Generate test user data
    const timestamp = Date.now();
    const testUser = {{
        firstName: 'Demo',
        lastName: 'User',
        email: `demo.user.${{timestamp}}@example.com`,
        password: 'Demo123!'
    }};
    
    console.log(`📧 Using email: ${{testUser.email}}`);
    
    // Fill first name
    const firstNameField = page.locator('input[placeholder*="First"], input[name*="firstName"], input[id*="firstName"]').first();
    if (await firstNameField.isVisible()) {{
        await firstNameField.fill(testUser.firstName);
        await page.waitForTimeout(500);
    }}
    
    // Fill last name  
    const lastNameField = page.locator('input[placeholder*="Last"], input[name*="lastName"], input[id*="lastName"]').first();
    if (await lastNameField.isVisible()) {{
        await lastNameField.fill(testUser.lastName);
        await page.waitForTimeout(500);
    }}
    
    // Fill email
    const emailField = page.locator('input[type="email"]').first();
    await emailField.fill(testUser.email);
    await page.waitForTimeout(500);
    
    // Fill password
    const passwordField = page.locator('input[type="password"]').first();
    await passwordField.fill(testUser.password);
    await page.waitForTimeout(500);
    
    await page.screenshot({{ path: '{self.session_dir}/03_form_filled.png' }});
    
    // Step 4: Submit registration
    console.log('📱 Step 4: Submitting registration...');
    const submitButton = page.locator('button:has-text("Register"), button:has-text("Sign Up"), button[type="submit"]');
    await submitButton.click();
    
    // Wait for response
    await page.waitForTimeout(3000);
    await page.screenshot({{ path: '{self.session_dir}/04_registration_submitted.png' }});
    
    // Step 5: Check for success
    console.log('📱 Step 5: Checking registration result...');
    
    const isMainApp = await page.locator('[data-testid="main-nav"], .bottom-nav, .tab-bar, text="Swipe", text="Matches"').isVisible();
    const hasSuccessMessage = await page.locator('text="registered successfully", text="Registration successful", text="Welcome"').isVisible();
    
    if (isMainApp || hasSuccessMessage) {{
        console.log('✅ Registration successful! User is logged in.');
        await page.screenshot({{ path: '{self.session_dir}/05_success_main_app.png' }});
    }} else {{
        console.log('⚠️ Registration response unclear. Taking screenshot for review.');
        await page.screenshot({{ path: '{self.session_dir}/05_unclear_result.png' }});
    }}
    
    // Final screenshot
    await page.waitForTimeout(2000);
    await page.screenshot({{ path: '{self.session_dir}/06_final_state.png' }});
    
    console.log('🎬 Demo completed! Check screenshots for visual verification.');
}});
'''
        
        elif demo_type == "existing_user":
            return f'''
import {{ test, expect }} from '@playwright/test';

test('Visual Demo - Existing User Login Journey', async ({{ page }}) => {{
    await page.setViewportSize({{ width: 1280, height: 720 }});
    
    console.log('🎬 Starting Existing User Login Demo');
    
    // Use predefined test credentials
    const testUser = {{
        email: 'testuser@example.com',
        password: 'Test123!'
    }};
    
    await page.goto('http://localhost:3001');
    await page.waitForTimeout(2000);
    await page.screenshot({{ path: '{self.session_dir}/01_login_screen.png' }});
    
    await page.fill('input[type="email"]', testUser.email);
    await page.fill('input[type="password"]', testUser.password);
    await page.screenshot({{ path: '{self.session_dir}/02_credentials_entered.png' }});
    
    await page.click('button:has-text("Login"), button:has-text("Log In")');
    await page.waitForTimeout(3000);
    await page.screenshot({{ path: '{self.session_dir}/03_login_result.png' }});
    
    console.log('🎬 Login demo completed!');
}});
'''
        
        else:
            # Default demo
            return self.create_demo_script("new_user")

    def show_demo_results(self):
        """Show where demo results can be found"""
        self.log("INFO", "📊 Demo Results Summary:")
        print(f"  📸 Screenshots: {self.session_dir}")
        
        # List screenshot files
        screenshots = list(self.session_dir.glob("*.png"))
        if screenshots:
            print(f"  📷 {len(screenshots)} screenshots captured:")
            for shot in sorted(screenshots):
                print(f"    • {shot.name}")
        
        # Check for video files
        test_results = self.e2e_dir / 'test-results'
        if test_results.exists():
            videos = list(test_results.glob("**/video.webm"))
            if videos:
                print(f"  🎥 Videos: {len(videos)} video(s) recorded")
                for video in videos:
                    print(f"    • {video}")
        
        # Check for HTML report
        html_report = self.e2e_dir / 'playwright-report' / 'index.html'
        if html_report.exists():
            print(f"  📋 HTML Report: {html_report}")
            print(f"     Open with: npx playwright show-report")

    def interactive_menu(self):
        """Interactive menu for visual demos"""
        while True:
            print("\n" + "="*60)
            print("🎬 VISUAL DATING APP DEMO SYSTEM")
            print("   (Powered by Playwright)")
            print("="*60)
            
            if not self.check_backend_services():
                print("\n❌ Backend services not running. Please start them first.")
                print("Run: cd /home/m/development/DatingApp && docker-compose -f environments/demo/docker-compose.demo.yml up -d")
                break
            
            if not self.check_playwright_setup():
                print("\n❌ Playwright setup incomplete. Please check configuration.")
                break
            
            print("\n📋 Available Visual Demos:")
            print("1. 🆕 New User Registration Journey (with screenshots)")
            print("2. 👤 Existing User Login Journey (with screenshots)")  
            print("3. 🎥 Record Full Demo Video")
            print("4. 🖼️  View Previous Screenshots")
            print("5. 📊 Open Playwright Report")
            print("6. 🧹 Clean Demo Files")
            print("0. ❌ Exit")
            
            choice = input("\nChoose an option (0-6): ").strip()
            
            if choice == "0":
                self.log("INFO", "👋 Exiting visual demo system...")
                break
            elif choice == "1":
                asyncio.run(self.run_visual_demo("new_user"))
            elif choice == "2":
                asyncio.run(self.run_visual_demo("existing_user"))
            elif choice == "3":
                asyncio.run(self.run_visual_demo("full_demo"))
            elif choice == "4":
                self.view_screenshots()
            elif choice == "5":
                self.open_playwright_report()
            elif choice == "6":
                self.clean_demo_files()
            else:
                print("❌ Invalid option. Please try again.")

    def view_screenshots(self):
        """View available screenshots"""
        sessions = list(self.screenshots_dir.glob("session_*"))
        if not sessions:
            print("📸 No screenshot sessions found.")
            return
        
        print(f"\n📸 Available Screenshot Sessions ({len(sessions)}):")
        for i, session in enumerate(sorted(sessions), 1):
            screenshots = list(session.glob("*.png"))
            print(f"{i}. {session.name} ({len(screenshots)} screenshots)")
        
        print(f"\n📁 Screenshots directory: {self.screenshots_dir}")

    def open_playwright_report(self):
        """Open Playwright HTML report"""
        report_cmd = ['npx', 'playwright', 'show-report']
        try:
            subprocess.Popen(report_cmd, cwd=self.e2e_dir)
            self.log("SUCCESS", "🌐 Opening Playwright report in browser...")
        except Exception as e:
            self.log("ERROR", f"❌ Failed to open report: {e}")

    def clean_demo_files(self):
        """Clean up demo files"""
        import shutil
        
        confirm = input("🗑️  Delete all demo screenshots and videos? (y/N): ").strip().lower()
        if confirm == 'y':
            try:
                if self.screenshots_dir.exists():
                    shutil.rmtree(self.screenshots_dir)
                    self.screenshots_dir.mkdir(exist_ok=True)
                
                test_results = self.e2e_dir / 'test-results'
                if test_results.exists():
                    shutil.rmtree(test_results)
                
                playwright_report = self.e2e_dir / 'playwright-report'
                if playwright_report.exists():
                    shutil.rmtree(playwright_report)
                
                self.log("SUCCESS", "🧹 Demo files cleaned successfully!")
            except Exception as e:
                self.log("ERROR", f"❌ Failed to clean files: {e}")
        else:
            print("🚫 Cleanup cancelled.")

def main():
    """Main entry point"""
    demo_system = VisualDemoSystem()
    demo_system.interactive_menu()

if __name__ == "__main__":
    main()
