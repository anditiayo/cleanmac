import Foundation

/// Scans all major directories and calculates their total sizes using `du` command
/// as fallback when FileManager enumeration fails due to permissions.
public final class DeepStorageScanner: Sendable {
    public init() {}

    public struct DirectorySize: Identifiable, Sendable {
        public let id: String
        public let name: String
        public let url: URL
        public let size: Int64
        public let category: StorageCategory
        public let isAccessible: Bool
        public let hasChildren: Bool

        public init(id: String, name: String, url: URL, size: Int64, category: StorageCategory, isAccessible: Bool, hasChildren: Bool = false) {
            self.id = id
            self.name = name
            self.url = url
            self.size = size
            self.category = category
            self.isAccessible = isAccessible
            self.hasChildren = hasChildren
        }

        public var formattedSize: String {
            ByteFormatter.string(from: size)
        }
    }

    /// Get size using `du -sk` command — works even when FileManager can't enumerate
    public func duSize(path: String) -> Int64 {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/du")
        process.arguments = ["-sk", path]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8),
               let sizeStr = output.split(separator: "\t").first,
               let sizeKB = Int64(sizeStr.trimmingCharacters(in: .whitespacesAndNewlines)) {
                return sizeKB * 1024 // Convert KB to bytes
            }
        } catch { }
        return 0
    }

    /// Scan subdirectories of a given folder (for drill-down)
    public func scanSubdirectories(of url: URL) async -> [DirectorySize] {
        var items: [DirectorySize] = []

        // Use ls to get directory contents
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/ls")
        process.arguments = ["-1A", url.path]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice

        guard (try? process.run()) != nil else { return [] }
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else { return [] }

        let names = output.split(separator: "\n").map(String.init)
        for name in names {
            let itemURL = url.appendingPathComponent(name)
            let size = duSize(path: itemURL.path)
            if size > 10 * 1024 * 1024 { // Only show items > 10 MB in drill down
                var isDir: ObjCBool = false
                let exists = FileManager.default.fileExists(atPath: itemURL.path, isDirectory: &isDir)
                let category = StorageCategory.category(for: itemURL)

                items.append(DirectorySize(
                    id: itemURL.path,
                    name: name,
                    url: itemURL,
                    size: size,
                    category: category,
                    isAccessible: exists,
                    hasChildren: isDir.boolValue
                ))
            }
        }

        return items.sorted { $0.size > $1.size }
    }

    /// Scan all major directories and return their sizes
    public func scanAllDirectories(
        onProgress: (@Sendable (String) -> Void)? = nil
    ) async -> [DirectorySize] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let fm = FileManager.default
        var results: [DirectorySize] = []

        // Define all directories to scan with categories
        let targets: [(String, String, StorageCategory)] = [
            // User visible directories
            ("Documents", "Documents", .documents),
            ("Downloads", "Downloads", .downloads),
            ("Desktop", "Desktop", .documents),
            ("Movies", "Movies", .media),
            ("Music", "Music", .media),
            ("Pictures", "Pictures", .media),

            // iCloud Drive (if Desktop & Documents in iCloud is enabled)
            ("Library/Mobile Documents/com~apple~CloudDocs", "iCloud Drive (Local Copy)", .documents),

            // Library directories (system data & app data)
            ("Library/Application Support", "App Support Data", .other),
            ("Library/Caches", "Caches", .cache),
            ("Library/Containers", "App Containers (App Store Apps)", .apps),
            ("Library/Group Containers", "Group Containers", .apps),
            ("Library/Logs", "System Logs", .cache),
            ("Library/Mail", "Mail Data", .other),
            ("Library/Messages", "iMessage Data & Attachments", .other),
            ("Library/Developer", "Developer Tools Data", .developer),
            ("Library/Safari", "Safari Data", .other),

            // Developer directories
            ("Library/Developer/Xcode/DerivedData", "Xcode DerivedData (Build Cache)", .developer),
            ("Library/Developer/Xcode/Archives", "Xcode Archives", .developer),
            ("Library/Developer/Xcode/iOS DeviceSupport", "iOS Device Support", .developer),
            ("Library/Developer/CoreSimulator/Devices", "iOS Simulator Devices", .developer),

            // Photos library
            ("Pictures/Photos Library.photoslibrary", "Photos Library", .media),

            // Hidden developer & package manager caches
            (".npm", "npm Cache", .developer),
            (".yarn", "Yarn Cache", .developer),
            (".cargo", "Cargo/Rust Cache", .developer),
            (".gradle", "Gradle Cache", .developer),
            (".cocoapods", "CocoaPods Cache", .developer),
            (".docker", "Docker Data", .developer),
            (".gem", "Ruby Gems", .developer),
            (".local/share", "Local Share Data", .other),

            // Trash
            (".Trash", "Tempat Sampah (Trash)", .cache),
        ]

        for (subpath, name, category) in targets {
            let fullPath = home.appendingPathComponent(subpath)
            guard fm.fileExists(atPath: fullPath.path) else { continue }

            onProgress?("Menganalisis: \(name)...")

            let size = duSize(path: fullPath.path)

            if size > 1 * 1024 * 1024 { // Only show dirs > 1 MB
                results.append(DirectorySize(
                    id: fullPath.path,
                    name: name,
                    url: fullPath,
                    size: size,
                    category: category,
                    isAccessible: true,
                    hasChildren: true
                ))
            }
        }

        // Deep inspect top subfolders in Application Support (where System Data hides!)
        onProgress?("Menganalisis App Support per aplikasi...")
        let appSupport = home.appendingPathComponent("Library/Application Support", isDirectory: true)
        if fm.fileExists(atPath: appSupport.path) {
            let subdirs = await scanSubdirectories(of: appSupport)
            for sub in subdirs.prefix(8) where sub.size > 100 * 1024 * 1024 { // > 100 MB
                results.append(DirectorySize(
                    id: sub.url.path,
                    name: "App Support: \(sub.name)",
                    url: sub.url,
                    size: sub.size,
                    category: .other,
                    isAccessible: true,
                    hasChildren: true
                ))
            }
        }

        // Deep inspect top subfolders in Containers (App Store apps data)
        onProgress?("Menganalisis App Containers...")
        let containers = home.appendingPathComponent("Library/Containers", isDirectory: true)
        if fm.fileExists(atPath: containers.path) {
            let subdirs = await scanSubdirectories(of: containers)
            for sub in subdirs.prefix(8) where sub.size > 100 * 1024 * 1024 { // > 100 MB
                results.append(DirectorySize(
                    id: sub.url.path,
                    name: "Container: \(sub.name)",
                    url: sub.url,
                    size: sub.size,
                    category: .apps,
                    isAccessible: true,
                    hasChildren: true
                ))
            }
        }

        // Deep inspect Documents subfolders (so the user sees where 56 GB goes!)
        onProgress?("Menganalisis subfolder Documents...")
        let documents = home.appendingPathComponent("Documents", isDirectory: true)
        if fm.fileExists(atPath: documents.path) {
            let subdirs = await scanSubdirectories(of: documents)
            for sub in subdirs where sub.size > 50 * 1024 * 1024 { // > 50 MB
                results.append(DirectorySize(
                    id: sub.url.path,
                    name: "Documents: \(sub.name)",
                    url: sub.url,
                    size: sub.size,
                    category: .documents,
                    isAccessible: true,
                    hasChildren: true
                ))
            }
        }

        // Scan /Applications
        onProgress?("Menganalisis: /Applications...")
        let systemAppsSize = duSize(path: "/Applications")
        if systemAppsSize > 0 {
            results.append(DirectorySize(
                id: "/Applications",
                name: "Applications (/Applications)",
                url: URL(fileURLWithPath: "/Applications"),
                size: systemAppsSize,
                category: .apps,
                isAccessible: true,
                hasChildren: true
            ))
        }

        // Scan /System
        onProgress?("Menganalisis: macOS System...")
        let systemSize = duSize(path: "/System")
        if systemSize > 0 {
            results.append(DirectorySize(
                id: "/System",
                name: "macOS System (/System)",
                url: URL(fileURLWithPath: "/System"),
                size: systemSize,
                category: .other,
                isAccessible: true,
                hasChildren: false
            ))
        }

        // Deduplicate by path
        var unique: [String: DirectorySize] = [:]
        for r in results {
            if unique[r.id] == nil {
                unique[r.id] = r
            }
        }

        return Array(unique.values).sorted { $0.size > $1.size }
    }
}
