import SwiftUI
import AppKit

public struct ScanPermissionSheet: View {
    @ObservedObject var viewModel: DashboardViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var permissions: ScanPermissions
    @State private var rememberChoice: Bool = true

    public init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
        self._permissions = State(initialValue: viewModel.scanPermissions)
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.85), Color.cyan.opacity(0.85)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)

                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(loc("perm.title"))
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(loc("perm.badge"))
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.15))
                            .foregroundColor(.green)
                            .cornerRadius(4)
                    }

                    Text(loc("perm.sub"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button {
                    viewModel.showScanPermissionSheet = false
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

            // Checklist Content
            ScrollView {
                VStack(spacing: 10) {
                    checklistRow(
                        title: loc("perm.appsTitle"),
                        description: loc("perm.appsDesc"),
                        icon: "app.badge.fill",
                        iconColor: .blue,
                        isOn: $permissions.scanApplications
                    )

                    checklistRow(
                        title: loc("perm.filesTitle"),
                        description: loc("perm.filesDesc"),
                        icon: "doc.badge.gearshape.fill",
                        iconColor: .green,
                        isOn: $permissions.scanLargeFiles
                    )

                    checklistRow(
                        title: loc("perm.junkTitle"),
                        description: loc("perm.junkDesc"),
                        icon: "sparkles",
                        iconColor: .red,
                        isOn: $permissions.scanJunk
                    )

                    checklistRow(
                        title: loc("perm.cacheTitle"),
                        description: loc("perm.cacheDesc"),
                        icon: "trash.fill",
                        iconColor: .purple,
                        isOn: $permissions.scanCaches
                    )

                    checklistRow(
                        title: loc("perm.deepTitle"),
                        description: loc("perm.deepDesc"),
                        icon: "folder.badge.questionmark",
                        iconColor: .cyan,
                        isOn: $permissions.scanDeepDirectories
                    )
                }
                .padding(20)
            }
            .frame(maxHeight: 280)

            Divider()

            // Footer
            VStack(spacing: 12) {
                HStack {
                    Toggle(isOn: $rememberChoice) {
                        HStack(spacing: 6) {
                            Text(loc("perm.remember"))
                                .font(.caption)
                                .fontWeight(.medium)
                            Text(loc("perm.rememberSub"))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .toggleStyle(.checkbox)

                    Spacer()
                }

                HStack {
                    Button {
                        viewModel.showScanPermissionSheet = false
                        dismiss()
                    } label: {
                        Text(loc("action.cancel"))
                    }
                    .buttonStyle(ModernSecondaryButtonStyle())
                    .keyboardShortcut(.cancelAction)

                    Spacer()

                    Button {
                        viewModel.saveAndApplyPermissions(permissions, remember: rememberChoice)
                        viewModel.showScanPermissionSheet = false
                        dismiss()
                        viewModel.startScanWithOptions()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                            Text(loc("action.allowAndScan"))
                        }
                    }
                    .buttonStyle(ModernPrimaryButtonStyle(tintColor: .blue))
                    .disabled(!permissions.hasAnySelected)
                    .keyboardShortcut(.defaultAction)
                }
            }
            .padding(16)
            .background(Color(nsColor: .windowBackgroundColor).opacity(0.6))
        }
        .frame(width: 530, height: 450)
    }

    private func checklistRow(
        title: String,
        description: String,
        icon: String,
        iconColor: Color,
        isOn: Binding<Bool>
    ) -> some View {
        Button {
            isOn.wrappedValue.toggle()
        } label: {
            HStack(spacing: 14) {
                // Checkbox toggle
                Image(systemName: isOn.wrappedValue ? "checkmark.square.fill" : "square")
                    .font(.system(size: 18))
                    .foregroundColor(isOn.wrappedValue ? .accentColor : .secondary)

                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 36, height: 36)

                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(iconColor)
                }

                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)

                    Text(description)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isOn.wrappedValue ? Color(nsColor: .controlBackgroundColor).opacity(0.7) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isOn.wrappedValue ? iconColor.opacity(0.3) : Color.gray.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
