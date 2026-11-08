import Foundation

public enum FolderSizeCalculator {
    /// Calculate physical on-disk size of a file or directory
    /// Deduplicates hardlinks/clones via fileResourceIdentifier
    public static func size(of url: URL) -> Int64 {
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) else {
            return 0
        }

        if !isDir.boolValue {
            let values = try? url.resourceValues(forKeys: [.totalFileAllocatedSizeKey, .fileSizeKey])
            return Int64(values?.totalFileAllocatedSize ?? values?.fileSize ?? 0)
        }

        guard let enumerator = FileManager.default.enumerator(
            at: url,
            includingPropertiesForKeys: [
                .totalFileAllocatedSizeKey,
                .fileSizeKey,
                .isSymbolicLinkKey,
                .isDirectoryKey,
                .fileResourceIdentifierKey
            ],
            options: [.skipsPackageDescendants]
        ) else {
            return 0
        }

        var total: Int64 = 0
        var visitedIdentifiers = Set<NSObject>()

        // Maximum physical cap: 200 GB
        let maxDiskCap: Int64 = 200 * 1024 * 1024 * 1024

        while let fileURL = enumerator.nextObject() as? URL {
            guard let values = try? fileURL.resourceValues(forKeys: [
                .totalFileAllocatedSizeKey,
                .fileSizeKey,
                .isSymbolicLinkKey,
                .fileResourceIdentifierKey
            ]) else {
                continue
            }

            if values.isSymbolicLink == true {
                continue
            }

            // Deduplicate hardlinks using unique file resource identifier
            if let identifier = values.fileResourceIdentifier as? NSObject {
                if visitedIdentifiers.contains(identifier) {
                    continue
                }
                visitedIdentifiers.insert(identifier)
            }

            let size = values.totalFileAllocatedSize ?? values.fileSize ?? 0
            total += Int64(size)

            if total >= maxDiskCap {
                return maxDiskCap
            }
        }

        return min(total, maxDiskCap)
    }

    public static func deepBundleSize(of bundleURL: URL) -> Int64 {
        guard let enumerator = FileManager.default.enumerator(
            at: bundleURL,
            includingPropertiesForKeys: [.totalFileAllocatedSizeKey, .fileSizeKey, .isSymbolicLinkKey, .fileResourceIdentifierKey],
            options: [] // Recurse inside app bundle
        ) else {
            return 0
        }

        var total: Int64 = 0
        var visitedIdentifiers = Set<NSObject>()

        while let fileURL = enumerator.nextObject() as? URL {
            guard let values = try? fileURL.resourceValues(forKeys: [.totalFileAllocatedSizeKey, .fileSizeKey, .isSymbolicLinkKey, .fileResourceIdentifierKey]) else {
                continue
            }
            if values.isSymbolicLink == true {
                continue
            }
            if let identifier = values.fileResourceIdentifier as? NSObject {
                if visitedIdentifiers.contains(identifier) {
                    continue
                }
                visitedIdentifiers.insert(identifier)
            }
            let size = values.totalFileAllocatedSize ?? values.fileSize ?? 0
            total += Int64(size)
        }
        return total
    }
}
