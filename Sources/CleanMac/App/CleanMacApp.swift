import SwiftUI

@main
struct CleanMacApp: App {
    var body: some Scene {
        WindowGroup {
            MainContentView()
                .frame(minWidth: 800, minHeight: 550)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
    }
}

