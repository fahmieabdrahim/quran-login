# Quran Login

**Play Surah Al-Fatihah automatically when you log in to macOS.**

Quran Login is a lightweight macOS utility that runs in the background and plays **Surah Al-Fatihah** by **Mishary Rashid Alafasy** after the user logs in.

It runs entirely at the user level and does not require `sudo`.

---

## Features

* 🎧 Play Surah Al-Fatihah
* 🕌 Mishary Rashid Alafasy recitation
* 🔐 Automatic playback after macOS login
* ▶️ Manual playback from Terminal
* 🔄 Install / Update
* 🟢 Enable Auto Login
* 🔴 Disable Auto Login
* 🗑️ Uninstall
* 👤 User-level installation
* 🚫 No `sudo` required
* 🍎 Designed for macOS

---

## Installation

Open **Terminal** and run:

```bash
curl -fsSL https://raw.githubusercontent.com/fahmieabdrahim/quran-login/main/install.sh | bash
```

The installer will:

1. Create the Quran Login directory
2. Download the Quran Login script
3. Create the `quran-login` command
4. Configure the user's `PATH`
5. Start Quran Login

After installation, run:

```bash
quran-login
```

---

## Menu

Quran Login provides a simple Terminal menu:

```text
╔══════════════════════════════════════════════╗
║           QURAN LOGIN - macOS               ║
╠══════════════════════════════════════════════╣
║  Mishary Rashid Alafasy                     ║
║  Surah Al-Fatihah                           ║
╚══════════════════════════════════════════════╝

STATUS
────────────────────────────────────────────
Installation : INSTALLED
Auto Login   : ENABLED
Qari         : Mishary Rashid Alafasy
Surah        : Al-Fatihah

1. Install / Update
2. ▶  Play Al-Fatihah
3. Enable Auto Login
4. Disable Auto Login
5. Uninstall
6. Exit

Pilih [1-6]:
```

### 1. Install / Update

Downloads the required audio files and creates the playback script.

### 2. Play Al-Fatihah

Immediately plays Surah Al-Fatihah without logging out.

### 3. Enable Auto Login

Enables automatic playback whenever the user logs in to macOS.

### 4. Disable Auto Login

Stops automatic playback after login.

### 5. Uninstall

Removes Quran Login, its audio files and the LaunchAgent.

### 6. Exit

Closes the Terminal menu.

---

## How Auto Login Works

Quran Login uses a macOS **LaunchAgent**.

The LaunchAgent starts the playback script when the user logs in:

```text
macOS Login
     │
     ▼
LaunchAgent
     │
     ▼
play.sh
     │
     ▼
afplay
     │
     ▼
Surah Al-Fatihah
```

The LaunchAgent is installed at:

```text
~/Library/LaunchAgents/com.quran.login.plist
```

The playback script is located at:

```text
~/QuranLogin/scripts/play.sh
```

Audio files are stored at:

```text
~/QuranLogin/audio/
```

---

## Audio

Recitation:

**Mishary Rashid Alafasy**

Surah:

**Al-Fatihah**

Audio source:

**EveryAyah**

The audio files are downloaded during installation and stored locally on the Mac.

---

## Requirements

* macOS
* Internet connection during installation
* `curl`
* `afplay`

`curl` and `afplay` are normally available on macOS.

No additional package manager is required.

---

## Installation Location

Quran Login uses the user's home directory:

```text
~/QuranLogin
```

The command is installed at:

```text
~/bin/quran-login
```

The LaunchAgent is installed at:

```text
~/Library/LaunchAgents/com.quran.login.plist
```

No system-wide files are required.

---

## Uninstall

Run:

```bash
quran-login
```

Then select:

```text
5. Uninstall
```

This removes:

```text
~/QuranLogin
~/Library/LaunchAgents/com.quran.login.plist
```

and the temporary log files.

---

## Manual Testing

To test the player directly:

```bash
~/QuranLogin/scripts/play.sh
```

To check the LaunchAgent:

```bash
launchctl print "gui/$(id -u)/com.quran.login"
```

To check the error log:

```bash
cat /tmp/quran-login-error.log
```

To check the normal log:

```bash
cat /tmp/quran-login.log
```

---

## Project Structure

```text
quran-login/
├── quran-login.sh
├── install.sh
└── README.md
```

After installation on macOS:

```text
~/QuranLogin/
├── audio/
│   ├── 001001.mp3
│   ├── 001002.mp3
│   ├── 001003.mp3
│   ├── 001004.mp3
│   ├── 001005.mp3
│   ├── 001006.mp3
│   └── 001007.mp3
│
└── scripts/
    └── play.sh
```

---

## License

This project is provided for personal and educational use.

The Quran recitation audio is provided by **EveryAyah** and belongs to its respective rights holders.

---

## Author

**Fahmie Abd Rahim**

GitHub:

https://github.com/fahmieabdrahim

````

### Cara letak dalam GitHub

Dalam repo **quran-login**:

1. Buka `README.md`
2. Klik **✏️ Edit**
3. `Ctrl + A`
4. Padam README lama
5. Paste README di atas
6. Klik **Commit changes**
7. Commit message:

```text
Update README
````

Selepas itu repo murid akan ada dokumentasi yang lebih kemas untuk orang lain install dan guna.

**Nota:** Saya sengaja kekalkan dokumentasi berdasarkan fungsi script kita sekarang — termasuk `LaunchAgent`, `afplay`, lokasi fail dan arahan `curl | bash`.
