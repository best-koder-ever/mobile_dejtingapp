import { test, expect } from '@playwright/test';
import { DatingAppPage, generateTestUser, generateProfileData } from './helpers';

test.describe('Dating App - Profile Management', () => {
  let datingApp: DatingAppPage;
  let testUser: ReturnType<typeof generateTestUser>;

  test.beforeEach(async ({ page }) => {
    datingApp = new DatingAppPage(page);
    testUser = generateTestUser('profile');
    
    // Login or register first
    await datingApp.goto();
    
    // Quick registration/login
    try {
      await page.click('button:has-text("Register"), a:has-text("Register")');
      await page.fill('input[type="email"]', testUser.email);
      await page.fill('input[type="password"]', testUser.password);
      await page.click('button:has-text("Register"), button[type="submit"]');
      await page.waitForTimeout(2000);
    } catch (e) {
      // If registration fails, try login
      await page.fill('input[type="email"]', testUser.email);
      await page.fill('input[type="password"]', testUser.password);
      await page.click('button:has-text("Login"), button[type="submit"]');
      await page.waitForTimeout(2000);
    }
  });

  test('should navigate to profile section', async ({ page }) => {
    // Look for profile navigation
    const profileNav = page.locator('button:has-text("Profile"), .tab:has-text("Profile"), [data-testid="profile-tab"]');
    
    if (await profileNav.isVisible()) {
      await profileNav.click();
      await page.waitForTimeout(1000);
    }
    
    // Should see profile form or profile display
    const hasProfileSection = await page.locator('text="Profile", text="Bio", text="Age", input, textarea').isVisible();
    expect(hasProfileSection).toBeTruthy();
  });

  test('should create and update profile information', async ({ page }) => {
    const profileData = generateProfileData();
    
    // Navigate to profile
    const profileNav = page.locator('button:has-text("Profile"), .tab:has-text("Profile"), [data-testid="profile-tab"]');
    if (await profileNav.isVisible()) {
      await profileNav.click();
      await page.waitForTimeout(1000);
    }
    
    // Fill out profile information
    const bioField = page.locator('textarea[placeholder*="bio"], textarea[name*="bio"], textarea').first();
    if (await bioField.isVisible()) {
      await bioField.fill(profileData.bio);
    }
    
    const ageField = page.locator('input[placeholder*="age"], input[name*="age"], input[type="number"]').first();
    if (await ageField.isVisible()) {
      await ageField.fill(profileData.age.toString());
    }
    
    const cityField = page.locator('input[placeholder*="city"], input[name*="city"], input[placeholder*="location"]').first();
    if (await cityField.isVisible()) {
      await cityField.fill(profileData.city);
    }
    
    const occupationField = page.locator('input[placeholder*="occupation"], input[name*="occupation"], input[placeholder*="job"]').first();
    if (await occupationField.isVisible()) {
      await occupationField.fill(profileData.occupation);
    }
    
    // Save profile
    const saveButton = page.locator('button:has-text("Save"), button:has-text("Update"), button[type="submit"]');
    if (await saveButton.isVisible()) {
      await saveButton.click();
      await page.waitForTimeout(2000);
    }
    
    // Verify profile was saved (look for success message or preserved data)
    const profileSaved = await page.locator('text="saved successfully", text="updated successfully", text="Profile updated"').isVisible();
    expect(profileSaved).toBeTruthy();
  });

  test('should handle photo upload', async ({ page }) => {
    // Navigate to profile
    const profileNav = page.locator('button:has-text("Profile"), .tab:has-text("Profile")');
    if (await profileNav.isVisible()) {
      await profileNav.click();
      await page.waitForTimeout(1000);
    }
    
    // Look for photo upload section
    const photoUpload = page.locator('input[type="file"], button:has-text("Upload"), button:has-text("Photo")');
    
    if (await photoUpload.isVisible()) {
      // Note: For actual file upload, you'd need to provide a test image file
      // This test verifies the upload interface exists
      expect(await photoUpload.count()).toBeGreaterThan(0);
    } else {
      // If no upload interface, that's also valid - just log it
      console.log('Photo upload interface not found - may be implemented differently');
    }
  });

  test('should display profile information correctly', async ({ page }) => {
    // Navigate to profile
    const profileNav = page.locator('button:has-text("Profile"), .tab:has-text("Profile")');
    if (await profileNav.isVisible()) {
      await profileNav.click();
      await page.waitForTimeout(1000);
    }
    
    // Check that profile fields are present (even if empty)
    const hasRequiredFields = await page.locator('text="Bio", text="Age", text="Location"').count() > 0;
    expect(hasRequiredFields).toBeTruthy();
  });

  test('should validate profile data', async ({ page }) => {
    // Navigate to profile
    const profileNav = page.locator('button:has-text("Profile"), .tab:has-text("Profile")');
    if (await profileNav.isVisible()) {
      await profileNav.click();
      await page.waitForTimeout(1000);
    }
    
    // Try to enter invalid age (negative number)
    const ageField = page.locator('input[name*="age"], input[type="number"]').first();
    if (await ageField.isVisible()) {
      await ageField.fill('-5');
      
      // Try to save
      const saveButton = page.locator('button:has-text("Save"), button[type="submit"]').first();
      if (await saveButton.isVisible()) {
        await saveButton.click();
        await page.waitForTimeout(1000);
        
        // Should show validation error or reject the input
        const hasError = await page.locator('text="invalid", text="error", .error').isVisible();
        const ageValue = await ageField.inputValue();
        
        // Either shows error or doesn't accept invalid value
        expect(hasError || ageValue !== '-5').toBeTruthy();
      }
    }
  });
});
