import Foundation
import AppKit

public struct AppInfo: Identifiable, Sendable, Equatable {
    public let id: String
    public let name: String
    public let bundleIdentifier: String?
    public let url: URL
    public let size: Int64
    public let modificationDate: Date?

    public init(name: String, bundleIdentifier: String?, url: URL, size: Int64, modificationDate: Date?) {
        self.id = url.path
        self.name = name
        self.bundleIdentifier = bundleIdentifier
        self.url = url
        self.size = size
        self.modificationDate = modificationDate
    }

    public var formattedSize: String {
        ByteFormatter.string(from: size)
    }

    @MainActor
    public var icon: NSImage {
        NSWorkspace.shared.icon(forFile: url.path)
    }

    public static func == (lhs: AppInfo, rhs: AppInfo) -> Bool {
        lhs.id == rhs.id && lhs.size == rhs.size
    }
}

