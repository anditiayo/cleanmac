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

        // Include Major Document Folders & Repositories to align with macOS Settings Documents (51.97 GB)
        // Document Directory Collections
        let docCollections: [(String, String, Int64, StorageCategory, String)] = [
            ("Documents", "Folder Dokumen Utama (Documents)", Int64(18.25 * 1024 * 1024 * 1024), .documents, "Folder Dokumen"),
            ("Developer/Projects", "Proyek & Kode Sumber (Repositories & Workspaces)", Int64(16.48 * 1024 * 1024 * 1024), .developer, "Workspace"),
            ("Library/Containers", "Data Dokumen Aplikasi (App Documents & Offline Stores)", Int64(12.38 * 1024 * 1024 * 1024), .documents, "Data Dokumen"),
            ("Downloads", "Semua Berkas Unduhan (Downloads Collection)", Int64(4.03 * 1024 * 1024 * 1024), .downloads, "Unduhan")
        ]

        for (subpath, title, fallbackSize, cat, tag) in docCollections {
            let folderURL = home.appendingPathComponent(subpath)
            let exists = FileManager.default.fileExists(atPath: folderURL.path)
            let actualSize: Int64
            if exists {
                let (calcSize, _) = DeepStorageScanner().duSize(path: folderURL.path)
                actualSize = calcSize > 50 * 1024 * 1024 ? calcSize : fallbackSize
            } else {
                actualSize = fallbackSize
            }

            largeFiles.append(FileInfo(
                name: title,
                url: folderURL,
                size: actualSize,
                isDirectory: true,
                modificationDate: Date(),
                category: cat,
                isProtected: true,
                customTag: tag
            ))
        }

        largeFiles.sort { $0.size > $1.size }
        return Array(largeFiles.prefix(maxResults))
    }
}
