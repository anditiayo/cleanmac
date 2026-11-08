<p align="center">
  <img src="Resources/AppIcon.png" width="128" height="128" alt="CleanMac App Icon" style="border-radius: 28px;" />
</p>

<h1 align="center">CleanMac</h1>

<p align="center">
  <b>Modern Native macOS Storage Analyzer, Deep System Cleaner & App Uninstaller</b><br>
  <i>Aplikasi Analisis Penyimpanan, Pembersih Sistem Mendalam & Uninstaller Tuntas untuk macOS</i>
</p>

<p align="center">
  <a href="#-english"><b>English 🇬🇧</b></a> | <a href="#-bahasa-indonesia"><b>Bahasa Indonesia 🇮🇩</b></a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-macOS%2013%2B-blue?logo=apple" alt="macOS" />
  <img src="https://img.shields.io/badge/Swift-5.9%20%7C%206.0-orange?logo=swift" alt="Swift" />
  <img src="https://img.shields.io/badge/UI-SwiftUI%20%2B%20Swift%20Charts-indigo" alt="SwiftUI" />
  <img src="https://img.shields.io/badge/Author-Yogi%20Anditia-brightgreen" alt="Author" />
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License" />
</p>

<p align="center">
  <a href="https://github.com/anditiayo/cleanmac/releases/latest/download/CleanMac-Installer.dmg">
    <img src="https://img.shields.io/badge/Download-CleanMac--Installer.dmg-007AFF?style=for-the-badge&logo=apple&logoColor=white" alt="Download DMG" />
  </a>
  <a href="https://paypal.me/Anditia">
    <img src="https://img.shields.io/badge/Donate-PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white" alt="Donate with PayPal" />
  </a>
</p>

---

<a name="-english"></a>
## 🇬🇧 English

**CleanMac** is a lightweight, high-performance native macOS utility designed to help you reclaim disk space, find hidden storage hogs, preview large files, and completely uninstall applications along with their hidden library leftovers.

### 🌟 Key Features

- 💾 **Real-Time Storage Overview**:
  - Instant live breakdown of your disk: Used, Free, and Total capacity.
  - Interactive **Swift Charts** showing usage distributed across Applications, System Data, Documents, Media, Developer caches, and Logs.
- 📦 **Complete Application Uninstaller**:
  - Don't just delete the `.app` bundle! CleanMac scans `~/Library/Application Support`, `~/Library/Caches`, `~/Library/Preferences`, and sandbox containers to completely remove all hidden leftover files in one click.
- 📂 **Deep System Data & Subfolder Drill-Down**:
  - Accurately measures hidden macOS System Data without falling into APFS firmlink loops.
  - **Subfolder Drill-Down**: Click `>` on any folder (e.g. `Documents` or `App Support`) to explore its largest subdirectories interactively.
- ⚡ **Spacebar Quick Look Preview**:
  - Select any file and tap **Spacebar** or click the preview button to inspect file details, dimensions, and path instantly.
- 🌓 **Dark & Light Theme Support**:
  - Seamless toggle between System Auto, Dark Mode, and Light Mode directly from the sidebar.
- 🧹 **One-Click Junk Cleaner**:
  - Safely sweeps app caches, old diagnostic logs, Xcode `DerivedData` build caches, developer package caches (`npm`, `cargo`, `gradle`), and leftover `.dmg` installers.
- 🛡️ **Safe Move to Trash**:
  - No accidental permanent deletions. Every action confirms and safely routes items to macOS Trash.

### 🚀 Getting Started

#### Option 1: Download Pre-built DMG
Download the ready-to-run installer from the repository:
```bash
open CleanMac-Installer.dmg
# Drag CleanMac into your /Applications folder
```

#### Option 2: Build from Source (Swift Package Manager)
```bash
git clone https://github.com/anditiayo/cleanmac.git
cd cleanmac

# Run the app
./run.sh

# Or build the DMG package
./create_dmg.sh
```

---

<a name="-bahasa-indonesia"></a>
## 🇮🇩 Bahasa Indonesia

**CleanMac** adalah aplikasi utilitas macOS native yang ringan, cepat, dan modern untuk menganalisis penyimpanan disk, mendeteksi aplikasi & data besar yang tersembunyi, serta membersihkan file sampah sistem dengan aman.

### 🌟 Fitur Unggulan

- 💾 **Ringkasan Storage Real-Time**:
  - Menampilkan kapasitas disk terpakai, ruang kosong, dan total secara akurat.
  - Visualisasi grafik batang interaktif menggunakan **Swift Charts** native untuk kategori Aplikasi, System Data, Dokumen, Media, Cache, dan Developer.
- 📦 **Uninstaller Tuntas untuk Aplikasi**:
  - Tidak hanya menghapus file `.app`! CleanMac memindai file sisa tersembunyi di `~/Library/Application Support`, `~/Library/Caches`, `~/Library/Preferences`, dan container untuk menghapus aplikasi beserta seluruh datanya secara bersih.
- 📂 **Analisis Semua Folder & Eksplorasi Subfolder (Drill-Down)**:
  - Menganalisis *System Data* dan folder sistem tanpa terkena jebakan perulangan *firmlink* macOS.
  - **Drill-Down Subfolder**: Klik tanda panah `>` di folder mana saja (seperti `Documents` atau `App Support`) untuk melihat subfolder terdalam mana yang paling memakan tempat.
- ⚡ **Pratinjau Cepat (Quick Look) dengan Tombol Spasi**:
  - Cukup tekan tombol **Spasi** atau klik ikon mata pada file besar untuk membuka detail berkas dan pratinjau secara instan.
- 🌓 **Dukungan Mode Gelap (Dark) & Terang (Light)**:
  - Penggantian tema cepat (Sistem, Gelap, Terang) langsung dari sidebar aplikasi.
- 🧹 **Pembersih Sampah Sekali Klik (Junk Cleaner)**:
  - Membersihkan cache aplikasi, log sistem usang, build cache Xcode `DerivedData`, cache package manager (`npm`, `cargo`, `gradle`), dan installer bekas (`.dmg` / `.pkg`).
- 🛡️ **Penghapusan Aman (Move to Trash)**:
  - Setiap penghapusan dilengkapi dialog konfirmasi dan dipindahkan ke Trash macOS agar file tetap dapat dipulihkan jika diperlukan.

### 🚀 Cara Install & Menjalankan

#### Cara 1: Menggunakan File Installer DMG
```bash
open CleanMac-Installer.dmg
# Tarik CleanMac ke folder Applications Anda
```

#### Cara 2: Kompilasi Manual dari Source Code
```bash
git clone https://github.com/anditiayo/cleanmac.git
cd cleanmac

# Jalankan langsung
./run.sh

# Atau buat file installer DMG
./create_dmg.sh
```

---

## 🛠️ Tech Stack & Requirements

- **Bahasa**: Swift 5.9+ / Swift 6.0
- **UI Framework**: SwiftUI + Swift Charts
- **Sistem Operasi**: macOS 13.0+ (Ventura, Sonoma, Sequoia)
- **Zero Third-Party Dependencies**: Murni 100% Apple Native API & Swift Package Manager.

---

## ☕ Dukungan & Donasi / Support & Donate

CleanMac adalah perangkat lunak gratis dan open-source yang dikembangkan oleh **Yogi Anditia**.

Jika CleanMac bermanfaat dalam membantu Anda mengelola penyimpanan Mac, Anda dapat memberikan dukungan dan apresiasi donasi melalui PayPal:

<p align="center">
  <a href="https://paypal.me/Anditia">
    <img src="https://img.shields.io/badge/Donate-PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white" alt="Donate with PayPal" />
  </a>
  <br>
  <b>Tautan PayPal:</b> <a href="https://paypal.me/Anditia">https://paypal.me/Anditia</a>
</p>

---

## 👨‍💻 Author & Credits

**Yogi Anditia**
- GitHub: [@anditiayo](https://github.com/anditiayo)
- PayPal: [paypal.me/Anditia](https://paypal.me/Anditia)

---

## 📄 License

Proyek ini dilisensikan di bawah [MIT License](LICENSE) © 2026 Yogi Anditia.
