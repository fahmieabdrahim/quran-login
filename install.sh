#!/bin/bash

set -e

REPO="https://raw.githubusercontent.com/fahmieabdrahim/quran-login/main"
APP_DIR="$HOME/QuranLogin"
BIN_DIR="$HOME/bin"

echo "======================================"
echo "       Quran Login Installer"
echo "======================================"
echo

mkdir -p "$APP_DIR"
mkdir -p "$BIN_DIR"

echo "[1/3] Download quran-login.sh..."

curl -fL "$REPO/quran-login.sh" \
    -o "$APP_DIR/quran-login.sh"

chmod +x "$APP_DIR/quran-login.sh"

echo "[2/3] Creating command..."

ln -sf "$APP_DIR/quran-login.sh" "$BIN_DIR/quran-login"

echo "[3/3] Updating PATH..."

SHELL_CONFIG="$HOME/.zshrc"

if ! grep -q 'export PATH="$HOME/bin:$PATH"' "$SHELL_CONFIG" 2>/dev/null; then
    echo 'export PATH="$HOME/bin:$PATH"' >> "$SHELL_CONFIG"
fi

export PATH="$HOME/bin:$PATH"

echo
echo "======================================"
echo " Installation complete!"
echo "======================================"
echo
echo "Run:"
echo
echo "    quran-login"
echo

"$BIN_DIR/quran-login"
