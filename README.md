# MikroskopCapture

Eine einfache macOS-App zum Aufnehmen von Bildern und Videos von einem Mikroskop über eine Elgato 4K X Capture-Karte.

## Features

- **Live-Preview** des Mikroskop-Feeds
- **Foto-Aufnahme** mit einem Klick
- **Video-Aufnahme** mit Zeitzähler im Button
- **Automatische Geräteerkennung** (bevorzugt externe Capture-Karten)
- **Dateiname-Dialog** nach jeder Aufnahme
- **Speicherung auf Netzlaufwerk** möglich
- **Konfigurierbare Dateinamen** (Präfix, Datum, Suffix)
- **Verschiedene Formate** (JPEG/PNG/TIFF für Bilder, MOV/MP4 für Videos)

## Systemanforderungen

- macOS 14.0 (Sonoma) oder neuer
- Elgato 4K X oder andere USB-Capture-Karte

## Installation

### Option 1: Vorkompilierte App
```bash
cp -r MikroskopCapture.app /Applications/
```

### Option 2: Selbst kompilieren
```bash
./build-app.sh
cp -r MikroskopCapture.app /Applications/
```

## Verwendung

### Erster Start
1. App starten
2. Kamera-Berechtigung erlauben (wird automatisch abgefragt)
3. Capture-Gerät wird automatisch erkannt

### Foto aufnehmen
1. Auf **FOTO** klicken
2. Bezeichnung eingeben (optional)
3. **Speichern** klicken

### Video aufnehmen
1. Auf **VIDEO** klicken → Aufnahme startet, Timer läuft
2. Erneut auf **VIDEO** (zeigt Zeit) klicken → Aufnahme stoppt
3. Bezeichnung eingeben (optional)
4. **Speichern** klicken

### Einstellungen
Über das Zahnrad-Symbol oder `⌘ + ,`:

- **Gerät**: Bevorzugtes Capture-Gerät auswählen
- **Speicher**: Speicherpfad und Dateiformate
- **Dateiname**: Präfix, Datum-Format, Suffix

## Dateistruktur

```
MikroskopCapture/
├── Package.swift           # Swift Package Definition
├── build-app.sh           # Build-Script
├── README.md              # Diese Datei
└── Sources/
    └── MikroskopCapture/
        ├── MikroskopCaptureApp.swift  # App-Einstiegspunkt
        ├── ContentView.swift          # Hauptansicht
        ├── CameraManager.swift        # Kamera-Logik
        ├── AppSettings.swift          # Einstellungen
        ├── SettingsView.swift         # Einstellungen-UI
        └── Info.plist                 # App-Metadaten
```

## Entwicklung

### Voraussetzungen
- Swift 5.9+
- macOS 14.0+ SDK

### Build
```bash
# Debug Build
swift build

# Release Build + App Bundle
./build-app.sh
```

### Direkt ausführen (ohne App Bundle)
```bash
swift run
```

## Lizenz

MIT License - Frei verwendbar
