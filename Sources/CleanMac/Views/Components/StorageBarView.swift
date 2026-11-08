import SwiftUI

public struct StorageBarView: View {
    public let diskInfo: DiskInfo

    public init(diskInfo: DiskInfo) {
        self.diskInfo = diskInfo
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Macintosh HD", systemImage: "internaldrive.fill")
                    .font(.headline)
                Spacer()
                Text("\(Int(diskInfo.usedPercentage * 100))% Terpakai")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(nsColor: .separatorColor).opacity(0.3))
                        .frame(height: 16)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: diskInfo.usedPercentage > 0.9 ? [.orange, .red] : [.blue, .cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, min(geo.size.width * CGFloat(diskInfo.usedPercentage), geo.size.width)), height: 16)
                }
            }
            .frame(height: 16)

            HStack {
                HStack(spacing: 6) {
                    Circle().fill(Color.blue).frame(width: 8, height: 8)
                    Text("Terpakai: \(diskInfo.usedFormatted)")
                        .font(.caption)
                        .foregroundColor(.primary)
                }

                Spacer()

                HStack(spacing: 6) {
                    Circle().fill(Color.secondary.opacity(0.4)).frame(width: 8, height: 8)
                    Text("Tersedia: \(diskInfo.freeFormatted)")
                        .font(.caption)
                        .foregroundColor(.primary)
                }

                Spacer()

                Text("Total: \(diskInfo.totalFormatted)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
        )
    }
}

