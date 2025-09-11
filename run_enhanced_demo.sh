#!/bin/bash
"""
Enhanced Dating App Demo Runner with Visual Debugging
Automatically sets up the environment and runs the enhanced demo system
"""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${PURPLE}╔══════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║     ENHANCED DATING APP DEMO SYSTEM     ║${NC}"
echo -e "${PURPLE}║     WITH VISUAL DEBUGGING SUPPORT       ║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════╝${NC}"
echo ""

# Change to the correct directory
cd /home/m/development/mobile-apps/flutter/dejtingapp

# Check if virtual environment exists
if [ ! -d "demo_env" ]; then
    echo -e "${YELLOW}🔧 Setting up visual debugging environment...${NC}"
    python3 -m venv demo_env
    source demo_env/bin/activate
    pip install pyautogui Pillow
    echo -e "${GREEN}✅ Virtual environment created with visual debugging support${NC}"
else
    echo -e "${CYAN}🎯 Using existing visual debugging environment${NC}"
fi

# Activate virtual environment
source demo_env/bin/activate

# Check for required system packages
echo -e "${CYAN}🔍 Checking system dependencies...${NC}"

# Check for gnome-screenshot
if ! command -v gnome-screenshot &> /dev/null; then
    echo -e "${YELLOW}📸 Installing gnome-screenshot for screenshots...${NC}"
    sudo apt install -y gnome-screenshot
fi

# Check for xdotool and wmctrl
if ! command -v xdotool &> /dev/null || ! command -v wmctrl &> /dev/null; then
    echo -e "${YELLOW}🔧 Installing automation tools...${NC}"
    sudo apt install -y xdotool wmctrl
fi

echo -e "${GREEN}✅ All dependencies ready!${NC}"
echo ""

# Check if backend services are running
echo -e "${CYAN}🔍 Checking backend services...${NC}"
if curl -s http://localhost:5001/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Backend services are running${NC}"
else
    echo -e "${YELLOW}⚠️  Backend services not detected${NC}"
    echo -e "${YELLOW}   You may need to start them with:${NC}"
    echo -e "${BLUE}   cd /home/m/development/DatingApp${NC}"
    echo -e "${BLUE}   docker-compose up -d${NC}"
    echo ""
fi

# Run the enhanced demo system
echo -e "${PURPLE}🚀 Starting Enhanced Demo System...${NC}"
echo ""

# Pass command line arguments to the demo
python3 automated_journey_demo.py "$@"

echo ""
echo -e "${PURPLE}👋 Enhanced demo session completed!${NC}"

# Show session summary if screenshots exist
if [ -d "demo_screenshots" ]; then
    screenshot_count=$(find demo_screenshots -name "*.png" | wc -l)
    if [ $screenshot_count -gt 0 ]; then
        echo -e "${GREEN}📸 Session generated $screenshot_count screenshots${NC}"
        echo -e "${CYAN}   Location: $(pwd)/demo_screenshots/${NC}"
    fi
fi
