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
                        Text(file.category.rawValue)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(file.category.color.opacity(0.15))
                            .foregroundColor(file.category.color)
                            .cornerRadius(4)

                        Text(file.isDirectory ? "Folder / Direktori" : "Berkas (File)")
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
                DetailRow(title: "Ukuran", value: file.formattedSize, isMonospace: true)
                DetailRow(title: "Lokasi", value: file.url.path, isMonospace: false, isPath: true)

                if let modDate = file.modificationDate {
                    DetailRow(
                        title: "Terakhir Diubah",
                        value: modDate.formatted(date: .long, time: .shortened),
                        isMonospace: false
                    )
                }

                DetailRow(
                    title: "Ekstensi",
                    value: file.url.pathExtension.isEmpty ? "(Folder / Tanpa ekstensi)" : ".\(file.url.pathExtension)",
                    isMonospace: true
                )
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(10)

            Spacer()

            // Action Buttons
            HStack(spacing: 12) {
                Button {
                    NSWorkspace.shared.open(file.url)
                } label: {
                    Label("Buka Berkas", systemImage: "arrow.up.right.square")
                }
                .buttonStyle(.bordered)

                Button {
                    onReveal()
                } label: {
                    Label("Tampilkan di Finder", systemImage: "folder")
                }
                .buttonStyle(.bordered)

                Spacer()

                Button(role: .destructive) {
                    dismiss()
                    onTrash()
                } label: {
                    Label("Pindahkan ke Trash", systemImage: "trash")
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
        }
        .padding(24)
        .frame(width: 520, height: 350)
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
