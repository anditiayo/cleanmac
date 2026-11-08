import SwiftUI

public struct StorageBarView: View {
    public let diskInfo: DiskInfo
    public let categories: [CategoryUsage]

    public init(diskInfo: DiskInfo, categories: [CategoryUsage] = []) {
        self.diskInfo = diskInfo
        self.categories = categories
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                Label("Macintosh HD", systemImage: "internaldrive.fill")
                    .font(.headline)
                Spacer()
                Text("\(diskInfo.usedFormatted) \(loc("bar.usedOf")) \(diskInfo.totalFormatted)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Multi-segment storage bar (macOS Settings style)
            GeometryReader { geo in
                let totalWidth = geo.size.width

                ZStack(alignment: .leading) {
                    // Background track (empty / free space)
                    RoundedRectangle(cornerRadius: 7)
                        .fill(Color(nsColor: .separatorColor).opacity(0.35))
                        .frame(height: 20)

                    if categories.isEmpty {
                        // Fallback before scan
                        RoundedRectangle(cornerRadius: 7)
                            .fill(Color.blue)
                            .frame(width: max(0, min(totalWidth * CGFloat(diskInfo.usedPercentage), totalWidth)), height: 20)
                    } else {
                        // Multi-color segmented bar
                        HStack(spacing: 1.5) {
                            ForEach(categories) { item in
                                let segmentWidth = max(2, totalWidth * CGFloat(Double(item.size) / Double(max(1, diskInfo.totalSpace))))
                                Rectangle()
                                    .fill(item.category.color)
                                    .frame(width: segmentWidth, height: 20)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                    }
                }
            }
            .frame(height: 20)

            // Category legend with colored dots
            if !categories.isEmpty {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 130), spacing: 8)], alignment: .leading, spacing: 6) {
                    ForEach(categories) { item in
                        HStack(spacing: 5) {
                            Circle()
                                .fill(item.category.color)
                                .frame(width: 8, height: 8)
                            Text(item.category.localizedName)
                                .font(.caption)
                                .foregroundColor(.primary)
                            Text(item.formattedSize)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }

                    // Available space legend
                    HStack(spacing: 5) {
                        Circle()
                            .fill(Color.secondary.opacity(0.4))
                            .frame(width: 8, height: 8)
                        Text(loc("bar.available"))
                            .font(.caption)
                            .foregroundColor(.primary)
                        Text(diskInfo.freeFormatted)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 4)
            } else {
                HStack {
                    HStack(spacing: 6) {
                        Circle().fill(Color.blue).frame(width: 8, height: 8)
                        Text("\(loc("bar.used")): \(diskInfo.usedFormatted)")
                            .font(.caption)
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        Circle().fill(Color.secondary.opacity(0.4)).frame(width: 8, height: 8)
                        Text("\(loc("bar.available")): \(diskInfo.freeFormatted)")
                            .font(.caption)
                    }
                    Spacer()
                    Text("\(loc("bar.total")): \(diskInfo.totalFormatted)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
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
