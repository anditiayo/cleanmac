import Foundation

public final class CacheScanner: Sendable {
    public init() {}

    /// Get size using `du -sk` command — works even when FileManager can't enumerate
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

    /// List directory contents using `ls` when FileManager fails
    private func listDirectory(at url: URL) -> [URL] {
        // Try FileManager first
        if let contents = try? FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) {
            return contents
        }

        // Fallback: use `ls` command
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

    public func scanCaches(
        onProgress: (@Sendable (String) -> Void)? = nil
    ) async -> [FileInfo] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let libraryDir = home.appendingPathComponent("Library", isDirectory: true)
        let cacheDirs = [
            libraryDir.appendingPathComponent("Caches", isDirectory: true),
            libraryDir.appendingPathComponent("Logs", isDirectory: true)
        ]

        var results: [FileInfo] = []

        for dir in cacheDirs {
            guard FileManager.default.fileExists(atPath: dir.path) else { continue }
            onProgress?(dir.lastPathComponent)

            let contents = listDirectory(at: dir)

            for itemURL in contents {
                // Try FileManager size first, then fallback to du
                var size = FolderSizeCalculator.size(of: itemURL)
                if size == 0 {
                    size = duSize(path: itemURL.path)
                }

                // Filter items > 5 MB (lowered threshold)
                if size > 5 * 1024 * 1024 {
                    let modDate = (try? itemURL.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate
                    results.append(FileInfo(
                        name: itemURL.lastPathComponent,
                        url: itemURL,
                        size: size,
                        isDirectory: true,
                        modificationDate: modDate,
                        category: .cache
                    ))
                }
            }
        }

        return results.sorted { $0.size > $1.size }
    }
}
