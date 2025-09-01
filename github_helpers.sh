#!/bin/bash
# 🔧 Non-interactive GitHub Actions Helper Scripts
# Usage: ./github_helpers.sh

echo "🚀 GitHub Actions Helper Commands"
echo "=================================="

# Function to show latest workflow status
show_latest_status() {
    echo "📊 Latest Workflow Status:"
    gh run list --limit 5
    echo ""
}

# Function to show latest successful run
show_latest_success() {
    echo "✅ Latest Successful Run:"
    LATEST_SUCCESS=$(gh run list --status success --limit 1 --json databaseId --jq '.[0].databaseId')
    if [ "$LATEST_SUCCESS" != "null" ] && [ -n "$LATEST_SUCCESS" ]; then
        gh run view $LATEST_SUCCESS
    else
        echo "No successful runs found"
    fi
    echo ""
}

# Function to show latest failed run details
show_latest_failure() {
    echo "❌ Latest Failed Run Details:"
    LATEST_FAILED=$(gh run list --status failure --limit 1 --json databaseId --jq '.[0].databaseId')
    if [ "$LATEST_FAILED" != "null" ] && [ -n "$LATEST_FAILED" ]; then
        echo "Failure Details:"
        gh run view $LATEST_FAILED
        echo ""
        echo "Failure Logs:"
        gh run view $LATEST_FAILED --log-failed
    else
        echo "No failed runs found"
    fi
    echo ""
}

# Function to show logs of latest run (auto-select)
show_latest_logs() {
    echo "📋 Latest Run Logs:"
    LATEST_RUN=$(gh run list --limit 1 --json databaseId --jq '.[0].databaseId')
    if [ "$LATEST_RUN" != "null" ] && [ -n "$LATEST_RUN" ]; then
        gh run view $LATEST_RUN --log
    else
        echo "No runs found"
    fi
    echo ""
}

# Function to show monitoring status
show_monitoring_status() {
    echo "📈 Monitoring & Services Status:"
    echo "================================"
    cd /home/m/development/DatingApp 2>/dev/null || echo "DatingApp directory not found"
    
    echo "🐳 Docker Services:"
    docker-compose ps | grep -E "(Up|healthy|Exit)" | head -10
    echo ""
    
    echo "🌐 Available Dashboards:"
    echo "• Grafana: http://localhost:3000"
    echo "• Auth Service: http://localhost:8081"
    echo "• Matchmaking: http://localhost:8083" 
    echo "• Swipe Service: http://localhost:8084"
    echo "• API Gateway: http://localhost:8080"
    echo ""
}

# Function to check repository status
show_repo_status() {
    echo "📦 Repository Status:"
    echo "===================="
    echo "Current repository: $(gh repo view --json name,owner --jq '.owner.login + "/" + .name')"
    echo "Branch: $(git branch --show-current)"
    echo "Last commit: $(git log -1 --oneline)"
    echo ""
    
    echo "🔓 Repository Visibility:"
    gh repo list best-koder-ever --limit 15 --json name,visibility | jq -r '.[] | "\(.name): \(.visibility)"' | grep -E "(mobile_dejtingapp|auth-service|MatchmakingService|photo-service|swipe-service|UserService|TestDataGenerator|dejting-yarp|dating)"
    echo ""
}

# Function to check all .NET services GitHub Actions
show_dotnet_services_status() {
    echo "🏗️ .NET Services GitHub Actions Status:"
    echo "========================================"
    for repo in auth-service matchmaking-service photo-service swipe-service UserService TestDataGenerator dejting-yarp; do
        echo "📋 $repo:"
        STATUS=$(gh run list --repo best-koder-ever/$repo --limit 1 --json status,conclusion,name --jq '.[0] | "\(.status): \(.conclusion // "running") - \(.name)"' 2>/dev/null)
        if [ -n "$STATUS" ]; then
            echo "   $STATUS"
        else
            echo "   ❌ No runs or access issue"
        fi
        echo ""
    done
}

# Function to trigger professional CI/CD workflow
trigger_professional_workflow() {
    echo "🚀 Triggering Professional Dating App CI/CD..."
    echo "================================================"
    
    cd /home/m/development/DatingApp 2>/dev/null || {
        echo "❌ DatingApp directory not found"
        return 1
    }
    
    echo "📋 Triggering main CI/CD pipeline..."
    gh workflow run "Professional Dating App CI/CD" --ref main || echo "   ⚠️  Failed to trigger main workflow"
    
    echo ""
    echo "✅ Professional pipeline triggered!"
    echo "🌐 Main Pipeline: https://github.com/best-koder-ever/DatingApp-Config/actions"
    echo "📱 Flutter App: https://github.com/best-koder-ever/mobile_dejtingapp/actions"
    echo ""
    echo "💡 Use './github_helpers.sh status' to monitor progress"
    echo ""
}

# Function to trigger all .NET service workflows (legacy - kept for backward compatibility)
trigger_all_dotnet_workflows() {
    echo "🚀 Triggering GitHub Actions for all .NET services..."
    echo "======================================================"
    echo "⚠️  Note: Individual service workflows are legacy."
    echo "🎯 Consider using 'trigger-pro' for the unified professional pipeline."
    echo ""
    
    services=("auth-service" "matchmaking-service" "photo-service" "swipe-service" "UserService" "TestDataGenerator" "dejting-yarp")
    workflows=("🔐 Auth Service CI/CD" "💕 Matchmaking Service CI/CD" "📸 Photo Service CI/CD" "👆 Swipe Service CI/CD" "👤 User Service CI/CD" "🔄 Test Data Generator CI/CD" "🌐 YARP Gateway CI/CD")
    
    base_dir="/home/m/development/DatingApp"
    
    for i in "${!services[@]}"; do
        service="${services[$i]}"
        workflow="${workflows[$i]}"
        
        echo "📋 Triggering $service..."
        (cd "$base_dir/$service" && gh workflow run "$workflow" --ref main 2>/dev/null) || echo "   ⚠️  Failed to trigger $service"
    done
    
    echo ""
    echo "✅ All individual workflows triggered! Check GitHub for results:"
    echo "🌐 https://github.com/best-koder-ever/auth-service/actions"
    echo "🌐 https://github.com/best-koder-ever/matchmaking-service/actions"
    echo "🌐 https://github.com/best-koder-ever/photo-service/actions"
    echo "🌐 https://github.com/best-koder-ever/swipe-service/actions"
    echo "🌐 https://github.com/best-koder-ever/UserService/actions"
    echo "🌐 https://github.com/best-koder-ever/TestDataGenerator/actions"
    echo "🌐 https://github.com/best-koder-ever/dejting-yarp/actions"
    echo ""
}

# Function to use Gemini AI for code review
ai_code_review() {
    echo "🤖 AI Code Review with Gemini..."
    echo "================================="
    
    cd /home/m/development/DatingApp 2>/dev/null || {
        echo "❌ DatingApp directory not found"
        return 1
    }
    
    echo "📋 Analyzing latest changes..."
    LATEST_COMMIT=$(git log -1 --oneline)
    echo "Latest commit: $LATEST_COMMIT"
    echo ""
    
    echo "🔍 Running Gemini code review..."
    if command -v gemini &> /dev/null; then
        gemini "Review my latest dating app changes for best practices, security, and performance. Latest commit: $LATEST_COMMIT. Focus on .NET microservices and Flutter mobile app patterns."
    else
        echo "❌ Gemini CLI not found. Install with: npm install -g @google/generative-ai-cli"
        echo "💡 Alternative: Use 'gemini' command directly in terminal"
    fi
    echo ""
}

# Function to get AI planning assistance
ai_feature_planning() {
    echo "🎯 AI Feature Planning with Gemini..."
    echo "====================================="
    
    echo "🤖 Getting AI assistance for dating app feature planning..."
    if command -v gemini &> /dev/null; then
        gemini "I'm building a dating app with .NET microservices backend and Flutter mobile app. Help me plan the next features to implement. Current services: auth-service, user-service, matchmaking-service, swipe-service, photo-service. What should I prioritize for user engagement and technical excellence?"
    else
        echo "❌ Gemini CLI not found. Install with: npm install -g @google/generative-ai-cli"
        echo "💡 Alternative: Use 'gemini' command directly in terminal"
    fi
    echo ""
}

# Function to get AI optimization suggestions
ai_optimization() {
    echo "⚡ AI Optimization Analysis with Gemini..."
    echo "========================================="
    
    cd /home/m/development/DatingApp 2>/dev/null || {
        echo "❌ DatingApp directory not found"
        return 1
    }
    
    echo "🔍 Analyzing codebase for optimization opportunities..."
    if command -v gemini &> /dev/null; then
        gemini "Analyze my dating app architecture for performance optimizations. I have .NET microservices (auth, user, matchmaking, swipe, photo services) and Flutter mobile app. Suggest improvements for scalability, performance, and user experience."
    else
        echo "❌ Gemini CLI not found. Install with: npm install -g @google/generative-ai-cli"
        echo "💡 Alternative: Use 'gemini' command directly in terminal"
    fi
    echo ""
}

# Function to get AI debugging help
ai_debug_help() {
    echo "🐛 AI Debugging Assistant with Gemini..."
    echo "========================================"
    
    echo "🤖 Getting AI debugging assistance..."
    echo "💡 Tip: Describe your issue after running this command"
    
    if command -v gemini &> /dev/null; then
        echo "Usage: gemini 'Help me debug this dating app issue: [describe your problem]'"
        echo "Example: gemini 'My matchmaking service is slow when processing 1000+ users'"
    else
        echo "❌ Gemini CLI not found. Install with: npm install -g @google/generative-ai-cli"
        echo "💡 Alternative: Use 'gemini' command directly in terminal"
    fi
    echo ""
}

# Function to use smart AI with full project context
smart_ai_context() {
    echo "🧠 Smart AI with Full Project Context..."
    echo "======================================="
    
    cd /home/m/development/DatingApp 2>/dev/null || {
        echo "❌ DatingApp directory not found"
        return 1
    }
    
    # Generate comprehensive context
    echo "📊 Generating project context from actual code and git history..."
    
    local context_summary="Dating App Development Context:
    
Recent commits: $(git log --oneline -5)
Current files: $(find . -name "*.cs" -o -name "*.dart" | wc -l) code files
Services: $(ls -d */ 2>/dev/null | grep -E "(auth|user|match|swipe|photo)" | tr '\n' ' ')
Recent changes: $(git diff --name-only HEAD~3..HEAD | wc -l) files modified
Open TODOs: $(grep -r "TODO\|FIXME" . --include="*.cs" --include="*.dart" 2>/dev/null | wc -l) items"

    echo "✅ Context ready!"
    echo ""
    echo "🤖 What would you like AI help with?"
    echo "1) Smart feature planning (knows your current code)"
    echo "2) Smart code review (understands recent changes)"  
    echo "3) Smart debugging (sees full project context)"
    echo "4) Smart status analysis (tracks real progress)"
    echo ""
    read -p "Enter choice (1-4): " choice
    
    case $choice in
        1)
            echo "🎯 Smart AI Planning..."
            if command -v gemini &> /dev/null; then
                gemini "Based on this dating app project: $context_summary

                Analyze my actual codebase and suggest what features to implement next for a complete dating app. Consider what's already built vs what's missing."
            else
                echo "❌ Gemini CLI not found"
            fi
            ;;
        2)
            echo "🔍 Smart AI Review..."
            if command -v gemini &> /dev/null; then
                gemini "Review my dating app development: $context_summary

                Analyze recent changes, code quality, architecture decisions, and suggest improvements based on what I've actually built."
            else
                echo "❌ Gemini CLI not found"
            fi
            ;;
        3)
            echo "🐛 Smart AI Debugging..."
            echo "Describe your issue:"
            read -r issue
            if command -v gemini &> /dev/null; then
                gemini "Help debug this dating app issue: $issue

                Project context: $context_summary
                
                Provide solutions considering my actual codebase and recent changes."
            else
                echo "❌ Gemini CLI not found"
            fi
            ;;
        4)
            echo "📊 Smart Status Analysis..."
            if command -v gemini &> /dev/null; then
                gemini "Analyze my dating app development progress: $context_summary

                Based on actual git history and code structure, tell me:
                - What percentage complete is my dating app?
                - What are the next logical features to implement?
                - What potential issues do you see?"
            else
                echo "❌ Gemini CLI not found"
            fi
            ;;
    esac
    echo ""
}
    echo "📊 DATING APP PROJECT STATUS & MEMORY"
    echo "====================================="
    
    cd /home/m/development/DatingApp 2>/dev/null || {
        echo "❌ DatingApp directory not found"
        return 1
    }
    
    echo "📖 Reading project memory..."
    if [ -f "PROJECT_MEMORY.md" ]; then
        echo ""
        echo "🎯 Current Phase & Status:"
        grep -A 5 "Status.*IN PROGRESS" PROJECT_MEMORY.md || echo "Phase info not found"
        
        echo ""
        echo "✅ Completed This Week:"
        grep -A 10 "What We Built:" PROJECT_MEMORY.md | tail -5
        
        echo ""
        echo "🎯 Next Priorities:"
        grep -A 5 "Immediate.*This Week" PROJECT_MEMORY.md | tail -4
        
        echo ""
        echo "🤖 Want to update project status or get AI planning help?"
        echo "1) Update project status"
        echo "2) AI analysis of current project state"
        echo "3) AI planning for next features"
        echo "4) View full project memory"
        echo ""
        read -p "Enter choice (1-4) or press Enter to continue: " choice
        
        case $choice in
            1)
                echo "📝 Updating project status..."
                echo "What did you complete today? (Enter to skip)"
                read -r COMPLETED
                if [ -n "$COMPLETED" ]; then
                    echo "- $(date +%Y-%m-%d): $COMPLETED" >> PROJECT_MEMORY.md
                    echo "✅ Status updated!"
                fi
                ;;
            2)
                echo "🤖 Getting AI analysis..."
                if command -v gemini &> /dev/null; then
                    gemini "Analyze my dating app project status. Here's the current state: $(cat PROJECT_MEMORY.md | head -50). What should I focus on next and what are potential issues?"
                else
                    echo "❌ Gemini CLI not found"
                fi
                ;;
            3)
                echo "🎯 Getting AI planning assistance..."
                if command -v gemini &> /dev/null; then
                    gemini "Based on my dating app project memory, help me plan the next development phase. Current services: auth, user, matchmaking, swipe, photo. What features should I implement next for a real dating app?"
                else
                    echo "❌ Gemini CLI not found"
                fi
                ;;
            4)
                echo "📖 Full Project Memory:"
                cat PROJECT_MEMORY.md
                ;;
        esac
    else
        echo "❌ Project memory file not found"
        echo "💡 Create it by running: touch PROJECT_MEMORY.md"
    fi
    echo ""
}

# Function to run local testing (integrated from test_workflow_locally.sh)
local_testing() {
    echo "🧪 LOCAL TESTING MENU"
    echo "===================="
    echo "Choose testing option:"
    echo "1) Quick build test (30 seconds)"
    echo "2) Full local simulation with act"
    echo "3) Start all services locally"
    echo "4) Stop all local services"
    echo ""
    read -p "Enter choice (1-4): " choice
    
    cd /home/m/development/DatingApp 2>/dev/null || {
        echo "❌ DatingApp directory not found"
        return 1
    }
    
    case $choice in
        1)
            echo "🔧 Running quick build test..."
            ./test_workflow_locally.sh build-local 2>/dev/null || {
                echo "🔧 Testing builds locally..."
                for service in auth-service user-service matchmaking-service swipe-service photo-service; do
                    echo "🔍 Testing $service..."
                    cd $service
                    case "$service" in
                        "auth-service") dotnet build AuthService.csproj ;;
                        "user-service") dotnet build UserService.csproj ;;
                        "matchmaking-service") dotnet build MatchmakingService.csproj ;;
                        "swipe-service") dotnet build swipe-service.csproj ;;
                        "photo-service") dotnet build PhotoService.csproj ;;
                    esac
                    cd ..
                done
            }
            ;;
        2)
            echo "🎬 Running full simulation with act..."
            if command -v act &> /dev/null; then
                act -j quick-validation
            else
                echo "❌ Act not found. Install with: curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash"
            fi
            ;;
        3)
            echo "🚀 Starting all services locally..."
            docker-compose up -d postgres
            echo "Starting .NET services..."
            echo "🔐 Auth: http://localhost:8081"
            echo "👤 User: http://localhost:8082" 
            echo "💕 Matchmaking: http://localhost:8083"
            echo "👆 Swipe: http://localhost:8084"
            echo "📸 Photo: http://localhost:8085"
            echo "🌐 Gateway: http://localhost:8080"
            ;;
        4)
            echo "🛑 Stopping all local services..."
            docker-compose down
            echo "✅ All services stopped"
            ;;
        *)
            echo "❌ Invalid choice"
            ;;
    esac
    echo ""
}

# Main menu
case "${1:-menu}" in
    "status"|"s")
        show_latest_status
        ;;
    "success"|"ok")
        show_latest_success
        ;;
    "failure"|"fail"|"f")
        show_latest_failure
        ;;
    "logs"|"l")
        show_latest_logs
        ;;
    "monitoring"|"mon"|"m")
        show_monitoring_status
        ;;
    "repo"|"r")
        show_repo_status
        ;;
    "dotnet"|"services"|"d")
        show_dotnet_services_status
        ;;
    "trigger"|"t")
        trigger_all_dotnet_workflows
        ;;
    "trigger-pro"|"pro"|"tp")
        trigger_professional_workflow
        ;;
    "ai-review"|"review"|"ar")
        ai_code_review
        ;;
    "ai-plan"|"plan"|"ap")
        ai_feature_planning
        ;;
    "ai-optimize"|"opt"|"ao")
        ai_optimization
        ;;
    "ai-debug"|"debug"|"ad")
        ai_debug_help
        ;;
    "local"|"test"|"lt")
        local_testing
        ;;
    "status-project"|"memory"|"sp")
        project_status
        ;;
    "smart-ai"|"smart"|"sa")
        smart_ai_context
        ;;
    "all"|"a")
        show_repo_status
        show_latest_status
        show_dotnet_services_status
        show_monitoring_status
        ;;
    *)
        echo "Usage: $0 [command]"
        echo ""
        echo "🎯 MAIN DEVELOPMENT MENU:"
        echo "  memory|sp       - 📊 Project status & memory (NEW!)"
        echo "  local|test      - 🧪 Local testing & services"
        echo "  trigger-pro|pro - 🚀 Professional CI/CD pipeline"
        echo "  status|s        - 📊 Show workflow status"
        echo ""
        echo "🤖 AI ASSISTANT:"
        echo "  smart-ai|smart  - 🧠 Smart AI with project context (BETTER!)"
        echo "  ai-plan|ap      - 🎯 AI feature planning"
        echo "  ai-review|ar    - 🔍 AI code review"
        echo "  ai-optimize|ao  - ⚡ AI optimization tips"
        echo "  ai-debug|ad     - 🐛 AI debugging help"
        echo ""
        echo "📋 DETAILED INFO:"
        echo "  success|ok   - ✅ Latest successful run"
        echo "  failure|f    - ❌ Latest failed run with logs"
        echo "  logs|l       - 📋 Latest run logs"
        echo "  monitoring|m - 📈 Services & monitoring status"
        echo "  repo|r       - 📦 Repository status"
        echo "  dotnet|d     - 🏗️ .NET services status"
        echo "  all|a        - � Everything"
        echo ""
        echo "🚀 AI-POWERED WORKFLOW:"
        echo "  1. $0 memory    # Check project status & plan with AI"
        echo "  2. $0 local     # Test locally first (30 seconds)"
        echo "  3. Code with GitHub Copilot in VS Code"
        echo "  4. $0 ar        # AI review before commit"
        echo "  5. $0 pro       # Professional CI/CD (when ready)"
        echo ""
        echo "💡 NEW: Project memory tracks everything for you & AI!"
        ;;
esac
