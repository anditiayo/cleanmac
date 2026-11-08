import SwiftUI

public struct AppListView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @State private var searchText: String = ""
    @State private var sortAscending: Bool = false
    @State private var appToTrash: AppInfo? = nil
    @State private var showTrashConfirm: Bool = false

    public init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
    }

    private var filteredApps: [AppInfo] {
        var list = viewModel.applications
        if !searchText.isEmpty {
            list = list.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                ($0.bundleIdentifier?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        return list.sorted {
            sortAscending ? $0.size < $1.size : $0.size > $1.size
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
                    Text("Aplikasi Terinstal")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Ditemukan \(viewModel.applications.count) aplikasi • Total: \(ByteFormatter.string(from: viewModel.totalAppsSize))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Search field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Cari aplikasi...", text: $searchText)
                        .textFieldStyle(.plain)
                        .frame(width: 180)
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

                // Sort toggle
                Button {
                    sortAscending.toggle()
                } label: {
                    Label(sortAscending ? "Terkecil" : "Terbesar", systemImage: sortAscending ? "arrow.up.circle" : "arrow.down.circle")
                }
            }
            .padding()

            Divider()

            if filteredApps.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "app.badge.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text(viewModel.isScanning ? "Sedang memindai aplikasi..." : "Tidak ada aplikasi ditemukan.")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(filteredApps) { app in
                    HStack(spacing: 14) {
                        Image(nsImage: app.icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(app.name)
                                .font(.body)
                                .fontWeight(.medium)
                            Text(app.url.path)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }

                        Spacer()

                        Text(app.formattedSize)
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.semibold)

                        Button {
                            viewModel.revealInFinder(url: app.url)
                        } label: {
                            Image(systemName: "folder.badge.gearshape")
                        }
                        .help("Tampilkan di Finder")
                        .buttonStyle(.borderless)

                        Button(role: .destructive) {
                            appToTrash = app
                            showTrashConfirm = true
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red.opacity(0.8))
                        }
                        .help("Hapus Aplikasi (Pindahkan ke Trash)")
                        .buttonStyle(.borderless)
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.inset)
                .confirmationDialog(
                    "Hapus Aplikasi?",
                    isPresented: $showTrashConfirm,
                    titleVisibility: .visible,
                    presenting: appToTrash
                ) { app in
                    Button("Pindahkan ke Trash (\(app.formattedSize))", role: .destructive) {
                        _ = viewModel.moveToTrash(url: app.url)
                    }
                    Button("Batal", role: .cancel) {}
                } message: { app in
                    Text("Aplikasi '\(app.name)' akan dipindahkan ke Trash. Anda tetap dapat mengembalikannya dari Trash sebelum dikosongkan.")
                }
            }
        }
    }
}

