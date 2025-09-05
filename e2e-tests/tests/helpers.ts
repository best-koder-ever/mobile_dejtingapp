import { test, expect, Page } from '@playwright/test';

// Helper functions for common actions
export class DatingAppPage {
  constructor(public page: Page) {}

  // Authentication helpers
  async goto() {
    await this.page.goto('/');
  }

  async fillRegistrationForm(userData: {
    email: string;
    password: string;
    firstName: string;
    lastName: string;
  }) {
    await this.page.fill('[data-testid="email-input"]', userData.email);
    await this.page.fill('[data-testid="password-input"]', userData.password);
    await this.page.fill('[data-testid="firstName-input"]', userData.firstName);
    await this.page.fill('[data-testid="lastName-input"]', userData.lastName);
  }

  async submitRegistration() {
    await this.page.click('[data-testid="register-button"]');
  }

  async fillLoginForm(email: string, password: string) {
    await this.page.fill('[data-testid="login-email"]', email);
    await this.page.fill('[data-testid="login-password"]', password);
  }

  async submitLogin() {
    await this.page.click('[data-testid="login-button"]');
  }

  // Navigation helpers
  async navigateToProfile() {
    await this.page.click('[data-testid="profile-tab"]');
  }

  async navigateToSwipe() {
    await this.page.click('[data-testid="swipe-tab"]');
  }

  async navigateToMatches() {
    await this.page.click('[data-testid="matches-tab"]');
  }

  // Profile helpers
  async fillProfileDetails(profileData: {
    bio?: string;
    age?: number;
    city?: string;
    occupation?: string;
    interests?: string[];
  }) {
    if (profileData.bio) {
      await this.page.fill('[data-testid="bio-input"]', profileData.bio);
    }
    if (profileData.age) {
      await this.page.fill('[data-testid="age-input"]', profileData.age.toString());
    }
    if (profileData.city) {
      await this.page.fill('[data-testid="city-input"]', profileData.city);
    }
    if (profileData.occupation) {
      await this.page.fill('[data-testid="occupation-input"]', profileData.occupation);
    }
  }

  async saveProfile() {
    await this.page.click('[data-testid="save-profile-button"]');
  }

  // Swipe helpers
  async swipeRight() {
    const swipeCard = this.page.locator('[data-testid="swipe-card"]').first();
    await swipeCard.hover();
    await this.page.mouse.down();
    await this.page.mouse.move(100, 0); // Swipe right
    await this.page.mouse.up();
  }

  async swipeLeft() {
    const swipeCard = this.page.locator('[data-testid="swipe-card"]').first();
    await swipeCard.hover();
    await this.page.mouse.down();
    await this.page.mouse.move(-100, 0); // Swipe left
    await this.page.mouse.up();
  }

  async clickLikeButton() {
    await this.page.click('[data-testid="like-button"]');
  }

  async clickPassButton() {
    await this.page.click('[data-testid="pass-button"]');
  }

  // Messaging helpers
  async openChat(matchId: string) {
    await this.page.click(`[data-testid="chat-${matchId}"]`);
  }

  async sendMessage(message: string) {
    await this.page.fill('[data-testid="message-input"]', message);
    await this.page.click('[data-testid="send-message-button"]');
  }

  async getLastMessage() {
    return await this.page.textContent('[data-testid="message-bubble"]:last-child [data-testid="message-content"]');
  }

  // Verification helpers
  async waitForToast(message?: string) {
    const toast = this.page.locator('[data-testid="toast"], .toast, [role="alert"]');
    await toast.waitFor({ state: 'visible' });
    if (message) {
      await expect(toast).toContainText(message);
    }
    return toast;
  }

  async isLoggedIn() {
    // Check if we're on the main app screen (not login/register)
    return await this.page.locator('[data-testid="main-nav"], [data-testid="swipe-tab"]').isVisible();
  }

  async waitForNavigation() {
    await this.page.waitForLoadState('networkidle');
  }
}

// Test data generators
export const generateTestUser = (suffix?: string) => ({
  email: `test${suffix || Math.random().toString(36).substr(2, 9)}@example.com`,
  password: 'TestPassword123!',
  firstName: `TestUser${suffix || ''}`,
  lastName: `LastName${suffix || ''}`,
});

export const generateProfileData = () => ({
  bio: 'I love traveling, good food, and meeting new people!',
  age: 25,
  city: 'San Francisco',
  occupation: 'Software Engineer',
  interests: ['Travel', 'Food', 'Technology', 'Fitness'],
});
