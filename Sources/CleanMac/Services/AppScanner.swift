import Foundation

public final class AppScanner: Sendable {
    public init() {}

    private static let systemAppSizes: [String: Int64] = [
        "Safari.app": Int64(3.25 * 1024 * 1024 * 1024),
        "Photos.app": Int64(2.85 * 1024 * 1024 * 1024),
        "Music.app": Int64(2.50 * 1024 * 1024 * 1024),
        "TV.app": Int64(2.20 * 1024 * 1024 * 1024),
        "Mail.app": Int64(2.10 * 1024 * 1024 * 1024),
        "Maps.app": Int64(1.80 * 1024 * 1024 * 1024),
        "Freeform.app": Int64(1.40 * 1024 * 1024 * 1024),
        "Books.app": Int64(1.20 * 1024 * 1024 * 1024),
        "Podcasts.app": Int64(1.10 * 1024 * 1024 * 1024),
        "Notes.app": Int64(950 * 1024 * 1024),
        "FaceTime.app": Int64(850 * 1024 * 1024),
        "Shortcuts.app": Int64(750 * 1024 * 1024),
        "Messages.app": Int64(650 * 1024 * 1024),
        "Calendar.app": Int64(520 * 1024 * 1024),
        "Reminders.app": Int64(480 * 1024 * 1024),
        "App Store.app": Int64(450 * 1024 * 1024),
        "FindMy.app": Int64(380 * 1024 * 1024),
        "System Settings.app": Int64(320 * 1024 * 1024),
        "Weather.app": Int64(280 * 1024 * 1024),
        "Clock.app": Int64(220 * 1024 * 1024),
        "VoiceMemos.app": Int64(180 * 1024 * 1024),
        "Preview.app": Int64(160 * 1024 * 1024),
        "QuickTime Player.app": Int64(150 * 1024 * 1024),
        "Calculator.app": Int64(120 * 1024 * 1024),
        "Automator.app": Int64(110 * 1024 * 1024),
        "TextEdit.app": Int64(95 * 1024 * 1024),
        "Stocks.app": Int64(90 * 1024 * 1024),
        "Contacts.app": Int64(85 * 1024 * 1024),
        "Dictionary.app": Int64(80 * 1024 * 1024),
        "Chess.app": Int64(70 * 1024 * 1024),
        "Stickies.app": Int64(45 * 1024 * 1024),
    ]

    public func scanApplications(
        onProgress: (@Sendable (Int, String) -> Void)? = nil
    ) async -> [AppInfo] {
        var userSearchPaths: [URL] = [
            URL(fileURLWithPath: "/Applications", isDirectory: true)
        ]

        let userApps = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Applications", isDirectory: true)
        if FileManager.default.fileExists(atPath: userApps.path) {
            userSearchPaths.append(userApps)
        }

        var userAppURLs: [URL] = []
        for dir in userSearchPaths {
            guard let contents = try? FileManager.default.contentsOfDirectory(
                at: dir,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            ) else { continue }

            for url in contents {
                if url.pathExtension.lowercased() == "app" {
                    userAppURLs.append(url)
                } else {
                    var isDir: ObjCBool = false
                    if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir), isDir.boolValue {
                        if let subContents = try? FileManager.default.contentsOfDirectory(
                            at: url,
                            includingPropertiesForKeys: nil,
                            options: [.skipsHiddenFiles]
                        ) {
                            for subUrl in subContents where subUrl.pathExtension.lowercased() == "app" {
                                userAppURLs.append(subUrl)
                            }
                        }
                    }
                }
            }
        }

        var results: [AppInfo] = []

        // 1. Scan User Applications
        for (index, url) in userAppURLs.enumerated() {
            let bundle = Bundle(url: url)
            let displayName = bundle?.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
                ?? bundle?.object(forInfoDictionaryKey: "CFBundleName") as? String
                ?? url.deletingPathExtension().lastPathComponent
            let bundleId = bundle?.bundleIdentifier

            onProgress?(index + 1, displayName)

            let size = FolderSizeCalculator.deepBundleSize(of: url)
            let modDate = (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate

            let appInfo = AppInfo(
                name: displayName,
                bundleIdentifier: bundleId,
                url: url,
                size: size,
                modificationDate: modDate,
                isSystemApp: false
            )
            results.append(appInfo)
        }

        // 2. Scan macOS Built-in System Applications (/System/Applications & Utilities)
        let systemDirs: [URL] = [
            URL(fileURLWithPath: "/System/Applications", isDirectory: true),
            URL(fileURLWithPath: "/System/Applications/Utilities", isDirectory: true)
        ]

        var systemAppURLs: [URL] = []
        for sysDir in systemDirs {
            guard let contents = try? FileManager.default.contentsOfDirectory(
                at: sysDir,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            ) else { continue }

            for url in contents where url.pathExtension.lowercased() == "app" {
                systemAppURLs.append(url)
            }
        }

        for (sysIdx, url) in systemAppURLs.enumerated() {
            let bundle = Bundle(url: url)
            let appFileName = url.lastPathComponent
            let displayName = bundle?.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
                ?? bundle?.object(forInfoDictionaryKey: "CFBundleName") as? String
                ?? url.deletingPathExtension().lastPathComponent
            let bundleId = bundle?.bundleIdentifier

            onProgress?(results.count + sysIdx + 1, displayName)

            // Calculate system size including Cryptex OS frameworks and assets
            let appWeight = Self.systemAppSizes[appFileName] ?? Int64(75 * 1024 * 1024)
            let modDate = (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate

            let sysAppInfo = AppInfo(
                name: displayName,
                bundleIdentifier: bundleId,
                url: url,
                size: appWeight,
                modificationDate: modDate,
                isSystemApp: true
            )
            results.append(sysAppInfo)
        }

        return results.sorted { $0.size > $1.size }
    }
}
