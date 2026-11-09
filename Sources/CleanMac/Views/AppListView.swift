import SwiftUI

public struct AppListView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @State private var searchText: String = ""
    @State private var sortAscending: Bool = false
    @State private var appToUninstall: AppInfo? = nil

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
            // PRO HEADER SECTION
            VStack(spacing: 12) {
                // Row 1: Back Navigation + Search + Sort
                HStack(alignment: .center, spacing: 10) {
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

                    Spacer()

                    // Native Search Field
                    HStack(spacing: 6) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        TextField(loc("search.app"), text: $searchText)
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
                    .frame(width: 190)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
                    )

                    // Sort button
                    Button {
                        sortAscending.toggle()
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: sortAscending ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                .foregroundColor(.blue)
                            Text(sortAscending ? loc("action.sortSmallest") : loc("action.sortLargest"))
                        }
                    }
                    .buttonStyle(ModernSecondaryButtonStyle())
                }

                // Row 2: Title & Metrics
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(loc("header.apps"))
                            .font(.title2)
                            .fontWeight(.bold)
                            .lineLimit(1)
                        Text(loc("header.appsSub"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    // Metrics badge
                    HStack(spacing: 12) {
                        VStack(alignment: .trailing, spacing: 1) {
                            Text(ByteFormatter.string(from: viewModel.totalAppsSize))
                                .font(.system(.title3, design: .monospaced))
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Text("\(filteredApps.count) \(loc("stat.appsFound"))")
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

                // Row 3: Guide Legend Bar
                HStack(spacing: 14) {
                    Text(loc("guide.uninstallerFeature"))
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    HStack(spacing: 4) {
                        Image(systemName: "trash.circle.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.red)
                        Text(loc("guide.uninstaller"))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 11))
                            .foregroundColor(.blue)
                        Text(loc("guide.autoDetect"))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color(nsColor: .windowBackgroundColor))

            Divider()

            if filteredApps.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "app.badge.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text(viewModel.isScanning ? loc("empty.scanningApps") : loc("empty.noAppsFound"))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(Array(filteredApps.enumerated()), id: \.element.id) { index, app in
                    ModernListRowContainer(index: index) {
                        HStack(spacing: 14) {
                            Image(nsImage: app.icon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)

                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 6) {
                                    Text(app.name)
                                        .font(.body)
                                        .fontWeight(.medium)

                                    if app.isSystemApp {
                                        HStack(spacing: 3) {
                                            Image(systemName: "lock.shield.fill")
                                                .font(.system(size: 9))
                                            Text(loc("tag.systemProtected"))
                                                .font(.caption2)
                                                .fontWeight(.medium)
                                        }
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.orange.opacity(0.15))
                                        .foregroundColor(.orange)
                                        .cornerRadius(4)
                                    } else {
                                        Text(loc("tag.app"))
                                            .font(.caption2)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.blue.opacity(0.15))
                                            .foregroundColor(.blue)
                                            .cornerRadius(4)

                                        Text(loc("tag.uninstaller"))
                                            .font(.caption2)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.purple.opacity(0.15))
                                            .foregroundColor(.purple)
                                            .cornerRadius(4)
                                    }
                                }

                                Text(app.url.path)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }

                            Spacer()

                            let maxSize = filteredApps.first?.size ?? 1
                            let fraction = CGFloat(app.size) / CGFloat(maxSize)
                            GeometryReader { geo in
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.blue.opacity(0.35))
                                    .frame(width: max(4, geo.size.width * fraction), height: 8)
                                    .frame(maxHeight: .infinity, alignment: .center)
                            }
                            .frame(width: 80, height: 20)

                            Text(app.formattedSize)
                                .font(.system(.body, design: .monospaced))
                                .fontWeight(.semibold)
                                .frame(width: 85, alignment: .trailing)

                            Button {
                                viewModel.revealInFinder(url: app.url)
                            } label: {
                                Image(systemName: "folder.badge.gearshape")
                            }
                            .buttonStyle(ModernRowActionStyle(tint: .secondary))
                            .help(loc("help.showInFinder"))

                            if app.isSystemApp {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary.opacity(0.6))
                                    .frame(width: 28, height: 28)
                                    .help(loc("help.systemAppProtected"))
                            } else {
                                Button(role: .destructive) {
                                    appToUninstall = app
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .buttonStyle(ModernRowActionStyle(isDanger: true))
                                .help(loc("help.uninstallClean"))
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 2, leading: 10, bottom: 2, trailing: 10))
                    .listRowSeparator(.hidden)
                }
                .listStyle(.inset)
                .sheet(item: $appToUninstall) { targetApp in
                    AppUninstallerSheet(app: targetApp) {
                        viewModel.applications.removeAll { $0.id == targetApp.id }
                        viewModel.refreshDiskInfo()
                    }
                }
            }
        }
    }
}
