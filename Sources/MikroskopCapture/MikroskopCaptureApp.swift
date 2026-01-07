//
//  MikroskopCaptureApp.swift
//  MikroskopCapture
//
//  Einfache App zum Aufnehmen von Mikroskop-Bildern und Videos
//

import SwiftUI

@main
struct MikroskopCaptureApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var showSettings = false
    
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
