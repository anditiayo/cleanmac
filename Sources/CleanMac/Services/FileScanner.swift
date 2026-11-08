import Foundation

public final class FileScanner: Sendable {
    public init() {}

    public func scanLargeFiles(
        minSizeBytes: Int64 = 10 * 1024 * 1024, // 10 MB
        maxResults: Int = 100,
        onProgress: (@Sendable (String) -> Void)? = nil
    ) async -> [FileInfo] {
        let home = FileManager.default.homeDirectoryForCurrentUser

        // Target user-facing folders where large files actually belong
        let targetDirs: [URL] = [
            home.appendingPathComponent("Downloads", isDirectory: true),
            home.appendingPathComponent("Documents", isDirectory: true),
            home.appendingPathComponent("Desktop", isDirectory: true),
            home.appendingPathComponent("Movies", isDirectory: true),
            home.appendingPathComponent("Music", isDirectory: true),
            home.appendingPathComponent("Pictures", isDirectory: true),
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

                // If it's a directory (and not an app/package), only match known bulky dev folders
                if isDirectory && !isPackage {
                    let folderName = fileURL.lastPathComponent
                    let bulkyFolders = [
                        "node_modules", "DerivedData", ".build", "Pods", ".gradle",
                        "build", "target", "dist", "venv", ".venv", "vendor"
                    ]
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
                    continue
                }

                // Normal file: check size
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

        // Also check standalone large files sitting directly in home folder
        if let homeContents = try? FileManager.default.contentsOfDirectory(
            at: home,
            includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) {
            for item in homeContents {
                var isDir: ObjCBool = false
                FileManager.default.fileExists(atPath: item.path, isDirectory: &isDir)
                if !isDir.boolValue {
                    let size = FolderSizeCalculator.size(of: item)
                    if size >= minSizeBytes {
                        largeFiles.append(FileInfo(
                            name: item.lastPathComponent,
                            url: item,
                            size: size,
                            isDirectory: false,
                            modificationDate: (try? item.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate,
                            category: StorageCategory.category(for: item)
                        ))
                    }
                }
            }
        }

        largeFiles.sort { $0.size > $1.size }
        return Array(largeFiles.prefix(maxResults))
    }
}
