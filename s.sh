#!/bin/bash
# set -e

if [ -t 1 ] && [ -n "$(tput colors)" ] && [ "$(tput colors)" -ge 8 ]; then
    BOLD=$(tput bold)
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    CYAN=$(tput setaf 6)
    BLUE=$(tput setaf 4)
    MAGENTA=$(tput setaf 5)
    NC=$(tput sgr0)
else
    BOLD=""
    RED=""
    GREEN=""
    YELLOW=""
    CYAN=""
    BLUE=""
    MAGENTA=""
    NC=""
fi

# Paths
SWARM_DIR="$HOME/rl-swarm"
CONFIG_FILE="$SWARM_DIR/.swarm_config"
LOG_FILE="$HOME/swarm_log.txt"
SWAP_FILE="/swapfile"
REPO_URL="https://github.com/gensyn-ai/rl-swarm.git"

# Global Variables
KEEP_TEMP_DATA=true

# Logging
log() {
    local level="$1"
    local msg="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $msg" >> "$LOG_FILE"
    case "$level" in
        ERROR) echo -e "${RED}$msg${NC}" ;;
        WARN) echo -e "${YELLOW}$msg${NC}" ;;
        INFO) echo -e "${CYAN}$msg${NC}" ;;
    esac
}

# Initialize
init() {
    clear
    touch "$LOG_FILE"
    log "INFO" "=== HUSTLE AIRDROPS RL-SWARM MANAGER STARTED ==="
}

show_header() {
    clear
    echo -e "${BLUE}${BOLD}"
    echo "┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐"
    echo "│  ██╗░░██╗██╗░░░██╗░██████╗████████╗██╗░░░░░███████╗  ░█████╗░██╗██████╗░██████╗░██████╗░░█████╗░██████╗░░██████╗  │"
    echo "│  ██║░░██║██║░░░██║██╔════╝╚══██╔══╝██║░░░░░██╔════╝  ██╔══██╗██║██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔════╝  │"
    echo "│  ███████║██║░░░██║╚█████╗░░░░██║░░░██║░░░░░█████╗░░  ███████║██║██████╔╝██║░░██║██████╔╝██║░░██║██████╔╝╚█████╗░  │"
    echo "│  ██╔══██║██║░░░██║░╚═══██╗░░░██║░░░██║░░░░░██╔══╝░░  ██╔══██║██║██╔══██╗██║░░██║██╔══██╗██║░░██║██╔═══╝░░╚═══██╗  │"
    echo "│  ██║░░██║╚██████╔╝██████╔╝░░░██║░░░███████╗███████╗  ██║░░██║██║██║░░██║██████╔╝██║░░██║╚█████╔╝██║░░░░░██████╔╝  │"
    echo "│  ╚═╝░░╚═╝░╚═════╝░╚═════╝░░░░╚═╝░░░╚══════╝╚══════╝  ╚═╝░░╚═╝╚═╝╚═╝░░╚═╝╚═════╝░╚═╝░░╚═╝░╚════╝░╚═╝░░░░░╚═════╝░  │"
    echo "└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘"
    echo -e "${YELLOW}           🚀 Gensyn RL-Swarm Launcher by Hustle Airdrops 🚀${NC}"
    echo -e "${YELLOW}              GitHub: https://github.com/HustleAirdrops${NC}"
    echo -e "${YELLOW}              Telegram: https://t.me/Hustle_Airdrops${NC}"
    echo -e "${GREEN}===============================================================================${NC}"
}

install_deps() {
    echo "🔄 Updating package list..."
    sudo apt update -y

    echo "📦 Installing essential packages..."
    sudo apt install -y python3 python3-venv python3-pip curl wget screen git lsof ufw jq perl gnupg

    echo "🟢 Installing Node.js 20..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt install -y nodejs

    echo "🧵 Installing Yarn..."
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/yarn.gpg
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt update -y
    sudo apt install -y yarn

    echo "🛡️ Setting up firewall..."
    sudo ufw allow 22
    sudo ufw allow 3000/tcp
    sudo ufw enable

    echo "🌩️ Installing Cloudflared..."
    wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    sudo dpkg -i cloudflared-linux-amd64.deb || sudo apt install -f
    rm -f cloudflared-linux-amd64.deb

    echo "✅ All dependencies installed successfully!"
}

manage_swap() {
    if [ ! -f "$SWAP_FILE" ]; then
        sudo fallocate -l 1G "$SWAP_FILE" >/dev/null 2>&1
        sudo chmod 600 "$SWAP_FILE" >/dev/null 2>&1
        sudo mkswap "$SWAP_FILE" >/dev/null 2>&1
        sudo swapon "$SWAP_FILE" >/dev/null 2>&1
        echo "$SWAP_FILE none swap sw 0 0" | sudo tee -a /etc/fstab >/dev/null 2>&1
    fi
}

disable_swap() {
    if [ -f "$SWAP_FILE" ]; then
        sudo swapoff "$SWAP_FILE"
        sudo rm -f "$SWAP_FILE"
        sudo sed -i "\|$SWAP_FILE|d" /etc/fstab
    fi
}

run_fixall() {
    echo -e "${CYAN}🔧 Applying comprehensive fixes...${NC}"
    if curl -fsSL https://raw.githubusercontent.com/hustleairdrops/Gensyn-Advanced-Solutions/main/fixall.sh | bash >/dev/null 2>&1; then
        touch "$SWARM_DIR/.fixall_done"
        echo -e "${GREEN}✅ All fixes applied successfully!${NC}"
    else
        echo -e "${RED}❌ Failed to apply fixes!${NC}"
    fi
    sleep 5
}

modify_run_script() {
    local run_script="$SWARM_DIR/run_rl_swarm.sh"

    if [ -f "$run_script" ]; then
        # 1. Preserve shebang line and remove old KEEP_TEMP_DATA definition
        awk '
        NR==1 && $0 ~ /^#!\/bin\/bash/ { print; next }
        $0 !~ /^\s*: "\$\{KEEP_TEMP_DATA:=.*\}"/ { print }
        ' "$run_script" > "$run_script.tmp" && mv "$run_script.tmp" "$run_script"

        # 2. Inject new KEEP_TEMP_DATA just after #!/bin/bash
        sed -i '1a : "${KEEP_TEMP_DATA:='"$KEEP_TEMP_DATA"'}"' "$run_script"

        # 3. Patch rm logic only if not already patched
        if grep -q 'rm -r \$ROOT_DIR/modal-login/temp-data/\*\.json' "$run_script" && \
           ! grep -q 'if \[ "\$KEEP_TEMP_DATA" != "true" \]; then' "$run_script"; then

            perl -i -pe '
                s#rm -r \$ROOT_DIR/modal-login/temp-data/\*\.json 2> /dev/null \|\| true#
if [ "\$KEEP_TEMP_DATA" != "true" ]; then
    rm -r \$ROOT_DIR/modal-login/temp-data/*.json 2> /dev/null || true
fi#' "$run_script"
        fi
    fi
}

fix_kill_command() {
    local run_script="$SWARM_DIR/run_rl_swarm.sh"

    if [ -f "$run_script" ]; then
        if grep -q 'kill -- -\$\$ || true' "$run_script"; then
            perl -i -pe 's#kill -- -\$\$ \|\| true#kill -TERM -- -\$\$ 2>/dev/null || true#' "$run_script"
            log "INFO" "✅ Fixed kill command in $run_script to suppress errors"
        else
            log "INFO" "ℹ️ Kill command already updated or not found"
        fi
    else
        log "ERROR" "❌ run_rl_swarm.sh not found at $run_script"
    fi
}


clone_repo() {

    if [ -f "$SWARM_DIR/swarm.pem" ]; then
        sudo cp "$SWARM_DIR/swarm.pem" "$HOME/swarm.pem"
        chown "$USER":"$USER" "$HOME/swarm.pem"
        chmod 600 "$HOME/swarm.pem"
    fi

    sudo rm -rf "$SWARM_DIR" 2>/dev/null
    git clone "$REPO_URL" "$SWARM_DIR" >/dev/null 2>&1
    cd "$SWARM_DIR"
    git checkout tags/v0.5.5 >/dev/null 2>&1
    git checkout -b my-branch-from-v0.5.5 >/dev/null 2>&1

    if [ -f "$HOME/swarm.pem" ]; then
        cp "$HOME/swarm.pem" "$SWARM_DIR/swarm.pem"
        chown "$USER":"$USER" "$SWARM_DIR/swarm.pem"
        chmod 600 "$SWARM_DIR/swarm.pem"
    fi
}

create_default_config() {
    log "INFO" "Creating default config at $CONFIG_FILE"
    mkdir -p "$SWARM_DIR"
    cat <<EOF > "$CONFIG_FILE"
PUSH=N
EOF
    chmod 600 "$CONFIG_FILE"
    log "INFO" "Default config created"
}

fix_swarm_pem_permissions() {
    local pem_file="$SWARM_DIR/swarm.pem"
    if [ -f "$pem_file" ]; then
        sudo chown "$(whoami)":"$(whoami)" "$pem_file"
        sudo chmod 600 "$pem_file"
        log "INFO" "✅ swarm.pem permissions fixed"
    else
        log "WARN" "⚠️ swarm.pem not found at $pem_file"
    fi
}

auto_enter_inputs() {
    # Simulate 'N' for pushing to Hugging Face
    HF_TOKEN=${HF_TOKEN:-""}
    if [ -n "${HF_TOKEN}" ]; then
        HUGGINGFACE_ACCESS_TOKEN=${HF_TOKEN}
    else
        HUGGINGFACE_ACCESS_TOKEN="None"
        echo -e "${GREEN}>> Would you like to push models you train in the RL swarm to the Hugging Face Hub? [y/N] N${NC}"
        echo -e "${GREEN}>>> No answer was given, so NO models will be pushed to Hugging Face Hub${NC}"
    fi

    # Simulate Enter for MODEL_NAME
    MODEL_NAME=""
    echo -e "${GREEN}>> Enter the name of the model you want to use in huggingface repo/name format, or press [Enter] to use the default model.${NC}"
    echo -e "${GREEN}>> Using default model from config${NC}"
}

install_node() {
    set +m  

    show_header
    echo -e "${CYAN}${BOLD}INSTALLATION${NC}"
    echo -e "${YELLOW}===============================================================================${NC}"
    
    echo -e "\n${CYAN}Auto-login configuration:${NC}"
    echo -e "${YELLOW}Auto-login ENABLED by default (no prompt)...${NC}"
    KEEP_TEMP_DATA=true
    export KEEP_TEMP_DATA

    # Handle swarm.pem from SWARM_DIR
    if [ -f "$SWARM_DIR/swarm.pem" ]; then
        echo -e "\n${YELLOW}⚠️ Existing swarm.pem detected in SWARM_DIR!${NC}"
        echo -e "${GREEN}Using existing swarm.pem...${NC}"
        sudo cp "$SWARM_DIR/swarm.pem" "$HOME/swarm.pem"
        log "INFO" "PEM copied from SWARM_DIR to HOME"
    fi

    echo -e "\n${YELLOW}Starting installation...${NC}"

    spinner() {
        local pid=$1
        local msg="$2"
        local spinstr="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
        while kill -0 "$pid" 2>/dev/null; do
            for (( i=0; i<${#spinstr}; i++ )); do
                printf "\r$msg ${spinstr:$i:1} "
                sleep 0.15
            done
        done
        printf "\r$msg ✅ Done"; tput el; echo
    }

    ( install_deps ) & spinner $! "📦 Installing dependencies"
    ( clone_repo ) & spinner $! "📥 Cloning repo"
    ( modify_run_script ) & spinner $! "🧠 Modifying run script"

    if [ -f "$HOME/swarm.pem" ]; then
        sudo cp "$HOME/swarm.pem" "$SWARM_DIR/swarm.pem"
        sudo chmod 600 "$SWARM_DIR/swarm.pem"
    fi

    echo -e "\n${GREEN}✅ Installation completed!${NC}"
    echo -e "Auto-login: ${GREEN}ENABLED${NC}"
    echo -e "${YELLOW}${BOLD}👉 Press Enter to return to the menu...${NC}"
    read
    sleep 1
}

run_node() {
    show_header
    echo -e "${CYAN}${BOLD}🚀 RUN MODE: Auto-Restart Mode (DEFAULT)${NC}"
    echo -e "${YELLOW}===============================================================================${NC}"

    if [ ! -f "$SWARM_DIR/swarm.pem" ]; then
        if [ -f "$HOME/swarm.pem" ]; then
            sudo cp "$HOME/swarm.pem" "$SWARM_DIR/swarm.pem"
            sudo chmod 600 "$SWARM_DIR/swarm.pem"
        else
            echo -e "${RED}swarm.pem not found in HOME directory. Proceeding without it...${NC}"
        fi
    fi

    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        echo -e "\n${BOLD}${CYAN}⚙️  CURRENT CONFIGURATION${NC}"
        echo -e "${YELLOW}-------------------------------------------------${NC}"
        echo -e "🚀 Push to HF     : ${GREEN}$PUSH${NC}"
        echo -e "${YELLOW}-------------------------------------------------${NC}"
    else
        echo -e "${RED}❗ No config found. Creating default...${NC}"
        create_default_config
        source "$CONFIG_FILE"
    fi
    
    auto_enter_inputs

    : "${KEEP_TEMP_DATA:=true}"
    export KEEP_TEMP_DATA
    modify_run_script
    sudo chmod +x "$SWARM_DIR/run_rl_swarm.sh"
    fix_kill_command

    # Hardcoded Auto-Restart Mode
    log "INFO" "Starting node in auto-restart mode"
    cd "$SWARM_DIR"
    fix_swarm_pem_permissions
    manage_swap
    python3 -m venv .venv
    source .venv/bin/activate
    while true; do
        KEEP_TEMP_DATA="$KEEP_TEMP_DATA" ./run_rl_swarm.sh <<EOF
$PUSH
$MODEL_NAME
EOF
        log "WARN" "Node crashed, restarting in 5 seconds..."
        echo -e "${YELLOW}⚠️ Node crashed. Restarting in 5 seconds...${NC}"
        sleep 5
    done
}

main_menu() {
    show_header
    echo -e "${CYAN}${BOLD}🛠 Auto-installing and running the node...${NC}"
    install_node
    run_node
}

# Initialize and start
init
trap "echo -e '\n${GREEN}✅ Stopped gracefully${NC}'; disable_swap; exit 0" SIGINT
main_menu
