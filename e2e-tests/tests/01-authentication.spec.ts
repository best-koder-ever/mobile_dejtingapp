import { test, expect } from '@playwright/test';
import { DatingAppPage, generateTestUser, generateProfileData } from './helpers';

test.describe('Dating App - Authentication Flow', () => {
  let datingApp: DatingAppPage;

  test.beforeEach(async ({ page }) => {
    datingApp = new DatingAppPage(page);
    await datingApp.goto();
  });

  test('should display login screen on initial load', async ({ page }) => {
    await expect(page).toHaveTitle(/DatingApp|Dating/i);
    
    // Check if login form is visible
    await expect(page.locator('[data-testid="login-email"], input[type="email"]')).toBeVisible();
    await expect(page.locator('[data-testid="login-password"], input[type="password"]')).toBeVisible();
    await expect(page.locator('[data-testid="login-button"], button:has-text("Login"), button:has-text("Log In")')).toBeVisible();
  });

  test('should register a new user successfully', async ({ page }) => {
    const testUser = generateTestUser();
    
    // Navigate to register screen
    await page.click('button:has-text("Register"), button:has-text("Sign Up"), a:has-text("Register")');
    
    // Fill registration form
    await page.fill('input[type="email"]', testUser.email);
    await page.fill('input[type="password"]', testUser.password);
    
    // Look for first name and last name fields (they might be combined or separate)
    const firstNameField = page.locator('input[placeholder*="First"], input[name*="firstName"], input[id*="firstName"]').first();
    const lastNameField = page.locator('input[placeholder*="Last"], input[name*="lastName"], input[id*="lastName"]').first();
    
    if (await firstNameField.isVisible()) {
      await firstNameField.fill(testUser.firstName);
    }
    if (await lastNameField.isVisible()) {
      await lastNameField.fill(testUser.lastName);
    }
    
    // Submit registration
    await page.click('button:has-text("Register"), button:has-text("Sign Up"), button[type="submit"]');
    
    // Wait for success (redirect to main app or success message)
    await page.waitForTimeout(2000); // Give time for navigation
    
    // Verify successful registration (either redirected to main app or success message)
    const isMainApp = await page.locator('[data-testid="main-nav"], .bottom-nav, .tab-bar').isVisible();
    const hasSuccessMessage = await page.locator('text="registered successfully", text="Registration successful", text="Welcome"').isVisible();
    
    expect(isMainApp || hasSuccessMessage).toBeTruthy();
  });

  test('should login with existing credentials', async ({ page }) => {
    // Use a predefined test account or register one first
    const testUser = generateTestUser('login');
    
    // Try to register first (in case account doesn't exist)
    try {
      await page.click('button:has-text("Register"), button:has-text("Sign Up"), a:has-text("Register")');
      await page.fill('input[type="email"]', testUser.email);
      await page.fill('input[type="password"]', testUser.password);
      await page.click('button:has-text("Register"), button:has-text("Sign Up"), button[type="submit"]');
      await page.waitForTimeout(1000);
    } catch (e) {
      // Account might already exist, continue with login
    }
    
    // Go back to login if we're not there
    if (await page.locator('button:has-text("Login"), a:has-text("Login")').isVisible()) {
      await page.click('button:has-text("Login"), a:has-text("Login")');
    }
    
    // Fill login form
    await page.fill('input[type="email"]', testUser.email);
    await page.fill('input[type="password"]', testUser.password);
    
    // Submit login
    await page.click('button:has-text("Login"), button:has-text("Log In"), button[type="submit"]');
    
    // Wait for navigation
    await page.waitForTimeout(3000);
    
    // Verify successful login (should see main app interface)
    const isLoggedIn = await page.locator('[data-testid="main-nav"], .bottom-nav, .tab-bar, text="Swipe", text="Matches", text="Profile"').isVisible();
    expect(isLoggedIn).toBeTruthy();
  });

  test('should show error for invalid credentials', async ({ page }) => {
    // Try to login with invalid credentials
    await page.fill('input[type="email"]', 'invalid@example.com');
    await page.fill('input[type="password"]', 'wrongpassword');
    
    await page.click('button:has-text("Login"), button:has-text("Log In"), button[type="submit"]');
    
    // Wait for error message
    await page.waitForTimeout(2000);
    
    // Check for error message
    const hasError = await page.locator('text="Invalid", text="Error", text="credentials", .error, .alert-error').isVisible();
    expect(hasError).toBeTruthy();
  });

  test('should validate required fields', async ({ page }) => {
    // Try to register with empty fields
    await page.click('button:has-text("Register"), button:has-text("Sign Up"), a:has-text("Register")');
    
    // Try to submit with empty form
    await page.click('button:has-text("Register"), button:has-text("Sign Up"), button[type="submit"]');
    
    // Should show validation errors or prevent submission
    const hasValidationError = await page.locator('text="required", text="Required", .error, .validation-error').isVisible();
    expect(hasValidationError).toBeTruthy();
  });
});
