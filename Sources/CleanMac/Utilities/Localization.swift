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

        // ── System Data Breakdown ──
        case "sysdata.title": return isId ? "Rincian System Data" : "System Data Breakdown"
        case "sysdata.subtitle": return isId ? "Daftar komponen yang menyusun ruang abu-abu (System Data) di macOS" : "Components making up the gray System Data storage on macOS"
        case "sysdata.explanation": return isId
            ? "macOS mengelompokkan file core OS, container aplikasi, snapshot sistem, simulator pengembang, dan memori virtual ke dalam kategori 'System Data'."
            : "macOS groups core OS files, app containers, system snapshots, developer simulators, and virtual memory into 'System Data'."
        case "sysdata.core": return isId ? "macOS System OS (Core)" : "macOS System OS (Core)"
        case "sysdata.coreDesc": return isId ? "Volume sistem tersegel (Sealed System Volume) berisi kernel & binary macOS" : "Sealed System Volume containing the macOS kernel & core system binaries"
        case "sysdata.groupContainers": return isId ? "Group Containers (WhatsApp & Office)" : "Group Containers (WhatsApp & Office)"
        case "sysdata.groupContainersDesc": return isId ? "Data chat WhatsApp, database MS Office, Canva, dan share extension" : "WhatsApp chat media, MS Office databases, Canva, and shared app extensions"
        case "sysdata.appSupport": return isId ? "App Support & Database Lokal" : "App Support & Local Databases"
        case "sysdata.appSupportDesc": return isId ? "Profile Chrome/Brave, Docker, data VS Code, dan database aplikasi lokal" : "Chrome/Brave profiles, Docker storage, VS Code data, and local app databases"
        case "sysdata.devSdk": return isId ? "Android SDK & Developer Tools" : "Android SDK & Developer Tools"
        case "sysdata.devSdkDesc": return isId ? "Android emulator platform, Xcode toolchains, dan SDK runtimes" : "Android emulator images, Xcode toolchains, and SDK platform runtimes"
        case "sysdata.containers": return isId ? "App Containers (Sandboxed)" : "App Containers (Sandboxed)"
        case "sysdata.containersDesc": return isId ? "Container sandbox terisolasi untuk aplikasi dari Mac App Store" : "Isolated sandbox containers for Mac App Store applications"
        case "sysdata.snapshots": return isId ? "APFS Local Snapshots (macOS Update)" : "APFS Local Snapshots (macOS Update)"
        case "sysdata.snapshotsDesc": return isId ? "Cadangan pemulihan lokal otomatis sebelum macOS update & Time Machine" : "Automatic local recovery snapshots created before macOS updates & Time Machine"
        case "sysdata.sysCaches": return isId ? "Cache Sistem, Daemon & Logs" : "System Caches, Daemons & Logs"
        case "sysdata.sysCachesDesc": return isId ? "Cache sementara sistem operasi di /private/var/folders dan daemon" : "Temporary OS caches in /private/var/folders and daemon logs"
        case "sysdata.vmSwap": return isId ? "Sleepimage & Virtual Memory (Swap)" : "Sleepimage & Virtual Memory (Swap)"
        case "sysdata.vmSwapDesc": return isId ? "Memori virtual disk swap & RAM snapshot saat Mac hibernasi" : "Virtual memory disk swap & RAM state saved when Mac sleeps"
        case "sysdata.residual": return isId ? "Sisa File Sistem & Firmlinks macOS" : "Remaining macOS System Files & Firmlinks"
        case "sysdata.residualDesc": return isId ? "Struktur direktori firmlink APFS, font sistem, dan alokasi filesystem macOS" : "APFS firmlink filesystem structures, system fonts, and OS allocations"
        case "sysdata.footerHint": return isId ? "Tips: Gunakan 'Pembersih Sampah' & 'Cache & Logs' untuk mengosongkan ruang yang aman dihapus." : "Tip: Use 'Junk Cleaner' & 'Cache & Logs' to safely free up cleanable space."
        case "sysdata.inspectBtn": return isId ? "Rincian" : "Inspect"

        // ── Cleanable Types ──
        case "clean.appCache": return isId ? "Cache Aplikasi" : "Application Caches"
        case "clean.systemLogs": return isId ? "File Log & Diagnostik" : "System & Diagnostic Logs"
        case "clean.xcode": return isId ? "Xcode DerivedData (Build Cache)" : "Xcode DerivedData (Build Cache)"
        case "clean.installers": return isId ? "Installer Bekas (.dmg / .pkg)" : "Old Installers (.dmg / .pkg)"
        case "clean.trash": return isId ? "Tempat Sampah (Trash)" : "Trash"
        case "clean.devCache": return isId ? "Cache Package Manager (npm/cargo)" : "Package Manager Caches (npm/cargo)"
        case "clean.safetyRecreated": return isId ? "Sangat Aman (dibuat ulang otomatis jika dibutuhkan)" : "Very Safe (automatically recreated when needed)"
        case "clean.safetyLogs": return isId ? "Sangat Aman (hanya catatan log teks)" : "Very Safe (plain text system logs)"
        case "clean.safetyXcode": return isId ? "Aman (hanya cache build, Xcode akan compile ulang)" : "Safe (build cache, Xcode recompiles)"
        case "clean.safetyInstallers": return isId ? "Aman jika aplikasi sudah terinstall" : "Safe if apps are already installed"
        case "clean.safetyTrash": return isId ? "Aman (file yang sudah dibuang ke Trash)" : "Safe (files already in Trash)"
        case "clean.safetyDevCache": return isId ? "Aman (cache dapat diunduh ulang)" : "Safe (packages can be re-downloaded)"

        // ── Navigation ──
        case "nav.dashboard": return "Dashboard"
        case "nav.allFolders": return isId ? "Semua Folder" : "All Folders"
        case "nav.junkCleaner": return isId ? "Pembersih Sampah" : "Junk Cleaner"
        case "nav.apps": return isId ? "Aplikasi" : "Applications"
        case "nav.files": return isId ? "File Besar" : "Large Files"
        case "nav.caches": return "Cache & Logs"

        // ── Actions ──
        case "action.scan": return "SCAN"
        case "action.scanning": return isId ? "MEMINDAI..." : "SCANNING..."
        case "action.back": return "Dashboard"
        case "action.backFolder": return isId ? "Kembali" : "Back"
        case "action.selectAll": return isId ? "Semua" : "All"
        case "action.deselectAll": return isId ? "Batal" : "None"
        case "action.deleteSelected": return isId ? "Hapus Yang Dipilih" : "Delete Selected"
        case "action.cleanAllCaches": return isId ? "Bersihkan Semua Cache" : "Clean All Caches"
        case "action.sortLargest": return isId ? "Terbesar" : "Largest"
        case "action.sortSmallest": return isId ? "Terkecil" : "Smallest"
        case "action.cancel": return isId ? "Batal" : "Cancel"
        case "action.allowAndScan": return isId ? "Izinkan & Mulai Scan" : "Allow & Start Scan"
        case "action.seeAll": return isId ? "Lihat Semua" : "See All"
        case "action.startScan": return isId ? "Mulai Scan" : "Start Scan"
        case "action.rescan": return isId ? "Scan Ulang" : "Rescan"
        case "action.close": return isId ? "Tutup" : "Close"
        case "action.moveToTrash": return isId ? "Pindahkan ke Trash" : "Move to Trash"
        case "action.deleteNow": return isId ? "Hapus Sekarang" : "Delete Now"
        case "action.openFile": return isId ? "Buka Berkas" : "Open File"
        case "action.showInFinder": return isId ? "Tampilkan di Finder" : "Show in Finder"

        // ── Headers ──
        case "header.allFolders": return isId ? "Semua Folder & System Data" : "All Folders & System Data"
        case "header.allFoldersSub": return isId ? "Analisis seluruh penggunaan direktori di sistem" : "Deep analysis of system directory storage usage"
        case "header.junkCleaner": return isId ? "Pembersih File Aman Dihapus" : "Safe-to-Remove Junk Cleaner"
        case "header.junkCleanerSub": return isId ? "Cache build, temporary log, package manager cache, dan installer sisa" : "Build cache, temporary logs, package manager cache, and residual installers"
        case "header.apps": return isId ? "Aplikasi Terinstal" : "Installed Applications"
        case "header.appsSub": return isId ? "Kelola aplikasi terpasang & copot sisa berkas secara tuntas (Uninstaller)" : "Manage installed apps & completely remove leftovers (Uninstaller)"
        case "header.files": return isId ? "Dokumen & Berkas Besar" : "Documents & Large Files"
        case "header.filesSub": return isId ? "Semua berkas dokumen, folder proyek, unduhan, dan file besar pengguna" : "User documents, project folders, downloads, and large files"
        case "header.caches": return isId ? "Cache & File Sementara" : "Cache & Temporary Files"
        case "header.cachesSub": return isId ? "Berkas cache aplikasi dan log diagnostik di folder ~/Library/Caches" : "Application caches and diagnostic logs in ~/Library/Caches"

        // ── Safety & Guides ──
        case "safety.critical": return isId ? "Sistem (Proteksi)" : "System (Protected)"
        case "safety.caution": return isId ? "Hati-hati" : "Caution"
        case "safety.safe": return isId ? "Aman Dihapus" : "Safe to Delete"
        case "guide.safetyTitle": return isId ? "Panduan Keamanan:" : "Safety Guide:"
        case "guide.safe": return isId ? "Aman Dihapus" : "Safe to Delete"
        case "guide.caution": return isId ? "Hati-hati (Data Pengguna)" : "Caution (User Data)"
        case "guide.critical": return isId ? "Proteksi Sistem" : "System Protected"
        case "guide.quickLook": return isId ? "Tekan Spasi untuk Pratinjau Cepat (Quick Look)" : "Press Spacebar for Quick Look Preview"
        case "guide.uninstaller": return isId ? "Copot Bersih Termasuk Berkas Sisa di ~/Library" : "Clean uninstall including leftovers in ~/Library"
        case "guide.uninstallerFeature": return isId ? "Fitur Uninstaller:" : "Uninstaller Feature:"
        case "guide.autoDetect": return isId ? "Deteksi Otomatis Ukuran & Bundle ID" : "Auto-detect Size & Bundle ID"
        case "guide.cacheSafety": return isId ? "Aman Dihapus (Akan dibuat ulang otomatis oleh aplikasi saat diperlukan)" : "Safe to delete (System will recreate automatically when needed)"
        case "guide.cacheGuide": return isId ? "Panduan Cache:" : "Cache Guide:"
        case "guide.hint": return isId ? "Petunjuk:" : "Hints:"
        case "guide.eyeIcon": return isId ? "Ikon Mata untuk Buka Detail & Folder" : "Eye icon to open Detail & Folder"
        case "guide.potentialSave": return isId ? "Potensi Hemat:" : "Potential Save:"
        case "guide.safeDelete": return isId ? "Aman Dihapus (Dipindahkan ke Trash)" : "Safe to Delete (Moved to Trash)"

        // ── Search placeholders ──
        case "search.folder": return isId ? "Cari folder..." : "Search folders..."
        case "search.app": return isId ? "Cari aplikasi..." : "Search apps..."
        case "search.file": return isId ? "Cari file..." : "Search files..."
        case "search.cache": return isId ? "Cari cache..." : "Search caches..."

        // ── Categories ──
        case "cat.all": return isId ? "Semua Kategori" : "All Categories"
        case "cat.title": return isId ? "Kategori" : "Category"
        case "cat.apps": return isId ? "Aplikasi" : "Applications"
        case "cat.documents": return isId ? "Dokumen" : "Documents"
        case "cat.media": return "Media"
        case "cat.downloads": return "Downloads"
        case "cat.cache": return "Cache & Logs"
        case "cat.developer": return isId ? "Pengembang" : "Developer"
        case "cat.other": return "System Data"
        case "cat.detected": return isId ? "Kategori Terdeteksi" : "Categories Detected"

        // ── Dashboard ──
        case "dash.title": return "CleanMac Storage"
        case "dash.cardAllFolders": return isId ? "Semua Folder" : "All Folders"
        case "dash.cardCleanable": return isId ? "Bisa Dihapus" : "Cleanable"
        case "dash.cardApps": return isId ? "Aplikasi" : "Applications"
        case "dash.cardLargeFiles": return isId ? "File Besar" : "Large Files"
        case "dash.cardCaches": return "Cache & Logs"
        case "dash.cardSystemData": return "System Data"
        case "dash.catBreakdown": return isId ? "Penggunaan Berdasarkan Kategori" : "Usage by Category"
        case "dash.catBreakdownSub": return isId ? "Rincian alokasi penyimpanan Macintosh HD (gaya macOS Settings)" : "Macintosh HD storage allocation breakdown (macOS Settings style)"
        case "dash.topApps": return isId ? "Top 5 Aplikasi Terbesar" : "Top 5 Largest Applications"
        case "dash.topFiles": return isId ? "Top 5 File / Data Terbesar" : "Top 5 Largest Files"
        case "dash.scanHint": return isId ? "Klik 'SCAN' untuk melihat rincian kategori." : "Click 'SCAN' to see category breakdown."

        // ── Dashboard Stats ──
        case "stat.foldersAnalyzed": return isId ? "folder dianalisis" : "folders analyzed"
        case "stat.junkItems": return isId ? "item sampah" : "junk items"
        case "stat.appsDetected": return isId ? "apps terdeteksi" : "apps detected"
        case "stat.filesDetected": return isId ? "file (>10MB)" : "files (>10MB)"
        case "stat.cacheFolders": return isId ? "folder cache" : "cache folders"
        case "stat.macosSystem": return isId ? "macOS & sistem" : "macOS & system"
        case "stat.appsFound": return isId ? "aplikasi terdeteksi" : "applications found"
        case "stat.filesFound": return isId ? "file ditemukan" : "files found"
        case "stat.itemsSelected": return isId ? "item dipilih" : "items selected"
        case "stat.from": return isId ? "dari" : "of"

        // ── Permission Sheet ──
        case "perm.title": return isId ? "Izin Pemindaian" : "Scan Permissions"
        case "perm.badge": return isId ? "Konfirmasi Sekali" : "One-Time Confirm"
        case "perm.sub": return isId ? "Pilih modul & area yang diizinkan untuk dipindai oleh CleanMac:" : "Select modules & directories allowed to be scanned by CleanMac:"
        case "perm.remember": return isId ? "Ingat izin ini (jangan tampilkan lagi)" : "Remember permission (do not ask again)"
        case "perm.rememberSub": return isId ? "— Scan berikutnya langsung berjalan tanpa pop-up" : "— Next scans will run immediately without pop-up"
        case "perm.appsTitle": return isId ? "Aplikasi & Uninstaller" : "Applications & Uninstaller"
        case "perm.appsDesc": return isId ? "/Applications & ~/Applications — Ukuran app dan sisa berkas uninstaller" : "/Applications & ~/Applications — App size and uninstaller leftovers"
        case "perm.filesTitle": return isId ? "File Besar Pengguna" : "User Large Files"
        case "perm.filesDesc": return isId ? "Downloads, Dokumen, Desktop — Berkas besar berukuran >10 MB" : "Downloads, Documents, Desktop — Large files >10 MB"
        case "perm.junkTitle": return isId ? "Pembersih Sampah" : "Junk Cleaner"
        case "perm.junkDesc": return isId ? "Trash, Cache Build (Xcode, npm, rust), Installer .dmg/.pkg sementara" : "Trash, Build cache (Xcode, npm, rust), Temp .dmg/.pkg installers"
        case "perm.cacheTitle": return isId ? "Cache & Log Pengguna" : "User Caches & Logs"
        case "perm.cacheDesc": return isId ? "~/Library/Caches & ~/Library/Logs — File cache dan log sistem" : "~/Library/Caches & ~/Library/Logs — Cache and system log files"
        case "perm.deepTitle": return isId ? "Analisis Semua Folder (Deep Scan)" : "Analyze All Folders (Deep Scan)"
        case "perm.deepDesc": return isId ? "Pemetaan mendalam hierarki direktori & indikator keamanan folder" : "Deep directory hierarchy mapping & folder safety indicators"

        // ── File Detail Sheet ──
        case "file.size": return isId ? "Ukuran" : "Size"
        case "file.location": return isId ? "Lokasi" : "Location"
        case "file.lastModified": return isId ? "Terakhir Diubah" : "Last Modified"
        case "file.extension": return isId ? "Ekstensi" : "Extension"
        case "tag.directory": return isId ? "Folder / Direktori" : "Folder / Directory"
        case "tag.file": return isId ? "Berkas (File)" : "File"
        case "tag.noExtension": return isId ? "Folder / Tanpa ekstensi" : "Folder / No extension"

        // ── Uninstaller ──
        case "uninst.badge": return isId ? "Uninstaller Tuntas" : "Complete Uninstaller"
        case "uninst.scanning": return isId ? "Memindai data & file sisa aplikasi..." : "Scanning app data & residual files..."
        case "uninst.fileListTitle": return isId ? "Daftar Berkas yang Akan Dihapus:" : "Files to be Deleted:"
        case "uninst.mainApp": return isId ? "Aplikasi Utama" : "Main Application"
        case "uninst.leftovers": return isId ? "Data Terkait & File Sisa" : "Related Data & Leftovers"
        case "uninst.noLeftovers": return isId ? "Tidak ada file sisa tersembunyi ditemukan di Library." : "No hidden leftover files found in Library."
        case "uninst.uninstallBtn": return isId ? "Uninstall Tuntas" : "Complete Uninstall"
        case "uninst.removing": return isId ? "Menghapus aplikasi dan data terkait..." : "Removing application and related files..."

        // ── Footer / Sidebar ──
        case "footer.theme": return isId ? "Tema" : "Theme"
        case "footer.language": return isId ? "Bahasa" : "Language"
        case "footer.about": return isId ? "Tentang & Donasi (Yogi Anditia)" : "About & Donate (Yogi Anditia)"

        // ── About View ──
        case "about.version": return isId ? "Versi 1.0 (Build 1)" : "Version 1.0 (Build 1)"
        case "about.madeBy": return isId ? "Dibuat dengan ❤️ oleh" : "Made with ❤️ by"
        case "about.desc": return isId
            ? "Penganalisis penyimpanan disk macOS, pendeteksi berkas besar, pembersih sampah sistem, dan uninstaller aplikasi tuntas."
            : "macOS disk storage analyzer, large file detector, system junk cleaner, and complete app uninstaller."
        case "about.donate": return isId ? "Dukung Pengembang via PayPal" : "Support Developer via PayPal"
        case "about.star": return isId ? "Beri Bintang di GitHub" : "Star on GitHub"
        case "about.menuTitle": return isId ? "Tentang CleanMac" : "About CleanMac"

        // ── Storage Bar ──
        case "bar.used": return isId ? "Terpakai" : "Used"
        case "bar.available": return isId ? "Tersedia" : "Available"
        case "bar.total": return "Total"
        case "bar.usedOf": return isId ? "terpakai dari" : "used of"

        // ── Scan Settings Help ──
        case "help.scanSettings": return isId ? "Atur Izin & Opsi Pemindaian..." : "Scan Permissions & Options..."
        case "help.showInFinder": return isId ? "Tampilkan di Finder" : "Show in Finder"
        case "help.systemAppProtected": return isId ? "Aplikasi sistem bawaan macOS ini dilindungi demi keamanan dan tidak dapat dihapus." : "This built-in macOS system application is protected for security and cannot be deleted."
        case "help.uninstallClean": return isId ? "Uninstall Tuntas (Hapus Aplikasi & Semua Data Terkait)" : "Complete Uninstall (Remove App & All Related Data)"
        case "help.openSubfolder": return isId ? "Buka isi subfolder ini" : "Open this subfolder"
        case "help.systemProtected": return isId ? "Folder sistem ini dilindungi demi keamanan macOS dan tidak dapat dihapus." : "This system folder is protected for macOS security and cannot be deleted."
        case "help.cautionFolder": return isId ? "Hati-hati: Folder berisi data pengguna" : "Caution: Folder contains user data"
        case "help.moveToTrash": return isId ? "Pindahkan ke Trash" : "Move to Trash"
        case "help.quickLook": return isId ? "Quick Look / Pratinjau (Spasi)" : "Quick Look / Preview (Space)"
        case "help.openInFinder": return isId ? "Buka di Finder" : "Open in Finder"
        case "help.deleteItem": return isId ? "Hapus Item Ini" : "Delete This Item"

        // ── Empty States ──
        case "empty.loadingSubfolder": return isId ? "Menghitung ukuran subfolder..." : "Calculating subfolder sizes..."
        case "empty.scanningFolders": return isId ? "Sedang memindai semua folder..." : "Scanning all folders..."
        case "empty.noFolderMatch": return isId ? "Tidak ada folder yang cocok." : "No matching folders found."
        case "empty.scanningApps": return isId ? "Sedang memindai aplikasi..." : "Scanning applications..."
        case "empty.noAppsFound": return isId ? "Tidak ada aplikasi ditemukan." : "No applications found."
        case "empty.scanningFiles": return isId ? "Sedang memindai file besar..." : "Scanning large files..."
        case "empty.noFilesFound": return isId ? "Tidak ada file besar ditemukan." : "No large files found."
        case "empty.scanningCaches": return isId ? "Sedang memindai folder cache..." : "Scanning cache folders..."
        case "empty.noCachesFound": return isId ? "Tidak ada folder cache signifikan (>10 MB)." : "No significant cache folders (>10 MB)."
        case "empty.scanningJunk": return isId ? "Sedang menganalisis file yang bisa dibersihkan..." : "Analyzing cleanable files..."
        case "empty.noJunk": return isId ? "Sistem Anda bersih! Tidak ada file sampah signifikan." : "Your system is clean! No significant junk files."

        // ── Confirmation Dialogs ──
        case "dialog.moveToTrash": return isId ? "Pindahkan ke Trash?" : "Move to Trash?"
        case "dialog.moveToTrashBtn": return isId ? "Pindahkan ke Trash" : "Move to Trash"
        case "dialog.cautionWarning": return isId
            ? "⚠️ PERHATIAN: Folder ini berisi data aplikasi atau pengguna. Pastikan Anda tidak memerlukan file di dalamnya sebelum memindahkan ke Trash."
            : "⚠️ WARNING: This folder contains app or user data. Make sure you don't need the files inside before moving to Trash."
        case "dialog.folderWillBeTrashed": return isId
            ? "Folder ini akan dipindahkan ke Trash."
            : "This folder will be moved to Trash."
        case "dialog.fileConfirm": return isId
            ? "Apakah Anda yakin ingin memindahkan file ini ke Trash?"
            : "Are you sure you want to move this file to Trash?"
        case "dialog.deleteSelectedTitle": return isId ? "Hapus File Terpilih?" : "Delete Selected Files?"
        case "dialog.deleteSelectedMsg": return isId
            ? "File-file ini akan dihapus permanen untuk menghemat ruang disk Anda."
            : "These files will be permanently deleted to free up your disk space."
        case "dialog.deleteItemTitle": return isId ? "Hapus Item Ini?" : "Delete This Item?"
        case "dialog.deleteItemMsg": return isId
            ? "Item ini akan dihapus dari sistem Anda."
            : "This item will be deleted from your system."

        // ── Tags ──
        case "tag.app": return isId ? "Aplikasi" : "App"
        case "tag.uninstaller": return "Uninstaller"
        case "tag.systemProtected": return isId ? "Proteksi Sistem" : "System Protected"
        case "tag.documentFolder": return isId ? "Folder Dokumen" : "Document Folder"
        case "tag.cache": return "Cache"
        case "tag.safeToDelete": return isId ? "Aman Dihapus" : "Safe to Delete"
        case "tag.apfsClone": return "APFS Clone"

        // ── Scan Status Messages ──
        case "status.ready": return isId ? "Siap" : "Ready"
        case "status.readingDisk": return isId ? "Membaca kapasitas disk..." : "Reading disk capacity..."
        case "status.deepScan": return isId ? "Deep scan: menganalisis semua folder..." : "Deep scan: analyzing all folders..."
        case "status.scanningApps": return isId ? "Memindai aplikasi terinstal..." : "Scanning installed applications..."
        case "status.scanningApp": return isId ? "Memindai app:" : "Scanning app:"
        case "status.scanningLargeFiles": return isId ? "Memindai file besar pengguna..." : "Scanning user large files..."
        case "status.scanningFolder": return isId ? "Memindai folder:" : "Scanning folder:"
        case "status.scanningCaches": return isId ? "Memindai direktori cache..." : "Scanning cache directories..."
        case "status.checkingCaches": return isId ? "Memeriksa cache:" : "Checking caches:"
        case "status.scanningJunk": return isId ? "Memindai file sampah..." : "Scanning junk files..."
        case "status.scanDone": return isId ? "Scan selesai!" : "Scan complete!"
        case "status.found": return isId ? "Ditemukan" : "Found"
        case "status.folders": return "folder"
        case "status.apps": return "app"
        case "status.largeFiles": return isId ? "file besar" : "large files"
        case "status.junkItems": return isId ? "item sampah" : "junk items"
        case "status.deletedJunk": return isId ? "Berhasil menghapus" : "Successfully deleted"
        case "status.junkItemsSuffix": return isId ? "item sampah!" : "junk items!"
        case "status.cleanedCache": return isId ? "Berhasil membersihkan" : "Successfully cleaned"
        case "status.cacheFolders": return isId ? "folder cache!" : "cache folders!"
        case "status.trashFailed": return isId ? "Gagal memindahkan ke Trash:" : "Failed to move to Trash:"

        default:
            return key
        }
    }
}

public func loc(_ key: String) -> String {
    LocalizationManager.shared.text(key)
}
