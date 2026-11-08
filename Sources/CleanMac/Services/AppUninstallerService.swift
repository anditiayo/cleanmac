import Foundation

public struct AppLeftoverItem: Identifiable, Sendable {
    public let id: String
    public let name: String
    public let url: URL
    public let size: Int64
    public let locationType: String

    public init(name: String, url: URL, size: Int64, locationType: String) {
        self.id = url.path
        self.name = name
        self.url = url
        self.size = size
        self.locationType = locationType
    }

    public var formattedSize: String {
        ByteFormatter.string(from: size)
    }
}

public struct CompleteAppPackage: Identifiable, Sendable {
    public let id: String
    public let app: AppInfo
    public let leftovers: [AppLeftoverItem]

    public var totalSize: Int64 {
        app.size + leftovers.reduce(0) { $0 + $1.size }
    }

    public var formattedTotalSize: String {
        ByteFormatter.string(from: totalSize)
    }

    public var leftoversTotalSize: Int64 {
        leftovers.reduce(0) { $0 + $1.size }
    }

    public var formattedLeftoversSize: String {
        ByteFormatter.string(from: leftoversTotalSize)
    }
}

public final class AppUninstallerService: Sendable {
    public init() {}

    public func findLeftovers(for app: AppInfo) -> [AppLeftoverItem] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let library = home.appendingPathComponent("Library", isDirectory: true)
        let fm = FileManager.default
        var leftovers: [AppLeftoverItem] = []

        let appName = app.name.lowercased()
        let cleanName = app.url.deletingPathExtension().lastPathComponent.lowercased()
        let bundleId = app.bundleIdentifier?.lowercased()

        // Match criteria helper
        func isMatch(_ filename: String) -> Bool {
            let lower = filename.lowercased()
            if let bundleId = bundleId, lower.contains(bundleId) { return true }
            if lower == appName || lower == cleanName { return true }
            if lower.hasPrefix("\(cleanName).") || lower.hasPrefix("\(appName).") { return true }
            return false
        }

        // 1. Application Support
        let appSupport = library.appendingPathComponent("Application Support", isDirectory: true)
        if let contents = try? fm.contentsOfDirectory(at: appSupport, includingPropertiesForKeys: nil) {
            for item in contents where isMatch(item.lastPathComponent) {
                let size = FolderSizeCalculator.size(of: item)
                leftovers.append(AppLeftoverItem(name: item.lastPathComponent, url: item, size: size, locationType: "Application Support"))
            }
        }

        // 2. Caches
        let caches = library.appendingPathComponent("Caches", isDirectory: true)
        if let contents = try? fm.contentsOfDirectory(at: caches, includingPropertiesForKeys: nil) {
            for item in contents where isMatch(item.lastPathComponent) {
                let size = FolderSizeCalculator.size(of: item)
                leftovers.append(AppLeftoverItem(name: item.lastPathComponent, url: item, size: size, locationType: "Caches"))
            }
        }

        // 3. Preferences (.plist)
        let preferences = library.appendingPathComponent("Preferences", isDirectory: true)
        if let contents = try? fm.contentsOfDirectory(at: preferences, includingPropertiesForKeys: nil) {
            for item in contents where isMatch(item.lastPathComponent) {
                let size = (try? item.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
                leftovers.append(AppLeftoverItem(name: item.lastPathComponent, url: item, size: Int64(size), locationType: "Preferences"))
            }
        }

        // 4. Containers
        let containers = library.appendingPathComponent("Containers", isDirectory: true)
        if let contents = try? fm.contentsOfDirectory(at: containers, includingPropertiesForKeys: nil) {
            for item in contents where isMatch(item.lastPathComponent) {
                let size = FolderSizeCalculator.size(of: item)
                leftovers.append(AppLeftoverItem(name: item.lastPathComponent, url: item, size: size, locationType: "App Container"))
            }
        }

        // 5. Saved Application State
        let savedState = library.appendingPathComponent("Saved Application State", isDirectory: true)
        if let contents = try? fm.contentsOfDirectory(at: savedState, includingPropertiesForKeys: nil) {
            for item in contents where isMatch(item.lastPathComponent) {
                let size = FolderSizeCalculator.size(of: item)
                leftovers.append(AppLeftoverItem(name: item.lastPathComponent, url: item, size: size, locationType: "Saved State"))
            }
        }

        // 6. Logs
        let logs = library.appendingPathComponent("Logs", isDirectory: true)
        if let contents = try? fm.contentsOfDirectory(at: logs, includingPropertiesForKeys: nil) {
            for item in contents where isMatch(item.lastPathComponent) {
                let size = FolderSizeCalculator.size(of: item)
                leftovers.append(AppLeftoverItem(name: item.lastPathComponent, url: item, size: size, locationType: "Logs"))
            }
        }

        return leftovers.sorted { $0.size > $1.size }
    }

    public func uninstallCompletely(package: CompleteAppPackage) -> (success: Bool, message: String) {
        var count = 0
        var totalBytesFreed: Int64 = 0

        // 1. Move the .app bundle to trash
        var resultingURL: NSURL?
        do {
            try FileManager.default.trashItem(at: package.app.url, resultingItemURL: &resultingURL)
            count += 1
            totalBytesFreed += package.app.size
        } catch {
            return (false, "Gagal memindahkan aplikasi ke Trash: \(error.localizedDescription)")
        }

        // 2. Move all leftover files to trash
        for item in package.leftovers {
            do {
                var res: NSURL?
                try FileManager.default.trashItem(at: item.url, resultingItemURL: &res)
                count += 1
                totalBytesFreed += item.size
            } catch {
                continue
            }
        }

        return (true, "Berhasil menghapus \(package.app.name) beserta \(package.leftovers.count) data terkait (\(ByteFormatter.string(from: totalBytesFreed)) dibebaskan)!")
    }
}
