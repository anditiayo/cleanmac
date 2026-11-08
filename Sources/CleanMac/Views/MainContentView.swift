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
                    }
                }
                .listStyle(.sidebar)

                Divider()

                // Settings Footer in Sidebar (Language & Theme)
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Text(selectedLanguage == .indonesian ? "Bahasa:" : "Language:")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        Picker("Bahasa", selection: $selectedLanguageRaw) {
                            ForEach(AppLanguage.allCases) { lang in
                                Text("\(lang.flag) \(lang.shortLabel)").tag(lang.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                        .controlSize(.small)
                    }

                    HStack(spacing: 8) {
                        Text(selectedLanguage == .indonesian ? "Tema:" : "Theme:")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        Picker("Tema", selection: $selectedThemeRaw) {
                            ForEach(AppTheme.allCases) { theme in
                                Image(systemName: theme.iconName).tag(theme.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                        .controlSize(.small)
                    }

                    Button {
                        showAboutSheet = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "info.circle")
                            Text("Tentang & Donasi (Yogi Anditia)")
                        }
                        .font(.caption2)
                        .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                }
                .padding(10)
                .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
            }
            .navigationSplitViewColumnWidth(min: 190, ideal: 210, max: 250)
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
            .frame(minWidth: 620, minHeight: 460)
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
