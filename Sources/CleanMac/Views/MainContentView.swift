import SwiftUI

public struct MainContentView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @AppStorage("appTheme") private var selectedThemeRaw: String = AppTheme.system.rawValue

    private var selectedTheme: AppTheme {
        AppTheme(rawValue: selectedThemeRaw) ?? .system
    }

    public init() {}

    public var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                List(NavigationTab.allCases, selection: $viewModel.selectedTab) { tab in
                    NavigationLink(value: tab) {
                        Label(tab.rawValue, systemImage: tab.iconName)
                    }
                }
                .listStyle(.sidebar)

                Divider()

                // Theme Switcher Footer in Sidebar
                HStack(spacing: 8) {
                    Text("Tema:")
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
        .onAppear {
            viewModel.refreshDiskInfo()
        }
    }
}
