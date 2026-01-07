# PROGRESS.md - MikroskopCapture

## Current Status: ✅ MVP Complete

**Last Updated:** 2026-01-07

---

## Session: 2026-01-07

### Objective
Native macOS App erstellen für Arztpraxis zum Aufnehmen von Mikroskop-Bildern/Videos über Elgato 4K X.

### Completed

- [x] **Projektstruktur** - Swift Package mit SwiftUI
- [x] **Live Preview** - AVFoundation Integration für Elgato 4K X
- [x] **Foto-Aufnahme** - Screenshot vom Live-Feed
- [x] **Video-Aufnahme** - MOV Recording mit Timer
- [x] **Dateiname-Dialog** - Nach jeder Aufnahme
- [x] **Settings** - Gerät, Pfad, Dateiformat, Naming
- [x] **Keyboard Shortcuts** - F (Foto), V (Video)
- [x] **8-bit Clean Design** - Terminal-Style UI
- [x] **Datum-Bug gefixt** - Timestamp wird beim Dialog-Öffnen fixiert
- [x] **Settings-Button gefixt** - Öffnet jetzt als Sheet
- [x] **Top-Timer entfernt** - Nur noch im Button sichtbar
- [x] **Buttons als Overlay** - 50/50 über Preview

### Design Decisions

| Decision | Reasoning |
|----------|-----------|
| Swift Package statt Xcode Project | Einfacher zu verwalten, kein Xcode nötig zum Bauen |
| SwiftUI statt AppKit | Moderner, weniger Code, einfacher zu maintainen |
| Sheet statt separates Window für Settings | Einfacher für Nutzer, bleibt im Kontext |
| Monospace Font | Terminal-Ästhetik, professionell, gut lesbar |
| Overlay-Buttons | Maximiert Preview-Fläche |

### Technical Notes

- **macOS 14+ required** - Wegen `.external` Device Type in AVFoundation
- **Kein Code Signing** - Für lokale Nutzung, muss für Distribution signiert werden
- **Info.plist** - Enthält Camera Usage Description für Berechtigung

---

## Pending / Future

### High Priority
- [ ] Settings testen (funktioniert der Sheet?)
- [ ] Auf Praxis-Mac deployen und testen

### Medium Priority
- [ ] App Icon erstellen (8-bit Mikroskop?)
- [ ] MP4-Export Option (aktuell nur MOV)
- [ ] Fehlerbehandlung verbessern (Netzwerk-Timeout etc.)

### Low Priority
- [ ] Code Signing für Distribution
- [ ] DMG Installer erstellen
- [ ] Auto-Update Mechanismus
- [ ] Mehrsprachigkeit (aktuell EN UI)

---

## Files Changed This Session

```
Sources/MikroskopCapture/
├── MikroskopCaptureApp.swift  ✏️ Settings Window/Sheet
├── ContentView.swift          ✏️ Overlay Buttons, Shortcuts, Design
├── CameraManager.swift        ✅ Unchanged
├── AppSettings.swift          ✏️ Timestamp Parameter
├── SettingsView.swift         ✏️ 8-bit Design, Date Format
└── Info.plist                 ✅ Unchanged
```

---

## Build & Test

```bash
# Im Projektverzeichnis
cd /Users/jh/Git/cvrt-gmbh/mikroskop-capture

# Bauen
./build-app.sh

# Starten
open MikroskopCapture.app

# Oder direkt
swift run
```

---

## Customer Feedback Loop

| Feedback | Status | Action |
|----------|--------|--------|
| "Datum läuft weiter im Dialog" | ✅ Fixed | Timestamp wird fixiert |
| "Settings öffnet nicht" | ✅ Fixed | Sheet statt Window |
| "Timer oben unnötig" | ✅ Fixed | Entfernt, nur im Button |
| "Buttons sollten größer sein" | ✅ Fixed | 50/50 Overlay |
| "Keyboard Shortcuts" | ✅ Added | F und V |
| "8-bit Design" | ✅ Implemented | Terminal Style |
