#!/bin/bash
# Quick Keyring Reset Script
echo '🔐 Resetting Ubuntu Keyring for Auto-Unlock'
echo '========================================='
echo
echo '⚠️  WARNING: This will remove your current keyring and all stored passwords!'
echo 'You will need to re-enter passwords for applications that use the keyring.'
echo
echo 'Steps this script will perform:'
echo '1. Backup current keyring'
echo '2. Remove login keyring'
echo '3. Instructions for setting up new keyring'
echo
read -p 'Do you want to continue? (y/N): ' -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo
    echo '📁 Creating backup...'
    cp ~/.local/share/keyrings/login.keyring ~/.local/share/keyrings/login.keyring.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || echo 'No existing keyring to backup'
    
    echo '🗑️  Removing current keyring...'
    rm -f ~/.local/share/keyrings/login.keyring
    
    echo '✅ Done!'
    echo
    echo '📋 NEXT STEPS:'
    echo '1. Log out completely (not just lock screen)'
    echo '2. Log back in'
    echo '3. When prompted for keyring password, use your Ubuntu login password'
    echo '4. Or leave it empty for no password protection'
    echo
    echo '💡 TIP: Using your login password enables automatic unlock!'
else
    echo 'Operation cancelled.'
fi
