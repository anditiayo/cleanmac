import SwiftUI

public final class LocalizationManager: ObservableObject {
    public static let shared = LocalizationManager()

    @AppStorage("appLanguage") public var currentLanguageRaw: String = AppLanguage.indonesian.rawValue

    public var language: AppLanguage {
        get { AppLanguage(rawValue: currentLanguageRaw) ?? .indonesian }
        set {
            currentLanguageRaw = newValue.rawValue
            objectWillChange.send()
        }
    }

    public func text(_ key: String) -> String {
        let isId = (language == .indonesian)
        switch key {
        // Navigation
        case "nav.dashboard": return isId ? "Dashboard" : "Dashboard"
        case "nav.allFolders": return isId ? "Semua Folder" : "All Folders"
        case "nav.junkCleaner": return isId ? "Pembersih Sampah" : "Junk Cleaner"
        case "nav.apps": return isId ? "Aplikasi" : "Applications"
        case "nav.files": return isId ? "File Besar" : "Large Files"
        case "nav.caches": return isId ? "Cache & Logs" : "Caches & Logs"

        // Actions
        case "action.scan": return isId ? "Mulai Scan" : "Start Scan"
        case "action.scanning": return isId ? "Memindai..." : "Scanning..."
        case "action.back": return isId ? "Dashboard" : "Dashboard"
        case "action.selectAll": return isId ? "Pilih Semua" : "Select All"
        case "action.deselectAll": return isId ? "Batal Pilih" : "Deselect All"
        case "action.deleteSelected": return isId ? "Hapus Yang Dipilih" : "Delete Selected"
        case "action.cleanAllCaches": return isId ? "Bersihkan Semua Cache" : "Clean All Caches"
        case "action.sortLargest": return isId ? "Terbesar" : "Largest"
        case "action.sortSmallest": return isId ? "Terkecil" : "Smallest"
        case "action.cancel": return isId ? "Batal" : "Cancel"
        case "action.allowAndScan": return isId ? "Izinkan & Mulai Scan" : "Allow & Start Scan"
        case "action.seeAll": return isId ? "Lihat Semua" : "See All"

        // Headers
        case "header.allFolders": return isId ? "Semua Folder & System Data" : "All Folders & System Data"
        case "header.allFoldersSub": return isId ? "Analisis seluruh penggunaan direktori di sistem" : "Deep analysis of system directory storage usage"
        case "header.junkCleaner": return isId ? "Pembersih File Aman Dihapus" : "Safe-to-Remove Junk Cleaner"
        case "header.junkCleanerSub": return isId ? "Cache build, temporary log, package manager cache, dan installer sisa" : "Build cache, temporary logs, package manager cache, and residual installers"
        case "header.apps": return isId ? "Aplikasi Terinstal" : "Installed Applications"
        case "header.appsSub": return isId ? "Kelola aplikasi terpasang & copot sisa berkas secara tuntas (Uninstaller)" : "Manage installed apps & completely remove leftovers (Uninstaller)"
        case "header.files": return isId ? "File & Folder Besar" : "Large Files & Folders"
        case "header.filesSub": return isId ? "Berkas pengguna (>10 MB) di Downloads, Dokumen, Desktop, Movies & Pictures" : "User files (>10 MB) in Downloads, Documents, Desktop, Movies & Pictures"
        case "header.caches": return isId ? "Cache & Temporary Files" : "Cache & Temporary Files"
        case "header.cachesSub": return isId ? "Berkas cache aplikasi dan log diagnostik di folder ~/Library/Caches" : "Application caches and diagnostic logs in ~/Library/Caches"

        // Safety Guides
        case "guide.safetyTitle": return isId ? "Panduan Keamanan:" : "Safety Guide:"
        case "guide.safe": return isId ? "Aman Dihapus" : "Safe to Delete"
        case "guide.caution": return isId ? "Hati-hati (Data Pengguna)" : "Caution (User Data)"
        case "guide.critical": return isId ? "Proteksi Sistem" : "System Protected"
        case "guide.quickLook": return isId ? "Tekan Spasi untuk Pratinjau Cepat (Quick Look)" : "Press Spacebar for Quick Look Preview"
        case "guide.uninstaller": return isId ? "Copot Bersih Termasuk Berkas Sisa di ~/Library" : "Clean uninstall including leftovers in ~/Library"
        case "guide.cacheSafety": return isId ? "Aman Dihapus (Sistem akan membuat ulang otomatis jika diperlukan)" : "Safe to delete (System will recreate automatically when needed)"

        // Search placeholders
        case "search.folder": return isId ? "Cari folder..." : "Search folders..."
        case "search.app": return isId ? "Cari aplikasi..." : "Search apps..."
        case "search.file": return isId ? "Cari file..." : "Search files..."
        case "search.cache": return isId ? "Cari cache..." : "Search caches..."

        // Categories
        case "cat.all": return isId ? "Semua Kategori" : "All Categories"
        case "cat.title": return isId ? "Kategori" : "Category"

        // Dashboard
        case "dash.title": return isId ? "CleanMac Storage" : "CleanMac Storage"
        case "dash.cardAllFolders": return isId ? "Semua Folder" : "All Folders"
        case "dash.cardCleanable": return isId ? "Bisa Dihapus" : "Cleanable"
        case "dash.cardApps": return isId ? "Aplikasi" : "Applications"
        case "dash.cardLargeFiles": return isId ? "File Besar" : "Large Files"
        case "dash.cardCaches": return isId ? "Cache & Logs" : "Caches & Logs"
        case "dash.cardSystemData": return isId ? "System Data" : "System Data"
        case "dash.catBreakdown": return isId ? "Penggunaan Berdasarkan Kategori" : "Usage by Category"
        case "dash.catBreakdownSub": return isId ? "Rincian alokasi penyimpanan Macintosh HD (gaya macOS Settings)" : "Macintosh HD storage allocation breakdown (macOS Settings style)"
        case "dash.topApps": return isId ? "Top 5 Aplikasi Terbesar" : "Top 5 Largest Applications"
        case "dash.topFiles": return isId ? "Top 5 File / Data Terbesar" : "Top 5 Largest Files"

        // Permission Sheet
        case "perm.title": return isId ? "Izin Pemindaian" : "Scan Permissions"
        case "perm.badge": return isId ? "Konfirmasi Sekali" : "One-Time Confirm"
        case "perm.sub": return isId ? "Pilih modul & area yang diizinkan untuk dipindai oleh CleanMac:" : "Select modules & directories allowed to be scanned by CleanMac:"
        case "perm.remember": return isId ? "Ingat izin ini (muncul sekali saja)" : "Remember this permission (show once only)"
        case "perm.rememberSub": return isId ? "— Scan berikutnya akan langsung berjalan otomatis" : "— Next scans will run automatically"

        // Footer
        case "footer.theme": return isId ? "Tema:" : "Theme:"
        case "footer.language": return isId ? "Bahasa:" : "Language:"
        case "footer.about": return isId ? "Tentang & Donasi (Yogi Anditia)" : "About & Donate (Yogi Anditia)"

        default:
            return key
        }
    }
}

public func loc(_ key: String) -> String {
    LocalizationManager.shared.text(key)
}
