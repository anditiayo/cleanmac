import SwiftUI

public enum StorageCategory: String, CaseIterable, Identifiable, Sendable {
    case documents = "Documents"
    case apps = "Applications"
    case developer = "Developer"
    case media = "Media"
    case downloads = "Downloads"
    case cache = "Caches & Logs"
    case other = "System Data"
    case macos = "macOS"

    public var id: String { rawValue }

    public var localizedName: String {
        switch self {
        case .documents: return loc("cat.documents")
        case .apps: return loc("cat.apps")
        case .developer: return loc("cat.developer")
        case .media: return loc("cat.media")
        case .downloads: return loc("cat.downloads")
        case .cache: return loc("cat.cache")
        case .other: return loc("cat.other")
        case .macos: return "macOS"
        }
    }

    public var iconName: String {
        switch self {
        case .documents: return "doc.fill"
        case .apps: return "app.badge.fill"
        case .developer: return "hammer.fill"
        case .media: return "photo.tv"
        case .downloads: return "arrow.down.circle.fill"
        case .cache: return "trash.circle.fill"
        case .other: return "externaldrive.fill"
        case .macos: return "apple.logo"
        }
    }

    public var color: Color {
        switch self {
        case .documents: return Color(red: 0.95, green: 0.28, blue: 0.25) // Apple Red
        case .apps: return Color(red: 0.98, green: 0.58, blue: 0.16)      // Apple Orange
        case .developer: return Color(red: 0.98, green: 0.80, blue: 0.15) // Apple Yellow
        case .media: return Color(red: 0.22, green: 0.80, blue: 0.40)     // Apple Green
        case .downloads: return Color(red: 0.65, green: 0.35, blue: 0.85) // Purple
        case .cache: return Color(red: 0.25, green: 0.70, blue: 0.90)     // Cyan
        case .other: return Color(red: 0.55, green: 0.55, blue: 0.58)     // Apple Medium Gray (System Data)
        case .macos: return Color(red: 0.35, green: 0.35, blue: 0.38)     // Apple Dark Gray (macOS)
        }
    }

    public static func category(for url: URL) -> StorageCategory {
        let ext = url.pathExtension.lowercased()
        let path = url.path

        if path.hasPrefix("/System") {
            return .macos
        }

        if path.hasPrefix("/Applications") || path.contains("/Applications/") || ext == "app" {
            return .apps
        }

        if path.contains("/Library/Caches") || path.contains("/Library/Logs") {
            return .cache
        }

        if path.contains("/Developer") || path.contains("/.xcode") || path.contains("/node_modules") || path.contains("/DerivedData") {
            return .developer
        }

        if path.contains("/Downloads") {
            return .downloads
        }

        let mediaExtensions = ["mp4", "mov", "mkv", "avi", "mp3", "wav", "flac", "aac", "jpg", "jpeg", "png", "heic", "gif", "svg", "raw", "cr2"]
        if mediaExtensions.contains(ext) {
            return .media
        }

        let docExtensions = ["pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx", "txt", "rtf", "md", "pages", "numbers", "key"]
        if docExtensions.contains(ext) {
            return .documents
        }

        return .other
    }
}
