//
//  ContentView.swift
//  MikroskopCapture
//
//  Hauptansicht mit Live-Preview und großen Buttons
//  Design: Clean 8-bit / Retro Terminal Style
//

import SwiftUI
import AVFoundation
import AppKit

// MARK: - Design Constants (Catppuccin Mocha)

struct DesignSystem {
    // Monospace Font - JetBrains Mono Nerd Font (bundled with app)
    private static let fontName = "JetBrainsMonoNerdFont-Regular"
    private static let fontNameMedium = "JetBrainsMonoNerdFont-Medium"
    private static let fontNameBold = "JetBrainsMonoNerdFont-Bold"
    
    static let mono = Font.custom(fontName, size: 14)
    static let monoSmall = Font.custom(fontName, size: 12)
    static let monoLarge = Font.custom(fontNameMedium, size: 16)
    static let monoXL = Font.custom(fontNameMedium, size: 20)
    static let monoTitle = Font.custom(fontNameBold, size: 20)
    
    // Catppuccin Mocha - Base Colors
    static let bg = Color(hex: "1e1e2e")           // Base
    static let bgSecondary = Color(hex: "181825")  // Mantle
    static let bgTertiary = Color(hex: "11111b")   // Crust
    static let surface0 = Color(hex: "313244")     // Surface0
    static let surface1 = Color(hex: "45475a")     // Surface1
    static let surface2 = Color(hex: "585b70")     // Surface2
    
    // Catppuccin Mocha - Overlay Colors
    static let overlay0 = Color(hex: "6c7086")
    static let overlay1 = Color(hex: "7f849c")
    static let overlay2 = Color(hex: "9399b2")
    
    // Catppuccin Mocha - Text Colors
    static let textPrimary = Color(hex: "cdd6f4")   // Text
    static let textSecondary = Color(hex: "a6adc8") // Subtext0
    static let textTertiary = Color(hex: "bac2de")  // Subtext1
    
    // Catppuccin Mocha - Border
    static let border = Color(hex: "45475a")        // Surface1
    
    // Catppuccin Mocha - Accent Colors
    static let accent = Color(hex: "a6e3a1")        // Green
    static let accentBlue = Color(hex: "89b4fa")    // Blue
    static let accentOrange = Color(hex: "fab387")  // Peach
    static let danger = Color(hex: "f38ba8")        // Red
    static let warning = Color(hex: "f9e2af")       // Yellow
    static let mauve = Color(hex: "cba6f7")         // Mauve
    static let teal = Color(hex: "94e2d5")          // Teal
    static let sky = Color(hex: "89dceb")           // Sky
    static let lavender = Color(hex: "b4befe")      // Lavender
    static let rosewater = Color(hex: "f5e0dc")     // Rosewater
    static let flamingo = Color(hex: "f2cdcd")      // Flamingo
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct ContentView: View {
    @Binding var showSettings: Bool
    @StateObject private var cameraManager = CameraManager()
    @ObservedObject private var settings = AppSettings.shared
    @Environment(\.openWindow) private var openWindow
    
    @State private var showingSaveDialog = false
    @State private var pendingImage: NSImage?
    @State private var pendingVideoURL: URL?
    @State private var customFileName = ""
    @State private var isVideo = false
    @State private var captureTimestamp: Date?
    @State private var showDeviceMenu = false
    @State private var isQuickVideoCapture = false
    @State private var showFlash = false
    
    var body: some View {
        ZStack {
            // Full Preview
            previewView
            
            // Overlay UI
            VStack(spacing: 0) {
                // Top Bar
                headerView
                
                Spacer()
                
                // Bottom Buttons (Overlay)
                buttonBar
            }
            
            // Flash overlay
            if showFlash {
                Color.white
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }
        }
        .background(DesignSystem.bg)
        .onAppear {
            setupCallbacks()
            cameraManager.startSession()
            
            // Setup keyboard monitoring
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                return handleKeyEvent(event)
            }
        }
        .onDisappear {
            cameraManager.stopSession()
        }
        .sheet(isPresented: $showingSaveDialog) {
            SaveDialogView(
                fileName: $customFileName,
                isVideo: isVideo,
                timestamp: captureTimestamp ?? Date(),
                onSave: saveFile,
                onCancel: cancelSave
            )
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .alert("/ ERROR", isPresented: .constant(cameraManager.error != nil)) {
            Button("OK") {
                cameraManager.error = nil
            }
        } message: {
            Text(cameraManager.error ?? "")
        }
    }
    
    // MARK: - Keyboard Handler
    
    private func handleKeyEvent(_ event: NSEvent) -> NSEvent? {
        // Don't handle if dialog is showing
        guard !showingSaveDialog && !showSettings else { return event }
        
        // Check custom keybindings
        
        // Quick Photo (no dialog)
        if settings.quickPhotoKey.matches(event) {
            if cameraManager.previewImage != nil && !cameraManager.isRecording {
                quickCapturePhoto()
                return nil
            }
        }
        
        // Quick Video (no dialog)
        if settings.quickVideoKey.matches(event) {
            if cameraManager.previewImage != nil || cameraManager.isRecording {
                toggleVideoRecording(quick: true)
                return nil
            }
        }
        
        // Regular Photo (with dialog)
        if settings.photoKey.matches(event) {
            if cameraManager.previewImage != nil && !cameraManager.isRecording {
                capturePhoto()
                return nil
            }
        }
        
        // Regular Video (with dialog)
        if settings.videoKey.matches(event) {
            if cameraManager.previewImage != nil || cameraManager.isRecording {
                toggleVideoRecording(quick: false)
                return nil
            }
        }
        
        return event
    }
    
    // MARK: - Header (Device Selector + Settings)
    
    private var headerView: some View {
        HStack(spacing: 16) {
            // Device Selector Button with Popover Menu
            Button(action: { showDeviceMenu.toggle() }) {
                HStack(spacing: 8) {
                    Text("●")
                        .font(.system(size: 10))
                        .foregroundColor(cameraManager.selectedDevice != nil ? DesignSystem.accent : DesignSystem.danger)
                    
                    Text(cameraManager.selectedDevice?.localizedName.uppercased() ?? "NO DEVICE")
                        .font(DesignSystem.mono)
                        .foregroundColor(DesignSystem.textPrimary)
                }
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showDeviceMenu, arrowEdge: .bottom) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(cameraManager.availableDevices, id: \.uniqueID) { device in
                        Button(action: {
                            cameraManager.selectDevice(device)
                            showDeviceMenu = false
                        }) {
                            HStack(spacing: 8) {
                                Text("●")
                                    .font(.system(size: 8))
                                    .foregroundColor(cameraManager.selectedDevice?.uniqueID == device.uniqueID ? DesignSystem.accent : .clear)
                                
                                Text(device.localizedName)
                                    .font(DesignSystem.mono)
                                    .foregroundColor(DesignSystem.textPrimary)
                                
                                if device.deviceType == .external {
                                    Text("EXT")
                                        .font(DesignSystem.monoSmall)
                                        .foregroundColor(DesignSystem.textSecondary)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .background(cameraManager.selectedDevice?.uniqueID == device.uniqueID ? DesignSystem.accent.opacity(0.1) : Color.clear)
                    }
                    
                    if cameraManager.availableDevices.isEmpty {
                        Text("No devices found")
                            .font(DesignSystem.mono)
                            .foregroundColor(DesignSystem.textSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                    }
                    
                    Divider()
                        .background(DesignSystem.border)
                    
                    Button(action: {
                        cameraManager.discoverDevices()
                        showDeviceMenu = false
                    }) {
                        Text("Refresh Devices")
                            .font(DesignSystem.mono)
                            .foregroundColor(DesignSystem.textSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                }
                .frame(minWidth: 200)
                .background(DesignSystem.bgSecondary)
            }
            
            // Version Number with repo link (left side, next to device)
            Button(action: openRepoURL) {
                Text("v1.0.1")
                    .font(DesignSystem.monoSmall)
                    .foregroundColor(DesignSystem.textSecondary.opacity(0.5))
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                if hovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
            
            Spacer()
            
            // Media Button - opens save folder
            Button(action: openMediaFolder) {
                Text("/ MEDIA")
                    .font(DesignSystem.monoSmall)
                    .foregroundColor(DesignSystem.textSecondary)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                if hovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
            
            // Settings Button
            Button(action: { showSettings = true }) {
                Text("/ SETTINGS")
                    .font(DesignSystem.monoSmall)
                    .foregroundColor(DesignSystem.textSecondary)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                if hovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(DesignSystem.bg.opacity(0.85))
    }
    
    // MARK: - Preview
    
    private var previewView: some View {
        GeometryReader { geometry in
            ZStack {
                if let image = cameraManager.previewImage {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // No Signal State
                    VStack(spacing: 20) {
                        Text("▢")
                            .font(.system(size: 48))
                            .foregroundColor(DesignSystem.border)
                        
                        VStack(spacing: 8) {
                            Text("/ NO SIGNAL")
                                .font(DesignSystem.monoLarge)
                                .foregroundColor(DesignSystem.textSecondary)
                            
                            if cameraManager.availableDevices.isEmpty {
                                Text("Connect capture device")
                                    .font(DesignSystem.monoSmall)
                                    .foregroundColor(DesignSystem.textSecondary.opacity(0.6))
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(DesignSystem.bg)
    }
    
    // MARK: - Button Bar (Overlay)
    
    private var buttonBar: some View {
        HStack(spacing: 0) {
            // FOTO Button - 50%
            OverlayButton(
                label: "FOTO",
                shortcut: settings.photoKey.displayString,
                color: DesignSystem.accentBlue,
                isActive: false,
                isDisabled: cameraManager.previewImage == nil || cameraManager.isRecording,
                action: capturePhoto
            )
            
            // Divider
            Rectangle()
                .fill(DesignSystem.border.opacity(0.5))
                .frame(width: 1)
            
            // VIDEO Button - 50%
            OverlayButton(
                label: cameraManager.isRecording ? "STOP [\(formatDuration(cameraManager.recordingDuration))]" : "VIDEO",
                shortcut: settings.videoKey.displayString,
                color: cameraManager.isRecording ? DesignSystem.danger : DesignSystem.accentOrange,
                isActive: cameraManager.isRecording,
                isDisabled: cameraManager.previewImage == nil && !cameraManager.isRecording,
                action: { toggleVideoRecording(quick: false) }
            )
        }
        .frame(height: 70)
        .background(DesignSystem.bg.opacity(0.85))
    }
    
    // MARK: - Actions
    
    private func setupCallbacks() {
        cameraManager.onPhotoCaptured = { (image: NSImage) in
            pendingImage = image
            pendingVideoURL = nil
            isVideo = false
            customFileName = ""
            captureTimestamp = Date()
            showingSaveDialog = true
        }
        
        cameraManager.onVideoCaptured = { (url: URL) in
            if isQuickVideoCapture {
                // Quick capture - save immediately without dialog (with counter increment)
                let timestamp = Date()
                let fileName = settings.generateFileName(baseName: "", isVideo: true, timestamp: timestamp, incrementCounter: true)
                let destinationURL = settings.fullPath(for: fileName)
                
                let directory = destinationURL.deletingLastPathComponent()
                try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                
                do {
                    try FileManager.default.moveItem(at: url, to: destinationURL)
                } catch {
                    cameraManager.error = "Video speichern fehlgeschlagen: \(error.localizedDescription)"
                }
                isQuickVideoCapture = false
            } else {
                // Normal capture - show dialog
                pendingVideoURL = url
                pendingImage = nil
                isVideo = true
                customFileName = ""
                captureTimestamp = Date()
                showingSaveDialog = true
            }
        }
    }
    
    private func capturePhoto() {
        triggerCaptureFeedback()
        cameraManager.capturePhoto()
    }
    
    private func quickCapturePhoto() {
        guard let image = cameraManager.previewImage else { return }
        
        triggerCaptureFeedback()
        
        // Generate auto filename and save immediately (with counter increment)
        let timestamp = Date()
        let fileName = settings.generateFileName(baseName: "", isVideo: false, timestamp: timestamp, incrementCounter: true)
        let destinationURL = settings.fullPath(for: fileName)
        
        let directory = destinationURL.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        
        saveImage(image, to: destinationURL)
    }
    
    private func toggleVideoRecording(quick: Bool = false) {
        if cameraManager.isRecording {
            // Stop recording - quick mode saves without dialog
            if quick {
                isQuickVideoCapture = true
            }
            cameraManager.stopVideoRecording()
        } else {
            // Start recording - remember if this is quick mode
            isQuickVideoCapture = quick
            cameraManager.startVideoRecording()
        }
    }
    
    private func openMediaFolder() {
        let path: String
        if settings.savePath.hasPrefix("~") {
            path = NSString(string: settings.savePath).expandingTildeInPath
        } else {
            path = settings.savePath
        }
        
        let url = URL(fileURLWithPath: path)
        NSWorkspace.shared.open(url)
    }
    
    private func openRepoURL() {
        if let url = URL(string: "https://github.com/cvrt-gmbh/mikroskop-capture") {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func saveFile() {
        let fileName = settings.generateFileName(baseName: customFileName, isVideo: isVideo, timestamp: captureTimestamp ?? Date(), incrementCounter: true)
        let destinationURL = settings.fullPath(for: fileName)
        
        let directory = destinationURL.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        
        if let image = pendingImage {
            saveImage(image, to: destinationURL)
        } else if let videoURL = pendingVideoURL {
            saveVideo(from: videoURL, to: destinationURL)
        }
        
        pendingImage = nil
        pendingVideoURL = nil
        captureTimestamp = nil
        showingSaveDialog = false
    }
    
    private func cancelSave() {
        if let videoURL = pendingVideoURL {
            try? FileManager.default.removeItem(at: videoURL)
        }
        
        pendingImage = nil
        pendingVideoURL = nil
        captureTimestamp = nil
        showingSaveDialog = false
    }
    
    private func saveImage(_ image: NSImage, to url: URL) {
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else {
            cameraManager.error = "Bild konnte nicht konvertiert werden"
            return
        }
        
        let data: Data?
        
        switch settings.imageFormat {
        case .jpeg:
            data = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.9])
        case .png:
            data = bitmap.representation(using: .png, properties: [:])
        case .tiff:
            data = bitmap.representation(using: .tiff, properties: [:])
        }
        
        guard let imageData = data else {
            cameraManager.error = "Bild konnte nicht gespeichert werden"
            return
        }
        
        do {
            try imageData.write(to: url)
        } catch {
            cameraManager.error = "Speichern fehlgeschlagen: \(error.localizedDescription)"
        }
    }
    
    private func saveVideo(from sourceURL: URL, to destinationURL: URL) {
        do {
            try FileManager.default.moveItem(at: sourceURL, to: destinationURL)
        } catch {
            cameraManager.error = "Video speichern fehlgeschlagen: \(error.localizedDescription)"
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Capture Feedback
    
    private func triggerCaptureFeedback() {
        // Flash
        if settings.flashEnabled {
            withAnimation(.easeOut(duration: 0.05)) {
                showFlash = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeIn(duration: 0.15)) {
                    showFlash = false
                }
            }
        }
        
        // Sound
        if settings.soundEnabled {
            NSSound.beep()  // System beep as fallback
            // Alternative: Use system camera shutter sound
            if let sound = NSSound(named: "Tink") {
                sound.play()
            }
        }
    }
}

// MARK: - Overlay Button (Full Width, 50% each)

struct OverlayButton: View {
    let label: String
    let shortcut: String
    let color: Color
    let isActive: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(label)
                    .font(DesignSystem.monoLarge)
                    .fontWeight(.medium)
                    .foregroundColor(isDisabled ? DesignSystem.textSecondary.opacity(0.3) : (isActive || isHovered ? color : DesignSystem.textPrimary))
                
                Text("[ \(shortcut) ]")
                    .font(DesignSystem.monoSmall)
                    .foregroundColor(isDisabled ? DesignSystem.textSecondary.opacity(0.2) : DesignSystem.textSecondary.opacity(0.5))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                isActive ? color.opacity(0.15) : (isHovered && !isDisabled ? color.opacity(0.08) : Color.clear)
            )
            .overlay(
                Rectangle()
                    .stroke(isActive ? color.opacity(0.5) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .onHover { hovering in
            isHovered = hovering
            if hovering && !isDisabled {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}

// MARK: - Save Dialog

struct SaveDialogView: View {
    @Binding var fileName: String
    let isVideo: Bool
    let timestamp: Date
    let onSave: () -> Void
    let onCancel: () -> Void
    
    @ObservedObject private var settings = AppSettings.shared
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(isVideo ? "/ SAVE VIDEO" : "/ SAVE PHOTO")
                    .font(DesignSystem.monoTitle)
                    .foregroundColor(DesignSystem.textPrimary)
                
                Spacer()
                
                Text(isVideo ? ".MOV" : ".\(settings.imageFormat.fileExtension.uppercased())")
                    .font(DesignSystem.mono)
                    .foregroundColor(isVideo ? DesignSystem.accentOrange : DesignSystem.accentBlue)
            }
            .padding(20)
            .background(DesignSystem.bgSecondary)
            
            Divider()
                .background(DesignSystem.border)
            
            // Content
            VStack(alignment: .leading, spacing: 20) {
                // Name Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("/ NAME")
                        .font(DesignSystem.monoSmall)
                        .foregroundColor(DesignSystem.textSecondary)
                    
                    TextField("", text: $fileName, prompt: Text("optional").foregroundColor(DesignSystem.textSecondary.opacity(0.5)))
                        .font(DesignSystem.mono)
                        .foregroundColor(DesignSystem.textPrimary)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(DesignSystem.bg)
                        .overlay(
                            Rectangle()
                                .stroke(DesignSystem.border, lineWidth: 1)
                        )
                        .focused($isTextFieldFocused)
                        .onSubmit { onSave() }
                }
                
                // Filename Preview
                VStack(alignment: .leading, spacing: 8) {
                    Text("/ FILENAME")
                        .font(DesignSystem.monoSmall)
                        .foregroundColor(DesignSystem.textSecondary)
                    
                    Text(settings.generateFileName(baseName: fileName, isVideo: isVideo, timestamp: timestamp))
                        .font(DesignSystem.mono)
                        .foregroundColor(DesignSystem.accent)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(DesignSystem.bg)
                        .overlay(
                            Rectangle()
                                .stroke(DesignSystem.accent.opacity(0.3), lineWidth: 1)
                        )
                }
                
                // Path
                VStack(alignment: .leading, spacing: 8) {
                    Text("/ PATH")
                        .font(DesignSystem.monoSmall)
                        .foregroundColor(DesignSystem.textSecondary)
                    
                    Text(settings.savePath)
                        .font(DesignSystem.monoSmall)
                        .foregroundColor(DesignSystem.textSecondary.opacity(0.7))
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
            .padding(20)
            
            Divider()
                .background(DesignSystem.border)
            
            // Actions
            HStack(spacing: 16) {
                Button(action: onCancel) {
                    Text("[ ESC ] CANCEL")
                        .font(DesignSystem.mono)
                        .foregroundColor(DesignSystem.textSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(DesignSystem.bg)
                        .overlay(
                            Rectangle()
                                .stroke(DesignSystem.border, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.escape)
                
                Spacer()
                
                Button(action: onSave) {
                    Text("[ ⏎ ] SAVE")
                        .font(DesignSystem.mono)
                        .foregroundColor(DesignSystem.bg)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(DesignSystem.accent)
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.return)
            }
            .padding(20)
            .background(DesignSystem.bgSecondary)
        }
        .frame(width: 420)
        .background(DesignSystem.bgSecondary)
        .overlay(
            Rectangle()
                .stroke(DesignSystem.border, lineWidth: 1)
        )
        .onAppear {
            isTextFieldFocused = true
        }
    }
}
