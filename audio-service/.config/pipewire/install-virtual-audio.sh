#!/bin/bash
set -euo pipefail

SERVICE_NAME="virtual-audio"
SERVICE_FILE="$HOME/.config/systemd/user/${SERVICE_NAME}.service"
SOURCE_FILE="$(dirname "$0")/${SERVICE_NAME}.service"

usage() {
  echo "Usage: $0 [-u]"
  echo "  No arguments: install service"
  echo "  -u          : uninstall service"
  exit 1
}

if [[ "${1:-}" == "-u" ]]; then
  echo "Uninstalling $SERVICE_NAME..."
  systemctl --user stop "$SERVICE_NAME" || true
  systemctl --user disable "$SERVICE_NAME" || true
  rm -f "$SERVICE_FILE"
  systemctl --user daemon-reload
  echo "Uninstalled $SERVICE_NAME."
  exit 0
elif [[ $# -gt 0 ]]; then
  usage
fi

echo "Installing $SERVICE_NAME..."
mkdir -p "$(dirname "$SERVICE_FILE")"
cp "$SOURCE_FILE" "$SERVICE_FILE"

systemctl --user daemon-reload
systemctl --user enable --now "$SERVICE_NAME"

echo "$SERVICE_NAME installed and started."
