# AGENTS.md - MikroskopCapture

## Project Overview

**MikroskopCapture** - Native macOS App für Ärzte zum Aufnehmen von Mikroskop-Bildern und Videos über Elgato 4K X Capture-Karte.

## Tech Stack

- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI
- **Video:** AVFoundation
- **Build:** Swift Package Manager
- **Target:** macOS 14.0+ (Sonoma)

## Project Structure

```
mikroskop-capture/
├── Package.swift              # Swift Package Definition
├── build-app.sh              # Build-Script für .app Bundle
├── README.md                 # Dokumentation
├── AGENTS.md                 # Diese Datei
├── PROGRESS.md               # Task-Tracking
├── MikroskopCapture.app/     # Kompilierte App
└── Sources/
    └── MikroskopCapture/
        ├── MikroskopCaptureApp.swift  # App Entry Point
        ├── ContentView.swift          # Hauptansicht + Buttons
        ├── CameraManager.swift        # AVFoundation Kamera-Logik
        ├── AppSettings.swift          # UserDefaults Settings
        ├── SettingsView.swift         # Einstellungen-UI
        └── Info.plist                 # App-Metadaten & Permissions
```

## Design System

**Style:** Clean 8-bit / Retro Terminal

### Colors
| Name | Hex | Usage |
|------|-----|-------|
| bg | `#0D0D0D` | Haupthintergrund |
| bgSecondary | `#1A1A1A` | Sekundärer Hintergrund |
| border | `#333333` | Rahmen, Trennlinien |
| textPrimary | `#E5E5E5` | Haupttext |
| textSecondary | `#808080` | Sekundärtext |
| accent | `#00FF88` | Terminal Green - Akzent |
| accentBlue | `#4A9EFF` | Foto-Button |
| accentOrange | `#FF9F43` | Video-Button |
| danger | `#FF5555` | Recording, Fehler |

### Typography
- **Font:** SF Mono (monospace)
- **Sizes:** 12px (small), 14px (normal), 16px (large), 20px (title)

## Key Features

1. **Live Preview** - Echtzeit-Feed von Capture-Karte
2. **Foto-Aufnahme** - Taste F oder Button
3. **Video-Aufnahme** - Taste V oder Button (Toggle Start/Stop)
4. **Dateiname-Dialog** - Nach jeder Aufnahme
5. **Netzlaufwerk-Support** - Speichern auf Server
6. **Konfigurierbare Dateinamen** - Präfix, Datum, Suffix

## Build Commands

```bash
# Debug Build
swift build

# Release Build + App Bundle
./build-app.sh

# Direkt ausführen
swift run

# App starten
open MikroskopCapture.app
```

## Conventions

### Code Style
- Deutsche Kommentare erlaubt (Zielgruppe: deutsche Ärzte)
- UI-Texte: Englisch (clean terminal style)
- Variablen/Funktionen: Englisch

### Commits
- Deutsch oder Englisch
- Format: `[Bereich] Beschreibung`
- Beispiel: `[UI] Settings-Dialog als Sheet implementiert`

## Customer Context

- **Kunde:** Arztpraxis
- **Nutzer:** Arzt (kein IT-Hintergrund)
- **Hardware:** Mac + Elgato 4K X + Mikroskop
- **Anforderung:** Maximale Einfachheit

## Known Issues / TODOs

- [ ] MP4-Export (aktuell nur MOV)
- [ ] App Icon erstellen
- [ ] Code Signing für Distribution
- [ ] Automatische Updates

## Contact

Projekt von CVRT GmbH für Coffeebreak/Praxis-Kunde.
