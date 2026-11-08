import SwiftUI

public struct JunkCleanerView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @State private var showDeleteSelectedAlert = false
    @State private var itemToDelete: CleanableItem? = nil

    public init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            // PRO HEADER SECTION
            VStack(spacing: 12) {
                // Row 1: Back Navigation + Selection Actions
                HStack(alignment: .center, spacing: 10) {
                    Button {
                        viewModel.selectedTab = .dashboard
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 11, weight: .semibold))
                            Text(loc("action.back"))
                        }
                    }
                    .buttonStyle(ModernSecondaryButtonStyle())

                    Spacer()

                    if !viewModel.cleanableItems.isEmpty {
                        HStack(spacing: 10) {
                            // Integrated Segmented Selection Pill
                            HStack(spacing: 0) {
                                Button {
                                    viewModel.selectAllCleanables()
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 11))
                                            .foregroundColor(.blue)
                                        Text(loc("action.selectAll"))
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                }
                                .buttonStyle(.plain)

                                Divider()
                                    .frame(height: 14)

                                Button {
                                    viewModel.deselectAllCleanables()
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "xmark.circle")
                                            .font(.system(size: 11))
                                            .foregroundColor(.secondary)
                                        Text(loc("action.deselectAll"))
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                }
                                .buttonStyle(.plain)
                            }
                            .background(Color(nsColor: .controlBackgroundColor))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
                            )

                            // Pro Modern Red Delete Button
                            Button(role: .destructive) {
                                showDeleteSelectedAlert = true
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 12, weight: .semibold))
                                    Text(loc("action.deleteSelected"))
                                }
                            }
                            .buttonStyle(ModernPrimaryButtonStyle(isDestructive: true))
                            .disabled(viewModel.selectedCleanableIDs.isEmpty)
                        }
                    }
                }

                // Row 2: Title & Metrics
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(loc("header.junkCleaner"))
                            .font(.title2)
                            .fontWeight(.bold)
                            .lineLimit(1)
                        Text(loc("header.junkCleanerSub"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    // Metrics badge
                    HStack(spacing: 12) {
                        VStack(alignment: .trailing, spacing: 1) {
                            Text(ByteFormatter.string(from: viewModel.selectedCleanableSize))
                                .font(.system(.title3, design: .monospaced))
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Text("\(viewModel.selectedCleanableIDs.count) \(loc("stat.from")) \(viewModel.cleanableItems.count) \(loc("stat.itemsSelected"))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(nsColor: .controlBackgroundColor).opacity(0.8))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
                    )
                }

                // Row 3: Safety Guide Legend Bar
                HStack(spacing: 14) {
                    Text(loc("guide.safetyTitle"))
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.green)
                        Text(loc("guide.safeDelete"))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 11))
                            .foregroundColor(.blue)
                        Text("\(loc("guide.potentialSave")) \(ByteFormatter.string(from: viewModel.totalCleanableSize))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color(nsColor: .windowBackgroundColor))

            Divider()

            if viewModel.cleanableItems.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 56))
                        .foregroundColor(.green.opacity(0.8))
                    Text(viewModel.isScanning ? loc("empty.scanningJunk") : loc("empty.noJunk"))
                        .font(.headline)
                        .foregroundColor(.primary)
                    if !viewModel.isScanning {
                        Button {
                            viewModel.startFullScan()
                        } label: {
                            Text(loc("action.rescan"))
                        }
                        .buttonStyle(ModernSecondaryButtonStyle(accentColor: .blue))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(CleanableType.allCases) { type in
                        let items = viewModel.cleanableItems.filter { $0.type == type }
                        if !items.isEmpty {
                            Section {
                                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                                    ModernListRowContainer(index: index) {
                                        cleanableRow(item)
                                    }
                                    .listRowInsets(EdgeInsets(top: 2, leading: 10, bottom: 2, trailing: 10))
                                    .listRowSeparator(.hidden)
                                }
                            } header: {
                                HStack(spacing: 8) {
                                    Image(systemName: type.iconName)
                                        .foregroundColor(.orange)
                                    Text(type.localizedTitle)
                                        .font(.headline)
                                    Spacer()
                                    Text(type.localizedSafetyLevel)
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.green.opacity(0.12))
                                        .foregroundColor(.green)
                                        .cornerRadius(4)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .listStyle(.inset)
            }
        }
        .confirmationDialog(
            loc("dialog.deleteSelectedTitle"),
            isPresented: $showDeleteSelectedAlert,
            titleVisibility: .visible
        ) {
            Button("\(loc("action.deleteNow")) (\(ByteFormatter.string(from: viewModel.selectedCleanableSize)))", role: .destructive) {
                viewModel.deleteSelectedCleanables()
            }
            Button(loc("action.cancel"), role: .cancel) {}
        } message: {
            Text(loc("dialog.deleteSelectedMsg"))
        }
        .confirmationDialog(
            loc("dialog.deleteItemTitle"),
            isPresented: Binding(
                get: { itemToDelete != nil },
                set: { if !$0 { itemToDelete = nil } }
            ),
            titleVisibility: .visible,
            presenting: itemToDelete
        ) { item in
            Button("\(loc("dialog.deleteItemTitle")) '\(item.name)' (\(item.formattedSize))", role: .destructive) {
                viewModel.deleteCleanableItem(item)
            }
            Button(loc("action.cancel"), role: .cancel) {}
        } message: { item in
            Text(loc("dialog.deleteItemMsg"))
        }
    }

    private func cleanableRow(_ item: CleanableItem) -> some View {
        let isSelected = viewModel.selectedCleanableIDs.contains(item.id)

        return HStack(spacing: 12) {
            Button {
                viewModel.toggleCleanableSelection(id: item.id)
            } label: {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .secondary)
                    .font(.title3)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.body)
                    .fontWeight(.medium)
                Text(item.detail)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(item.url.path)
                    .font(.caption2)
                    .foregroundColor(.secondary.opacity(0.7))
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer()

            let maxSize = viewModel.cleanableItems.first?.size ?? 1
            let fraction = CGFloat(item.size) / CGFloat(max(1, maxSize))
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.red.opacity(0.35))
                    .frame(width: max(4, geo.size.width * fraction), height: 8)
                    .frame(maxHeight: .infinity, alignment: .center)
            }
            .frame(width: 80, height: 20)

            Text(item.formattedSize)
                .font(.system(.body, design: .monospaced))
                .fontWeight(.semibold)
                .frame(width: 85, alignment: .trailing)

            Button {
                viewModel.revealInFinder(url: item.url)
            } label: {
                Image(systemName: "folder.badge.gearshape")
            }
            .buttonStyle(ModernRowActionStyle(tint: .secondary))
            .help(loc("help.openInFinder"))

            Button(role: .destructive) {
                itemToDelete = item
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(ModernRowActionStyle(isDanger: true))
            .help(loc("help.deleteItem"))
        }
        .padding(.vertical, 4)
    }
}
