#!/bin/bash
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

help() {
    cat <<EOF
Usage: $SCRIPT_NAME [options]

Options:
  -h, --help        Show this help message
EOF
}

install() {
    echo "Installing prerequisite packages..."
    
    # Enable contrib and non-free repositories for additional packages
    echo "Enabling contrib and non-free repositories..."
    
    # Check if contrib/non-free are already enabled in the new .sources format
    if ! grep -q "contrib" /etc/apt/sources.list.d/*.sources 2>/dev/null && ! grep -q "contrib" /etc/apt/sources.list 2>/dev/null; then
        echo "Adding contrib and non-free to sources..."
        
        # Find the main debian.sources file
        DEBIAN_SOURCES="/etc/apt/sources.list.d/debian.sources"
        
        if [ -f "$DEBIAN_SOURCES" ]; then
            # Backup original debian.sources
            sudo cp "$DEBIAN_SOURCES" "${DEBIAN_SOURCES}.backup"
            
            # Check current Components line and add contrib/non-free if not present
            CURRENT_COMPONENTS=$(grep "^Components:" "$DEBIAN_SOURCES" | head -1)
            echo "Current components: $CURRENT_COMPONENTS"
            
            # Add contrib and non-free to Components line if not already present
            if ! echo "$CURRENT_COMPONENTS" | grep -q "contrib"; then
                sudo sed -i '/^Components:/ s/main/main contrib/' "$DEBIAN_SOURCES"
            fi
            if ! echo "$CURRENT_COMPONENTS" | grep -q "non-free[^-]"; then
                sudo sed -i '/^Components:/ s/$/\ non-free/' "$DEBIAN_SOURCES"
            fi
            
            NEW_COMPONENTS=$(grep "^Components:" "$DEBIAN_SOURCES" | head -1)
            echo "Updated components: $NEW_COMPONENTS"
            echo "Repositories updated in $DEBIAN_SOURCES"
        else
            echo "Warning: Could not find debian.sources file, trying traditional sources.list..."
            # Fallback to old method if .sources file doesn't exist
            if [ -f /etc/apt/sources.list ]; then
                sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup
                sudo sed -i '/deb.*trixie main$/ s/main$/main contrib non-free/' /etc/apt/sources.list
                sudo sed -i '/deb-src.*trixie main$/ s/main$/main contrib non-free/' /etc/apt/sources.list
            fi
        fi
        
        echo "Repositories updated"
    else
        echo "contrib/non-free repositories already enabled"
    fi
    
    sudo apt update
    sudo DEBIAN_FRONTEND=noninteractive apt install -y \
        `# Core system packages` \
        apt-transport-https \
        ca-certificates \
        curl \
        wget \
        lsb-release \
        `# Security and GPG` \
        gnupg \
        dirmngr \
        gpg-agent \
        `# Development tools` \
        build-essential \
        git \
        `# Text editors` \
        vim \
        nano \
        neovim \
        `# Programming languages and runtimes` \
        python3-dev \
        `# Archive and file tools` \
        unzip \
        zip \
        tar \
        gzip \
        rsync \
        `# System utilities` \
        htop \
        `# Terminal and shell` \
        tmux \
        screen \
        zsh \
        bash-completion \
        `# Network tools` \
        openssh-client \
        `# Fonts and rendering` \
        fonts-liberation \
        fonts-liberation2 \
        fonts-dejavu \
        fonts-dejavu-core \
        fonts-dejavu-extra \
        fonts-noto \
        fonts-noto-color-emoji \
        fonts-roboto \
        fonts-droid-fallback \
        fonts-ubuntu \
        fonts-open-sans \
        fonts-crosextra-carlito \
        fonts-crosextra-caladea \
        ttf-mscorefonts-installer \
        fontconfig \
        fonts-powerline
    echo "Prerequisite packages installed"

    echo "Installing Homebrew..."
    if ! command -v brew &> /dev/null; then
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for current session
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        
        # Add Homebrew to shell config files
        echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
        if [ -f ~/.zshrc ]; then
            echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc
        fi
        
        echo "Homebrew installed and added to shell config"
    else
        echo "Homebrew already installed"
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi

    echo "Installing GCC via Homebrew..."
    if ! brew list gcc &> /dev/null; then
        brew install gcc
        echo "GCC installed"
    else
        echo "GCC already installed"
    fi

    echo "Installing pnpm via Homebrew..."
    if ! brew list pnpm &> /dev/null; then
        brew install pnpm
        echo "pnpm installed"
    else
        echo "pnpm already installed"
    fi

    echo "Installing uv via Homebrew..."
    if ! brew list uv &> /dev/null; then
        brew install uv
        echo "uv installed"
    else
        echo "uv already installed"
    fi

    echo "Installing modern fonts via Homebrew..."
    # Install Homebrew font cask repository
    brew tap homebrew/cask-fonts 2>/dev/null || true
    
    # Nerd Font versions of popular programming fonts
    fonts_to_install=(
        "font-jetbrains-mono-nerd-font" 
        "font-source-code-pro-nerd-font"
        "font-cascadia-code-nerd-font"
        "font-hack-nerd-font"
        "font-ubuntu-mono-nerd-font"
    )
    
    for font in "${fonts_to_install[@]}"; do
        if ! brew list --cask "$font" &> /dev/null; then
            echo "Installing $font..."
            brew install --cask "$font" 2>/dev/null || echo "Failed to install $font (may not be available)"
        else
            echo "$font already installed"
        fi
    done

    # Refresh font cache
    echo "Refreshing font cache..."
    fc-cache -fv > /dev/null 2>&1 || true

    echo "All prerequisites installed successfully!"
    echo ""
    echo "Homebrew, pnpm, and uv are now installed and configured."
    echo "Restart your shell or run 'source ~/.bashrc' to use all commands."
}

main() {
    install
}

# --- arg parsing ---
if [[ $# -gt 0 ]]; then
    case "$1" in
    -h | --help)
        help
        exit 0
        ;;
    *)
        echo "Unknown option: $1"
        help
        exit 1
        ;;
    esac
fi

main
