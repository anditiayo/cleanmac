import SwiftUI
import AppKit

public enum NavigationTab: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case allFolders = "Semua Folder"
    case junkCleaner = "Pembersih Sampah"
    case apps = "Aplikasi"
    case files = "File Besar"
    case caches = "Cache & Logs"

    public var id: String { rawValue }

    public var iconName: String {
        switch self {
        case .dashboard: return "gauge.medium"
        case .allFolders: return "folder.badge.questionmark"
        case .junkCleaner: return "sparkles"
        case .apps: return "app.badge.fill"
        case .files: return "doc.badge.gearshape.fill"
        case .caches: return "trash.fill"
        }
    }
}

public struct CategoryUsage: Identifiable {
    public let id: String
    public let category: StorageCategory
    public let size: Int64

    public var formattedSize: String {
        ByteFormatter.string(from: size)
    }
}

@MainActor
public final class DashboardViewModel: ObservableObject {
    @Published public var diskInfo: DiskInfo = .empty
    @Published public var applications: [AppInfo] = []
    @Published public var largeFiles: [FileInfo] = []
    @Published public var cacheFiles: [FileInfo] = []
    @Published public var cleanableItems: [CleanableItem] = []
    @Published public var selectedCleanableIDs: Set<String> = []
    @Published public var directorySizes: [DeepStorageScanner.DirectorySize] = []
    @Published public var isScanning: Bool = false
    @Published public var currentStatus: String = "Ready"
    @Published public var selectedTab: NavigationTab = .dashboard
    @Published public var searchText: String = ""

    private let diskAnalyzer = DiskAnalyzer()
    private let appScanner = AppScanner()
    private let fileScanner = FileScanner()
    private let cacheScanner = CacheScanner()
    private let junkScanner = JunkCleanerScanner()
    private let deepScanner = DeepStorageScanner()

    public init() {
        refreshDiskInfo()
    }

    public func refreshDiskInfo() {
        diskInfo = diskAnalyzer.analyzeMainDisk()
    }

    public func startFullScan() {
        guard !isScanning else { return }
        isScanning = true
        currentStatus = "Reading disk usage..."

        Task { [weak self] in
            guard let self = self else { return }
            self.refreshDiskInfo()

            // 1. Deep directory scan first (most comprehensive)
            self.currentStatus = "Deep scan: menganalisis semua folder..."
            let dirs = await self.deepScanner.scanAllDirectories { [weak self] status in
                Task { @MainActor [weak self] in
                    self?.currentStatus = status
                }
            }
            self.directorySizes = dirs

            // 2. App scan
            self.currentStatus = "Scanning installed applications..."
            let apps = await self.appScanner.scanApplications { [weak self] current, name in
                Task { @MainActor [weak self] in
                    self?.currentStatus = "Scanning app: \(name)"
                }
            }
            self.applications = apps

            // 3. Large files (lower threshold to 10 MB)
            self.currentStatus = "Scanning large user files..."
            let files = await self.fileScanner.scanLargeFiles(minSizeBytes: 10 * 1024 * 1024, maxResults: 200) { [weak self] folder in
                Task { @MainActor [weak self] in
                    self?.currentStatus = "Scanning folder: \(folder)"
                }
            }
            self.largeFiles = files

            // 4. Caches
            self.currentStatus = "Scanning cache directories..."
            let caches = await self.cacheScanner.scanCaches { [weak self] folder in
                Task { @MainActor [weak self] in
                    self?.currentStatus = "Checking caches: \(folder)"
                }
            }
            self.cacheFiles = caches

            // 5. Cleanable junk
            self.currentStatus = "Scanning cleanable junk files..."
            let cleanables = await self.junkScanner.scanCleanableItems { [weak self] status in
                Task { @MainActor [weak self] in
                    self?.currentStatus = status
                }
            }
            self.cleanableItems = cleanables
            self.selectedCleanableIDs = Set(cleanables.map { $0.id })

            self.isScanning = false
            self.currentStatus = "Scan selesai! Ditemukan \(dirs.count) folder, \(apps.count) app, \(files.count) file besar, \(cleanables.count) item sampah."
        }
    }

    public var totalAppsSize: Int64 {
        applications.reduce(0) { $0 + $1.size }
    }

    public var totalLargeFilesSize: Int64 {
        largeFiles.reduce(0) { $0 + $1.size }
    }

    public var totalCachesSize: Int64 {
        cacheFiles.reduce(0) { $0 + $1.size }
    }

    public var totalCleanableSize: Int64 {
        cleanableItems.reduce(0) { $0 + $1.size }
    }

    public var selectedCleanableSize: Int64 {
        cleanableItems.filter { selectedCleanableIDs.contains($0.id) }.reduce(0) { $0 + $1.size }
    }

    public var totalDirectorySizesScanned: Int64 {
        directorySizes.reduce(0) { $0 + $1.size }
    }

    public func toggleCleanableSelection(id: String) {
        if selectedCleanableIDs.contains(id) {
            selectedCleanableIDs.remove(id)
        } else {
            selectedCleanableIDs.insert(id)
        }
    }

    public func selectAllCleanables() {
        selectedCleanableIDs = Set(cleanableItems.map { $0.id })
    }

    public func deselectAllCleanables() {
        selectedCleanableIDs.removeAll()
    }

    public func deleteCleanableItem(_ item: CleanableItem) {
        if item.type == .trash {
            if let contents = try? FileManager.default.contentsOfDirectory(at: item.url, includingPropertiesForKeys: nil) {
                for file in contents {
                    try? FileManager.default.removeItem(at: file)
                }
            }
        } else {
            try? FileManager.default.removeItem(at: item.url)
        }
        cleanableItems.removeAll { $0.id == item.id }
        selectedCleanableIDs.remove(item.id)
        refreshDiskInfo()
    }

    public func deleteSelectedCleanables() {
        let itemsToDelete = cleanableItems.filter { selectedCleanableIDs.contains($0.id) }
        var count = 0
        for item in itemsToDelete {
            deleteCleanableItem(item)
            count += 1
        }
        refreshDiskInfo()
        currentStatus = "Berhasil menghapus \(count) item sampah!"
    }

    // Use deep scanner data for category breakdown (much more accurate)
    public var categoryUsages: [CategoryUsage] {
        var map: [StorageCategory: Int64] = [:]

        for dir in directorySizes {
            map[dir.category, default: 0] += dir.size
        }

        // Fallback to old method if deep scan hasn't run
        if map.isEmpty {
            map[.apps] = totalAppsSize
            map[.cache] = totalCachesSize
            for file in largeFiles {
                map[file.category, default: 0] += file.size
            }
        }

        return StorageCategory.allCases.compactMap { cat in
            guard let size = map[cat], size > 0 else { return nil }
            return CategoryUsage(id: cat.rawValue, category: cat, size: size)
        }.sorted { $0.size > $1.size }
    }

    public func revealInFinder(url: URL) {
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    public func moveToTrash(url: URL) -> Bool {
        do {
            var resultingURL: NSURL?
            try FileManager.default.trashItem(at: url, resultingItemURL: &resultingURL)

            applications.removeAll { $0.url == url }
            largeFiles.removeAll { $0.url == url }
            cacheFiles.removeAll { $0.url == url }
            refreshDiskInfo()
            return true
        } catch {
            currentStatus = "Gagal memindahkan ke Trash: \(error.localizedDescription)"
            return false
        }
    }

    public func cleanAllCaches() {
        var count = 0
        for cache in cacheFiles {
            do {
                var resultingURL: NSURL?
                try FileManager.default.trashItem(at: cache.url, resultingItemURL: &resultingURL)
                count += 1
            } catch {
                continue
            }
        }
        cacheFiles.removeAll()
        refreshDiskInfo()
        currentStatus = "Berhasil membersihkan \(count) folder cache!"
    }
}
