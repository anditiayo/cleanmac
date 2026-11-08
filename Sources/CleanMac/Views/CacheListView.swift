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
            // PRO HEADER SECTION
            VStack(spacing: 12) {
                // Row 1: Back Navigation + Search + Action
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
                        TextField(loc("search.cache"), text: $searchText)
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

                    if !viewModel.cacheFiles.isEmpty {
                        Button(role: .destructive) {
                            viewModel.cleanAllCaches()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 11, weight: .semibold))
                                Text(loc("action.cleanAllCaches"))
                            }
                        }
                        .buttonStyle(ModernPrimaryButtonStyle(isDestructive: true))
                    }
                }

                // Row 2: Title & Metrics
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(loc("header.caches"))
                            .font(.title2)
                            .fontWeight(.bold)
                            .lineLimit(1)
                        Text(loc("header.cachesSub"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    // Metrics badge
                    HStack(spacing: 12) {
                        VStack(alignment: .trailing, spacing: 1) {
                            Text(ByteFormatter.string(from: viewModel.totalCachesSize))
                                .font(.system(.title3, design: .monospaced))
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Text("\(filteredCaches.count) \(loc("stat.cacheFolders"))")
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
                    Text(loc("guide.cacheGuide"))
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.green)
                        Text(loc("guide.cacheSafety"))
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

            if filteredCaches.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text(viewModel.isScanning ? loc("empty.scanningCaches") : loc("empty.noCachesFound"))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(Array(filteredCaches.enumerated()), id: \.element.id) { index, item in
                    ModernListRowContainer(index: index) {
                        HStack(spacing: 14) {
                            Image(systemName: "archivebox.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.orange)
                                .frame(width: 36, height: 36)

                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 6) {
                                    Text(item.name)
                                        .font(.body)
                                        .fontWeight(.medium)

                                    Text(loc("tag.cache"))
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.orange.opacity(0.15))
                                        .foregroundColor(.orange)
                                        .cornerRadius(4)

                                    Text(loc("tag.safeToDelete"))
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.green.opacity(0.15))
                                        .foregroundColor(.green)
                                        .cornerRadius(4)
                                }

                                Text(item.url.path)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }

                            Spacer()

                            let maxSize = filteredCaches.first?.size ?? 1
                            let fraction = CGFloat(item.size) / CGFloat(maxSize)
                            GeometryReader { geo in
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.orange.opacity(0.35))
                                    .frame(width: max(4, geo.size.width * fraction), height: 8)
                                    .frame(maxHeight: .infinity, alignment: .center)
                            }
                            .frame(width: 80, height: 20)

                            Text(item.formattedSize)
                                .font(.system(.body, design: .monospaced))
                                .fontWeight(.semibold)
                                .frame(width: 85, alignment: .trailing)

                            Button {
                                viewModel.revealInFinder(url: item.url)
                            } label: {
                                Image(systemName: "folder.badge.gearshape")
                            }
                            .buttonStyle(ModernRowActionStyle(tint: .secondary))
                            .help(loc("help.showInFinder"))

                            Button(role: .destructive) {
                                _ = viewModel.moveToTrash(url: item.url)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(ModernRowActionStyle(isDanger: true))
                            .help(loc("help.moveToTrash"))
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 2, leading: 10, bottom: 2, trailing: 10))
                    .listRowSeparator(.hidden)
                }
                .listStyle(.inset)
            }
        }
    }
}
