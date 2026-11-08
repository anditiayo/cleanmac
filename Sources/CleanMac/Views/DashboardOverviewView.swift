import SwiftUI

public struct DashboardOverviewView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @State private var showSystemDataSheet: Bool = false

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
                        Text(loc("dash.title"))
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(viewModel.currentStatus)
                            .font(.subheadline)
                            .foregroundColor(viewModel.isScanning ? .blue : .secondary)
                    }

                    Spacer()

                    HStack(spacing: 10) {
                        Button {
                            viewModel.requestScan()
                        } label: {
                            HStack(spacing: 8) {
                                if viewModel.isScanning {
                                    ProgressView()
                                        .controlSize(.small)
                                        .tint(.white)
                                } else {
                                    Image(systemName: "sparkle.magnifyingglass")
                                        .font(.system(size: 16, weight: .bold))
                                }
                                Text(viewModel.isScanning ? loc("action.scanning") : loc("action.scan"))
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .tracking(0.5)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 22)
                            .padding(.vertical, 9)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(red: 0.16, green: 0.80, blue: 0.38), Color(red: 0.11, green: 0.65, blue: 0.30)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                            )
                            .shadow(color: Color.green.opacity(0.35), radius: 6, x: 0, y: 3)
                        }
                        .buttonStyle(.plain)
                        .disabled(viewModel.isScanning)

                        Button {
                            viewModel.showScanPermissionSheet = true
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 13, weight: .semibold))
                                .frame(height: 20)
                        }
                        .buttonStyle(ModernSecondaryButtonStyle())
                        .help(loc("help.scanSettings"))
                    }
                }

                // 1. Storage Bar
                StorageBarView(diskInfo: viewModel.diskInfo, categories: viewModel.categoryUsages)

                // 2. Quick Stat Cards - Symmetrical 3x2 Grid
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                    StatCard(
                        title: loc("dash.cardAllFolders"),
                        value: ByteFormatter.string(from: viewModel.totalDirectorySizesScanned),
                        subtitle: "\(viewModel.directorySizes.count) \(loc("stat.foldersAnalyzed"))",
                        icon: "folder.badge.questionmark",
                        color: .cyan
                    ) {
                        viewModel.selectedTab = .allFolders
                    }

                    StatCard(
                        title: loc("dash.cardCleanable"),
                        value: ByteFormatter.string(from: viewModel.totalCleanableSize),
                        subtitle: "\(viewModel.cleanableItems.count) \(loc("stat.junkItems"))",
                        icon: "sparkles",
                        color: .red
                    ) {
                        viewModel.selectedTab = .junkCleaner
                    }

                    StatCard(
                        title: loc("dash.cardApps"),
                        value: ByteFormatter.string(from: viewModel.displayAppsSize),
                        subtitle: "\(viewModel.applications.count) \(loc("stat.appsDetected"))",
                        icon: "app.badge.fill",
                        color: Color(red: 0.98, green: 0.58, blue: 0.16)
                    ) {
                        viewModel.selectedTab = .apps
                    }

                    StatCard(
                        title: loc("cat.documents"),
                        value: ByteFormatter.string(from: viewModel.displayDocumentsSize),
                        subtitle: "\(viewModel.largeFiles.count) \(loc("stat.filesDetected"))",
                        icon: "doc.fill",
                        color: Color(red: 0.95, green: 0.28, blue: 0.25)
                    ) {
                        viewModel.selectedTab = .files
                    }

                    StatCard(
                        title: "macOS",
                        value: ByteFormatter.string(from: viewModel.macOSSize),
                        subtitle: loc("stat.macosSystem"),
                        icon: "apple.logo",
                        color: Color(red: 0.35, green: 0.35, blue: 0.38)
                    ) {
                        showSystemDataSheet = true
                    }

                    StatCard(
                        title: loc("dash.cardSystemData"),
                        value: ByteFormatter.string(from: viewModel.systemDataSize),
                        subtitle: loc("sysdata.inspectBtn"),
                        icon: "internaldrive.fill",
                        color: Color(red: 0.55, green: 0.55, blue: 0.58)
                    ) {
                        showSystemDataSheet = true
                    }
                }

                // 3. Storage Category Breakdown
                StorageChartView(categories: viewModel.categoryUsages) { category in
                    switch category {
                    case .apps:
                        viewModel.selectedTab = .apps
                    case .cache:
                        viewModel.selectedTab = .caches
                    case .documents, .downloads, .media:
                        viewModel.selectedTab = .files
                    case .developer:
                        viewModel.selectedTab = .allFolders
                    case .other, .macos:
                        showSystemDataSheet = true
                    }
                }

                // 4. Top 5 Largest Apps
                if !viewModel.applications.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(loc("dash.topApps"))
                                .font(.headline)
                            Spacer()
                            Button {
                                viewModel.selectedTab = .apps
                            } label: {
                                HStack(spacing: 4) {
                                    Text(loc("action.seeAll"))
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 9, weight: .semibold))
                                }
                            }
                            .buttonStyle(ModernSecondaryButtonStyle(accentColor: .blue))
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
                            Text(loc("dash.topFiles"))
                                .font(.headline)
                            Spacer()
                            Button {
                                viewModel.selectedTab = .files
                            } label: {
                                HStack(spacing: 4) {
                                    Text(loc("action.seeAll"))
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 9, weight: .semibold))
                                }
                            }
                            .buttonStyle(ModernSecondaryButtonStyle(accentColor: .blue))
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
                                        Text(file.category.localizedName)
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
        .sheet(isPresented: $viewModel.showScanPermissionSheet) {
            ScanPermissionSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showSystemDataSheet) {
            SystemDataDetailSheet(viewModel: viewModel)
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
