# Generate QR code from text/URL
qr() {
    if [ -z "$1" ]; then
        echo "Usage: qr 'text or URL'"
        return
    fi
    echo "$1" | curl -s -d @- https://qrcode.show -H "Accept: image/ascii"
}



# ========================================================
# PRODUCTIVITY ENHANCERS
# ========================================================

# Pomodoro timer
timer() {
    local work_min=${1:-25}
    local break_min=${2:-5}
    
    echo "✅ Starting Timer: ${work_min}min work, ${break_min}min break"
    
    while true; do
        # Work session
        echo "✅ Work session started! Focus for ${work_min} minutes..."
        for ((i=work_min*60; i>0; i--)); do
            printf "\rWork time remaining: %02d:%02d" $((i/60)) $((i%60))
            sleep 1
        done
        echo -e "\n✅ Work session finished! Time for a break."
        notify-send "Pomodoro" "Work session finished! Take a break." 2>/dev/null || echo -e "\a"
        
        # Break session
        echo "☕ Break time! Rest for ${break_min} minutes..."
        for ((i=break_min*60; i>0; i--)); do
            printf "\rBreak time remaining: %02d:%02d" $((i/60)) $((i%60))
            sleep 1
        done
        echo -e "\n✅ Break finished! Back to work."
        notify-send "Pomodoro" "Break finished! Back to work." 2>/dev/null || echo -e "\a"
        
        read -t 5 -p "Continue? (y/n): " choice
        if [[ "$choice" == "n" ]]; then
            break
        fi
    done
}

# Added cphtdocs (copy instead of move)
cphtdocs() {
    # Help
    if [ "$1" == "--help" ] || [ "$#" -ne 1 ]; then
        echo "Usage: cphtdocs <repo_name>"
        echo "Example: cphtdocs myproject"
        return 1
    fi

    REPO_NAME="$1"
    SOURCE_PATH="$PWD/$REPO_NAME"
    DEST_PATH="/opt/lampp/htdocs/$REPO_NAME"

    # Check if source exists
    if [ ! -d "$SOURCE_PATH" ]; then
        echo "❌ Error: '$REPO_NAME' not found in current directory."
        return 1
    fi

    # Remove existing repo in htdocs
    if [ -d "$DEST_PATH" ]; then
        echo "⚠️ Existing '$REPO_NAME' found in htdocs. Removing..."
        sudo rm -rf "$DEST_PATH"
    fi

    # Copy repo
    echo "✅ Copying '$REPO_NAME' to /opt/lampp/htdocs..."
    sudo cp -r "$SOURCE_PATH" /opt/lampp/htdocs/

    # Set permissions
    echo "✅ Setting permissions..."
    sudo chmod -R 777 "$DEST_PATH"

    echo "✅ Done! '$REPO_NAME' is now copied to htdocs!"
}


alias reload="source ~/.bashrc && echo '✅ Bash reloaded successfully!'"
alias python="python3"


# Auto activate/deactivate Python venv named "env" (checks parent folders too)

_find_env_dir() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/env/bin/activate" ]]; then
            echo "$dir/env"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    return 1
}

auto_venv_parent() {
    local env_path
    env_path="$(_find_env_dir)"

    # If found env and not active -> activate
    if [[ -n "$env_path" && -z "$VIRTUAL_ENV" ]]; then
        source "$env_path/bin/activate"
        echo "🐍 venv ON → $env_path"
        return
    fi

    # If found env but different from active -> switch
    if [[ -n "$env_path" && -n "$VIRTUAL_ENV" && "$VIRTUAL_ENV" != "$env_path" ]]; then
        deactivate
        source "$env_path/bin/activate"
        echo "🔁 venv SWITCH → $env_path"
        return
    fi

    # If no env found but venv active -> deactivate
    if [[ -z "$env_path" && -n "$VIRTUAL_ENV" ]]; then
        deactivate
        echo "❌ venv OFF"
        return
    fi
}

# Run on every prompt (so it triggers after cd)
PROMPT_COMMAND="auto_venv_parent; $PROMPT_COMMAND"

#create virtual venv 
mkvenv() {
    if [[ -d "env" ]]; then
        echo -n "⚠️ env already exists. Delete and recreate? (y/N): "
        read -r choice

        case "$choice" in
            y|Y|yes|YES)
                echo "🗑️ Removing existing env..."
                rm -rf env
                ;;
            *)
                echo "❌ Aborted. Keeping existing env."
                return 0
                ;;
        esac
    fi

    echo "🐍 Creating python venv (env)..."
    python3 -m venv env

    if [[ -f "env/bin/activate" ]]; then
        source env/bin/activate
        echo "✅ venv created & activated"
    else
        echo "❌ Failed to create venv"
    fi
}

# Remove python venv named "env" (checks parent folders)

rmvenv() {
    local dir="$PWD"
    local env_path=""

    # Find env in current or parent directories
    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/env" && -f "$dir/env/bin/activate" ]]; then
            env_path="$dir/env"
            break
        fi
        dir="$(dirname "$dir")"
    done

    if [[ -z "$env_path" ]]; then
        echo "❌ No env found in current or parent directories"
        return 1
    fi

    echo "🐍 Found venv at: $env_path"
    echo -n "⚠️ Do you want to delete this env? (y/N): "
    read -r choice

    case "$choice" in
        y|Y|yes|YES)
            # Deactivate if active
            if [[ -n "$VIRTUAL_ENV" && "$VIRTUAL_ENV" == "$env_path" ]]; then
                deactivate
                echo "🔌 venv deactivated"
            fi

            rm -rf "$env_path"
            echo "🗑️ env deleted successfully"
            ;;
        *)
            echo "❌ Aborted. env not deleted"
            ;;
    esac
}

# XAMPP aliases
alias xampp='sudo /opt/lampp/manager-linux-x64.run'

# Open VS Code as root
vsroot() {
    if [[ -z "$1" ]]; then
        sudo code --user-data-dir="/root/.vscode-root" "$PWD"
    else
        sudo code --user-data-dir="/root/.vscode-root" "$1"
    fi
}


doctor() {
    echo "Doctor Scan Started"
    echo "----------------------------------"

    # Python
    if command -v python3 >/dev/null 2>&1; then
        python3 --version 2>/dev/null && echo "✅ Python installed"
    else
        echo "❌ Python not installed"
    fi

    # Virtualenv
    if [[ -n "$VIRTUAL_ENV" ]]; then
        echo "✅ venv ACTIVE: $VIRTUAL_ENV"
    else
        echo "⚠️ venv not active"
    fi

    # Git
    if command -v git >/dev/null 2>&1; then
        echo "✅ Git installed"
    else
        echo "❌ Git not installed"
    fi

    # Docker
    if command -v docker >/dev/null 2>&1; then
        if docker info >/dev/null 2>&1; then
            echo "✅ Docker running"
        else
            echo "⚠️ Docker installed but not running"
        fi
    else
        echo "⚠️ Docker not installed"
    fi

    # XAMPP
    if [[ -f "/opt/lampp/ctlscript.sh" ]]; then
        if sudo /opt/lampp/ctlscript.sh status 2>/dev/null | grep -qi running; then
            echo "✅ XAMPP running"
        else
            echo "⚠️ XAMPP installed but stopped"
        fi
    else
        echo "⚠️ XAMPP not found"
    fi

    # Ports
    echo "----------------------------------"
    echo "Port check:"
    for port in 80 443 8000 5173 3306 8080; do
        if ss -ltn 2>/dev/null | grep -q ":$port "; then
            echo "❌ Port $port in use"
        else
            echo "✅ Port $port free"
        fi
    done

    # Disk space
    echo "----------------------------------"
    df -h / | awk 'NR==2 {print "Disk usage: "$5" used ("$4" free)"}'

    echo "----------------------------------"
    echo "Doctor Scan Completed"
}

# Quick go aliases
alias cdp='cd ~/Projects'
alias cdg='cd ~/GithubManagement'


fhere() {
if [ -z "$1" ]; then
echo "❌ Usage: fhere <name>"
return 1
fi
find . -iname "*$1*" 2>/dev/null
}


editbash() {
sudo geany ~/.bashrc
echo "⚠️ Reloading bashrc..."
source ~/.bashrc
echo "✅ bashrc reloaded"
}


whouses() {
if [ -z "$1" ]; then
echo "❌ Usage: whouses <port>"
return 1
fi
sudo ss -ltnp | grep ":$1 "
}


killallport() {
ports=(3000 5173 8000 8080 5000)
for p in "${ports[@]}"; do
if sudo fuser -k "$p"/tcp 2>/dev/null; then
echo "✅ Killed port $p"
fi
done
}


whereami() {
echo "Path: $PWD"


if [ -d .git ]; then
branch=$(git branch --show-current 2>/dev/null)
echo "✅ Git branch: $branch"
else
echo "⚠️ Not a git repository"
fi


if [ -n "$VIRTUAL_ENV" ]; then
echo "✅ venv active"
else
echo "⚠️ venv not active"
fi


if [ -f docker-compose.yml ] || [ -f Dockerfile ]; then
echo "✅ Docker detected"
else
echo "⚠️ Docker not detected"
fi
}


netcheck() {
if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
echo "✅ Internet reachable"
else
echo "❌ No internet"
fi


if ping -c 1 google.com >/dev/null 2>&1; then
echo "✅ DNS working"
else
echo "❌ DNS problem"
fi
}
