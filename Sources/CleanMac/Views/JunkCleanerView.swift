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
                            Text("Dashboard")
                                .font(.subheadline)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
                        )
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    if !viewModel.cleanableItems.isEmpty {
                        HStack(spacing: 8) {
                            // Integrated Segmented Selection Pill
                            HStack(spacing: 0) {
                                Button {
                                    viewModel.selectAllCleanables()
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 11))
                                            .foregroundColor(.blue)
                                        Text("Semua")
                                            .font(.subheadline)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
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
                                        Text("Batal")
                                            .font(.subheadline)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                }
                                .buttonStyle(.plain)
                            }
                            .background(Color(nsColor: .controlBackgroundColor))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
                            )

                            // Pro Red Delete Button
                            Button(role: .destructive) {
                                showDeleteSelectedAlert = true
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 12, weight: .semibold))
                                    Text("Hapus Yang Dipilih")
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(
                                            viewModel.selectedCleanableIDs.isEmpty
                                            ? Color.gray.opacity(0.4)
                                            : Color(red: 0.88, green: 0.22, blue: 0.22)
                                        )
                                )
                                .shadow(color: viewModel.selectedCleanableIDs.isEmpty ? .clear : Color.red.opacity(0.25), radius: 4, x: 0, y: 2)
                            }
                            .buttonStyle(.plain)
                            .disabled(viewModel.selectedCleanableIDs.isEmpty)
                        }
                    }
                }

                // Row 2: Title & Metrics
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Pembersih File Aman Dihapus")
                            .font(.title2)
                            .fontWeight(.bold)
                            .lineLimit(1)
                        Text("Cache build, temporary log, package manager cache, dan installer sisa")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    // Metrics badge (Matching DirectorySizesView)
                    HStack(spacing: 12) {
                        VStack(alignment: .trailing, spacing: 1) {
                            Text(ByteFormatter.string(from: viewModel.selectedCleanableSize))
                                .font(.system(.title3, design: .monospaced))
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Text("\(viewModel.selectedCleanableIDs.count) dari \(viewModel.cleanableItems.count) item dipilih")
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
                    Text("Panduan Keamanan:")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.green)
                        Text("Aman Dihapus (Dipindahkan ke Trash)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 11))
                            .foregroundColor(.blue)
                        Text("Potensi Hemat: \(ByteFormatter.string(from: viewModel.totalCleanableSize))")
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
                    Text(viewModel.isScanning ? "Sedang menganalisis file yang bisa dibersihkan..." : "Sistem Anda bersih! Tidak ada file sampah signifikan.")
                        .font(.headline)
                        .foregroundColor(.primary)
                    if !viewModel.isScanning {
                        Button("Scan Ulang") {
                            viewModel.startFullScan()
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(CleanableType.allCases) { type in
                        let items = viewModel.cleanableItems.filter { $0.type == type }
                        if !items.isEmpty {
                            Section {
                                ForEach(items) { item in
                                    cleanableRow(item)
                                }
                            } header: {
                                HStack(spacing: 8) {
                                    Image(systemName: type.iconName)
                                        .foregroundColor(.orange)
                                    Text(type.rawValue)
                                        .font(.headline)
                                    Spacer()
                                    Text(type.safetyLevel)
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
            "Hapus File Terpilih?",
            isPresented: $showDeleteSelectedAlert,
            titleVisibility: .visible
        ) {
            Button("Hapus Sekarang (\(ByteFormatter.string(from: viewModel.selectedCleanableSize)))", role: .destructive) {
                viewModel.deleteSelectedCleanables()
            }
            Button("Batal", role: .cancel) {}
        } message: {
            Text("File-file ini akan dihapus permanen untuk menghemat ruang disk Anda.")
        }
        .confirmationDialog(
            "Hapus Item Ini?",
            isPresented: Binding(
                get: { itemToDelete != nil },
                set: { if !$0 { itemToDelete = nil } }
            ),
            titleVisibility: .visible,
            presenting: itemToDelete
        ) { item in
            Button("Hapus '\(item.name)' (\(item.formattedSize))", role: .destructive) {
                viewModel.deleteCleanableItem(item)
            }
            Button("Batal", role: .cancel) {}
        } message: { item in
            Text("Item ini akan dihapus dari sistem Anda.")
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

            // Relative visual size bar (matching DirectorySizesView)
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
            .help("Buka di Finder")
            .buttonStyle(.borderless)

            Button(role: .destructive) {
                itemToDelete = item
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.red.opacity(0.85))
            }
            .help("Hapus Item Ini")
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 4)
    }
}

