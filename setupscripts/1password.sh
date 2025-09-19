#!/bin/bash
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

help() {
  cat <<EOF
Usage: $SCRIPT_NAME [options]

Options:
  -u, --uninstall   Remove 1Password, repo, keyrings, and debsig policy
  -h, --help        Show this help message
EOF
}

install_1password() {
  local arch; arch="$(dpkg --print-architecture)"

  echo "Adding 1Password repository..."
  curl -fsSL https://downloads.1password.com/linux/keys/1password.asc \
    | sudo gpg --dearmor -o /usr/share/keyrings/1password-archive-keyring.gpg

  printf "deb [arch=%s signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/%s stable main\n" "$arch" "$arch" \
    | sudo tee /etc/apt/sources.list.d/1password.list >/dev/null

  echo "Verifying repository"
  sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
  curl -fsSL https://downloads.1password.com/linux/debian/debsig/1password.pol \
    | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol >/dev/null

  sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
  curl -fsSL https://downloads.1password.com/linux/keys/1password.asc \
    | sudo gpg --dearmor -o /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg

  echo "Installing 1Password"
  sudo apt update
  sudo DEBIAN_FRONTEND=noninteractive apt install -y 1password 1password-cli

  echo "1Password installed"
}

uninstall() {
  echo "Removing packages…"
  sudo apt purge -y 1password 1password-cli || true
  sudo apt autoremove -y || true
  sudo apt clean || true

  echo "Cleaning APT source and keyring…"
  sudo rm -f /etc/apt/sources.list.d/1password.list
  sudo rm -f /usr/share/keyrings/1password-archive-keyring.gpg

  echo "Removing debsig policy and key…"
  sudo rm -rf /etc/debsig/policies/AC2D62742012EA22
  sudo rm -rf /usr/share/debsig/keyrings/AC2D62742012EA22

  echo "Updating APT…"
  sudo apt update || true

  echo "Removing 1Password configuration…"
  rm -rf ~/.config/1Password
  rm -rf ~/1Password

  echo "1Password uninstalled"
}

main() {
  install_1password
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
