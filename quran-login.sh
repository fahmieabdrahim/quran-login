#!/bin/bash

# ============================================================
# Quran Login - macOS
# Mishary Rashid Alafasy / EveryAyah
# User-level Quran Al-Fatihah player
# ============================================================

set -u


# ============================================================
# CONFIGURATION
# ============================================================

APP_NAME="Quran Login"

APP_DIR="$HOME/QuranLogin"

AUDIO_DIR="$APP_DIR/audio"
SCRIPT_DIR="$APP_DIR/scripts"

PLIST_DIR="$HOME/Library/LaunchAgents"

PLAYER_SCRIPT="$SCRIPT_DIR/play.sh"
PLIST_FILE="$PLIST_DIR/com.quran.login.plist"

AUDIO_BASE="https://everyayah.com/data/Alafasy_128kbps"

AUDIO_FILES=(
  "001001.mp3"
  "001002.mp3"
  "001003.mp3"
  "001004.mp3"
  "001005.mp3"
  "001006.mp3"
  "001007.mp3"
)


# ============================================================
# COLORS
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'


# ============================================================
# INPUT
# ============================================================

read_input() {
    local value=""

    if [[ -r /dev/tty ]]; then
        IFS= read -r value < /dev/tty
    else
        IFS= read -r value
    fi

    printf '%s' "$value"
}


pause_screen() {
    echo
    printf "Press Enter to continue..."
    read_input >/dev/null
}


# ============================================================
# HEADER
# ============================================================

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


# ============================================================
# STATUS
# ============================================================

is_installed() {

    [[ -f "$PLAYER_SCRIPT" && -d "$AUDIO_DIR" ]]
}


is_enabled() {

    launchctl print \
        "gui/$(id -u)/com.quran.login" \
        >/dev/null 2>&1
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


# ============================================================
# DIRECTORIES
# ============================================================

create_directories() {

    mkdir -p "$APP_DIR"
    mkdir -p "$AUDIO_DIR"
    mkdir -p "$SCRIPT_DIR"
    mkdir -p "$PLIST_DIR"
}


# ============================================================
# DOWNLOAD AUDIO
# ============================================================

download_audio() {

    echo
    echo -e "${CYAN}Downloading Mishary Alafasy - Al-Fatihah...${NC}"
    echo

    create_directories

    local failed=0

    for file in "${AUDIO_FILES[@]}"; do

        if [[ -s "$AUDIO_DIR/$file" ]]; then
            echo -e "${GREEN}✓ Already exists:${NC} $file"
            continue
        fi

        echo "Downloading $file ..."

        if curl \
            -fL \
            --retry 3 \
            --connect-timeout 15 \
            --progress-bar \
            "$AUDIO_BASE/$file" \
            -o "$AUDIO_DIR/$file"
        then

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

    echo -e "${RED}✗ Ada audio yang gagal dimuat turun.${NC}"

    return 1
}


# ============================================================
# CREATE PLAYER
# ============================================================

create_player() {

    create_directories

    cat > "$PLAYER_SCRIPT" <<EOF
#!/bin/bash

AUDIO_DIR="$AUDIO_DIR"

LOCK_DIR="/tmp/quran-login.lock"
LOCK_PID_FILE="/tmp/quran-login.pid"


# ============================================================
# PREVENT DUPLICATE PLAYBACK
# ============================================================

if [[ -f "\$LOCK_PID_FILE" ]]; then

    OLD_PID="\$(cat "\$LOCK_PID_FILE" 2>/dev/null || true)"

    if [[ -n "\$OLD_PID" ]] && kill -0 "\$OLD_PID" 2>/dev/null; then
        exit 0
    fi

    rm -f "\$LOCK_PID_FILE"

    rmdir "\$LOCK_DIR" 2>/dev/null || true

fi


if ! mkdir "\$LOCK_DIR" 2>/dev/null; then
    exit 0
fi


echo "\$\$" > "\$LOCK_PID_FILE"


# ============================================================
# CLEANUP
# ============================================================

cleanup() {

    rm -f "\$LOCK_PID_FILE"

    rmdir "\$LOCK_DIR" 2>/dev/null || true
}

trap cleanup EXIT INT TERM


# ============================================================
# DELAY AFTER LOGIN
# ============================================================

sleep 5


# ============================================================
# AUDIO FILES
# ============================================================

AUDIO_FILES=(
    "001001.mp3"
    "001002.mp3"
    "001003.mp3"
    "001004.mp3"
    "001005.mp3"
    "001006.mp3"
    "001007.mp3"
)


# ============================================================
# PLAY AL-FATIHAH
# ============================================================

for file in "\${AUDIO_FILES[@]}"; do

    if [[ -f "\$AUDIO_DIR/\$file" ]]; then

        /usr/bin/afplay "\$AUDIO_DIR/\$file"

    fi

done

EOF

    chmod +x "$PLAYER_SCRIPT"

    echo -e "${GREEN}✓ Player script created.${NC}"
}


# ============================================================
# CREATE LAUNCHAGENT
# ============================================================

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


# ============================================================
# ENABLE AUTO LOGIN
# ============================================================

enable_auto_login() {

    if ! is_installed; then

        echo
        echo -e "${YELLOW}Quran Login belum dipasang.${NC}"
        echo "Pilih Install / Update dahulu."

        return 1
    fi


    create_launchagent


    launchctl bootout \
        "gui/$(id -u)/com.quran.login" \
        2>/dev/null || true


    if launchctl bootstrap \
        "gui/$(id -u)" \
        "$PLIST_FILE"
    then

        echo
        echo -e "${GREEN}✓ Auto Login ENABLED.${NC}"

        echo
        echo "Al-Fatihah akan dimainkan setiap kali user login."

        return 0

    else

        echo
        echo -e "${RED}✗ Gagal enable LaunchAgent.${NC}"

        return 1

    fi
}


# ============================================================
# DISABLE AUTO LOGIN
# ============================================================

disable_auto_login() {

    launchctl bootout \
        "gui/$(id -u)/com.quran.login" \
        2>/dev/null || true

    rm -f "$PLIST_FILE"

    echo
    echo -e "${GREEN}✓ Auto Login DISABLED.${NC}"
}


# ============================================================
# PLAY NOW
# ============================================================

play_now() {

    if ! is_installed; then

        echo
        echo -e "${YELLOW}Quran Login belum dipasang.${NC}"

        echo "Pilih Install / Update dahulu."

        return 1
    fi


    echo
    echo -e "${CYAN}▶ Memainkan Surah Al-Fatihah...${NC}"
    echo -e "${CYAN}Qari: Mishary Rashid Alafasy${NC}"

    echo

    "$PLAYER_SCRIPT"
}


# ============================================================
# INSTALL / UPDATE
# ============================================================

install_app() {

    header

    echo -e "${CYAN}INSTALL / UPDATE${NC}"

    echo

    echo "User     : $USER"
    echo "Location : $APP_DIR"

    echo

    printf "Teruskan? [Y/n]: "

    answer="$(read_input)"

    if [[ "$answer" =~ ^[Nn]$ ]]; then

        echo
        echo "Installation dibatalkan."

        return 0
    fi


    echo
    echo "1/3 Creating folders..."

    create_directories


    echo
    echo "2/3 Downloading audio..."

    if ! download_audio; then

        echo
        echo -e "${RED}Installation dihentikan kerana audio gagal dimuat turun.${NC}"

        return 1
    fi


    echo
    echo "3/3 Creating player..."

    create_player


    echo
    echo "══════════════════════════════════════════════"

    echo -e "${GREEN}✓ INSTALLATION COMPLETE${NC}"

    echo "══════════════════════════════════════════════"

    echo

    echo "Auto Login belum diaktifkan."

    echo

    echo "Gunakan menu:"
    echo "3. Enable Auto Login"

    echo
}


# ============================================================
# UNINSTALL
# ============================================================

uninstall_app() {

    header

    echo -e "${RED}UNINSTALL QURAN LOGIN${NC}"

    echo

    echo "Ini akan membuang:"
    echo "  $APP_DIR"
    echo "  $PLIST_FILE"

    echo

    printf "Betul-betul uninstall? [y/N]: "

    answer="$(read_input)"

    if [[ ! "$answer" =~ ^[Yy]$ ]]; then

        echo
        echo "Uninstall dibatalkan."

        return 0
    fi


    launchctl bootout \
        "gui/$(id -u)/com.quran.login" \
        2>/dev/null || true


    rm -f "$PLIST_FILE"

    rm -rf "$APP_DIR"


    rm -f \
        /tmp/quran-login.log \
        /tmp/quran-login-error.log \
        /tmp/quran-login.lock \
        /tmp/quran-login.pid


    echo
    echo -e "${GREEN}✓ Quran Login telah di-uninstall.${NC}"
}


# ============================================================
# MAIN MENU
# ============================================================

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

    printf "Pilih [1-6]: "


    # IMPORTANT:
    # Read directly from Terminal instead of stdin.
    # This makes the menu work even when the installer
    # was started using curl | bash.

    choice="$(read_input)"

    choice="${choice//$'\r'/}"


    case "$choice" in

        1)
            install_app
            pause_screen
            ;;

        2)
            play_now
            pause_screen
            ;;

        3)
            enable_auto_login
            pause_screen
            ;;

        4)
            disable_auto_login
            pause_screen
            ;;

        5)
            uninstall_app
            pause_screen
            ;;

        6)
            clear

            echo
            echo "Quran Login ditutup."
            echo

            exit 0
            ;;

        *)
            echo
            echo -e "${YELLOW}Pilihan tidak sah.${NC}"

            sleep 1
            ;;

    esac

done
