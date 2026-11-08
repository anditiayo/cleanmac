import SwiftUI

public struct CacheListView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @State private var searchText: String = ""

    public init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
    }

    private var filteredCaches: [FileInfo] {
        if searchText.isEmpty {
            return viewModel.cacheFiles
        }
        return viewModel.cacheFiles.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.url.path.localizedCaseInsensitiveContains(searchText)
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
                    Text("Cache & Temporary Files")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Total ukuran cache yang terdeteksi: \(ByteFormatter.string(from: viewModel.totalCachesSize))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Search field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Cari cache...", text: $searchText)
                        .textFieldStyle(.plain)
                        .frame(width: 160)
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

                if !viewModel.cacheFiles.isEmpty {
                    Button(role: .destructive) {
                        viewModel.cleanAllCaches()
                    } label: {
                        Label("Bersihkan Semua Cache", systemImage: "trash.circle")
                    }
                }
            }
            .padding()

            Divider()

            if filteredCaches.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text(viewModel.isScanning ? "Sedang memindai folder cache..." : "Tidak ada folder cache signifikan (>10 MB).")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(filteredCaches) { item in
                    HStack(spacing: 14) {
                        Image(systemName: "archivebox.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.orange)
                            .frame(width: 36, height: 36)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.name)
                                .font(.body)
                                .fontWeight(.medium)
                            Text(item.url.path)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }

                        Spacer()

                        Text(item.formattedSize)
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.semibold)

                        Button {
                            viewModel.revealInFinder(url: item.url)
                        } label: {
                            Image(systemName: "folder.badge.gearshape")
                        }
                        .help("Tampilkan di Finder")
                        .buttonStyle(.borderless)

                        Button(role: .destructive) {
                            _ = viewModel.moveToTrash(url: item.url)
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
            }
        }
    }
}

