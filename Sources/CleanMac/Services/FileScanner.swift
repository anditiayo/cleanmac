import Foundation

public final class FileScanner: Sendable {
    public init() {}

    public func scanLargeFiles(
        minSizeBytes: Int64 = 50 * 1024 * 1024, // default 50 MB
        maxResults: Int = 100,
        onProgress: (@Sendable (String) -> Void)? = nil
    ) async -> [FileInfo] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let targetDirs: [URL] = [
            home.appendingPathComponent("Downloads", isDirectory: true),
            home.appendingPathComponent("Documents", isDirectory: true),
            home.appendingPathComponent("Desktop", isDirectory: true),
            home.appendingPathComponent("Movies", isDirectory: true),
            home.appendingPathComponent("Music", isDirectory: true),
            home.appendingPathComponent("Pictures", isDirectory: true),
            // Also scan Library directories for big data consumers
            home.appendingPathComponent("Library/Application Support", isDirectory: true),
            home.appendingPathComponent("Library/Containers", isDirectory: true),
            home.appendingPathComponent("Library/Group Containers", isDirectory: true),
            home.appendingPathComponent("Library/Developer", isDirectory: true),
            home.appendingPathComponent("Library/Caches", isDirectory: true),
            home.appendingPathComponent("Library/Mail", isDirectory: true),
        ]

        var largeFiles: [FileInfo] = []

        for dir in targetDirs {
            guard FileManager.default.fileExists(atPath: dir.path) else { continue }
            onProgress?(dir.lastPathComponent)

            guard let enumerator = FileManager.default.enumerator(
                at: dir,
                includingPropertiesForKeys: [
                    .fileSizeKey,
                    .totalFileAllocatedSizeKey,
                    .isDirectoryKey,
                    .isPackageKey,
                    .contentModificationDateKey,
                    .isSymbolicLinkKey
                ],
                options: [.skipsPackageDescendants]
            ) else { continue }

            while let fileURL = enumerator.nextObject() as? URL {
                guard let values = try? fileURL.resourceValues(forKeys: [
                    .fileSizeKey,
                    .totalFileAllocatedSizeKey,
                    .isDirectoryKey,
                    .isPackageKey,
                    .contentModificationDateKey,
                    .isSymbolicLinkKey
                ]) else { continue }

                if values.isSymbolicLink == true { continue }

                let isDirectory = values.isDirectory ?? false
                let isPackage = values.isPackage ?? false

                // If it's a directory that isn't a package, check for special folders
                if isDirectory && !isPackage {
                    let folderName = fileURL.lastPathComponent
                    let bulkyFolders = ["node_modules", "DerivedData", ".build", "Pods", ".gradle",
                                        "build", "target", "dist", "__pycache__", ".tox", "venv",
                                        ".venv", "vendor"]
                    if bulkyFolders.contains(folderName) {
                        enumerator.skipDescendants()
                        let size = FolderSizeCalculator.size(of: fileURL)
                        if size >= minSizeBytes {
                            largeFiles.append(FileInfo(
                                name: folderName,
                                url: fileURL,
                                size: size,
                                isDirectory: true,
                                modificationDate: values.contentModificationDate,
                                category: .developer
                            ))
                        }
                    }
                    // Also treat large app-data directories (>100MB) as notable items
                    else if fileURL.path.contains("/Library/") {
                        let size = FolderSizeCalculator.size(of: fileURL)
                        if size >= minSizeBytes * 5 { // 50 MB threshold for Library subdirs
                            enumerator.skipDescendants()
                            largeFiles.append(FileInfo(
                                name: folderName,
                                url: fileURL,
                                size: size,
                                isDirectory: true,
                                modificationDate: values.contentModificationDate,
                                category: StorageCategory.category(for: fileURL)
                            ))
                        }
                    }
                    continue
                }

                let size = Int64(values.totalFileAllocatedSize ?? values.fileSize ?? 0)
                if size >= minSizeBytes {
                    let category = StorageCategory.category(for: fileURL)
                    largeFiles.append(FileInfo(
                        name: fileURL.lastPathComponent,
                        url: fileURL,
                        size: size,
                        isDirectory: isPackage,
                        modificationDate: values.contentModificationDate,
                        category: category
                    ))
                }
            }
        }

        largeFiles.sort { $0.size > $1.size }
        return Array(largeFiles.prefix(maxResults))
    }
}
