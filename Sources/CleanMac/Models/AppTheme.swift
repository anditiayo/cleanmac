import SwiftUI

public enum AppTheme: String, CaseIterable, Identifiable {
    case system = "Sistem"
    case dark = "Gelap"
    case light = "Terang"

    public var id: String { rawValue }

    public var iconName: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .dark: return "moon.fill"
        case .light: return "sun.max.fill"
        }
    }

    public var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .dark: return .dark
        case .light: return .light
        }
    }
}

