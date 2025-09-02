#!/bin/bash

# Flutter Chrome Development Aliases
# Add these to your ~/.bashrc or ~/.zshrc

# Always run Flutter with Chrome
alias frun='flutter run -d chrome --web-port=36349'
alias ftest='flutter test -d chrome'
alias fbuild='flutter build web'
alias fanalyze='flutter analyze'

# Development workflow shortcuts
alias fdev='flutter run -d chrome --web-port=36349 --debug'
alias fprod='flutter run -d chrome --web-port=36349 --release'
alias fhot='flutter run -d chrome --web-port=36349 --hot'

# Testing shortcuts  
alias fe2e='cd /home/m/development/DatingApp/e2e-tests && source venv/bin/activate && python test_login_enhanced.py'
alias fplaywright='cd /home/m/development/DatingApp/e2e-tests && ./run_all_tests.sh'

echo "🎯 Flutter Chrome aliases loaded!"
echo "Use: frun, ftest, fdev, fprod, fe2e, fplaywright"
