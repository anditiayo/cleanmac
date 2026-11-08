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
            // PRO HEADER SECTION
            VStack(spacing: 12) {
                // Row 1: Back Navigation + Filter Menu + Search + Sort
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

                    // Category Filter Dropdown
                    Menu {
                        Button("Semua Kategori") {
                            selectedCategory = nil
                        }
                        Divider()
                        ForEach(StorageCategory.allCases) { cat in
                            Button {
                                selectedCategory = cat
                            } label: {
                                Label(cat.rawValue, systemImage: cat.iconName)
                            }
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: selectedCategory == nil ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                                .foregroundColor(selectedCategory == nil ? .secondary : .blue)
                            Text(selectedCategory?.rawValue ?? "Kategori")
                                .font(.subheadline)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
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

                    // Native Search Field
                    HStack(spacing: 6) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        TextField("Cari file...", text: $searchText)
                            .textFieldStyle(.plain)
                            .font(.subheadline)
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .frame(width: 170)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
                    )

                    // Sort button
                    Button {
                        sortAscending.toggle()
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: sortAscending ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                .foregroundColor(.blue)
                            Text(sortAscending ? "Terkecil" : "Terbesar")
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
                }

                // Row 2: Title & Metrics
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("File & Folder Besar")
                            .font(.title2)
                            .fontWeight(.bold)
                            .lineLimit(1)
                        Text("Berkas pengguna (>10 MB) di Downloads, Dokumen, Desktop, Movies & Pictures")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    // Metrics badge
                    HStack(spacing: 12) {
                        VStack(alignment: .trailing, spacing: 1) {
                            Text(ByteFormatter.string(from: viewModel.totalLargeFilesSize))
                                .font(.system(.title3, design: .monospaced))
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Text("\(filteredFiles.count) file ditemukan")
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

                // Row 3: Guide Legend Bar
                HStack(spacing: 14) {
                    Text("Petunjuk:")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    HStack(spacing: 4) {
                        Image(systemName: "space")
                            .font(.system(size: 11))
                            .foregroundColor(.blue)
                        Text("Tekan Spasi untuk Pratinjau Cepat (Quick Look)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "eye.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.purple)
                        Text("Ikon Mata untuk Buka Detail & Folder")
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

                        // Relative visual size bar (matching DirectorySizesView)
                        let maxSize = filteredFiles.first?.size ?? 1
                        let fraction = CGFloat(file.size) / CGFloat(maxSize)
                        GeometryReader { geo in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(file.category.color.opacity(0.35))
                                .frame(width: max(4, geo.size.width * fraction), height: 8)
                                .frame(maxHeight: .infinity, alignment: .center)
                        }
                        .frame(width: 80, height: 20)

                        Text(file.formattedSize)
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.semibold)
                            .frame(width: 85, alignment: .trailing)

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
                                .foregroundColor(.red.opacity(0.85))
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

