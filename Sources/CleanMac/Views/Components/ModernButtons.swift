import SwiftUI

/// Modern macOS button style with subtle gradient, clean border stroke, and smooth hover
public struct ModernPrimaryButtonStyle: ButtonStyle {
    public var tintColor: Color = .blue
    public var isDestructive: Bool = false

    public init(tintColor: Color = .blue, isDestructive: Bool = false) {
        self.tintColor = tintColor
        self.isDestructive = isDestructive
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: isDestructive
                                ? [Color(red: 0.92, green: 0.28, blue: 0.28), Color(red: 0.78, green: 0.16, blue: 0.16)]
                                : [tintColor.opacity(0.95), tintColor],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.25), lineWidth: 0.75)
            )
            .shadow(
                color: (isDestructive ? Color.red : tintColor).opacity(configuration.isPressed ? 0.15 : 0.3),
                radius: configuration.isPressed ? 2 : 4,
                x: 0,
                y: configuration.isPressed ? 1 : 2
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// Secondary neutral button style for navigation, Finder reveals, filters
public struct ModernSecondaryButtonStyle: ButtonStyle {
    public var accentColor: Color? = nil

    public init(accentColor: Color? = nil) {
        self.accentColor = accentColor
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(accentColor ?? .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(nsColor: .controlBackgroundColor).opacity(configuration.isPressed ? 0.6 : 0.9))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        accentColor?.opacity(0.3) ?? Color(nsColor: .separatorColor).opacity(0.8),
                        lineWidth: 0.75
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// Compact action icon button for list rows (Finder, trash, eye preview)
public struct ModernRowActionStyle: ButtonStyle {
    public var tint: Color
    public var isDanger: Bool

    public init(tint: Color = .secondary, isDanger: Bool = false) {
        self.tint = tint
        self.isDanger = isDanger
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(isDanger ? Color.red.opacity(0.9) : tint)
            .frame(width: 26, height: 26)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        configuration.isPressed
                            ? (isDanger ? Color.red.opacity(0.2) : tint.opacity(0.2))
                            : Color(nsColor: .controlBackgroundColor).opacity(0.6)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color(nsColor: .separatorColor).opacity(0.5), lineWidth: 0.5)
            )
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// A wrapper view that adds alternating even/odd row backgrounds (zebra striping) and cursor hover highlights
public struct ModernListRowContainer<Content: View>: View {
    public let index: Int
    public let content: Content
    @State private var isHovered: Bool = false

    public init(index: Int, @ViewBuilder content: () -> Content) {
        self.index = index
        self.content = content()
    }

    public var body: some View {
        content
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 7)
                    .fill(rowBackgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(
                        isHovered ? Color.blue.opacity(0.35) : Color.clear,
                        lineWidth: 1
                    )
            )
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.15)) {
                    isHovered = hovering
                }
            }
    }

    private var rowBackgroundColor: Color {
        if isHovered {
            return Color.blue.opacity(0.12)
        } else if index % 2 == 0 {
            return Color(nsColor: .controlBackgroundColor).opacity(0.45)
        } else {
            return Color.clear
        }
    }
}
