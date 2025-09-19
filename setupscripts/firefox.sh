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

    echo "Installing Dependencies..."
    sudo apt update
    sudo apt install -y wget

    echo "Importing Mozilla APT repository key..."
    sudo install -d -m 0755 /etc/apt/keyrings
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc >/dev/null

    echo "Checking Fingerprint..."
    tmpdir=$(mktemp -d)
    FP=$(gpg --homedir "$tmpdir" --show-keys --with-fingerprint --with-colons \
        /etc/apt/keyrings/packages.mozilla.org.asc |
        awk -F: '/^fpr:/ {print $10; exit}')
    rm -rf "$tmpdir"

    test "$FP" = "35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3" &&
        echo "Fingerprint matches" || echo "Mismatch: $FP"

    echo "Adding Mozilla APT repository..."
    sudo tee /etc/apt/sources.list.d/mozilla.sources >/dev/null <<'EOF'
Types: deb
URIs: https://packages.mozilla.org/apt
Suites: mozilla
Components: main
Signed-By: /etc/apt/keyrings/packages.mozilla.org.asc
EOF

    echo "Updating APT to prioritize Mozilla packages..."
    echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla

    echo "Installing Firefox"
    sudo apt update
    sudo DEBIAN_FRONTEND=noninteractive apt install -y firefox

    echo "Firefox installed"
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
