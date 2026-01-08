//
//  ContentView.swift
//  MikroskopCapture
//
//  Hauptansicht mit Live-Preview und großen Buttons
//  Design: Clean 8-bit / Retro Terminal Style
//

import SwiftUI
import AVFoundation

// MARK: - Design Constants

struct DesignSystem {
    // Monospace Font
    static let mono = Font.custom("SF Mono", size: 14)
    static let monoSmall = Font.custom("SF Mono", size: 12)
    static let monoLarge = Font.custom("SF Mono", size: 16)
    static let monoXL = Font.custom("SF Mono", size: 20)
    static let monoTitle = Font.custom("SF Mono", size: 20)
    
    // Colors - Muted, clean
    static let bg = Color(hex: "0D0D0D")
    static let bgSecondary = Color(hex: "1A1A1A")
    static let border = Color(hex: "333333")
    static let textPrimary = Color(hex: "E5E5E5")
    static let textSecondary = Color(hex: "808080")
    static let accent = Color(hex: "00FF88")  // Terminal green
    static let accentBlue = Color(hex: "4A9EFF")
    static let accentOrange = Color(hex: "FF9F43")
    static let danger = Color(hex: "FF5555")
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
        
        switch event.charactersIgnoringModifiers?.lowercased() {
        case "f":
            if cameraManager.previewImage != nil && !cameraManager.isRecording {
                capturePhoto()
                return nil
            }
        case "v":
            if cameraManager.previewImage != nil || cameraManager.isRecording {
                toggleVideoRecording()
                return nil
            }
        default:
            break
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
                Text("v0.2.0")
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
                shortcut: "F",
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
                shortcut: "V",
                color: cameraManager.isRecording ? DesignSystem.danger : DesignSystem.accentOrange,
                isActive: cameraManager.isRecording,
                isDisabled: cameraManager.previewImage == nil && !cameraManager.isRecording,
                action: toggleVideoRecording
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
            pendingVideoURL = url
            pendingImage = nil
            isVideo = true
            customFileName = ""
            captureTimestamp = Date()
            showingSaveDialog = true
        }
    }
    
    private func capturePhoto() {
        cameraManager.capturePhoto()
    }
    
    private func toggleVideoRecording() {
        if cameraManager.isRecording {
            cameraManager.stopVideoRecording()
        } else {
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
        let fileName = settings.generateFileName(baseName: customFileName, isVideo: isVideo, timestamp: captureTimestamp ?? Date())
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
