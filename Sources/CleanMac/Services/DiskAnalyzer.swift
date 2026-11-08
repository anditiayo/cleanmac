import Foundation

public final class DiskAnalyzer: Sendable {
    public init() {}

    public func analyzeMainDisk() -> DiskInfo {
        let rootURL = URL(fileURLWithPath: "/")
        do {
            let values = try rootURL.resourceValues(forKeys: [
                .volumeTotalCapacityKey,
                .volumeAvailableCapacityForImportantUsageKey,
                .volumeAvailableCapacityKey
            ])

            let total = Int64(values.volumeTotalCapacity ?? 0)
            let free = values.volumeAvailableCapacityForImportantUsage ?? Int64(values.volumeAvailableCapacity ?? 0)
            let used = max(0, total - free)

            return DiskInfo(totalSpace: total, freeSpace: free, usedSpace: used)
        } catch {
            return .empty
        }
    }
}

