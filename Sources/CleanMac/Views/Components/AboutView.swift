import SwiftUI
import AppKit

public struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        VStack(spacing: 16) {
            // App Icon
            if let iconImage = Bundle.main.image(forResource: "AppIcon") ?? NSImage(contentsOfFile: "Resources/AppIcon.png") {
                Image(nsImage: iconImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 72, height: 72)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
            } else {
                Image(systemName: "internaldrive.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
            }

            // Title & Version
            VStack(spacing: 4) {
                Text("CleanMac")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Versi 1.0 (Build 1)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Developer Credit
            VStack(spacing: 6) {
                Text("Dibuat dengan ❤️ oleh")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("Yogi Anditia")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 4)

            Divider()
                .padding(.horizontal, 20)

            // Description
            Text("Penganalisis penyimpanan disk macOS, pendeteksi berkas besar, pembersih sampah sistem, dan uninstaller aplikasi tuntas.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            // Action Buttons (PayPal & GitHub)
            VStack(spacing: 10) {
                Button {
                    if let url = URL(string: "https://paypal.me/Anditia") {
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Dukung Pengembang via PayPal")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0.0, green: 0.45, blue: 0.85)) // PayPal Blue

                HStack(spacing: 10) {
                    Button {
                        if let url = URL(string: "https://github.com/anditiayo/cleanmac") {
                            NSWorkspace.shared.open(url)
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("Beri Bintang di GitHub")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 5)
                    }
                    .buttonStyle(.bordered)

                    Button("Tutup") {
                        dismiss()
                    }
                    .frame(width: 80)
                    .buttonStyle(.bordered)
                    .keyboardShortcut(.cancelAction)
                }
            }
            .padding(.horizontal, 24)

            // Copyright Footer
            Text("Copyright © 2026 Yogi Anditia. All rights reserved.")
                .font(.system(size: 10))
                .foregroundColor(.secondary.opacity(0.8))
                .padding(.top, 4)
        }
        .padding(.vertical, 24)
        .frame(width: 380)
    }
}

