# μCapture

Native macOS app for capturing microscope images and videos via capture cards (Elgato 4K X, etc.).

![macOS](https://img.shields.io/badge/macOS-14.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange)
![License](https://img.shields.io/badge/License-Non--Commercial-yellow)

## Features

- **Live Preview** - Real-time feed from capture device
- **Photo Capture** - Single frame capture with `F` key or button
- **Video Recording** - Start/stop with `V` key, timer in button
- **Device Switching** - Click device name in header to switch instantly
- **Auto Device Detection** - Prefers external capture cards
- **Configurable Filenames** - Prefix, date format, suffix
- **Network Storage** - Save directly to network drives
- **Multiple Formats** - JPEG/PNG/TIFF for images, MOV/MP4 for video
- **Custom Keybindings** - Configure all keyboard shortcuts

## Installation

### Homebrew

```bash
brew install --cask https://raw.githubusercontent.com/cvrt-gmbh/mu-capture/main/Casks/mucapture.rb
```

### Manual Download

Download the latest release from [Releases](https://github.com/cvrt-gmbh/mu-capture/releases) and drag `μCapture.app` to `/Applications/`.

### Build from Source

```bash
git clone https://github.com/cvrt-gmbh/mu-capture.git
cd mu-capture
./build-app.sh
cp -r 'μCapture.app' /Applications/
```

## Requirements

- macOS 14.0 (Sonoma) or later
- USB capture card (Elgato 4K X, Cam Link, or compatible)

## Usage

### Quick Start
1. Launch μCapture
2. Grant camera permission when prompted
3. Capture device is auto-detected

### Keyboard Shortcuts
| Key | Action |
|-----|--------|
| `F` | Capture photo |
| `V` | Start/stop video recording |
| `⇧F` | Quick capture photo (no dialog) |
| `⇧V` | Quick capture video (no dialog) |
| `⌘,` | Open settings |

### Switching Devices
Click on the device name in the header bar to see available devices and switch instantly.

### Settings (`⌘,`)
- **Device** - Set preferred startup device
- **Storage** - Save path and file formats
- **Naming** - Filename prefix, date format, suffix
- **Keys** - Customize keyboard shortcuts

## Project Structure

```
mu-capture/
├── Package.swift              # Swift Package definition
├── build-app.sh               # Build script for .app bundle
├── README.md                  # This file
├── CHANGELOG.md               # Version history
├── Casks/
│   └── mucapture.rb           # Homebrew Cask formula
├── Resources/
│   └── Fonts/                 # Bundled JetBrains Mono Nerd Font
└── Sources/
    └── MuCapture/
        ├── MuCaptureApp.swift     # App entry point
        ├── ContentView.swift       # Main view + buttons
        ├── CameraManager.swift     # AVFoundation camera logic
        ├── AppSettings.swift       # UserDefaults settings
        ├── SettingsView.swift      # Settings UI
        └── Info.plist              # App metadata & permissions
```

## Development

### Prerequisites
- Swift 5.9+
- macOS 14.0+ SDK

### Build Commands
```bash
# Debug build
swift build

# Release build + app bundle
./build-app.sh

# Run directly (without app bundle)
swift run
```

## Design

Clean terminal aesthetic with JetBrains Mono Nerd Font and Catppuccin Mocha colors.

| Color | Hex | Usage |
|-------|-----|-------|
| Background | `#1e1e2e` | Main background |
| Accent | `#a6e3a1` | Green highlights |
| Blue | `#89b4fa` | Photo button |
| Peach | `#fab387` | Video button |
| Red | `#f38ba8` | Recording state |

## License

**Non-Commercial Use Only** - Free for personal and educational use. Commercial use requires a separate license. See [LICENSE](LICENSE) for details.

For commercial licensing, contact: info@cavort.de

---

*Built by [CVRT GmbH](https://cvrt.dev)*
