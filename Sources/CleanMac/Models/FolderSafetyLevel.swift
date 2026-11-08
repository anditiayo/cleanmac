import SwiftUI

public enum FolderSafetyLevel: String, Sendable {
    case critical = "Sistem (Jangan Hapus)"
    case caution = "Hati-hati"
    case safe = "Aman Dihapus"

    public var badgeColor: Color {
        switch self {
        case .critical: return .red
        case .caution: return .orange
        case .safe: return .green
        }
    }

    public var iconName: String {
        switch self {
        case .critical: return "lock.shield.fill"
        case .caution: return "exclamationmark.triangle.fill"
        case .safe: return "checkmark.shield.fill"
        }
    }

    public static func evaluate(path: String, category: StorageCategory) -> FolderSafetyLevel {
        let p = path.lowercased()

        // Critical - Never allow direct deletion
        if p == "/system" || p.hasPrefix("/system/") || p.contains("library/application support") || p.contains("library/containers") {
            return .critical
        }

        // Caution - Contains user data or mixed contents
        if p.contains("group containers") || p.hasPrefix("/applications") || p.contains("library/developer") || category == .apps || p.contains("pictures") || p.contains("movies") || p.contains("documents") {
            return .caution
        }

        // Safe
        if p.contains("caches") || p.contains("logs") || p.contains(".trash") || p.contains("deriveddata") || p.contains(".gradle") || p.contains(".npm") || p.contains(".cargo") || category == .downloads || category == .cache {
            return .safe
        }

        return .caution
    }
}
