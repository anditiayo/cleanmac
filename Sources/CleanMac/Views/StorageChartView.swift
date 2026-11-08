import SwiftUI
import Charts

public struct StorageChartView: View {
    public let categories: [CategoryUsage]

    public init(categories: [CategoryUsage]) {
        self.categories = categories
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Penggunaan Berdasarkan Kategori")
                .font(.headline)

            if categories.isEmpty {
                Text("Klik 'Mulai Scan' untuk melihat rincian kategori.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
            } else {
                Chart(categories) { item in
                    BarMark(
                        x: .value("Ukuran", Double(item.size) / (1024 * 1024 * 1024)),
                        y: .value("Kategori", item.category.rawValue)
                    )
                    .foregroundStyle(item.category.color)
                    .annotation(position: .trailing) {
                        Text(item.formattedSize)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .chartXAxisLabel("Ukuran (GB)")
                .frame(height: max(140, CGFloat(categories.count * 35)))

                // Category chips
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 8) {
                    ForEach(categories) { item in
                        HStack(spacing: 8) {
                            Image(systemName: item.category.iconName)
                                .foregroundColor(item.category.color)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.category.rawValue)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                Text(item.formattedSize)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(8)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(8)
                    }
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

