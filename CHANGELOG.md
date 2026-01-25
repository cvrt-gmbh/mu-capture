# Changelog

All notable changes to μCapture will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.2] - 2026-01-25

### Fixed
- **App bundle renamed** to `MuCapture.app` for Spotlight/Launchpad compatibility (was `μCapture.app`)

## [1.0.1] - 2026-01-25

### Fixed
- Version now reads from Info.plist instead of hardcoded value
- App icon centered properly in dock

### Added
- Homebrew Cask support via `brew install cvrt-gmbh/cask/mucapture`

## [1.0.0] - 2026-01-25

### Changed
- **Rebranded** from MikroskopCapture to μCapture (MuCapture)
- **New app icon** - Catppuccin Mocha themed μ symbol
- **New design system** - Catppuccin Mocha color palette
- **Bundled font** - JetBrains Mono Nerd Font (no system dependency)
- **License** - Changed to Non-Commercial license
- **Homebrew support** - `brew tap cvrt-gmbh/mu-capture && brew install --cask mucapture`

### Added
- Quick capture shortcuts (`⇧F`, `⇧V`) for instant capture without dialog
- Custom keybindings configuration in settings
- Homebrew Cask formula for easy installation

## [0.2.0] - 2026-01-07

### Added
- **Device Selector Dropdown** - Click device name in header to switch capture device instantly
- **Refresh Devices** option in device dropdown menu
- Explanation text in Settings clarifying preferred vs active device

### Changed
- Settings "CAPTURE DEVICE" renamed to "PREFERRED DEVICE" for clarity
- Settings panel now stretches to fill available space (no longer fixed width)
- Tab bar in settings now always visible across all tabs
- Text fields in Naming tab now stretch to fill available width

### Fixed
- Tab bar disappearing when viewing NAMING tab in settings
- Settings panel centered with fixed width - now responsive

## [0.1.0] - 2026-01-07

### Added
- **Live Preview** - Real-time video feed from capture device
- **Photo Capture** - Capture current frame as image
- **Video Recording** - Record video with live duration timer
- **Save Dialog** - Custom filename input after each capture
- **Settings Panel** - Device, storage path, file naming configuration
- **Keyboard Shortcuts** - `F` for photo, `V` for video
- **Auto Device Detection** - Automatically selects first external device
- **Multiple Image Formats** - JPEG, PNG, TIFF support
- **Multiple Video Formats** - MOV, MP4 support
- **Date in Filename** - Configurable date format options
- **Prefix/Suffix** - Custom filename prefix and suffix
- **Network Storage** - Support for saving to network drives

### Technical
- Built with Swift 5.9 and SwiftUI
- Uses AVFoundation for video capture
- Swift Package Manager for dependencies
- Requires macOS 14.0 (Sonoma) or later

---

## Version History

| Version | Date | Summary |
|---------|------|---------|
| 1.0.2 | 2026-01-25 | App bundle renamed for Spotlight compatibility |
| 1.0.1 | 2026-01-25 | Version fix, centered icon, Homebrew support |
| 1.0.0 | 2026-01-25 | Rebrand to μCapture, Catppuccin design, Homebrew support |
| 0.2.0 | 2026-01-07 | Device selector dropdown, responsive settings |
| 0.1.0 | 2026-01-07 | Initial MVP release |

[Unreleased]: https://github.com/cvrt-gmbh/mu-capture/compare/v1.0.2...HEAD
[1.0.2]: https://github.com/cvrt-gmbh/mu-capture/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/cvrt-gmbh/mu-capture/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/cvrt-gmbh/mu-capture/compare/v0.2.0...v1.0.0
[0.2.0]: https://github.com/cvrt-gmbh/mu-capture/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/cvrt-gmbh/mu-capture/releases/tag/v0.1.0
