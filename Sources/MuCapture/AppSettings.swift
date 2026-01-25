//
//  AppSettings.swift
//  MikroskopCapture
//
//  Einstellungen der App
//

import Foundation
import SwiftUI
import Carbon.HIToolbox

// MARK: - KeyBinding Struct

struct KeyBinding: Codable, Equatable {
    var keyCode: UInt16      // Virtual key code
    var keyChar: String      // Display character ("F", "SPACE", etc.)
    var shift: Bool
    var command: Bool
    var option: Bool
    var control: Bool
    
    init(keyCode: UInt16 = 0, keyChar: String = "", shift: Bool = false, command: Bool = false, option: Bool = false, control: Bool = false) {
        self.keyCode = keyCode
        self.keyChar = keyChar
        self.shift = shift
        self.command = command
        self.option = option
        self.control = control
    }
    
    /// Display string like "⇧F", "⌘S", "SPACE"
    var displayString: String {
        var parts: [String] = []
        if control { parts.append("⌃") }
        if option { parts.append("⌥") }
        if shift { parts.append("⇧") }
        if command { parts.append("⌘") }
        parts.append(keyChar.uppercased())
        return parts.joined()
    }
    
    /// Check if this binding matches an NSEvent
    func matches(_ event: NSEvent) -> Bool {
        let flags = event.modifierFlags
        return event.keyCode == keyCode &&
               flags.contains(.shift) == shift &&
               flags.contains(.command) == command &&
               flags.contains(.option) == option &&
               flags.contains(.control) == control
    }
    
    /// Create from NSEvent
    static func from(_ event: NSEvent) -> KeyBinding {
        let flags = event.modifierFlags
        let keyChar = keyCharFromKeyCode(event.keyCode)
        
        return KeyBinding(
            keyCode: event.keyCode,
            keyChar: keyChar,
            shift: flags.contains(.shift),
            command: flags.contains(.command),
            option: flags.contains(.option),
            control: flags.contains(.control)
        )
    }
    
    /// Convert keyCode to readable character
    private static func keyCharFromKeyCode(_ keyCode: UInt16) -> String {
        switch Int(keyCode) {
        case kVK_Space: return "SPACE"
        case kVK_Return: return "⏎"
        case kVK_Tab: return "TAB"
        case kVK_Delete: return "⌫"
        case kVK_Escape: return "ESC"
        case kVK_LeftArrow: return "←"
        case kVK_RightArrow: return "→"
        case kVK_UpArrow: return "↑"
        case kVK_DownArrow: return "↓"
        case kVK_F1: return "F1"
        case kVK_F2: return "F2"
        case kVK_F3: return "F3"
        case kVK_F4: return "F4"
        case kVK_F5: return "F5"
        case kVK_F6: return "F6"
        case kVK_F7: return "F7"
        case kVK_F8: return "F8"
        case kVK_F9: return "F9"
        case kVK_F10: return "F10"
        case kVK_F11: return "F11"
        case kVK_F12: return "F12"
        case kVK_ANSI_A: return "A"
        case kVK_ANSI_B: return "B"
        case kVK_ANSI_C: return "C"
        case kVK_ANSI_D: return "D"
        case kVK_ANSI_E: return "E"
        case kVK_ANSI_F: return "F"
        case kVK_ANSI_G: return "G"
        case kVK_ANSI_H: return "H"
        case kVK_ANSI_I: return "I"
        case kVK_ANSI_J: return "J"
        case kVK_ANSI_K: return "K"
        case kVK_ANSI_L: return "L"
        case kVK_ANSI_M: return "M"
        case kVK_ANSI_N: return "N"
        case kVK_ANSI_O: return "O"
        case kVK_ANSI_P: return "P"
        case kVK_ANSI_Q: return "Q"
        case kVK_ANSI_R: return "R"
        case kVK_ANSI_S: return "S"
        case kVK_ANSI_T: return "T"
        case kVK_ANSI_U: return "U"
        case kVK_ANSI_V: return "V"
        case kVK_ANSI_W: return "W"
        case kVK_ANSI_X: return "X"
        case kVK_ANSI_Y: return "Y"
        case kVK_ANSI_Z: return "Z"
        case kVK_ANSI_0: return "0"
        case kVK_ANSI_1: return "1"
        case kVK_ANSI_2: return "2"
        case kVK_ANSI_3: return "3"
        case kVK_ANSI_4: return "4"
        case kVK_ANSI_5: return "5"
        case kVK_ANSI_6: return "6"
        case kVK_ANSI_7: return "7"
        case kVK_ANSI_8: return "8"
        case kVK_ANSI_9: return "9"
        default:
            // Fallback to character from event
            return "?"
        }
    }
    
    // MARK: - Default Bindings
    
    static let defaultPhoto = KeyBinding(keyCode: UInt16(kVK_ANSI_F), keyChar: "F")
    static let defaultVideo = KeyBinding(keyCode: UInt16(kVK_ANSI_V), keyChar: "V")
    static let defaultQuickPhoto = KeyBinding(keyCode: UInt16(kVK_ANSI_F), keyChar: "F", shift: true)
    static let defaultQuickVideo = KeyBinding(keyCode: UInt16(kVK_ANSI_V), keyChar: "V", shift: true)
}

class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    // MARK: - Keys
    private enum Keys {
        static let savePath = "savePath"
        static let preferredDeviceID = "preferredDeviceID"
        static let filePrefix = "filePrefix"
        static let fileSuffix = "fileSuffix"
        static let imageFormat = "imageFormat"
        static let videoFormat = "videoFormat"
        static let includeDate = "includeDate"
        static let dateFormat = "dateFormat"
        static let photoKey = "photoKey"
        static let videoKey = "videoKey"
        static let quickPhotoKey = "quickPhotoKey"
        static let quickVideoKey = "quickVideoKey"
        // Feedback settings
        static let flashEnabled = "flashEnabled"
        static let soundEnabled = "soundEnabled"
        // Counter settings
        static let includeCounter = "includeCounter"
        static let photoCounter = "photoCounter"
        static let videoCounter = "videoCounter"
        static let counterDigits = "counterDigits"
    }
    
    // MARK: - Published Properties
    
    @Published var savePath: String {
        didSet { UserDefaults.standard.set(savePath, forKey: Keys.savePath) }
    }
    
    @Published var preferredDeviceID: String? {
        didSet { UserDefaults.standard.set(preferredDeviceID, forKey: Keys.preferredDeviceID) }
    }
    
    @Published var filePrefix: String {
        didSet { UserDefaults.standard.set(filePrefix, forKey: Keys.filePrefix) }
    }
    
    @Published var fileSuffix: String {
        didSet { UserDefaults.standard.set(fileSuffix, forKey: Keys.fileSuffix) }
    }
    
    @Published var imageFormat: ImageFormat {
        didSet { UserDefaults.standard.set(imageFormat.rawValue, forKey: Keys.imageFormat) }
    }
    
    @Published var videoFormat: VideoFormat {
        didSet { UserDefaults.standard.set(videoFormat.rawValue, forKey: Keys.videoFormat) }
    }
    
    @Published var includeDate: Bool {
        didSet { UserDefaults.standard.set(includeDate, forKey: Keys.includeDate) }
    }
    
    @Published var dateFormat: String {
        didSet { UserDefaults.standard.set(dateFormat, forKey: Keys.dateFormat) }
    }
    
    // MARK: - Keybindings
    
    @Published var photoKey: KeyBinding {
        didSet { saveKeyBinding(photoKey, forKey: Keys.photoKey) }
    }
    
    @Published var videoKey: KeyBinding {
        didSet { saveKeyBinding(videoKey, forKey: Keys.videoKey) }
    }
    
    @Published var quickPhotoKey: KeyBinding {
        didSet { saveKeyBinding(quickPhotoKey, forKey: Keys.quickPhotoKey) }
    }
    
    @Published var quickVideoKey: KeyBinding {
        didSet { saveKeyBinding(quickVideoKey, forKey: Keys.quickVideoKey) }
    }
    
    // MARK: - Feedback Settings (disabled by default)
    
    @Published var flashEnabled: Bool {
        didSet { UserDefaults.standard.set(flashEnabled, forKey: Keys.flashEnabled) }
    }
    
    @Published var soundEnabled: Bool {
        didSet { UserDefaults.standard.set(soundEnabled, forKey: Keys.soundEnabled) }
    }
    
    // MARK: - Counter Settings
    
    @Published var includeCounter: Bool {
        didSet { UserDefaults.standard.set(includeCounter, forKey: Keys.includeCounter) }
    }
    
    @Published var photoCounter: Int {
        didSet { UserDefaults.standard.set(photoCounter, forKey: Keys.photoCounter) }
    }
    
    @Published var videoCounter: Int {
        didSet { UserDefaults.standard.set(videoCounter, forKey: Keys.videoCounter) }
    }
    
    @Published var counterDigits: Int {
        didSet { UserDefaults.standard.set(counterDigits, forKey: Keys.counterDigits) }
    }
    
    // MARK: - Enums
    
    enum ImageFormat: String, CaseIterable, Identifiable {
        case jpeg = "JPEG"
        case png = "PNG"
        case tiff = "TIFF"
        
        var id: String { rawValue }
        
        var fileExtension: String {
            switch self {
            case .jpeg: return "jpg"
            case .png: return "png"
            case .tiff: return "tiff"
            }
        }
    }
    
    enum VideoFormat: String, CaseIterable, Identifiable {
        case mov = "MOV"
        case mp4 = "MP4"
        
        var id: String { rawValue }
        
        var fileExtension: String {
            switch self {
            case .mov: return "mov"
            case .mp4: return "mp4"
            }
        }
    }
    
    // MARK: - Init
    
    private init() {
        // Lade gespeicherte Werte oder setze Defaults
        let defaults = UserDefaults.standard
        
        self.savePath = defaults.string(forKey: Keys.savePath) 
            ?? NSSearchPathForDirectoriesInDomains(.picturesDirectory, .userDomainMask, true).first 
            ?? "~/Pictures"
        
        self.preferredDeviceID = defaults.string(forKey: Keys.preferredDeviceID)
        
        self.filePrefix = defaults.string(forKey: Keys.filePrefix) ?? ""
        self.fileSuffix = defaults.string(forKey: Keys.fileSuffix) ?? ""
        
        self.imageFormat = ImageFormat(rawValue: defaults.string(forKey: Keys.imageFormat) ?? "") ?? .jpeg
        self.videoFormat = VideoFormat(rawValue: defaults.string(forKey: Keys.videoFormat) ?? "") ?? .mov
        
        self.includeDate = defaults.object(forKey: Keys.includeDate) as? Bool ?? true
        self.dateFormat = defaults.string(forKey: Keys.dateFormat) ?? "yyyy-MM-dd_HH-mm-ss"
        
        // Load keybindings (must use inline loading since helper methods not available yet)
        self.photoKey = Self.loadKeyBindingStatic(forKey: Keys.photoKey, default: .defaultPhoto)
        self.videoKey = Self.loadKeyBindingStatic(forKey: Keys.videoKey, default: .defaultVideo)
        self.quickPhotoKey = Self.loadKeyBindingStatic(forKey: Keys.quickPhotoKey, default: .defaultQuickPhoto)
        self.quickVideoKey = Self.loadKeyBindingStatic(forKey: Keys.quickVideoKey, default: .defaultQuickVideo)
        
        // Feedback settings - disabled by default
        self.flashEnabled = defaults.object(forKey: Keys.flashEnabled) as? Bool ?? false
        self.soundEnabled = defaults.object(forKey: Keys.soundEnabled) as? Bool ?? false
        
        // Counter settings
        self.includeCounter = defaults.object(forKey: Keys.includeCounter) as? Bool ?? false
        self.photoCounter = defaults.integer(forKey: Keys.photoCounter)  // defaults to 0
        self.videoCounter = defaults.integer(forKey: Keys.videoCounter)  // defaults to 0
        self.counterDigits = defaults.object(forKey: Keys.counterDigits) as? Int ?? 4
    }
    
    private static func loadKeyBindingStatic(forKey key: String, default defaultBinding: KeyBinding) -> KeyBinding {
        guard let data = UserDefaults.standard.data(forKey: key),
              let binding = try? JSONDecoder().decode(KeyBinding.self, from: data) else {
            return defaultBinding
        }
        return binding
    }
    
    // MARK: - Helper Methods
    
    /// Generiert Dateinamen mit optionalem fixiertem Zeitstempel
    func generateFileName(baseName: String, isVideo: Bool, timestamp: Date? = nil, incrementCounter: Bool = false) -> String {
        var components: [String] = []
        
        // Präfix
        if !filePrefix.isEmpty {
            components.append(filePrefix)
        }
        
        // Datum - verwende übergebenen Timestamp oder aktuelles Datum
        if includeDate {
            let formatter = DateFormatter()
            formatter.dateFormat = dateFormat
            let dateToUse = timestamp ?? Date()
            components.append(formatter.string(from: dateToUse))
        }
        
        // Counter
        if includeCounter {
            let counter = isVideo ? videoCounter : photoCounter
            let counterString = String(format: "%0\(counterDigits)d", counter)
            components.append(counterString)
            
            // Increment counter if requested (for actual saves, not previews)
            if incrementCounter {
                if isVideo {
                    videoCounter += 1
                } else {
                    photoCounter += 1
                }
            }
        }
        
        // Benutzername
        if !baseName.isEmpty {
            components.append(baseName)
        }
        
        // Suffix
        if !fileSuffix.isEmpty {
            components.append(fileSuffix)
        }
        
        let fileName = components.joined(separator: "_")
        let ext = isVideo ? videoFormat.fileExtension : imageFormat.fileExtension
        
        return "\(fileName).\(ext)"
    }
    
    /// Reset counters to zero
    func resetCounters() {
        photoCounter = 0
        videoCounter = 0
    }
    
    func fullPath(for fileName: String) -> URL {
        let baseURL: URL
        
        if savePath.hasPrefix("/") {
            baseURL = URL(fileURLWithPath: savePath)
        } else if savePath.hasPrefix("~") {
            let expanded = NSString(string: savePath).expandingTildeInPath
            baseURL = URL(fileURLWithPath: expanded)
        } else {
            baseURL = URL(fileURLWithPath: savePath)
        }
        
        return baseURL.appendingPathComponent(fileName)
    }
    
    // MARK: - KeyBinding Persistence
    
    private func saveKeyBinding(_ binding: KeyBinding, forKey key: String) {
        if let data = try? JSONEncoder().encode(binding) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func resetKeybindings() {
        photoKey = .defaultPhoto
        videoKey = .defaultVideo
        quickPhotoKey = .defaultQuickPhoto
        quickVideoKey = .defaultQuickVideo
    }
}
