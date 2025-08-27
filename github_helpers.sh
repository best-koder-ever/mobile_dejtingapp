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
    gh repo list best-koder-ever --limit 10 --json name,visibility | jq -r '.[] | "\(.name): \(.visibility)"' | grep -E "(mobile_dejtingapp|auth-service|matchmaking|dating)"
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
    "all"|"a")
        show_repo_status
        show_latest_status
        show_monitoring_status
        ;;
    *)
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  status|s     - Show latest workflow status"
        echo "  success|ok   - Show latest successful run"
        echo "  failure|f    - Show latest failed run with logs"
        echo "  logs|l       - Show logs of latest run"
        echo "  monitoring|m - Show monitoring & services status" 
        echo "  repo|r       - Show repository status"
        echo "  all|a        - Show everything"
        echo ""
        echo "Examples:"
        echo "  $0 status"
        echo "  $0 logs"
        echo "  $0 all"
        ;;
esac
