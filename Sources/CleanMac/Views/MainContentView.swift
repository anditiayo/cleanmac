import SwiftUI

public struct MainContentView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @AppStorage("appTheme") private var selectedThemeRaw: String = AppTheme.system.rawValue
    @AppStorage("appLanguage") private var selectedLanguageRaw: String = AppLanguage.indonesian.rawValue
    @State private var showAboutSheet: Bool = false

    private var selectedTheme: AppTheme {
        AppTheme(rawValue: selectedThemeRaw) ?? .system
    }

    private var selectedLanguage: AppLanguage {
        AppLanguage(rawValue: selectedLanguageRaw) ?? .indonesian
    }

    public init() {}

    public var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                List(NavigationTab.allCases, selection: $viewModel.selectedTab) { tab in
                    NavigationLink(value: tab) {
                        Label(tab.localizedTitle(for: selectedLanguage), systemImage: tab.iconName)
                            .font(.system(size: 13, weight: .medium))
                    }
                }
                .listStyle(.sidebar)

                Divider()

                // Modern Preferences Footer in Sidebar (Language & Theme)
                VStack(spacing: 10) {
                    // Language Switcher Row
                    HStack(spacing: 8) {
                        Image(systemName: "globe")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                            .frame(width: 16)

                        Text(loc("footer.language"))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.primary)
                            .fixedSize()

                        Spacer(minLength: 10)

                        Picker("", selection: $selectedLanguageRaw) {
                            ForEach(AppLanguage.allCases) { lang in
                                Text("\(lang.flag) \(lang.shortLabel)")
                                    .tag(lang.rawValue)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.segmented)
                        .controlSize(.small)
                        .frame(width: 104)
                    }

                    // Theme Switcher Row
                    HStack(spacing: 8) {
                        Image(systemName: "circle.lefthalf.filled")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .frame(width: 16)

                        Text(loc("footer.theme"))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.primary)
                            .fixedSize()

                        Spacer(minLength: 10)

                        Picker("", selection: $selectedThemeRaw) {
                            ForEach(AppTheme.allCases) { theme in
                                Image(systemName: theme.iconName).tag(theme.rawValue)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.segmented)
                        .controlSize(.small)
                        .frame(width: 104)
                    }

                    Divider()
                        .padding(.vertical, 2)

                    // About & Donate Pill Button
                    Button {
                        showAboutSheet = true
                    } label: {
                        HStack(spacing: 7) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                            Text(loc("footer.about"))
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.primary.opacity(0.9))
                                .lineLimit(1)
                            Spacer()
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(
                            RoundedRectangle(cornerRadius: 7)
                                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.7))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(Color(nsColor: .separatorColor).opacity(0.4), lineWidth: 0.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(14)
                .background(Color(nsColor: .controlBackgroundColor).opacity(0.4))
            }
            .navigationSplitViewColumnWidth(min: 240, ideal: 265, max: 320)
        } detail: {
            Group {
                switch viewModel.selectedTab {
                case .dashboard:
                    DashboardOverviewView(viewModel: viewModel)
                case .allFolders:
                    DirectorySizesView(viewModel: viewModel)
                case .junkCleaner:
                    JunkCleanerView(viewModel: viewModel)
                case .apps:
                    AppListView(viewModel: viewModel)
                case .files:
                    FileListView(viewModel: viewModel)
                case .caches:
                    CacheListView(viewModel: viewModel)
                }
            }
            .id(selectedLanguageRaw)
            .frame(minWidth: 640, minHeight: 480)
        }
        .preferredColorScheme(selectedTheme.colorScheme)
        .sheet(isPresented: $showAboutSheet) {
            AboutView()
        }
        .onAppear {
            viewModel.refreshDiskInfo()
        }
    }
}
