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

    public func localizedTitle(for language: AppLanguage) -> String {
        switch self {
        case .dashboard: return "Dashboard"
        case .allFolders: return language == .indonesian ? "Semua Folder" : "All Folders"
        case .junkCleaner: return language == .indonesian ? "Pembersih Sampah" : "Junk Cleaner"
        case .apps: return language == .indonesian ? "Aplikasi" : "Applications"
        case .files: return language == .indonesian ? "File Besar" : "Large Files"
        case .caches: return "Cache & Logs"
        }
    }

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
    @Published public var showScanPermissionSheet: Bool = false
    @Published public var scanPermissions = ScanPermissions()

    private let defaults = UserDefaults(suiteName: "com.cleanmac.app") ?? UserDefaults.standard

    public var hasAllowedScanPermission: Bool {
        get {
            defaults.bool(forKey: "hasAllowedScanPermission") || UserDefaults.standard.bool(forKey: "hasAllowedScanPermission")
        }
        set {
            defaults.set(newValue, forKey: "hasAllowedScanPermission")
            UserDefaults.standard.set(newValue, forKey: "hasAllowedScanPermission")
            defaults.synchronize()
            UserDefaults.standard.synchronize()
        }
    }

    private let diskAnalyzer = DiskAnalyzer()
    private let appScanner = AppScanner()
    private let fileScanner = FileScanner()
    private let cacheScanner = CacheScanner()
    private let junkScanner = JunkCleanerScanner()
    private let deepScanner = DeepStorageScanner()

    public init() {
        refreshDiskInfo()
        loadSavedPermissions()
    }

    private func loadSavedPermissions() {
        if let data = defaults.data(forKey: "savedScanPermissions") ?? UserDefaults.standard.data(forKey: "savedScanPermissions"),
           let saved = try? JSONDecoder().decode(ScanPermissions.self, from: data) {
            self.scanPermissions = saved
        }
    }

    public func refreshDiskInfo() {
        diskInfo = diskAnalyzer.analyzeMainDisk()
    }

    public func requestScan() {
        if !hasAllowedScanPermission {
            showScanPermissionSheet = true
        } else {
            startScanWithOptions()
        }
    }

    public func saveAndApplyPermissions(_ permissions: ScanPermissions, remember: Bool) {
        self.scanPermissions = permissions
        if let data = try? JSONEncoder().encode(permissions) {
            defaults.set(data, forKey: "savedScanPermissions")
            UserDefaults.standard.set(data, forKey: "savedScanPermissions")
        }
        if remember {
            self.hasAllowedScanPermission = true
        }
    }

    public func startScanWithOptions() {
        guard !isScanning else { return }
        isScanning = true
        currentStatus = loc("status.readingDisk")

        Task { [weak self] in
            guard let self = self else { return }
            self.refreshDiskInfo()

            var dirs: [DeepStorageScanner.DirectorySize] = self.directorySizes
            if self.scanPermissions.scanDeepDirectories {
                self.currentStatus = loc("status.deepScan")
                dirs = await self.deepScanner.scanAllDirectories { [weak self] status in
                    Task { @MainActor [weak self] in
                        self?.currentStatus = status
                    }
                }
                self.directorySizes = dirs
            }

            var apps: [AppInfo] = self.applications
            if self.scanPermissions.scanApplications {
                self.currentStatus = loc("status.scanningApps")
                apps = await self.appScanner.scanApplications { [weak self] _, name in
                    Task { @MainActor [weak self] in
                        self?.currentStatus = "\(loc("status.scanningApp")) \(name)"
                    }
                }
                self.applications = apps
            }

            var files: [FileInfo] = self.largeFiles
            if self.scanPermissions.scanLargeFiles {
                self.currentStatus = loc("status.scanningLargeFiles")
                files = await self.fileScanner.scanLargeFiles(minSizeBytes: 10 * 1024 * 1024, maxResults: 200) { [weak self] folder in
                    Task { @MainActor [weak self] in
                        self?.currentStatus = "\(loc("status.scanningFolder")) \(folder)"
                    }
                }
                self.largeFiles = files
            }

            var caches: [FileInfo] = self.cacheFiles
            if self.scanPermissions.scanCaches {
                self.currentStatus = loc("status.scanningCaches")
                caches = await self.cacheScanner.scanCaches { [weak self] folder in
                    Task { @MainActor [weak self] in
                        self?.currentStatus = "\(loc("status.checkingCaches")) \(folder)"
                    }
                }
                self.cacheFiles = caches
            }

            var cleanables: [CleanableItem] = self.cleanableItems
            if self.scanPermissions.scanJunk {
                self.currentStatus = loc("status.scanningJunk")
                cleanables = await self.junkScanner.scanCleanableItems { [weak self] status in
                    Task { @MainActor [weak self] in
                        self?.currentStatus = status
                    }
                }
                self.cleanableItems = cleanables
                self.selectedCleanableIDs = Set(cleanables.map { $0.id })
            }

            self.isScanning = false
            self.currentStatus = "\(loc("status.scanDone")) \(loc("status.found")) \(dirs.count) \(loc("status.folders")), \(apps.count) \(loc("status.apps")), \(files.count) \(loc("status.largeFiles")), \(cleanables.count) \(loc("status.junkItems"))."
        }
    }

    public func startFullScan() {
        startScanWithOptions()
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
        min(directorySizes.reduce(0) { $0 + $1.size }, diskInfo.usedSpace > 0 ? diskInfo.usedSpace : 250 * 1024 * 1024 * 1024)
    }

    public var systemDataSize: Int64 {
        let known = totalAppsSize + totalCachesSize + totalLargeFilesSize
        return max(0, diskInfo.usedSpace - known)
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
        currentStatus = "\(loc("status.deletedJunk")) \(count) \(loc("status.junkItemsSuffix"))"
    }

    public var categoryUsages: [CategoryUsage] {
        var map: [StorageCategory: Int64] = [:]

        // 1. Applications is strictly the apps installed
        map[.apps] = totalAppsSize

        // 2. Cache
        map[.cache] = totalCachesSize

        // 3. Collect specific categories
        for dir in directorySizes {
            if dir.category != .apps && dir.category != .other {
                map[dir.category, default: 0] += dir.size
            }
        }

        // 4. System Data & Other represents remaining used space
        if diskInfo.usedSpace > 0 {
            let knownUsed = map.values.reduce(0, +)
            let systemData = max(0, diskInfo.usedSpace - knownUsed)
            if systemData > 0 {
                map[.other] = systemData
            }
        }

        let activeCategories = StorageCategory.allCases.filter { $0 != .other }.compactMap { cat -> CategoryUsage? in
            guard let size = map[cat], size > 0 else { return nil }
            return CategoryUsage(id: cat.rawValue, category: cat, size: size)
        }.sorted { $0.size > $1.size }

        var result = activeCategories
        if let systemSize = map[.other], systemSize > 0 {
            result.append(CategoryUsage(id: StorageCategory.other.rawValue, category: .other, size: systemSize))
        }

        return result
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
            currentStatus = "\(loc("status.trashFailed")) \(error.localizedDescription)"
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
        currentStatus = "\(loc("status.cleanedCache")) \(count) \(loc("status.cacheFolders"))"
    }
}
