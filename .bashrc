# ========================================================
# XAMPP & DEVELOPMENT SHORTCUTS
# ========================================================

# Start XAMPP Graphical Manager
alias xampp='sudo /opt/lampp/manager-linux-x64.run'

# Navigate to htdocs directory
alias htdocs='cd /opt/lampp/htdocs'

# Open VS Code as root for a specific project inside htdocs
# Usage: vshtdocs foldername
vshtdocs() { 
    sudo code "/opt/lampp/htdocs/$1" --user-data-dir=~/.vscode-root --no-sandbox; 
}

# Open VS Code as root in the current working directory
alias vsroot='sudo code . --user-data-dir=~/.vscode-root --no-sandbox'

# ========================================================

#shortcuts

alias python='python3'

# auto venv activation and deactivation
# Auto-activate virtual environment when entering directory
function cd() {
    builtin cd "$@"
    
    # Check for virtual environment in current directory
    if [[ -f "env/bin/activate" ]]; then
#        echo "Found virtual environment in $(pwd)"
        source env/bin/activate
    # Check for venv/bin/activate (common alternative name)
    elif [[ -f "venv/bin/activate" ]]; then
#        echo "Found virtual environment in $(pwd)"
        source venv/bin/activate
    # Deactivate if no virtual environment found and we're in one
    elif [[ -n "$VIRTUAL_ENV" ]] && [[ ! -f "${VIRTUAL_ENV}/bin/activate" ]]; then
#        echo "Leaving virtual environment: $(basename $VIRTUAL_ENV)"
        deactivate
    fi
}

# Check current directory on new shell
if [[ -f "env/bin/activate" ]]; then
#   echo "Found virtual environment in $(pwd)"
    source env/bin/activate
elif [[ -f "venv/bin/activate" ]]; then
#    echo "Found virtual environment in $(pwd)"
    source venv/bin/activate
fi
