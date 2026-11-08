import SwiftUI
import AppKit

@main
struct CleanMacApp: App {
    var body: some Scene {
        WindowGroup {
            MainContentView()
                .frame(minWidth: 800, minHeight: 550)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("Tentang CleanMac") {
                    let alert = NSAlert()
                    alert.messageText = "CleanMac v1.0"
                    alert.informativeText = "Dibuat oleh Yogi Anditia\n\nTerima kasih telah menggunakan CleanMac!\nAnda dapat mendukung pengembangan aplikasi ini melalui PayPal di paypal.me/Anditia"
                    alert.alertStyle = .informational
                    alert.addButton(withTitle: "Dukung via PayPal")
                    alert.addButton(withTitle: "Buka GitHub")
                    alert.addButton(withTitle: "Tutup")

                    if let iconImage = Bundle.main.image(forResource: "AppIcon") ?? NSImage(contentsOfFile: "Resources/AppIcon.png") {
                        alert.icon = iconImage
                    }

                    let response = alert.runModal()
                    if response == .alertFirstButtonReturn {
                        if let url = URL(string: "https://paypal.me/Anditia") {
                            NSWorkspace.shared.open(url)
                        }
                    } else if response == .alertSecondButtonReturn {
                        if let url = URL(string: "https://github.com/anditiayo/cleanmac") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                }
            }
        }
    }
}
