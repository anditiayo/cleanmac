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
            list = list.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.url.path.localizedCaseInsensitiveContains(searchText)
            }
        }
        return list
    }

    private var totalSizeDisplayed: Int64 {
        currentItems.reduce(0) { $0 + $1.size }
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            VStack(alignment: .leading, spacing: 12) {
                // Navigation Bar with Back Button
                HStack(spacing: 12) {
                    if navigationStack.isEmpty {
                        // Button Back to Dashboard
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
                    } else {
                        // Button Back to previous folder / root
                        Button {
                            navigationStack.removeLast()
                            if let previous = navigationStack.last {
                                loadFolder(previous)
                            } else {
                                currentSubitems = []
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text(navigationStack.count > 1 ? navigationStack[navigationStack.count - 2].name : "Semua Folder")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.regular)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(navigationStack.isEmpty ? "Analisis Semua Folder & System Data" : navigationStack.last!.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .lineLimit(1)
                        Text("Total terdeteksi: \(ByteFormatter.string(from: totalSizeDisplayed)) • \(currentItems.count) item")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    if navigationStack.isEmpty {
                        Picker("Kategori", selection: $selectedCategory) {
                            Text("Semua").tag(StorageCategory?.none)
                            ForEach(StorageCategory.allCases) { cat in
                                Text(cat.rawValue).tag(StorageCategory?.some(cat))
                            }
                        }
                        .frame(width: 130)
                    }

                    // Search field
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Cari folder...", text: $searchText)
                            .textFieldStyle(.plain)
                            .frame(width: 130)
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
                }

                // Breadcrumb path when drilled down
                if !navigationStack.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "folder")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Button("Semua Folder") {
                            navigationStack.removeAll()
                            currentSubitems = []
                        }
                        .buttonStyle(.plain)
                        .font(.caption)
                        .foregroundColor(.blue)

                        ForEach(Array(navigationStack.enumerated()), id: \.offset) { index, item in
                            Text("/")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(item.name)
                                .font(.caption)
                                .fontWeight(index == navigationStack.count - 1 ? .bold : .regular)
                                .foregroundColor(index == navigationStack.count - 1 ? .primary : .blue)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            .padding()

            Divider()

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
                    Text(viewModel.isScanning ? "Sedang memindai semua folder..." : "Tidak ada folder besar di lokasi ini.")
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
                            .help("Buka isi folder ini")
                            .buttonStyle(.borderless)
                        }

                        Button {
                            viewModel.revealInFinder(url: dir.url)
                        } label: {
                            Image(systemName: "folder.badge.gearshape")
                        }
                        .help("Tampilkan di Finder")
                        .buttonStyle(.borderless)

                        Button(role: .destructive) {
                            folderToDelete = dir
                            showDeleteAlert = true
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
            Text("Folder '\(folder.name)' (\(folder.formattedSize)) akan dipindahkan ke Trash.")
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
