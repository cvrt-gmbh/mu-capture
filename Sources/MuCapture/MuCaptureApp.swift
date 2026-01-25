//
//  MuCaptureApp.swift
//  μCapture
//
//  Native macOS app for capturing microscope images and videos
//

import SwiftUI
import AppKit

@main
struct MuCaptureApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var showSettings = false
    
    init() {
        // Register bundled fonts at app startup
        FontLoader.loadBundledFonts()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(showSettings: $showSettings)
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) { }
            
            // Settings menu item (Cmd+,)
            CommandGroup(after: .appSettings) {
                Button("Settings...") {
                    showSettings = true
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
        
        // Settings Window
        Window("Settings", id: "settings") {
            SettingsView()
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 480, height: 380)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

// MARK: - Font Loader

enum FontLoader {
    static func loadBundledFonts() {
        let fontNames = [
            "JetBrainsMonoNerdFont-Regular",
            "JetBrainsMonoNerdFont-Medium",
            "JetBrainsMonoNerdFont-Bold"
        ]
        
        for fontName in fontNames {
            if let fontURL = Bundle.main.url(forResource: fontName, withExtension: "ttf", subdirectory: "Fonts") {
                var errorRef: Unmanaged<CFError>?
                if !CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &errorRef) {
                    if let error = errorRef?.takeRetainedValue() {
                        print("⚠️ Failed to load font \(fontName): \(error)")
                    }
                } else {
                    print("✅ Loaded font: \(fontName)")
                }
            } else {
                print("⚠️ Font file not found: \(fontName).ttf")
            }
        }
    }
}
