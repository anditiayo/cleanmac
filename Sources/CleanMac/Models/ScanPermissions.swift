import Foundation

public struct ScanPermissions: Codable, Equatable {
    public var scanApplications: Bool = true
    public var scanLargeFiles: Bool = true
    public var scanCaches: Bool = true
    public var scanJunk: Bool = true
    public var scanDeepDirectories: Bool = true

    public init(
        scanApplications: Bool = true,
        scanLargeFiles: Bool = true,
        scanCaches: Bool = true,
        scanJunk: Bool = true,
        scanDeepDirectories: Bool = true
    ) {
        self.scanApplications = scanApplications
        self.scanLargeFiles = scanLargeFiles
        self.scanCaches = scanCaches
        self.scanJunk = scanJunk
        self.scanDeepDirectories = scanDeepDirectories
    }

    public var hasAnySelected: Bool {
        scanApplications || scanLargeFiles || scanCaches || scanJunk || scanDeepDirectories
    }
}
