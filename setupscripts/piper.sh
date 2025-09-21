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
    sudo apt update
    sudo apt install -y piper
    echo "Piper installed"
}

main() {
  install
}

# --- arg parsing ---
if [[ $# -gt 0 ]]; then
  case "$1" in
    -h|--help)      help; exit 0 ;;
    *) echo "Unknown option: $1"; help; exit 1 ;;
  esac
fi

main
