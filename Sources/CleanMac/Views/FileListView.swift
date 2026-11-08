import SwiftUI

public struct FileListView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @State private var searchText: String = ""
    @State private var selectedCategory: StorageCategory? = nil
    @State private var sortAscending: Bool = false

    @State private var itemToTrash: FileInfo? = nil
    @State private var showTrashConfirm: Bool = false
    @State private var selectedFileForPreview: FileInfo? = nil
    @State private var selectedFileID: String? = nil

    public init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
    }

    private var filteredFiles: [FileInfo] {
        var list = viewModel.largeFiles
        if let cat = selectedCategory {
            list = list.filter { $0.category == cat }
        }
        if !searchText.isEmpty {
            list = list.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.url.path.localizedCaseInsensitiveContains(searchText)
            }
        }
        return list.sorted {
            sortAscending ? $0.size < $1.size : $0.size > $1.size
        }
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header bar
            HStack(spacing: 12) {
                Button {
                    viewModel.selectedTab = .dashboard
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Dashboard")
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)

                VStack(alignment: .leading, spacing: 4) {
                    Text("File & Folder Besar")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Ditemukan \(viewModel.largeFiles.count) file besar (>10 MB) • Total: \(ByteFormatter.string(from: viewModel.totalLargeFilesSize))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Filter by category
                Picker("Kategori", selection: $selectedCategory) {
                    Text("Semua").tag(StorageCategory?.none)
                    ForEach(StorageCategory.allCases) { cat in
                        Text(cat.rawValue).tag(StorageCategory?.some(cat))
                    }
                }
                .frame(width: 130)

                // Search field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Cari file...", text: $searchText)
                        .textFieldStyle(.plain)
                        .frame(width: 140)
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(6)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(8)

                // Sort toggle
                Button {
                    sortAscending.toggle()
                } label: {
                    Label(sortAscending ? "Terkecil" : "Terbesar", systemImage: sortAscending ? "arrow.up.circle" : "arrow.down.circle")
                }
            }
            .padding()

            Divider()

            if filteredFiles.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.badge.gearshape.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text(viewModel.isScanning ? "Sedang memindai file besar..." : "Tidak ada file besar ditemukan.")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(filteredFiles) { file in
                    HStack(spacing: 14) {
                        Image(nsImage: file.icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36, height: 36)

                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 6) {
                                Text(file.name)
                                    .font(.body)
                                    .fontWeight(.medium)

                                Text(file.category.rawValue)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(file.category.color.opacity(0.15))
                                    .foregroundColor(file.category.color)
                                    .cornerRadius(4)
                            }

                            Text(file.url.path)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }

                        Spacer()

                        Text(file.formattedSize)
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.semibold)

                        Button {
                            selectedFileForPreview = file
                        } label: {
                            Image(systemName: "eye")
                                .foregroundColor(.blue)
                        }
                        .help("Quick Look / Pratinjau (Spasi)")
                        .buttonStyle(.borderless)

                        Button {
                            viewModel.revealInFinder(url: file.url)
                        } label: {
                            Image(systemName: "folder.badge.gearshape")
                        }
                        .help("Tampilkan di Finder")
                        .buttonStyle(.borderless)

                        Button(role: .destructive) {
                            itemToTrash = file
                            showTrashConfirm = true
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red.opacity(0.8))
                        }
                        .help("Pindahkan ke Trash")
                        .buttonStyle(.borderless)
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.inset)
                .confirmationDialog(
                    "Pindahkan ke Trash?",
                    isPresented: $showTrashConfirm,
                    titleVisibility: .visible,
                    presenting: itemToTrash
                ) { item in
                    Button("Pindahkan ke Trash (\(item.formattedSize))", role: .destructive) {
                        _ = viewModel.moveToTrash(url: item.url)
                    }
                    Button("Batal", role: .cancel) {}
                } message: { item in
                    Text("Apakah Anda yakin ingin memindahkan '\(item.name)' ke Trash?")
                }
                .sheet(item: $selectedFileForPreview) { targetFile in
                    FileDetailSheet(file: targetFile) {
                        _ = viewModel.moveToTrash(url: targetFile.url)
                    } onReveal: {
                        viewModel.revealInFinder(url: targetFile.url)
                    }
                }
                .background(
                    Button("") {
                        if let first = filteredFiles.first {
                            selectedFileForPreview = first
                        }
                    }
                    .keyboardShortcut(.space, modifiers: [])
                    .opacity(0)
                )
            }
        }
    }
}

