//
//  UpdateChecker.swift
//  MuCapture
//
//  Checks for updates via GitHub API and provides upgrade action
//

import Foundation
import AppKit

class UpdateChecker: ObservableObject {
    @Published var updateAvailable = false
    @Published var latestVersion: String?
    @Published var isChecking = false

    private let repoOwner = "cvrt-gmbh"
    private let repoName = "mu-capture"
    private let cacheKey = "lastUpdateCheck"
    private let cachedVersionKey = "cachedLatestVersion"
    private let cacheValiditySeconds: TimeInterval = 24 * 60 * 60 // 24 hours

    private var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }

    init() {
        // Load cached state
        loadCachedState()
    }

    // MARK: - Public Methods

    func checkForUpdates(force: Bool = false) {
        // Skip if already checking
        guard !isChecking else { return }

        // Check cache validity (unless forced)
        if !force, let lastCheck = UserDefaults.standard.object(forKey: cacheKey) as? Date {
            let timeSinceLastCheck = Date().timeIntervalSince(lastCheck)
            if timeSinceLastCheck < cacheValiditySeconds {
                // Use cached result
                return
            }
        }

        isChecking = true

        let urlString = "https://api.github.com/repos/\(repoOwner)/\(repoName)/releases/latest"
        guard let url = URL(string: urlString) else {
            isChecking = false
            return
        }

        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isChecking = false

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let tagName = json["tag_name"] as? String else {
                    return
                }

                // Remove 'v' prefix if present (e.g., "v1.0.8" -> "1.0.8")
                let latestVersion = tagName.hasPrefix("v") ? String(tagName.dropFirst()) : tagName

                self?.latestVersion = latestVersion
                self?.updateAvailable = self?.isNewerVersion(latestVersion) ?? false

                // Cache the result
                UserDefaults.standard.set(Date(), forKey: self?.cacheKey ?? "")
                UserDefaults.standard.set(latestVersion, forKey: self?.cachedVersionKey ?? "")
            }
        }.resume()
    }

    func runBrewUpgrade() {
        let script = """
        tell application "Terminal"
            activate
            do script "brew upgrade cvrt-gmbh/cask/mucapture"
        end tell
        """

        if let appleScript = NSAppleScript(source: script) {
            var error: NSDictionary?
            appleScript.executeAndReturnError(&error)

            if let error = error {
                print("AppleScript error: \(error)")
            }
        }
    }

    // MARK: - Private Methods

    private func loadCachedState() {
        if let cachedVersion = UserDefaults.standard.string(forKey: cachedVersionKey),
           let lastCheck = UserDefaults.standard.object(forKey: cacheKey) as? Date {
            let timeSinceLastCheck = Date().timeIntervalSince(lastCheck)
            if timeSinceLastCheck < cacheValiditySeconds {
                latestVersion = cachedVersion
                updateAvailable = isNewerVersion(cachedVersion)
            }
        }
    }

    private func isNewerVersion(_ remote: String) -> Bool {
        let currentParts = currentVersion.split(separator: ".").compactMap { Int($0) }
        let remoteParts = remote.split(separator: ".").compactMap { Int($0) }

        // Pad arrays to same length
        let maxLength = max(currentParts.count, remoteParts.count)
        let current = currentParts + Array(repeating: 0, count: maxLength - currentParts.count)
        let latest = remoteParts + Array(repeating: 0, count: maxLength - remoteParts.count)

        for i in 0..<maxLength {
            if latest[i] > current[i] {
                return true
            } else if latest[i] < current[i] {
                return false
            }
        }

        return false
    }
}
