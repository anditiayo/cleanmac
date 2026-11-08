import SwiftUI

public struct MainContentView: View {
    @StateObject private var viewModel = DashboardViewModel()

    public init() {}

    public var body: some View {
        NavigationSplitView {
            List(NavigationTab.allCases, selection: $viewModel.selectedTab) { tab in
                NavigationLink(value: tab) {
                    Label(tab.rawValue, systemImage: tab.iconName)
                }
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 240)
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
            .frame(minWidth: 600, minHeight: 450)
        }
        .onAppear {
            viewModel.refreshDiskInfo()
        }
    }
}

