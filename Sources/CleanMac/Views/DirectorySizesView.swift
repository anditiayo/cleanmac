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
                                Text(loc("action.back"))
                            }
                        }
                        .buttonStyle(ModernSecondaryButtonStyle())
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
                                Text(loc("action.backFolder"))
                            }
                        }
                        .buttonStyle(ModernSecondaryButtonStyle(accentColor: .blue))
                    }

                    // Breadcrumb Path
                    if !navigationStack.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 4) {
                                Button(loc("nav.allFolders")) {
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

                    // Category Filter Menu
                    if navigationStack.isEmpty {
                        Menu {
                            Button(loc("cat.all")) {
                                selectedCategory = nil
                            }
                            Divider()
                            ForEach(StorageCategory.allCases) { cat in
                                Button {
                                    selectedCategory = cat
                                } label: {
                                    Label(cat.localizedName, systemImage: cat.iconName)
                                }
                            }
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: selectedCategory == nil ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                                    .foregroundColor(selectedCategory == nil ? .secondary : .blue)
                                Text(selectedCategory?.localizedName ?? loc("cat.title"))
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 8))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .buttonStyle(ModernSecondaryButtonStyle())
                    }

                    // Native-styled Search Field
                    HStack(spacing: 6) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        TextField(loc("search.folder"), text: $searchText)
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

                // Row 2: Page Title & Stats Badge
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(navigationStack.isEmpty ? loc("header.allFolders") : navigationStack.last!.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .lineLimit(1)
                        Text(navigationStack.isEmpty ? loc("header.allFoldersSub") : navigationStack.last!.url.path)
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
                            Text("\(currentItems.count) \(loc("stat.foldersAnalyzed"))")
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
                    Text(loc("guide.safetyTitle"))
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundColor(.green)
                        Text(loc("guide.safe"))
                            .foregroundColor(.secondary)
                    }
                    .font(.caption2)

                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text(loc("guide.caution"))
                            .foregroundColor(.secondary)
                    }
                    .font(.caption2)

                    HStack(spacing: 4) {
                        Image(systemName: "lock.shield.fill")
                            .foregroundColor(.red)
                        Text(loc("guide.critical"))
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
                    Text(loc("empty.loadingSubfolder"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if currentItems.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "folder.badge.questionmark")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text(viewModel.isScanning ? loc("empty.scanningFolders") : loc("empty.noFolderMatch"))
                        .foregroundColor(.secondary)
                    if !viewModel.isScanning && navigationStack.isEmpty {
                        Button {
                            viewModel.startFullScan()
                        } label: {
                            Text(loc("action.startScan"))
                        }
                        .buttonStyle(ModernPrimaryButtonStyle())
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(Array(currentItems.enumerated()), id: \.element.id) { index, dir in
                    ModernListRowContainer(index: index) {
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

                                    Text(dir.category.localizedName)
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
                                        Text(loc("tag.apfsClone"))
                                            .font(.caption2)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.purple.opacity(0.15))
                                            .foregroundColor(.purple)
                                            .cornerRadius(4)
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
                                }
                                .buttonStyle(ModernRowActionStyle(tint: .blue))
                                .help(loc("help.openSubfolder"))
                            }

                            Button {
                                viewModel.revealInFinder(url: dir.url)
                            } label: {
                                Image(systemName: "folder.badge.gearshape")
                            }
                            .buttonStyle(ModernRowActionStyle(tint: .secondary))
                            .help(loc("help.showInFinder"))

                            if dir.safetyLevel == .critical {
                                Image(systemName: "lock.shield.fill")
                                    .foregroundColor(.secondary.opacity(0.7))
                                    .frame(width: 26, height: 26)
                                    .help(loc("help.systemProtected"))
                            } else {
                                Button(role: .destructive) {
                                    folderToDelete = dir
                                    showDeleteAlert = true
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .buttonStyle(ModernRowActionStyle(isDanger: true))
                                .help(dir.safetyLevel == .caution ? loc("help.cautionFolder") : loc("help.moveToTrash"))
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 2, leading: 10, bottom: 2, trailing: 10))
                    .listRowSeparator(.hidden)
                }
                .listStyle(.inset)
            }
        }
        .confirmationDialog(
            loc("dialog.moveToTrash"),
            isPresented: $showDeleteAlert,
            titleVisibility: .visible,
            presenting: folderToDelete
        ) { folder in
            Button("\(loc("dialog.moveToTrashBtn")) (\(folder.formattedSize))", role: .destructive) {
                _ = viewModel.moveToTrash(url: folder.url)
                if !navigationStack.isEmpty, let parent = navigationStack.last {
                    loadFolder(parent)
                }
            }
            Button(loc("action.cancel"), role: .cancel) {}
        } message: { folder in
            if folder.safetyLevel == .caution {
                Text(loc("dialog.cautionWarning"))
            } else {
                Text(loc("dialog.folderWillBeTrashed"))
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
