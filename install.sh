```bash
#!/bin/bash

set -e

REPO="https://raw.githubusercontent.com/fahmieabdrahim/quran-login/main"
APP_DIR="$HOME/QuranLogin"
BIN_DIR="$HOME/bin"
SCRIPT="$APP_DIR/quran-login.sh"
COMMAND="$BIN_DIR/quran-login"
SHELL_CONFIG="$HOME/.zshrc"

echo
echo "======================================"
echo "       Quran Login Installer"
echo "======================================"
echo

echo "[1/4] Creating directories..."

mkdir -p "$APP_DIR"
mkdir -p "$BIN_DIR"

echo "[2/4] Downloading Quran Login..."

curl -fL --retry 3 --connect-timeout 10 \
    "$REPO/quran-login.sh" \
    -o "$SCRIPT"

chmod +x "$SCRIPT"

echo "[3/4] Creating command..."

ln -sfn "$SCRIPT" "$COMMAND"

echo "[4/4] Configuring PATH..."

touch "$SHELL_CONFIG"

if ! grep -Fqx 'export PATH="$HOME/bin:$PATH"' "$SHELL_CONFIG"; then
    printf '\nexport PATH="$HOME/bin:$PATH"\n' >> "$SHELL_CONFIG"
fi

export PATH="$HOME/bin:$PATH"

echo
echo "======================================"
echo "       Installation Complete!"
echo "======================================"
echo
echo "Installed to:"
echo "  $APP_DIR"
echo
echo "Command:"
echo "  quran-login"
echo
echo "Starting Quran Login..."
echo

exec "$COMMAND"
```
