import Foundation

public final class AppScanner: Sendable {
    public init() {}

    public func scanApplications(
        onProgress: (@Sendable (Int, String) -> Void)? = nil
    ) async -> [AppInfo] {
        var searchPaths: [URL] = [
            URL(fileURLWithPath: "/Applications", isDirectory: true)
        ]

        let userApps = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Applications", isDirectory: true)
        if FileManager.default.fileExists(atPath: userApps.path) {
            searchPaths.append(userApps)
        }

        var appURLs: [URL] = []
        for dir in searchPaths {
            guard let contents = try? FileManager.default.contentsOfDirectory(
                at: dir,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            ) else { continue }

            for url in contents {
                if url.pathExtension.lowercased() == "app" {
                    appURLs.append(url)
                } else {
                    // Check if subdirectory contains .app (e.g., /Applications/Utilities)
                    var isDir: ObjCBool = false
                    if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir), isDir.boolValue {
                        if let subContents = try? FileManager.default.contentsOfDirectory(
                            at: url,
                            includingPropertiesForKeys: nil,
                            options: [.skipsHiddenFiles]
                        ) {
                            for subUrl in subContents where subUrl.pathExtension.lowercased() == "app" {
                                appURLs.append(subUrl)
                            }
                        }
                    }
                }
            }
        }

        var results: [AppInfo] = []

        for (index, url) in appURLs.enumerated() {
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
                modificationDate: modDate
            )
            results.append(appInfo)
        }

        return results.sorted { $0.size > $1.size }
    }
}
