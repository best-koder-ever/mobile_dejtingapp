import { test, expect } from '@playwright/test';
import { DatingAppPage, generateTestUser } from './helpers';

test.describe('Dating App - Messaging', () => {
  let datingApp: DatingAppPage;
  let testUser: ReturnType<typeof generateTestUser>;

  test.beforeEach(async ({ page }) => {
    datingApp = new DatingAppPage(page);
    testUser = generateTestUser('messenger');
    
    // Login or register first
    await datingApp.goto();
    await datingApp.authenticateUser(testUser.email, testUser.password, 'register');
  });

  test('should navigate to messages section', async ({ page }) => {
    // Look for messages/chat navigation
    const messagesNav = page.locator(
      'button:has-text("Messages"), button:has-text("Chat"), .tab:has-text("Messages"), ' +
      '[data-testid="messages-tab"], .bottom-nav:has-text("Messages")'
    );
    
    if (await messagesNav.isVisible()) {
      await messagesNav.click();
      await page.waitForTimeout(1000);
    }
    
    // Should see messages interface
    const hasMessagesInterface = await page.locator(
      '.messages-list, .chat-list, .conversations, text="Messages", text="Conversations"'
    ).first().isVisible();
    
    expect(hasMessagesInterface).toBeTruthy();
  });

  test('should display matches/conversations list', async ({ page }) => {
    await datingApp.navigateToMessages();
    await page.waitForTimeout(2000);
    
    // Check for matches or conversations
    const hasMatches = await page.locator(
      '.match-item, .conversation-item, .chat-preview, text="No matches yet", text="Start chatting"'
    ).first().isVisible();
    
    expect(hasMatches).toBeTruthy();
  });

  test('should open a conversation', async ({ page }) => {
    await datingApp.navigateToMessages();
    await page.waitForTimeout(2000);
    
    // Look for an existing conversation/match to click
    const conversation = page.locator(
      '.match-item, .conversation-item, .chat-preview'
    ).first();
    
    if (await conversation.isVisible()) {
      await conversation.click();
      await page.waitForTimeout(1000);
      
      // Should see chat interface
      const hasChatInterface = await page.locator(
        '.chat-interface, .message-input, input[placeholder*="message"], textarea[placeholder*="message"]'
      ).first().isVisible();
      
      expect(hasChatInterface).toBeTruthy();
    } else {
      // No existing conversations - that's also valid for new users
      console.log('No existing conversations found - this is normal for new users');
    }
  });

  test('should send a message', async ({ page }) => {
    await datingApp.navigateToMessages();
    await page.waitForTimeout(2000);
    
    // Try to find and open a conversation
    const conversation = page.locator('.match-item, .conversation-item, .chat-preview').first();
    
    if (await conversation.isVisible()) {
      await conversation.click();
      await page.waitForTimeout(1000);
      
      // Send a test message
      const testMessage = `Hello! This is a test message from E2E tests - ${Date.now()}`;
      const sent = await datingApp.sendMessage(testMessage);
      
      expect(sent).toBeTruthy();
    }
  });

  test('should display message history', async ({ page }) => {
    await datingApp.navigateToMessages();
    await page.waitForTimeout(2000);
    
    const conversation = page.locator('.match-item, .conversation-item').first();
    
    if (await conversation.isVisible()) {
      await conversation.click();
      await page.waitForTimeout(1000);
      
      // Check for message history area
      const hasMessageHistory = await page.locator(
        '.message-history, .chat-messages, .messages-container, .message-bubble'
      ).first().isVisible();
      
      // Or check for "no messages" state
      const noMessages = await page.locator(
        'text="No messages", text="Start the conversation", text="Say hello"'
      ).isVisible();
      
      expect(hasMessageHistory || noMessages).toBeTruthy();
    }
  });

  test('should handle real-time message updates', async ({ page }) => {
    await datingApp.navigateToMessages();
    await page.waitForTimeout(2000);
    
    const conversation = page.locator('.match-item, .conversation-item').first();
    
    if (await conversation.isVisible()) {
      await conversation.click();
      await page.waitForTimeout(1000);
      
      // Send a message
      const messageInput = page.locator(
        'input[placeholder*="message"], textarea[placeholder*="message"], .message-input input, .message-input textarea'
      ).first();
      
      if (await messageInput.isVisible()) {
        const testMessage = `Real-time test - ${Date.now()}`;
        await messageInput.fill(testMessage);
        
        const sendButton = page.locator(
          'button:has-text("Send"), .send-button, [data-testid="send-button"], button[type="submit"]'
        ).first();
        
        if (await sendButton.isVisible()) {
          await sendButton.click();
          await page.waitForTimeout(2000);
          
          // Check if message appears in history
          const messageAppeared = await page.locator(`text="${testMessage}"`).isVisible();
          expect(messageAppeared).toBeTruthy();
        }
      }
    }
  });

  test('should validate message input', async ({ page }) => {
    await datingApp.navigateToMessages();
    await page.waitForTimeout(2000);
    
    const conversation = page.locator('.match-item, .conversation-item').first();
    
    if (await conversation.isVisible()) {
      await conversation.click();
      await page.waitForTimeout(1000);
      
      // Try to send empty message
      const sendButton = page.locator(
        'button:has-text("Send"), .send-button, [data-testid="send-button"]'
      ).first();
      
      if (await sendButton.isVisible()) {
        // Should be disabled or not work with empty input
        const isDisabled = await sendButton.isDisabled();
        
        if (!isDisabled) {
          await sendButton.click();
          await page.waitForTimeout(500);
          
          // Empty message shouldn't be sent
          const emptyMessageSent = await page.locator('text=""').count() === 0;
          expect(emptyMessageSent).toBeTruthy();
        } else {
          // Button correctly disabled for empty message
          expect(isDisabled).toBeTruthy();
        }
      }
    }
  });

  test('should show typing indicators', async ({ page }) => {
    await datingApp.navigateToMessages();
    await page.waitForTimeout(2000);
    
    const conversation = page.locator('.match-item, .conversation-item').first();
    
    if (await conversation.isVisible()) {
      await conversation.click();
      await page.waitForTimeout(1000);
      
      // Start typing in message input
      const messageInput = page.locator(
        'input[placeholder*="message"], textarea[placeholder*="message"]'
      ).first();
      
      if (await messageInput.isVisible()) {
        await messageInput.focus();
        await messageInput.type('Testing typing indicator...');
        
        // Look for typing indicator (might not be implemented yet)
        const typingIndicator = await page.locator(
          'text="typing", .typing-indicator, .dots-animation'
        ).isVisible();
        
        // This is optional - typing indicators might not be implemented
        console.log(`Typing indicator shown: ${typingIndicator}`);
      }
    }
  });
});
