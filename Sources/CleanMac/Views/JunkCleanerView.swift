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
            // Top Summary Bar
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Pembersih File Aman Dihapus")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("File cache, log sistem, build cache, dan installer bekas yang aman dibersihkan.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    if !viewModel.cleanableItems.isEmpty {
                        Button(role: .destructive) {
                            showDeleteSelectedAlert = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "trash.fill")
                                Text("Hapus Yang Dipilih (\(ByteFormatter.string(from: viewModel.selectedCleanableSize)))")
                                    .fontWeight(.semibold)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        .disabled(viewModel.selectedCleanableIDs.isEmpty)
                    }
                }

                HStack {
                    Text("Ditemukan: \(viewModel.cleanableItems.count) item • Potensi penghematan: \(ByteFormatter.string(from: viewModel.totalCleanableSize))")
                        .font(.caption)
                        .foregroundColor(.primary)

                    Spacer()

                    if !viewModel.cleanableItems.isEmpty {
                        Button("Pilih Semua") {
                            viewModel.selectAllCleanables()
                        }
                        .buttonStyle(.plain)
                        .font(.caption)
                        .foregroundColor(.blue)

                        Text("•").foregroundColor(.secondary)

                        Button("Batal Pilih") {
                            viewModel.deselectAllCleanables()
                        }
                        .buttonStyle(.plain)
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                }
            }
            .padding()
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

            Text(item.formattedSize)
                .font(.system(.body, design: .monospaced))
                .fontWeight(.semibold)

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

