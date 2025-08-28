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
    "all"|"a")
        show_repo_status
        show_latest_status
        show_dotnet_services_status
        show_monitoring_status
        ;;
    *)
        echo "Usage: $0 [command]"
        echo ""
        echo "🎯 Primary Commands:"
        echo "  trigger-pro|pro - Trigger professional CI/CD pipeline (RECOMMENDED)"
        echo "  status|s        - Show latest workflow status"
        echo "  all|a          - Show everything"
        echo ""
        echo "📋 Detailed Commands:"
        echo "  success|ok   - Show latest successful run"
        echo "  failure|f    - Show latest failed run with logs"
        echo "  logs|l       - Show logs of latest run"
        echo "  monitoring|m - Show monitoring & services status" 
        echo "  repo|r       - Show repository status"
        echo "  dotnet|d     - Show all .NET services GitHub Actions"
        echo "  trigger|t    - Trigger individual .NET service workflows (legacy)"
        echo ""
        echo "🚀 Professional Examples:"
        echo "  $0 pro          # Trigger main professional pipeline"
        echo "  $0 status       # Check pipeline status"
        echo "  $0 all          # Full status overview"
        echo ""
        echo "💡 For daily development: Use 'pro' command for professional CI/CD"
        ;;
esac
