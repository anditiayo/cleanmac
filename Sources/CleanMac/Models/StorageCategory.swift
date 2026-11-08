import SwiftUI

public enum StorageCategory: String, CaseIterable, Identifiable, Sendable {
    case apps = "Applications"
    case documents = "Documents"
    case media = "Media"
    case downloads = "Downloads"
    case cache = "Caches & Logs"
    case developer = "Developer"
    case other = "System Data & Other"

    public var id: String { rawValue }

    public var localizedName: String {
        switch self {
        case .apps: return loc("cat.apps")
        case .documents: return loc("cat.documents")
        case .media: return loc("cat.media")
        case .downloads: return loc("cat.downloads")
        case .cache: return loc("cat.cache")
        case .developer: return loc("cat.developer")
        case .other: return loc("cat.other")
        }
    }

    public var iconName: String {
        switch self {
        case .apps: return "app.badge.fill"
        case .documents: return "doc.fill"
        case .media: return "photo.tv"
        case .downloads: return "arrow.down.circle.fill"
        case .cache: return "trash.circle.fill"
        case .developer: return "hammer.fill"
        case .other: return "externaldrive.fill"
        }
    }

    public var color: Color {
        switch self {
        case .documents: return .red
        case .apps: return .orange
        case .developer: return .yellow
        case .media: return .green
        case .downloads: return .purple
        case .cache: return .cyan
        case .other: return Color(nsColor: .systemGray)
        }
    }

    public static func category(for url: URL) -> StorageCategory {
        let ext = url.pathExtension.lowercased()
        let path = url.path

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
