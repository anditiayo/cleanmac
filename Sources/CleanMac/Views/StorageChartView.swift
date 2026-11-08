import SwiftUI

public struct StorageChartView: View {
    public let categories: [CategoryUsage]
    public var onSelectCategory: ((StorageCategory) -> Void)? = nil

    public init(categories: [CategoryUsage], onSelectCategory: ((StorageCategory) -> Void)? = nil) {
        self.categories = categories
        self.onSelectCategory = onSelectCategory
    }

    private var totalUsed: Int64 {
        categories.reduce(0) { $0 + $1.size }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(loc("dash.catBreakdown"))
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(loc("dash.catBreakdownSub"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if !categories.isEmpty {
                    Text("\(categories.count) \(loc("cat.detected"))")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.secondary.opacity(0.12))
                        .cornerRadius(6)
                }
            }

            if categories.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary.opacity(0.4))
                    Text(loc("dash.scanHint"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 30)
            } else {
                VStack(spacing: 6) {
                    ForEach(Array(categories.enumerated()), id: \.element.id) { index, item in
                        ModernListRowContainer(index: index) {
                            categoryRow(for: item)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
        )
    }

    private func categoryRow(for item: CategoryUsage) -> some View {
        let percentage = totalUsed > 0 ? Double(item.size) / Double(totalUsed) : 0
        let percentageString = String(format: "%.1f%%", percentage * 100)

        return Button {
            onSelectCategory?(item.category)
        } label: {
            HStack(spacing: 12) {
                // Colored Icon squircle
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(item.category.color.opacity(0.15))
                        .frame(width: 34, height: 34)

                    Image(systemName: item.category.iconName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(item.category.color)
                }

                // Category Name & Details
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(item.category.localizedName)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.primary)

                        Text("• \(percentageString)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(nsColor: .separatorColor).opacity(0.2))
                                .frame(height: 5)

                            RoundedRectangle(cornerRadius: 3)
                                .fill(item.category.color)
                                .frame(width: max(4, geo.size.width * CGFloat(percentage)), height: 5)
                        }
                    }
                    .frame(height: 5)
                }

                Spacer()

                // Formatted Size
                Text(item.formattedSize)
                    .font(.system(.subheadline, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.6))
            }
        }
        .buttonStyle(.plain)
    }
}
