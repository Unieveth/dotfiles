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
    wget -O "/tmp/steam_latest.deb" "https://repo.steampowered.com/steam/archive/stable/steam_latest.deb"
    sudo apt install -y "/tmp/steam_latest.deb"
    echo "Steam installed"
}

uninstall() {
    echo "Uninstalling Steam..."
    sudo apt remove -y steam-installer
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
