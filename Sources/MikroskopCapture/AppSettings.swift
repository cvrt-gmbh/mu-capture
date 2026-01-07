//
//  AppSettings.swift
//  MikroskopCapture
//
//  Einstellungen der App
//

import Foundation
import SwiftUI

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
    }
    
    // MARK: - Helper Methods
    
    /// Generiert Dateinamen mit optionalem fixiertem Zeitstempel
    func generateFileName(baseName: String, isVideo: Bool, timestamp: Date? = nil) -> String {
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
}
