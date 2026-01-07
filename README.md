# MikroskopCapture

Native macOS app for capturing microscope images and videos via Elgato 4K X capture card.

![macOS](https://img.shields.io/badge/macOS-14.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange)
![License](https://img.shields.io/badge/License-Proprietary-red)

## Features

- **Live Preview** - Real-time feed from capture device
- **Photo Capture** - Single frame capture with `F` key or button
- **Video Recording** - Start/stop with `V` key, timer in button
- **Device Switching** - Click device name in header to switch instantly
- **Auto Device Detection** - Prefers external capture cards
- **Configurable Filenames** - Prefix, date format, suffix
- **Network Storage** - Save directly to network drives
- **Multiple Formats** - JPEG/PNG/TIFF for images, MOV/MP4 for video

## Requirements

- macOS 14.0 (Sonoma) or later
- Elgato 4K X or compatible USB capture card

## Installation

### Pre-built App
```bash
cp -r MikroskopCapture.app /Applications/
```

### Build from Source
```bash
./build-app.sh
cp -r MikroskopCapture.app /Applications/
```

## Usage

### Quick Start
1. Launch app
2. Grant camera permission when prompted
3. Capture device is auto-detected

### Keyboard Shortcuts
| Key | Action |
|-----|--------|
| `F` | Capture photo |
| `V` | Start/stop video recording |

### Switching Devices
Click on the device name in the header bar to see available devices and switch instantly.

### Settings
Click `/ SETTINGS` in the top-right corner:

- **Device** - Set preferred startup device
- **Storage** - Save path and file formats
- **Naming** - Filename prefix, date format, suffix

## Project Structure

```
mikroskop-capture/
├── Package.swift              # Swift Package definition
├── build-app.sh              # Build script for .app bundle
├── README.md                 # This file
├── CHANGELOG.md              # Version history
├── AGENTS.md                 # AI agent instructions
└── Sources/
    └── MikroskopCapture/
        ├── MikroskopCaptureApp.swift  # App entry point
        ├── ContentView.swift          # Main view + buttons
        ├── CameraManager.swift        # AVFoundation camera logic
        ├── AppSettings.swift          # UserDefaults settings
        ├── SettingsView.swift         # Settings UI
        └── Info.plist                 # App metadata & permissions
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

Clean 8-bit / Retro Terminal aesthetic with monospace fonts and muted colors.

| Color | Hex | Usage |
|-------|-----|-------|
| Background | `#0D0D0D` | Main background |
| Accent | `#00FF88` | Terminal green |
| Blue | `#4A9EFF` | Photo button |
| Orange | `#FF9F43` | Video button |
| Danger | `#FF5555` | Recording state |

## License

Proprietary - CVRT GmbH. All rights reserved.

---

*Built by CVRT GmbH for medical practice use.*
