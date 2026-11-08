import Foundation

public struct DiskInfo: Sendable, Equatable {
    public let totalSpace: Int64
    public let freeSpace: Int64
    public let usedSpace: Int64

    public var usedPercentage: Double {
        guard totalSpace > 0 else { return 0.0 }
        return Double(usedSpace) / Double(totalSpace)
    }

    public var freePercentage: Double {
        guard totalSpace > 0 else { return 0.0 }
        return Double(freeSpace) / Double(totalSpace)
    }

    public var totalFormatted: String {
        ByteFormatter.string(from: totalSpace)
    }

    public var freeFormatted: String {
        ByteFormatter.string(from: freeSpace)
    }

    public var usedFormatted: String {
        ByteFormatter.string(from: usedSpace)
    }

    public static let empty = DiskInfo(totalSpace: 0, freeSpace: 0, usedSpace: 0)
}

