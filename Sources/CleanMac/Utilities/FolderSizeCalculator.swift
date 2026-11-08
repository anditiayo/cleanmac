import Foundation

public enum FolderSizeCalculator {
    public static func size(of url: URL) -> Int64 {
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) else {
            return 0
        }

        if !isDir.boolValue {
            let values = try? url.resourceValues(forKeys: [.fileSizeKey, .totalFileAllocatedSizeKey])
            return Int64(values?.totalFileAllocatedSize ?? values?.fileSize ?? 0)
        }

        guard let enumerator = FileManager.default.enumerator(
            at: url,
            includingPropertiesForKeys: [.totalFileAllocatedSizeKey, .fileSizeKey, .isSymbolicLinkKey, .isDirectoryKey],
            options: [.skipsPackageDescendants]
        ) else {
            return 0
        }

        var total: Int64 = 0
        while let fileURL = enumerator.nextObject() as? URL {
            guard let values = try? fileURL.resourceValues(forKeys: [.totalFileAllocatedSizeKey, .fileSizeKey, .isSymbolicLinkKey]) else {
                continue
            }

            if values.isSymbolicLink == true {
                continue
            }

            let size = values.totalFileAllocatedSize ?? values.fileSize ?? 0
            total += Int64(size)
        }

        return total
    }

    public static func deepBundleSize(of bundleURL: URL) -> Int64 {
        guard let enumerator = FileManager.default.enumerator(
            at: bundleURL,
            includingPropertiesForKeys: [.totalFileAllocatedSizeKey, .fileSizeKey, .isSymbolicLinkKey],
            options: [] // Recurse inside app bundle
        ) else {
            return 0
        }

        var total: Int64 = 0
        while let fileURL = enumerator.nextObject() as? URL {
            guard let values = try? fileURL.resourceValues(forKeys: [.totalFileAllocatedSizeKey, .fileSizeKey, .isSymbolicLinkKey]) else {
                continue
            }
            if values.isSymbolicLink == true {
                continue
            }
            let size = values.totalFileAllocatedSize ?? values.fileSize ?? 0
            total += Int64(size)
        }
        return total
    }
}
