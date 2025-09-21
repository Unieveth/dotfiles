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
    local arch
    arch="$(dpkg --print-architecture)"

    sudo apt install -y wget
    echo "Installing prerequisite packages..."
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
        openssh-client
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
