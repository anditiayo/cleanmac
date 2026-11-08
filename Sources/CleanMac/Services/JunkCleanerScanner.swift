import Foundation

public enum CleanableType: String, CaseIterable, Identifiable, Sendable {
    case appCache = "Cache Aplikasi"
    case systemLogs = "File Log & Diagnostik"
    case xcodeDerivedData = "Xcode DerivedData (Build Cache)"
    case oldInstallers = "Installer Bekas (.dmg / .pkg)"
    case trash = "Tempat Sampah (Trash)"
    case developerCache = "Cache Package Manager (npm/yarn/cargo)"

    public var id: String { rawValue }

    public var localizedTitle: String {
        switch self {
        case .appCache: return loc("clean.appCache")
        case .systemLogs: return loc("clean.systemLogs")
        case .xcodeDerivedData: return loc("clean.xcode")
        case .oldInstallers: return loc("clean.installers")
        case .trash: return loc("clean.trash")
        case .developerCache: return loc("clean.devCache")
        }
    }

    public var iconName: String {
        switch self {
        case .appCache: return "archivebox.fill"
        case .systemLogs: return "doc.text.fill"
        case .xcodeDerivedData: return "hammer.fill"
        case .oldInstallers: return "opticaldisc.fill"
        case .trash: return "trash.fill"
        case .developerCache: return "shippingbox.fill"
        }
    }

    public var localizedSafetyLevel: String {
        switch self {
        case .appCache: return loc("clean.safetyRecreated")
        case .systemLogs: return loc("clean.safetyLogs")
        case .xcodeDerivedData: return loc("clean.safetyXcode")
        case .oldInstallers: return loc("clean.safetyInstallers")
        case .trash: return loc("clean.safetyTrash")
        case .developerCache: return loc("clean.safetyDevCache")
        }
    }

    public var safetyLevel: String {
        localizedSafetyLevel
    }
}

public struct CleanableItem: Identifiable, Sendable {
    public let id: String
    public let name: String
    public let url: URL
    public let size: Int64
    public let type: CleanableType
    public let detail: String

    public init(name: String, url: URL, size: Int64, type: CleanableType, detail: String) {
        self.id = url.path
        self.name = name
        self.url = url
        self.size = size
        self.type = type
        self.detail = detail
    }

    public var formattedSize: String {
        ByteFormatter.string(from: size)
    }
}

public final class JunkCleanerScanner: Sendable {
    public init() {}

    private func duSize(path: String) -> Int64 {
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
               let sizeKB = Int64(sizeStr) {
                return sizeKB * 1024
            }
        } catch { }
        return 0
    }

    private func listDirectory(at url: URL) -> [URL] {
        if let contents = try? FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) {
            return contents
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/ls")
        process.arguments = ["-1", url.path]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                return output.split(separator: "\n").map { name in
                    url.appendingPathComponent(String(name))
                }
            }
        } catch { }
        return []
    }

    public func scanCleanableItems(
        onProgress: (@Sendable (String) -> Void)? = nil
    ) async -> [CleanableItem] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        var results: [CleanableItem] = []

        // 1. App Caches (~/Library/Caches)
        onProgress?("Memeriksa Cache Aplikasi...")
        let cacheDir = home.appendingPathComponent("Library/Caches", isDirectory: true)
        let cacheItems = listDirectory(at: cacheDir)
        for item in cacheItems {
            var size = FolderSizeCalculator.size(of: item)
            if size == 0 { size = duSize(path: item.path) }
            if size > 1 * 1024 * 1024 { // > 1 MB threshold
                results.append(CleanableItem(
                    name: item.lastPathComponent,
                    url: item,
                    size: size,
                    type: .appCache,
                    detail: "Cache temporary aplikasi \(item.lastPathComponent)"
                ))
            }
        }

        // 2. Logs (~/Library/Logs)
        onProgress?("Memeriksa File Log...")
        let logsDir = home.appendingPathComponent("Library/Logs", isDirectory: true)
        let logItems = listDirectory(at: logsDir)
        for item in logItems {
            var size = FolderSizeCalculator.size(of: item)
            if size == 0 { size = duSize(path: item.path) }
            if size > 500 * 1024 { // > 500 KB threshold
                results.append(CleanableItem(
                    name: item.lastPathComponent,
                    url: item,
                    size: size,
                    type: .systemLogs,
                    detail: "Catatan riwayat/log sistem"
                ))
            }
        }

        // 3. Xcode DerivedData (~/Library/Developer/Xcode/DerivedData)
        onProgress?("Memeriksa Xcode DerivedData...")
        let derivedData = home.appendingPathComponent("Library/Developer/Xcode/DerivedData", isDirectory: true)
        if FileManager.default.fileExists(atPath: derivedData.path) {
            var size = FolderSizeCalculator.size(of: derivedData)
            if size == 0 { size = duSize(path: derivedData.path) }
            if size > 1 * 1024 * 1024 {
                results.append(CleanableItem(
                    name: "Xcode DerivedData",
                    url: derivedData,
                    size: size,
                    type: .xcodeDerivedData,
                    detail: "Cache build Xcode lama. Sangat aman dihapus untuk hemat ruang."
                ))
            }
        }

        // 4. Old Installers (.dmg / .pkg in ~/Downloads)
        onProgress?("Memeriksa Installer Bekas di Downloads...")
        let downloads = home.appendingPathComponent("Downloads", isDirectory: true)
        let downloadItems = listDirectory(at: downloads)
        for item in downloadItems {
            let ext = item.pathExtension.lowercased()
            if ext == "dmg" || ext == "pkg" {
                var size = FolderSizeCalculator.size(of: item)
                if size == 0 { size = duSize(path: item.path) }
                if size > 0 {
                    results.append(CleanableItem(
                        name: item.lastPathComponent,
                        url: item,
                        size: size,
                        type: .oldInstallers,
                        detail: "File installer macOS yang kemungkinan sudah selesai diinstall"
                    ))
                }
            }
        }

        // 5. Trash (~/.Trash)
        onProgress?("Memeriksa Tempat Sampah...")
        let trashDir = home.appendingPathComponent(".Trash", isDirectory: true)
        let trashSize = duSize(path: trashDir.path)
        if trashSize > 0 {
            results.append(CleanableItem(
                name: "Tempat Sampah (.Trash)",
                url: trashDir,
                size: trashSize,
                type: .trash,
                detail: "File yang sudah dibuang ke Trash namun belum dikosongkan"
            ))
        }

        // 6. Developer caches
        let devCaches: [(String, String)] = [
            (".npm/_cacache", "npm Package Cache"),
            (".cargo/registry/cache", "Cargo/Rust Cache"),
            (".gradle/caches", "Gradle Cache"),
            (".cocoapods/repos", "CocoaPods Specs Cache"),
        ]

        for (subpath, label) in devCaches {
            let fullPath = home.appendingPathComponent(subpath)
            let size = duSize(path: fullPath.path)
            if size > 5 * 1024 * 1024 {
                results.append(CleanableItem(
                    name: label,
                    url: fullPath,
                    size: size,
                    type: .developerCache,
                    detail: "Cache paket dependency yang bisa diunduh ulang saat dibutuhkan"
                ))
            }
        }

        return results.sorted { $0.size > $1.size }
    }
}
