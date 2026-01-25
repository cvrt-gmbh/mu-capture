//
//  SettingsView.swift
//  MikroskopCapture
//
//  Einstellungen für Gerät, Speicherpfad und Dateinamen
//  Design: Clean 8-bit / Retro Terminal Style
//

import SwiftUI
import AVFoundation

struct SettingsView: View {
    @ObservedObject private var settings = AppSettings.shared
    @StateObject private var cameraManager = CameraManager()
    
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab Bar - always visible
            HStack(spacing: 0) {
                TabButton(title: "DEVICE", index: 0, selectedTab: $selectedTab)
                TabButton(title: "STORAGE", index: 1, selectedTab: $selectedTab)
                TabButton(title: "NAMING", index: 2, selectedTab: $selectedTab)
                TabButton(title: "KEYS", index: 3, selectedTab: $selectedTab)
                TabButton(title: "FEEDBACK", index: 4, selectedTab: $selectedTab)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(DesignSystem.bgSecondary)
            
            Divider()
                .background(DesignSystem.border)
            
            // Content - stretches to fill available space
            Group {
                switch selectedTab {
                case 0:
                    deviceTab
                case 1:
                    storageTab
                case 2:
                    namingTab
                case 3:
                    keysTab
                case 4:
                    feedbackTab
                default:
                    deviceTab
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(DesignSystem.bg)
        }
        .frame(minWidth: 500, minHeight: 400)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.bg)
        .onAppear {
            cameraManager.discoverDevices()
        }
    }
    
    // MARK: - Device Tab
    
    private var deviceTab: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "PREFERRED DEVICE")
            
            // Explanation
            Text("Device to use on app startup. Click device name in header to switch during use.")
                .font(DesignSystem.monoSmall)
                .foregroundColor(DesignSystem.textSecondary.opacity(0.7))
                .padding(.bottom, 8)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(cameraManager.availableDevices, id: \.uniqueID) { device in
                    DeviceRow(
                        name: device.localizedName,
                        isExternal: device.deviceType == .external,
                        isSelected: settings.preferredDeviceID == device.uniqueID,
                        action: {
                            settings.preferredDeviceID = device.uniqueID
                        }
                    )
                }
                
                if cameraManager.availableDevices.isEmpty {
                    HStack(spacing: 8) {
                        Text("●")
                            .font(.system(size: 8))
                            .foregroundColor(DesignSystem.accentOrange)
                        Text("No devices found")
                            .font(DesignSystem.mono)
                            .foregroundColor(DesignSystem.textSecondary)
                    }
                    .padding(.vertical, 8)
                }
                
                // Auto option
                DeviceRow(
                    name: "AUTO (first external)",
                    isExternal: false,
                    isSelected: settings.preferredDeviceID == nil,
                    action: {
                        settings.preferredDeviceID = nil
                    }
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            Button(action: { cameraManager.discoverDevices() }) {
                Text("[ REFRESH ]")
                    .font(DesignSystem.monoSmall)
                    .foregroundColor(DesignSystem.textSecondary)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(24)
    }
    
    // MARK: - Storage Tab
    
    private var storageTab: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "SAVE PATH")
            
            HStack(spacing: 12) {
                Text(settings.savePath)
                    .font(DesignSystem.monoSmall)
                    .foregroundColor(DesignSystem.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(DesignSystem.bgSecondary)
                    .overlay(
                        Rectangle()
                            .stroke(DesignSystem.border, lineWidth: 1)
                    )
                
                Button(action: selectFolder) {
                    Text("...")
                        .font(DesignSystem.mono)
                        .foregroundColor(DesignSystem.textPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(DesignSystem.bgSecondary)
                        .overlay(
                            Rectangle()
                                .stroke(DesignSystem.border, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
            
            // Status
            HStack(spacing: 8) {
                Text("●")
                    .font(.system(size: 8))
                    .foregroundColor(folderExists ? DesignSystem.accent : DesignSystem.danger)
                Text(folderExists ? "Path exists" : "Path not found")
                    .font(DesignSystem.monoSmall)
                    .foregroundColor(DesignSystem.textSecondary)
            }
            
            Divider()
                .background(DesignSystem.border)
                .padding(.vertical, 8)
            
            SectionHeader(title: "FORMATS")
            
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("/ IMAGE")
                        .font(DesignSystem.monoSmall)
                        .foregroundColor(DesignSystem.textSecondary)
                    
                    HStack(spacing: 8) {
                        ForEach(AppSettings.ImageFormat.allCases) { format in
                            FormatButton(
                                label: format.rawValue,
                                isSelected: settings.imageFormat == format,
                                action: { settings.imageFormat = format }
                            )
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("/ VIDEO")
                        .font(DesignSystem.monoSmall)
                        .foregroundColor(DesignSystem.textSecondary)
                    
                    HStack(spacing: 8) {
                        ForEach(AppSettings.VideoFormat.allCases) { format in
                            FormatButton(
                                label: format.rawValue,
                                isSelected: settings.videoFormat == format,
                                action: { settings.videoFormat = format }
                            )
                        }
                    }
                }
                
                Spacer()
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(24)
    }
    
    // MARK: - Naming Tab
    
    private var namingTab: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "FILE NAMING")
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("/ PREFIX")
                        .font(DesignSystem.monoSmall)
                        .foregroundColor(DesignSystem.textSecondary)
                    
                    TextField("", text: $settings.filePrefix, prompt: Text("optional").foregroundColor(DesignSystem.textSecondary.opacity(0.4)))
                        .font(DesignSystem.mono)
                        .foregroundColor(DesignSystem.textPrimary)
                        .textFieldStyle(.plain)
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(DesignSystem.bgSecondary)
                        .overlay(
                            Rectangle()
                                .stroke(DesignSystem.border, lineWidth: 1)
                        )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("/ SUFFIX")
                        .font(DesignSystem.monoSmall)
                        .foregroundColor(DesignSystem.textSecondary)
                    
                    TextField("", text: $settings.fileSuffix, prompt: Text("optional").foregroundColor(DesignSystem.textSecondary.opacity(0.4)))
                        .font(DesignSystem.mono)
                        .foregroundColor(DesignSystem.textPrimary)
                        .textFieldStyle(.plain)
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(DesignSystem.bgSecondary)
                        .overlay(
                            Rectangle()
                                .stroke(DesignSystem.border, lineWidth: 1)
                        )
                }
            }
            
            Divider()
                .background(DesignSystem.border)
                .padding(.vertical, 8)
            
            // Date Toggle
            HStack {
                Text("/ DATE IN FILENAME")
                    .font(DesignSystem.monoSmall)
                    .foregroundColor(DesignSystem.textSecondary)
                
                Spacer()
                
                Button(action: { settings.includeDate.toggle() }) {
                    Text(settings.includeDate ? "[ ON ]" : "[ OFF ]")
                        .font(DesignSystem.mono)
                        .foregroundColor(settings.includeDate ? DesignSystem.accent : DesignSystem.textSecondary)
                }
                .buttonStyle(.plain)
            }
            
            if settings.includeDate {
                VStack(alignment: .leading, spacing: 8) {
                    Text("/ FORMAT")
                        .font(DesignSystem.monoSmall)
                        .foregroundColor(DesignSystem.textSecondary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        DateFormatRow(format: "yyyyMMdd-HHmmss", example: "20260107-153000", isSelected: settings.dateFormat == "yyyyMMdd-HHmmss") {
                            settings.dateFormat = "yyyyMMdd-HHmmss"
                        }
                        DateFormatRow(format: "yyyy-MM-dd_HH-mm-ss", example: "2026-01-07_15-30-00", isSelected: settings.dateFormat == "yyyy-MM-dd_HH-mm-ss") {
                            settings.dateFormat = "yyyy-MM-dd_HH-mm-ss"
                        }
                        DateFormatRow(format: "yyyyMMdd_HHmmss", example: "20260107_153000", isSelected: settings.dateFormat == "yyyyMMdd_HHmmss") {
                            settings.dateFormat = "yyyyMMdd_HHmmss"
                        }
                        DateFormatRow(format: "dd-MM-yyyy", example: "07-01-2026", isSelected: settings.dateFormat == "dd-MM-yyyy") {
                            settings.dateFormat = "dd-MM-yyyy"
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            Divider()
                .background(DesignSystem.border)
                .padding(.vertical, 8)
            
            // Counter Toggle
            HStack {
                Text("/ COUNTER IN FILENAME")
                    .font(DesignSystem.monoSmall)
                    .foregroundColor(DesignSystem.textSecondary)
                
                Spacer()
                
                Button(action: { settings.includeCounter.toggle() }) {
                    Text(settings.includeCounter ? "[ ON ]" : "[ OFF ]")
                        .font(DesignSystem.mono)
                        .foregroundColor(settings.includeCounter ? DesignSystem.accent : DesignSystem.textSecondary)
                }
                .buttonStyle(.plain)
            }
            
            if settings.includeCounter {
                HStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("/ DIGITS")
                            .font(DesignSystem.monoSmall)
                            .foregroundColor(DesignSystem.textSecondary)
                        
                        HStack(spacing: 8) {
                            ForEach([3, 4, 5, 6], id: \.self) { digits in
                                Button(action: { settings.counterDigits = digits }) {
                                    Text("\(digits)")
                                        .font(DesignSystem.monoSmall)
                                        .foregroundColor(settings.counterDigits == digits ? DesignSystem.bg : DesignSystem.textSecondary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(settings.counterDigits == digits ? DesignSystem.accent : Color.clear)
                                        .overlay(
                                            Rectangle()
                                                .stroke(settings.counterDigits == digits ? DesignSystem.accent : DesignSystem.border, lineWidth: 1)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("/ CURRENT")
                            .font(DesignSystem.monoSmall)
                            .foregroundColor(DesignSystem.textSecondary)
                        
                        HStack(spacing: 16) {
                            HStack(spacing: 4) {
                                Text("FOTO:")
                                    .font(DesignSystem.monoSmall)
                                    .foregroundColor(DesignSystem.textSecondary)
                                Text(String(format: "%0\(settings.counterDigits)d", settings.photoCounter))
                                    .font(DesignSystem.mono)
                                    .foregroundColor(DesignSystem.accentBlue)
                            }
                            
                            HStack(spacing: 4) {
                                Text("VIDEO:")
                                    .font(DesignSystem.monoSmall)
                                    .foregroundColor(DesignSystem.textSecondary)
                                Text(String(format: "%0\(settings.counterDigits)d", settings.videoCounter))
                                    .font(DesignSystem.mono)
                                    .foregroundColor(DesignSystem.accentOrange)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: { settings.resetCounters() }) {
                        Text("[ RESET ]")
                            .font(DesignSystem.monoSmall)
                            .foregroundColor(DesignSystem.textSecondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Spacer()
            
            // Preview
            VStack(alignment: .leading, spacing: 8) {
                Text("/ PREVIEW")
                    .font(DesignSystem.monoSmall)
                    .foregroundColor(DesignSystem.textSecondary)
                
                Text(settings.generateFileName(baseName: "sample", isVideo: false))
                    .font(DesignSystem.mono)
                    .foregroundColor(DesignSystem.accent)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(24)
    }
    
    // MARK: - Feedback Tab
    
    private var feedbackTab: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "CAPTURE FEEDBACK")
            
            Text("Visual and audio feedback when capturing photos or videos.")
                .font(DesignSystem.monoSmall)
                .foregroundColor(DesignSystem.textSecondary.opacity(0.7))
                .padding(.bottom, 8)
            
            // Flash Toggle
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("/ SCREEN FLASH")
                        .font(DesignSystem.mono)
                        .foregroundColor(DesignSystem.textPrimary)
                    
                    Text("Brief white flash on capture")
                        .font(DesignSystem.monoSmall)
                        .foregroundColor(DesignSystem.textSecondary.opacity(0.7))
                }
                
                Spacer()
                
                Button(action: { settings.flashEnabled.toggle() }) {
                    Text(settings.flashEnabled ? "[ ON ]" : "[ OFF ]")
                        .font(DesignSystem.mono)
                        .foregroundColor(settings.flashEnabled ? DesignSystem.accent : DesignSystem.textSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 8)
            
            Divider()
                .background(DesignSystem.border)
            
            // Sound Toggle
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("/ SHUTTER SOUND")
                        .font(DesignSystem.mono)
                        .foregroundColor(DesignSystem.textPrimary)
                    
                    Text("Camera shutter sound on capture")
                        .font(DesignSystem.monoSmall)
                        .foregroundColor(DesignSystem.textSecondary.opacity(0.7))
                }
                
                Spacer()
                
                Button(action: { settings.soundEnabled.toggle() }) {
                    Text(settings.soundEnabled ? "[ ON ]" : "[ OFF ]")
                        .font(DesignSystem.mono)
                        .foregroundColor(settings.soundEnabled ? DesignSystem.accent : DesignSystem.textSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 8)
            
            Spacer()
            
            // Note
            HStack(spacing: 8) {
                Text("●")
                    .font(.system(size: 8))
                    .foregroundColor(DesignSystem.textSecondary)
                Text("Both options are disabled by default")
                    .font(DesignSystem.monoSmall)
                    .foregroundColor(DesignSystem.textSecondary.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(24)
    }
    
    // MARK: - Keys Tab
    
    private var keysTab: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "KEYBOARD SHORTCUTS")
            
            Text("Click on a key binding to change it. Press ESC to cancel.")
                .font(DesignSystem.monoSmall)
                .foregroundColor(DesignSystem.textSecondary.opacity(0.7))
                .padding(.bottom, 8)
            
            // Standard captures (with dialog)
            VStack(alignment: .leading, spacing: 12) {
                Text("/ CAPTURE (with naming dialog)")
                    .font(DesignSystem.monoSmall)
                    .foregroundColor(DesignSystem.textSecondary)
                
                KeyBindingRow(
                    label: "FOTO",
                    binding: $settings.photoKey,
                    color: DesignSystem.accentBlue
                )
                
                KeyBindingRow(
                    label: "VIDEO",
                    binding: $settings.videoKey,
                    color: DesignSystem.accentOrange
                )
            }
            
            Divider()
                .background(DesignSystem.border)
                .padding(.vertical, 8)
            
            // Quick captures (no dialog)
            VStack(alignment: .leading, spacing: 12) {
                Text("/ QUICK CAPTURE (auto-save, no dialog)")
                    .font(DesignSystem.monoSmall)
                    .foregroundColor(DesignSystem.textSecondary)
                
                KeyBindingRow(
                    label: "QUICK FOTO",
                    binding: $settings.quickPhotoKey,
                    color: DesignSystem.accentBlue
                )
                
                KeyBindingRow(
                    label: "QUICK VIDEO",
                    binding: $settings.quickVideoKey,
                    color: DesignSystem.accentOrange
                )
            }
            
            Spacer()
            
            // Reset button
            Button(action: { settings.resetKeybindings() }) {
                Text("[ RESET TO DEFAULTS ]")
                    .font(DesignSystem.monoSmall)
                    .foregroundColor(DesignSystem.textSecondary)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(24)
    }
    
    // MARK: - Helpers
    
    private var folderExists: Bool {
        let path = NSString(string: settings.savePath).expandingTildeInPath
        var isDirectory: ObjCBool = false
        return FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) && isDirectory.boolValue
    }
    
    private func selectFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        panel.prompt = "Select"
        
        if panel.runModal() == .OK, let url = panel.url {
            settings.savePath = url.path
        }
    }
}

// MARK: - Helper Views

struct TabButton: View {
    let title: String
    let index: Int
    @Binding var selectedTab: Int
    
    var body: some View {
        Button(action: { selectedTab = index }) {
            Text("/ \(title)")
                .font(DesignSystem.mono)
                .foregroundColor(selectedTab == index ? DesignSystem.accent : DesignSystem.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(selectedTab == index ? DesignSystem.accent.opacity(0.1) : Color.clear)
        }
        .buttonStyle(.plain)
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text("/ \(title)")
            .font(DesignSystem.monoSmall)
            .foregroundColor(DesignSystem.textSecondary)
            .padding(.bottom, 4)
    }
}

struct DeviceRow: View {
    let name: String
    let isExternal: Bool
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(isSelected ? "●" : "○")
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? DesignSystem.accent : DesignSystem.textSecondary)
                
                Text(name)
                    .font(DesignSystem.mono)
                    .foregroundColor(isSelected ? DesignSystem.textPrimary : DesignSystem.textSecondary)
                
                if isExternal {
                    Text("EXT")
                        .font(DesignSystem.monoSmall)
                        .foregroundColor(DesignSystem.accentBlue)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .overlay(
                            Rectangle()
                                .stroke(DesignSystem.accentBlue.opacity(0.5), lineWidth: 1)
                        )
                }
                
                Spacer()
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }
}

struct FormatButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(DesignSystem.monoSmall)
                .foregroundColor(isSelected ? DesignSystem.bg : DesignSystem.textSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? DesignSystem.accent : Color.clear)
                .overlay(
                    Rectangle()
                        .stroke(isSelected ? DesignSystem.accent : DesignSystem.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

struct DateFormatRow: View {
    let format: String
    let example: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(isSelected ? "●" : "○")
                    .font(.system(size: 8))
                    .foregroundColor(isSelected ? DesignSystem.accent : DesignSystem.textSecondary)
                
                Text(example)
                    .font(DesignSystem.monoSmall)
                    .foregroundColor(isSelected ? DesignSystem.textPrimary : DesignSystem.textSecondary)
                
                Spacer()
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Key Binding Row

struct KeyBindingRow: View {
    let label: String
    @Binding var binding: KeyBinding
    let color: Color
    
    @State private var isRecording = false
    @State private var eventMonitor: Any?
    
    var body: some View {
        HStack(spacing: 16) {
            Text(label)
                .font(DesignSystem.mono)
                .foregroundColor(DesignSystem.textPrimary)
                .frame(width: 120, alignment: .leading)
            
            Button(action: startRecording) {
                Text(isRecording ? "PRESS KEY..." : "[ \(binding.displayString) ]")
                    .font(DesignSystem.mono)
                    .foregroundColor(isRecording ? DesignSystem.accentOrange : color)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(isRecording ? DesignSystem.accentOrange.opacity(0.1) : DesignSystem.bg)
                    .overlay(
                        Rectangle()
                            .stroke(isRecording ? DesignSystem.accentOrange : DesignSystem.border, lineWidth: 1)
                    )
                    .animation(.easeInOut(duration: 0.15), value: isRecording)
            }
            .buttonStyle(.plain)
            
            Spacer()
        }
    }
    
    private func startRecording() {
        isRecording = true
        
        // Add event monitor to capture next key press
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // ESC cancels
            if event.keyCode == 53 { // ESC key
                self.stopRecording()
                return nil
            }
            
            // Capture the key binding
            let newBinding = KeyBinding.from(event)
            self.binding = newBinding
            self.stopRecording()
            return nil
        }
    }
    
    private func stopRecording() {
        isRecording = false
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
}
