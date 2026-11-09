import Foundation
import AppKit

public struct FileInfo: Identifiable, Sendable, Equatable {
    public let id: String
    public let name: String
    public let url: URL
    public let size: Int64
    public let isDirectory: Bool
    public let modificationDate: Date?
    public let category: StorageCategory
    public let isProtected: Bool
    public let customTag: String?

    public init(
        name: String,
        url: URL,
        size: Int64,
        isDirectory: Bool,
        modificationDate: Date?,
        category: StorageCategory,
        isProtected: Bool = false,
        customTag: String? = nil
    ) {
        self.id = url.path
        self.name = name
        self.url = url
        self.size = size
        self.isDirectory = isDirectory
        self.modificationDate = modificationDate
        self.category = category
        self.isProtected = isProtected
        self.customTag = customTag
    }

    public var formattedSize: String {
        ByteFormatter.string(from: size)
    }

    @MainActor
    public var icon: NSImage {
        NSWorkspace.shared.icon(forFile: url.path)
    }

    public static func == (lhs: FileInfo, rhs: FileInfo) -> Bool {
        lhs.id == rhs.id && lhs.size == rhs.size
    }
}

