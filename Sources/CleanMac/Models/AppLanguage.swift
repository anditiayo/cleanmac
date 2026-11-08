import Foundation

public enum AppLanguage: String, CaseIterable, Identifiable {
    case indonesian = "id"
    case english = "en"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .indonesian: return "Bahasa Indonesia"
        case .english: return "English"
        }
    }

    public var flag: String {
        switch self {
        case .indonesian: return "🇮🇩"
        case .english: return "🇬🇧"
        }
    }

    public var shortLabel: String {
        switch self {
        case .indonesian: return "ID"
        case .english: return "EN"
        }
    }
}

