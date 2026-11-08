import SwiftUI
import AppKit

public struct AppUninstallerSheet: View {
    public let app: AppInfo
    public let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var leftovers: [AppLeftoverItem] = []
    @State private var selectedLeftoverIDs: Set<String> = []
    @State private var isLoading: Bool = true
    @State private var isUninstalling: Bool = false
    @State private var statusMessage: String? = nil

    private let uninstaller = AppUninstallerService()

    public init(app: AppInfo, onComplete: @escaping () -> Void) {
        self.app = app
        self.onComplete = onComplete
    }

    private var selectedTotalBytes: Int64 {
        let leftoverBytes = leftovers.filter { selectedLeftoverIDs.contains($0.id) }.reduce(0) { $0 + $1.size }
        return app.size + leftoverBytes
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 16) {
                Image(nsImage: app.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 54, height: 54)

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(app.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(loc("uninst.badge"))
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.15))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                    }

                    if let bundleId = app.bundleIdentifier {
                        Text(bundleId)
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
            .padding(20)

            Divider()

            if isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                    Text(loc("uninst.scanning"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(height: 280)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(loc("uninst.fileListTitle"))
                            .font(.headline)
                        Spacer()
                        Text("Total: \(ByteFormatter.string(from: selectedTotalBytes))")
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)

                    List {
                        // 1. The .app bundle itself (always selected)
                        Section {
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)

                                Image(nsImage: app.icon)
                                    .resizable()
                                    .frame(width: 24, height: 24)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(loc("uninst.mainApp")) (\(app.name))")
                                        .font(.body)
                                        .fontWeight(.medium)
                                    Text(app.url.path)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                }

                                Spacer()

                                Text(app.formattedSize)
                                    .font(.system(.body, design: .monospaced))
                                    .fontWeight(.semibold)
                            }
                            .padding(.vertical, 2)
                        } header: {
                            Text(loc("uninst.mainApp"))
                        }

                        // 2. Leftovers (App Support, Caches, Preferences, etc.)
                        if !leftovers.isEmpty {
                            Section {
                                ForEach(leftovers) { item in
                                    let isSelected = selectedLeftoverIDs.contains(item.id)
                                    HStack(spacing: 12) {
                                        Button {
                                            if isSelected {
                                                selectedLeftoverIDs.remove(item.id)
                                            } else {
                                                selectedLeftoverIDs.insert(item.id)
                                            }
                                        } label: {
                                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(isSelected ? .blue : .secondary)
                                        }
                                        .buttonStyle(.plain)

                                        VStack(alignment: .leading, spacing: 2) {
                                            HStack(spacing: 6) {
                                                Text(item.name)
                                                    .font(.body)
                                                    .fontWeight(.medium)
                                                Text(item.locationType)
                                                    .font(.caption2)
                                                    .padding(.horizontal, 5)
                                                    .padding(.vertical, 1)
                                                    .background(Color.orange.opacity(0.15))
                                                    .foregroundColor(.orange)
                                                    .cornerRadius(4)
                                            }

                                            Text(item.url.path)
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                                .truncationMode(.middle)
                                        }

                                        Spacer()

                                        Text(item.formattedSize)
                                            .font(.system(.body, design: .monospaced))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 2)
                                }
                            } header: {
                                HStack {
                                    Text("\(loc("uninst.leftovers")) (\(leftovers.count) item)")
                                    Spacer()
                                    Button(loc("action.selectAll")) {
                                        selectedLeftoverIDs = Set(leftovers.map { $0.id })
                                    }
                                    .buttonStyle(.plain)
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                                }
                            }
                        } else {
                            Section {
                                Text(loc("uninst.noLeftovers"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .listStyle(.inset)
                    .frame(height: 240)
                }
            }

            Divider()

            // Action Footer with Modern Buttons
            HStack(spacing: 14) {
                if let msg = statusMessage {
                    Text(msg)
                        .font(.caption)
                        .foregroundColor(.blue)
                }

                Spacer()

                Button(loc("action.cancel")) {
                    dismiss()
                }
                .buttonStyle(ModernSecondaryButtonStyle())

                Button(role: .destructive) {
                    performUninstall()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "trash.fill")
                        Text("\(loc("uninst.uninstallBtn")) (\(ByteFormatter.string(from: selectedTotalBytes)))")
                    }
                }
                .buttonStyle(ModernPrimaryButtonStyle(isDestructive: true))
                .disabled(isUninstalling || isLoading)
            }
            .padding(18)
        }
        .frame(width: 600, height: 450)
        .onAppear {
            scanForLeftovers()
        }
    }

    private func scanForLeftovers() {
        isLoading = true
        Task {
            let found = uninstaller.findLeftovers(for: app)
            await MainActor.run {
                self.leftovers = found
                self.selectedLeftoverIDs = Set(found.map { $0.id })
                self.isLoading = false
            }
        }
    }

    private func performUninstall() {
        isUninstalling = true
        statusMessage = loc("uninst.removing")

        let selectedLeftovers = leftovers.filter { selectedLeftoverIDs.contains($0.id) }
        let package = CompleteAppPackage(id: app.id, app: app, leftovers: selectedLeftovers)

        Task {
            let result = uninstaller.uninstallCompletely(package: package)
            await MainActor.run {
                self.isUninstalling = false
                if result.success {
                    onComplete()
                    dismiss()
                } else {
                    statusMessage = result.message
                }
            }
        }
    }
}
