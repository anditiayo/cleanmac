import Foundation

public struct ByteFormatter {
    private static let formatter: ByteCountFormatter = {
        let f = ByteCountFormatter()
        f.countStyle = .file
        f.allowedUnits = [.useBytes, .useKB, .useMB, .useGB, .useTB]
        f.includesUnit = true
        f.isAdaptive = true
        return f
    }()

    public static func string(from bytes: Int64) -> String {
        guard bytes >= 0 else { return "0 B" }
        return formatter.string(fromByteCount: bytes)
    }
}

