import SwiftUI
import AppKit
import QuickLook

public struct FileDetailSheet: View {
    public let file: FileInfo
    public let onTrash: () -> Void
    public let onReveal: () -> Void
    @Environment(\.dismiss) private var dismiss

    public init(file: FileInfo, onTrash: @escaping () -> Void, onReveal: @escaping () -> Void) {
        self.file = file
        self.onTrash = onTrash
        self.onReveal = onReveal
    }

    private var isProtectedFolder: Bool {
        if file.isProtected { return true }
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        let protectedPaths: Set<String> = [
            "\(home)/Documents",
            "\(home)/Downloads",
            "\(home)/Desktop",
            "\(home)/Movies",
            "\(home)/Music",
            "\(home)/Pictures",
            "\(home)/Library",
            "\(home)/Developer",
            "/System",
            "/Applications"
        ]
        return protectedPaths.contains(file.url.path) || file.url.path.hasPrefix("/System/")
    }

    public var body: some View {
        VStack(spacing: 20) {
            // Header with icon
            HStack(spacing: 16) {
                Image(nsImage: file.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 56, height: 56)

                VStack(alignment: .leading, spacing: 4) {
                    Text(file.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        if isProtectedFolder {
                            HStack(spacing: 3) {
                                Image(systemName: "lock.shield.fill")
                                    .font(.system(size: 9))
                                Text(loc("safety.protectedNoDelete"))
                                    .font(.caption2)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.15))
                            .foregroundColor(.orange)
                            .cornerRadius(4)
                        } else {
                            Text(file.category.localizedName)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(file.category.color.opacity(0.15))
                                .foregroundColor(file.category.color)
                                .cornerRadius(4)
                        }

                        Text(file.isDirectory ? loc("tag.directory") : loc("tag.file"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }

            Divider()

            // Details Table
            VStack(spacing: 10) {
                DetailRow(title: loc("file.size"), value: file.formattedSize, isMonospace: true)
                DetailRow(title: loc("file.location"), value: file.url.path, isMonospace: false, isPath: true)

                if let modDate = file.modificationDate {
                    DetailRow(
                        title: loc("file.lastModified"),
                        value: modDate.formatted(date: .long, time: .shortened),
                        isMonospace: false
                    )
                }

                DetailRow(
                    title: loc("file.extension"),
                    value: file.url.pathExtension.isEmpty ? "(\(loc("tag.noExtension")))" : ".\(file.url.pathExtension)",
                    isMonospace: true
                )
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(10)

            Spacer()

            // Redesigned Modern Action Buttons (Clear, Un-truncated, Distinct)
            HStack(spacing: 10) {
                Button {
                    NSWorkspace.shared.open(file.url)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: file.isDirectory ? "folder" : "arrow.up.right.square")
                            .font(.system(size: 13, weight: .semibold))
                        Text(file.isDirectory ? loc("action.openFolder") : loc("action.openFile"))
                    }
                }
                .buttonStyle(ModernSecondaryButtonStyle(accentColor: .blue))

                Button {
                    onReveal()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "folder.badge.gearshape")
                            .font(.system(size: 13, weight: .semibold))
                        Text(loc("action.showInFinder"))
                    }
                }
                .buttonStyle(ModernSecondaryButtonStyle())

                Spacer()

                if isProtectedFolder {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.orange)
                        Text(loc("safety.protectedNoDelete"))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color.orange.opacity(0.12))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    )
                    .help(loc("help.systemProtected"))
                } else {
                    Button(role: .destructive) {
                        dismiss()
                        onTrash()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 13, weight: .semibold))
                            Text(loc("action.moveToTrash"))
                        }
                    }
                    .buttonStyle(ModernPrimaryButtonStyle(isDestructive: true))
                }
            }
        }
        .padding(24)
        .frame(width: 560, height: 350)
    }
}

private struct DetailRow: View {
    let title: String
    let value: String
    let isMonospace: Bool
    var isPath: Bool = false

    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 110, alignment: .leading)

            if isMonospace {
                Text(value)
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else if isPath {
                Text(value)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .truncationMode(.middle)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(value)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
