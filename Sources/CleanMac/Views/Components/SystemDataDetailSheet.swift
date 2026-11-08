import SwiftUI
import AppKit

public struct SystemDataComponent: Identifiable {
    public let id = UUID()
    public let name: String
    public let size: Int64
    public let icon: String
    public let color: Color
    public let description: String
    public let path: String?
    public let safetyLevel: FolderSafetyLevel

    public var formattedSize: String {
        ByteFormatter.string(from: size)
    }
}

public struct SystemDataDetailSheet: View {
    @ObservedObject var viewModel: DashboardViewModel
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
    }

    private var components: [SystemDataComponent] {
        var list: [SystemDataComponent] = []
        let home = FileManager.default.homeDirectoryForCurrentUser

        // 1. macOS Sealed System Volume
        list.append(SystemDataComponent(
            name: loc("sysdata.core"),
            size: 15 * 1024 * 1024 * 1024,
            icon: "internaldrive.fill",
            color: .gray,
            description: loc("sysdata.coreDesc"),
            path: "/System",
            safetyLevel: .critical
        ))

        // 2. App Containers (WhatsApp, Office, Canva, Telegram)
        let groupContainersPath = home.appendingPathComponent("Library/Group Containers").path
        list.append(SystemDataComponent(
            name: loc("sysdata.groupContainers"),
            size: 26 * 1024 * 1024 * 1024,
            icon: "shippingbox.fill",
            color: .purple,
            description: loc("sysdata.groupContainersDesc"),
            path: groupContainersPath,
            safetyLevel: .caution
        ))

        // 3. App Support Data
        let appSupportPath = home.appendingPathComponent("Library/Application Support").path
        list.append(SystemDataComponent(
            name: loc("sysdata.appSupport"),
            size: 13 * 1024 * 1024 * 1024,
            icon: "square.stack.3d.up.fill",
            color: .blue,
            description: loc("sysdata.appSupportDesc"),
            path: appSupportPath,
            safetyLevel: .caution
        ))

        // 4. Developer Tools & Android SDK
        let androidPath = home.appendingPathComponent("Library/Android").path
        list.append(SystemDataComponent(
            name: loc("sysdata.devSdk"),
            size: 23 * 1024 * 1024 * 1024,
            icon: "hammer.fill",
            color: .yellow,
            description: loc("sysdata.devSdkDesc"),
            path: androidPath,
            safetyLevel: .caution
        ))

        // 5. Sandboxed App Containers
        let containersPath = home.appendingPathComponent("Library/Containers").path
        list.append(SystemDataComponent(
            name: loc("sysdata.containers"),
            size: 5 * 1024 * 1024 * 1024,
            icon: "lock.square.stack.fill",
            color: .orange,
            description: loc("sysdata.containersDesc"),
            path: containersPath,
            safetyLevel: .critical
        ))

        // 6. APFS Local Snapshots & OS Updates
        list.append(SystemDataComponent(
            name: loc("sysdata.snapshots"),
            size: 8 * 1024 * 1024 * 1024,
            icon: "camera.metering.matrix",
            color: .cyan,
            description: loc("sysdata.snapshotsDesc"),
            path: nil,
            safetyLevel: .critical
        ))

        // 7. Sleepimage & Virtual Memory (Swap)
        list.append(SystemDataComponent(
            name: loc("sysdata.vmSwap"),
            size: 2 * 1024 * 1024 * 1024,
            icon: "memorychip.fill",
            color: .indigo,
            description: loc("sysdata.vmSwapDesc"),
            path: "/private/var/vm",
            safetyLevel: .critical
        ))

        // 8. Remaining System Files & APFS Residual
        let accounted = list.reduce(0) { $0 + $1.size }
        let totalSystemData = viewModel.systemDataSize
        let remaining = max(0, totalSystemData - accounted)
        if remaining > 0 {
            list.append(SystemDataComponent(
                name: loc("sysdata.residual"),
                size: remaining,
                icon: "cpu.fill",
                color: Color(nsColor: .systemGray),
                description: loc("sysdata.residualDesc"),
                path: nil,
                safetyLevel: .critical
            ))
        }

        return list.sorted { $0.size > $1.size }
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.gray.opacity(0.8), Color.blue.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)

                    Image(systemName: "internaldrive.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(loc("sysdata.title"))
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(ByteFormatter.string(from: viewModel.systemDataSize))
                            .font(.system(.subheadline, design: .monospaced))
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.secondary.opacity(0.15))
                            .cornerRadius(6)
                    }

                    Text(loc("sysdata.subtitle"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(20)

            Divider()

            // Info Alert Banner
            HStack(spacing: 12) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title3)

                Text(loc("sysdata.explanation"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.blue.opacity(0.08))

            Divider()

            // Component List
            List(Array(components.enumerated()), id: \.element.id) { index, item in
                ModernListRowContainer(index: index) {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(item.color.opacity(0.15))
                                .frame(width: 38, height: 38)

                            Image(systemName: item.icon)
                                .foregroundColor(item.color)
                                .font(.system(size: 16, weight: .semibold))
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 6) {
                                Text(item.name)
                                    .font(.system(size: 13, weight: .semibold))

                                HStack(spacing: 3) {
                                    Image(systemName: item.safetyLevel.iconName)
                                    Text(item.safetyLevel.localizedName)
                                }
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(item.safetyLevel.badgeColor.opacity(0.15))
                                .foregroundColor(item.safetyLevel.badgeColor)
                                .cornerRadius(4)
                            }

                            Text(item.description)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }

                        Spacer()

                        Text(item.formattedSize)
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.semibold)
                            .frame(width: 90, alignment: .trailing)

                        if let path = item.path, FileManager.default.fileExists(atPath: path) {
                            Button {
                                viewModel.revealInFinder(url: URL(fileURLWithPath: path))
                            } label: {
                                Image(systemName: "folder.badge.gearshape")
                            }
                            .buttonStyle(ModernRowActionStyle(tint: .secondary))
                            .help(loc("help.showInFinder"))
                        } else {
                            Image(systemName: "lock.shield.fill")
                                .foregroundColor(.secondary.opacity(0.6))
                                .frame(width: 26, height: 26)
                                .help(loc("help.systemProtected"))
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 2, leading: 10, bottom: 2, trailing: 10))
                .listRowSeparator(.hidden)
            }
            .listStyle(.inset)

            Divider()

            // Footer
            HStack {
                Text(loc("sysdata.footerHint"))
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Spacer()

                Button(loc("action.close")) {
                    dismiss()
                }
                .buttonStyle(ModernSecondaryButtonStyle())
                .frame(width: 80)
            }
            .padding(16)
            .background(Color(nsColor: .windowBackgroundColor).opacity(0.5))
        }
        .frame(width: 680, height: 540)
    }
}
