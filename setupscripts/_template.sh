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
    # Install Code
}

uninstall() {
    # Uninstall Code
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
