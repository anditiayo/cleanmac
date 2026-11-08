import SwiftUI

public struct DirectorySizesView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @State private var searchText: String = ""
    @State private var selectedCategory: StorageCategory? = nil

    // Drill down states
    @State private var navigationStack: [DeepStorageScanner.DirectorySize] = []
    @State private var currentSubitems: [DeepStorageScanner.DirectorySize] = []
    @State private var isLoadingSubitems: Bool = false

    // Deletion states
    @State private var folderToDelete: DeepStorageScanner.DirectorySize? = nil
    @State private var showDeleteAlert: Bool = false

    private let deepScanner = DeepStorageScanner()

    public init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
    }

    private var currentItems: [DeepStorageScanner.DirectorySize] {
        let baseList = navigationStack.isEmpty ? viewModel.directorySizes : currentSubitems
        var list = baseList

        if let cat = selectedCategory, navigationStack.isEmpty {
            list = list.filter { $0.category == cat }
        }

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            list = list.filter {
                $0.name.localizedCaseInsensitiveContains(query) ||
                $0.url.path.localizedCaseInsensitiveContains(query)
            }
        }
        return list
    }

    private var totalSizeDisplayed: Int64 {
        currentItems.reduce(0) { $0 + $1.size }
    }

    public var body: some View {
        VStack(spacing: 0) {
            // PRO HEADER SECTION
            VStack(spacing: 12) {
                // Top Control Row: Navigation + Search + Filter
                HStack(alignment: .center, spacing: 10) {
                    // Back / Up Button
                    if navigationStack.isEmpty {
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
                    } else {
                        Button {
                            navigationStack.removeLast()
                            if let previous = navigationStack.last {
                                loadFolder(previous)
                            } else {
                                currentSubitems = []
                            }
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 11, weight: .semibold))
                                Text("Kembali")
                                    .font(.subheadline)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.blue.opacity(0.12))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }

                    // Breadcrumb Path (when inside subfolders)
                    if !navigationStack.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 4) {
                                Button("Semua Folder") {
                                    navigationStack.removeAll()
                                    currentSubitems = []
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                                .buttonStyle(.plain)

                                ForEach(Array(navigationStack.enumerated()), id: \.offset) { index, item in
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 9))
                                        .foregroundColor(.secondary)
                                    Text(item.name)
                                        .font(.caption)
                                        .fontWeight(index == navigationStack.count - 1 ? .bold : .regular)
                                        .foregroundColor(index == navigationStack.count - 1 ? .primary : .secondary)
                                }
                            }
                        }
                    }

                    Spacer()

                    // Category Filter Menu (Pro Dropdown)
                    if navigationStack.isEmpty {
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
                    }

                    // Native-styled Search Field
                    HStack(spacing: 6) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        TextField("Cari folder...", text: $searchText)
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
                }

                // Row 2: Clean Page Title & Stats Badge
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(navigationStack.isEmpty ? "Semua Folder & System Data" : navigationStack.last!.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .lineLimit(1)
                        Text(navigationStack.isEmpty ? "Analisis seluruh penggunaan direktori di sistem" : navigationStack.last!.url.path)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }

                    Spacer()

                    // Metrics Badge
                    HStack(spacing: 12) {
                        VStack(alignment: .trailing, spacing: 1) {
                            Text(ByteFormatter.string(from: totalSizeDisplayed))
                                .font(.system(.title3, design: .monospaced))
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Text("\(currentItems.count) folder dianalisis")
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

                // Safety Guide Legend Bar
                HStack(spacing: 14) {
                    Text("Panduan Keamanan:")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundColor(.green)
                        Text("Aman Dihapus")
                            .foregroundColor(.secondary)
                    }
                    .font(.caption2)

                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Hati-hati (Data Pengguna)")
                            .foregroundColor(.secondary)
                    }
                    .font(.caption2)

                    HStack(spacing: 4) {
                        Image(systemName: "lock.shield.fill")
                            .foregroundColor(.red)
                        Text("Proteksi Sistem")
                            .foregroundColor(.secondary)
                    }
                    .font(.caption2)

                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(nsColor: .separatorColor).opacity(0.12))
                .cornerRadius(6)
            }
            .padding(.horizontal, 18)
            .padding(.top, 14)
            .padding(.bottom, 12)
            .background(Color(nsColor: .windowBackgroundColor))

            Divider()

            // LIST CONTENT
            if isLoadingSubitems {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Menghitung ukuran subfolder...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if currentItems.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "folder.badge.questionmark")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text(viewModel.isScanning ? "Sedang memindai semua folder..." : "Tidak ada folder yang cocok.")
                        .foregroundColor(.secondary)
                    if !viewModel.isScanning && navigationStack.isEmpty {
                        Button("Mulai Scan") {
                            viewModel.startFullScan()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(currentItems) { dir in
                    HStack(spacing: 14) {
                        Image(systemName: dir.hasChildren ? "folder.fill" : dir.category.iconName)
                            .foregroundColor(dir.category.color)
                            .font(.title3)
                            .frame(width: 30)

                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 6) {
                                Text(dir.name)
                                    .font(.body)
                                    .fontWeight(.medium)

                                Text(dir.category.rawValue)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(dir.category.color.opacity(0.15))
                                    .foregroundColor(dir.category.color)
                                    .cornerRadius(4)

                                // Safety Badge
                                HStack(spacing: 3) {
                                    Image(systemName: dir.safetyLevel.iconName)
                                    Text(dir.safetyLevel.rawValue)
                                }
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(dir.safetyLevel.badgeColor.opacity(0.15))
                                .foregroundColor(dir.safetyLevel.badgeColor)
                                .cornerRadius(4)

                                if dir.isClonedOrVirtual {
                                    Text("APFS Clone")
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.purple.opacity(0.15))
                                        .foregroundColor(.purple)
                                        .cornerRadius(4)
                                        .help("File ini merupakan clone Copy-on-Write APFS yang membagikan blok fisik yang sama di disk")
                                }
                            }

                            Text(dir.url.path)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }

                        Spacer()

                        // Relative visual size bar
                        let maxSize = currentItems.first?.size ?? 1
                        let fraction = CGFloat(dir.size) / CGFloat(maxSize)
                        GeometryReader { geo in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(dir.category.color.opacity(0.35))
                                .frame(width: max(4, geo.size.width * fraction), height: 8)
                                .frame(maxHeight: .infinity, alignment: .center)
                        }
                        .frame(width: 80, height: 20)

                        Text(dir.formattedSize)
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.semibold)
                            .frame(width: 85, alignment: .trailing)

                        // Drill down button if it has children
                        if dir.hasChildren {
                            Button {
                                navigationStack.append(dir)
                                loadFolder(dir)
                            } label: {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.blue)
                            }
                            .help("Buka isi subfolder ini")
                            .buttonStyle(.borderless)
                        }

                        Button {
                            viewModel.revealInFinder(url: dir.url)
                        } label: {
                            Image(systemName: "folder.badge.gearshape")
                        }
                        .help("Tampilkan di Finder")
                        .buttonStyle(.borderless)

                        // Safety delete protection: System critical folders cannot be deleted!
                        if dir.safetyLevel == .critical {
                            Image(systemName: "lock.shield.fill")
                                .foregroundColor(.secondary.opacity(0.7))
                                .frame(width: 16)
                                .help("Folder sistem ini dilindungi demi keamanan macOS dan tidak dapat dihapus.")
                        } else {
                            Button(role: .destructive) {
                                folderToDelete = dir
                                showDeleteAlert = true
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(dir.safetyLevel == .caution ? .orange : .red.opacity(0.85))
                            }
                            .help(dir.safetyLevel == .caution ? "Hati-hati: Folder berisi data pengguna" : "Pindahkan ke Trash")
                            .buttonStyle(.borderless)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.inset)
            }
        }
        .confirmationDialog(
            "Pindahkan ke Trash?",
            isPresented: $showDeleteAlert,
            titleVisibility: .visible,
            presenting: folderToDelete
        ) { folder in
            Button("Pindahkan ke Trash (\(folder.formattedSize))", role: .destructive) {
                _ = viewModel.moveToTrash(url: folder.url)
                if !navigationStack.isEmpty, let parent = navigationStack.last {
                    loadFolder(parent)
                }
            }
            Button("Batal", role: .cancel) {}
        } message: { folder in
            if folder.safetyLevel == .caution {
                Text("⚠️ PERHATIAN: '\(folder.name)' (\(folder.formattedSize)) berisi data aplikasi atau pengguna. Pastikan Anda tidak memerlukan file di dalamnya sebelum memindahkan ke Trash.")
            } else {
                Text("Folder '\(folder.name)' (\(folder.formattedSize)) akan dipindahkan ke Trash.")
            }
        }
    }

    private func loadFolder(_ folder: DeepStorageScanner.DirectorySize) {
        isLoadingSubitems = true
        Task {
            let items = await deepScanner.scanSubdirectories(of: folder.url)
            await MainActor.run {
                self.currentSubitems = items
                self.isLoadingSubitems = false
            }
        }
    }
}
