#!/bin/bash
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

help() {
  cat <<EOF
Usage: $SCRIPT_NAME [options]

Options:
  -u, --uninstall   Remove 
  -h, --help        Show this help message
EOF
}

install() {
    echo "Installing Steam..."
    
    # Download and install Steam GPG key
    echo "Setting up Steam repository..."
    wget -O "/tmp/steam.gpg" "https://repo.steampowered.com/steam/archive/stable/steam.gpg"
    sudo cp "/tmp/steam.gpg" "/usr/share/keyrings/steam.gpg"
    
    # Add Steam repository
    sudo tee /etc/apt/sources.list.d/steam-stable.list <<'EOF'
deb [arch=amd64,i386 signed-by=/usr/share/keyrings/steam.gpg] https://repo.steampowered.com/steam/ stable steam
deb-src [arch=amd64,i386 signed-by=/usr/share/keyrings/steam.gpg] https://repo.steampowered.com/steam/ stable steam
EOF
    
    # Add i386 architecture and update package lists
    sudo dpkg --add-architecture i386
    sudo apt-get update
    
    # Install Steam and required dependencies
    sudo apt-get install -y \
        libgl1-mesa-dri:amd64 \
        libgl1-mesa-dri:i386 \
        libgl1-mesa-glx:amd64 \
        libgl1-mesa-glx:i386 \
        steam-launcher
    
    echo "Steam installed"
}

uninstall() {
    echo "Uninstalling Steam..."
    sudo apt remove -y steam-launcher
    
    # Optionally remove repository and GPG key
    echo "Removing Steam repository..."
    sudo rm -f /etc/apt/sources.list.d/steam-stable.list
    sudo rm -f /usr/share/keyrings/steam.gpg
    
    # Remove i386 architecture if no other packages need it
    echo "Note: i386 architecture was added during installation."
    echo "You may want to remove it with: sudo dpkg --remove-architecture i386"
    echo "Only do this if no other packages require i386 architecture."
    
    echo "Steam uninstalled"
}

main() {
  install
}

# --- arg parsing ---
if [[ $# -gt 0 ]]; then
  case "$1" in
    -u|--uninstall) uninstall; exit 0 ;;
    -h|--help)      help; exit 0 ;;
    *) echo "Unknown option: $1"; help; exit 1 ;;
  esac
fi

main
