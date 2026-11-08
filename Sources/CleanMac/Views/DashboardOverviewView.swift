import SwiftUI

public struct DashboardOverviewView: View {
    @ObservedObject var viewModel: DashboardViewModel

    public init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with scan action
                HStack(alignment: .center, spacing: 14) {
                    if let iconImage = Bundle.main.image(forResource: "AppIcon") ?? NSImage(contentsOfFile: "Resources/AppIcon.png") {
                        Image(nsImage: iconImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 48, height: 48)
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("CleanMac Storage")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(viewModel.currentStatus)
                            .font(.subheadline)
                            .foregroundColor(viewModel.isScanning ? .blue : .secondary)
                    }

                    Spacer()

                    Button {
                        viewModel.startFullScan()
                    } label: {
                        HStack(spacing: 6) {
                            if viewModel.isScanning {
                                ProgressView()
                                    .controlSize(.small)
                            } else {
                                Image(systemName: "arrow.clockwise")
                            }
                            Text(viewModel.isScanning ? "Scanning..." : "Mulai Scan")
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isScanning)
                }

                // 1. Storage Bar
                StorageBarView(diskInfo: viewModel.diskInfo)

                // 2. Quick Stat Cards - Row 1
                HStack(spacing: 12) {
                    StatCard(
                        title: "Total Terdeteksi",
                        value: ByteFormatter.string(from: viewModel.totalDirectorySizesScanned),
                        subtitle: "\(viewModel.directorySizes.count) folder dipindai",
                        icon: "folder.badge.questionmark",
                        color: .cyan
                    ) {
                        viewModel.selectedTab = .allFolders
                    }

                    StatCard(
                        title: "Bisa Dihapus",
                        value: ByteFormatter.string(from: viewModel.totalCleanableSize),
                        subtitle: "\(viewModel.cleanableItems.count) item sampah",
                        icon: "sparkles",
                        color: .red
                    ) {
                        viewModel.selectedTab = .junkCleaner
                    }

                    StatCard(
                        title: "Aplikasi",
                        value: ByteFormatter.string(from: viewModel.totalAppsSize),
                        subtitle: "\(viewModel.applications.count) apps terdeteksi",
                        icon: "app.badge.fill",
                        color: .blue
                    ) {
                        viewModel.selectedTab = .apps
                    }
                }

                // Quick Stat Cards - Row 2
                HStack(spacing: 12) {
                    StatCard(
                        title: "File Besar",
                        value: ByteFormatter.string(from: viewModel.totalLargeFilesSize),
                        subtitle: "\(viewModel.largeFiles.count) file (>10MB)",
                        icon: "doc.badge.gearshape.fill",
                        color: .green
                    ) {
                        viewModel.selectedTab = .files
                    }

                    StatCard(
                        title: "Cache & Logs",
                        value: ByteFormatter.string(from: viewModel.totalCachesSize),
                        subtitle: "\(viewModel.cacheFiles.count) folder cache",
                        icon: "trash.fill",
                        color: .orange
                    ) {
                        viewModel.selectedTab = .caches
                    }
                }

                // 3. Storage Chart
                StorageChartView(categories: viewModel.categoryUsages)

                // 4. Top 5 Largest Apps
                if !viewModel.applications.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Top 5 Aplikasi Terbesar")
                                .font(.headline)
                            Spacer()
                            Button("Lihat Semua") {
                                viewModel.selectedTab = .apps
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(.blue)
                            .font(.subheadline)
                        }

                        VStack(spacing: 8) {
                            ForEach(Array(viewModel.applications.prefix(5))) { app in
                                HStack {
                                    Image(nsImage: app.icon)
                                        .resizable()
                                        .frame(width: 28, height: 28)
                                    Text(app.name)
                                        .font(.body)
                                    Spacer()
                                    Text(app.formattedSize)
                                        .font(.system(.subheadline, design: .monospaced))
                                        .foregroundColor(.secondary)
                                }
                                .padding(8)
                                .background(Color(nsColor: .controlBackgroundColor))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
                    )
                }

                // 5. Top 5 Largest Files
                if !viewModel.largeFiles.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Top 5 File / Data Terbesar")
                                .font(.headline)
                            Spacer()
                            Button("Lihat Semua") {
                                viewModel.selectedTab = .files
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(.blue)
                            .font(.subheadline)
                        }

                        VStack(spacing: 8) {
                            ForEach(Array(viewModel.largeFiles.prefix(5))) { file in
                                HStack {
                                    Image(nsImage: file.icon)
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(file.name)
                                            .font(.body)
                                            .lineLimit(1)
                                        Text(file.category.rawValue)
                                            .font(.caption2)
                                            .foregroundColor(file.category.color)
                                    }
                                    Spacer()
                                    Text(file.formattedSize)
                                        .font(.system(.subheadline, design: .monospaced))
                                        .foregroundColor(.secondary)
                                }
                                .padding(8)
                                .background(Color(nsColor: .controlBackgroundColor))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
                    )
                }
            }
            .padding(20)
        }
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.title3)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }
}

