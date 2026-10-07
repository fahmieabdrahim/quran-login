#!/bin/bash
# Quran Login - macOS
# Mishary Rashid Alafasy / EveryAyah
# User-level installer and menu utility.

set -u

APP_NAME="Quran Login"
APP_DIR="$HOME/QuranLogin"
AUDIO_DIR="$APP_DIR/audio"
SCRIPT_DIR="$APP_DIR/scripts"
PLIST_DIR="$HOME/Library/LaunchAgents"
PLAYER_SCRIPT="$SCRIPT_DIR/play.sh"
PLIST_FILE="$PLIST_DIR/com.quran.login.plist"
AUDIO_BASE="https://everyayah.com/data/Alafasy_128kbps"

AUDIO_FILES=(
  "001001.mp3" "001002.mp3" "001003.mp3" "001004.mp3"
  "001005.mp3" "001006.mp3" "001007.mp3"
)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

pause_screen() {
  echo
  read -r -p "Press Enter to continue..."
}

header() {
  clear
  echo
  echo "╔══════════════════════════════════════════════╗"
  echo "║           QURAN LOGIN - macOS               ║"
  echo "╠══════════════════════════════════════════════╣"
  echo "║  Mishary Rashid Alafasy                     ║"
  echo "║  Surah Al-Fatihah                           ║"
  echo "╚══════════════════════════════════════════════╝"
  echo
}

is_installed() {
  [[ -f "$PLAYER_SCRIPT" && -d "$AUDIO_DIR" ]]
}

is_enabled() {
  launchctl print "gui/$(id -u)/com.quran.login" >/dev/null 2>&1
}

create_directories() {
  mkdir -p "$AUDIO_DIR" "$SCRIPT_DIR" "$PLIST_DIR"
}

download_audio() {
  echo
  echo -e "${CYAN}Downloading Mishary Alafasy - Al-Fatihah...${NC}"
  echo

  create_directories
  local failed=0

  for file in "${AUDIO_FILES[@]}"; do
    if [[ -f "$AUDIO_DIR/$file" ]]; then
      echo -e "${GREEN}✓ Already exists:${NC} $file"
      continue
    fi

    echo "Downloading $file ..."
    if curl -fL --progress-bar "$AUDIO_BASE/$file" -o "$AUDIO_DIR/$file"; then
      echo -e "${GREEN}✓ Downloaded:${NC} $file"
    else
      echo -e "${RED}✗ Failed:${NC} $file"
      rm -f "$AUDIO_DIR/$file"
      failed=1
    fi
  done

  echo
  if [[ "$failed" -eq 0 ]]; then
    echo -e "${GREEN}✓ Semua audio Al-Fatihah berjaya dimuat turun.${NC}"
    return 0
  fi

  echo -e "${RED}Ada audio yang gagal dimuat turun.${NC}"
  return 1
}

create_player() {
  create_directories

  cat > "$PLAYER_SCRIPT" <<EOF
#!/bin/bash

AUDIO_DIR="$AUDIO_DIR"
LOCK_DIR="/tmp/quran-login.lock"

if ! mkdir "\$LOCK_DIR" 2>/dev/null; then
  exit 0
fi

cleanup() {
  rmdir "\$LOCK_DIR" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

sleep 5

for file in \
  001001.mp3 \
  001002.mp3 \
  001003.mp3 \
  001004.mp3 \
  001005.mp3 \
  001006.mp3 \
  001007.mp3
do
  if [[ -f "\$AUDIO_DIR/\$file" ]]; then
    /usr/bin/afplay "\$AUDIO_DIR/\$file"
  fi
done
EOF

  chmod +x "$PLAYER_SCRIPT"
  echo -e "${GREEN}✓ Player script created.${NC}"
}

create_launchagent() {
  create_directories

  cat > "$PLIST_FILE" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.quran.login</string>

  <key>ProgramArguments</key>
  <array>
    <string>$PLAYER_SCRIPT</string>
  </array>

  <key>RunAtLoad</key>
  <true/>

  <key>ProcessType</key>
  <string>Background</string>

  <key>StandardOutPath</key>
  <string>/tmp/quran-login.log</string>

  <key>StandardErrorPath</key>
  <string>/tmp/quran-login-error.log</string>
</dict>
</plist>
EOF

  echo -e "${GREEN}✓ LaunchAgent created.${NC}"
}

enable_auto_login() {
  if ! is_installed; then
    echo -e "${YELLOW}Quran Login belum dipasang.${NC}"
    echo "Pilih Install / Update dahulu."
    return 1
  fi

  create_launchagent

  launchctl bootout "gui/$(id -u)/com.quran.login" 2>/dev/null || true

  if launchctl bootstrap "gui/$(id -u)" "$PLIST_FILE"; then
    echo
    echo -e "${GREEN}✓ Auto Login ENABLED.${NC}"
    echo "Al-Fatihah akan dimainkan setiap kali user login."
  else
    echo -e "${RED}✗ Gagal enable LaunchAgent.${NC}"
    return 1
  fi
}

disable_auto_login() {
  launchctl bootout "gui/$(id -u)/com.quran.login" 2>/dev/null || true
  rm -f "$PLIST_FILE"
  echo
  echo -e "${GREEN}✓ Auto Login DISABLED.${NC}"
}

play_now() {
  if ! is_installed; then
    echo -e "${YELLOW}Audio belum dipasang.${NC}"
    echo "Pilih Install / Update dahulu."
    return 1
  fi

  echo
  echo -e "${CYAN}▶ Memainkan Surah Al-Fatihah...${NC}"
  echo -e "${CYAN}Qari: Mishary Rashid Alafasy${NC}"
  echo

  "$PLAYER_SCRIPT"
}

install_app() {
  header
  echo -e "${CYAN}INSTALL / UPDATE${NC}"
  echo
  echo "User: $USER"
  echo "Lokasi: $APP_DIR"
  echo

  read -r -p "Teruskan? [Y/n]: " answer
  [[ "$answer" =~ ^[Nn]$ ]] && return

  echo
  echo "1/4 Creating folders..."
  create_directories

  echo "2/4 Downloading audio..."
  if ! download_audio; then
    echo -e "${RED}Installation dihentikan kerana audio gagal dimuat turun.${NC}"
    return 1
  fi

  echo
  echo "3/4 Creating player..."
  create_player

  echo
  echo "4/4 Enabling auto login..."
  enable_auto_login

  echo
  echo "══════════════════════════════════════════════"
  echo -e "${GREEN}✓ INSTALLATION COMPLETE${NC}"
  echo "══════════════════════════════════════════════"
  echo
}

uninstall_app() {
  header
  echo -e "${RED}UNINSTALL QURAN LOGIN${NC}"
  echo
  echo "Ini akan membuang:"
  echo "  $APP_DIR"
  echo "  $PLIST_FILE"
  echo

  read -r -p "Betul-betul uninstall? [y/N]: " answer
  [[ ! "$answer" =~ ^[Yy]$ ]] && { echo "Uninstall dibatalkan."; return; }

  launchctl bootout "gui/$(id -u)/com.quran.login" 2>/dev/null || true
  rm -f "$PLIST_FILE"
  rm -rf "$APP_DIR"
  rm -f /tmp/quran-login.log /tmp/quran-login-error.log

  echo
  echo -e "${GREEN}✓ Quran Login telah di-uninstall.${NC}"
}

show_status() {
  echo
  echo "STATUS"
  echo "────────────────────────────────────────────"
  if is_installed; then
    echo -e "Installation : ${GREEN}INSTALLED${NC}"
  else
    echo -e "Installation : ${RED}NOT INSTALLED${NC}"
  fi

  if is_enabled; then
    echo -e "Auto Login   : ${GREEN}ENABLED${NC}"
  else
    echo -e "Auto Login   : ${YELLOW}DISABLED${NC}"
  fi

  echo "Qari         : Mishary Rashid Alafasy"
  echo "Surah        : Al-Fatihah"
  echo "Location     : $APP_DIR"
  echo
}

while true; do
  header
  show_status

  echo "1. Install / Update"
  echo "2. ▶  Play Al-Fatihah"
  echo "3. Enable Auto Login"
  echo "4. Disable Auto Login"
  echo "5. Uninstall"
  echo "6. Exit"
  echo

  read -r -p "Pilih [1-6]: " choice

  case "$choice" in
    1) install_app; pause_screen ;;
    2) play_now; pause_screen ;;
    3) enable_auto_login; pause_screen ;;
    4) disable_auto_login; pause_screen ;;
    5) uninstall_app; pause_screen ;;
    6) clear; echo; echo "Quran Login ditutup."; echo; exit 0 ;;
    *) echo; echo -e "${YELLOW}Pilihan tidak sah.${NC}"; sleep 1 ;;
  esac
done
