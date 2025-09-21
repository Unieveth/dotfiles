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
    echo "Installing VS Code..."
    echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections
    wget -O "/tmp/vscode.deb" "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
    sudo apt install -y "/tmp/vscode.deb"
    echo "VS Code installed"
}

uninstall() {
    echo "Uninstalling VS Code..."
    sudo apt remove -y code
    echo "VS Code uninstalled"
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
