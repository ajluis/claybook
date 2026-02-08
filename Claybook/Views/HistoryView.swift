import SwiftUI
import SwiftData

struct HistoryView: View {
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            Picker("Category", selection: $selectedTab) {
                Text("Glazes").tag(0)
                Text("Colors").tag(1)
                Text("Clays").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()

            switch selectedTab {
            case 0: GlazeHistoryTab()
            case 1: ColorHistoryTab()
            default: ClayHistoryTab()
            }
        }
        .navigationTitle("History")
    }
}

struct GlazeHistoryTab: View {
    @Query private var allGlazes: [GlazeEntry]
    @Query private var allItems: [Item]

    private var glazeStats: [(name: String, count: Int, lastUsed: Date?)] {
        let grouped = Dictionary(grouping: allGlazes, by: \.name)
        return grouped.map { (name, entries) in
            let items = allItems.filter { item in
                item.stageLogs.flatMap(\.glazesUsed).contains { $0.name == name }
            }
            let lastDate = entries.compactMap { $0.stageLog?.date }.max()
            return (name: name, count: items.count, lastUsed: lastDate)
        }
        .sorted { $0.name < $1.name }
    }

    var body: some View {
        if glazeStats.isEmpty {
            EmptyStateView(icon: "paintbrush", title: "No Glazes", message: "Glazes will appear here after you log them.")
        } else {
            List(glazeStats, id: \.name) { stat in
                VStack(alignment: .leading, spacing: 4) {
                    Text(stat.name)
                        .font(.body.weight(.medium))
                    HStack(spacing: 12) {
                        Text("Used \(stat.count) time\(stat.count == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundStyle(Color.theme.textSecondary)
                        if let date = stat.lastUsed {
                            Text("Last: \(date.shortDisplay)")
                                .font(.caption)
                                .foregroundStyle(Color.theme.textTertiary)
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}

struct ColorHistoryTab: View {
    @Query private var allColors: [ColorEntry]
    @Query private var allItems: [Item]

    private var colorStats: [(name: String, hex: String?, count: Int)] {
        let grouped = Dictionary(grouping: allColors, by: \.name)
        return grouped.map { (name, entries) in
            let count = allItems.filter { item in
                item.stageLogs.flatMap(\.colorsUsed).contains { $0.name == name }
            }.count
            return (name: name, hex: entries.first?.paletteColor, count: count)
        }
        .sorted { $0.name < $1.name }
    }

    var body: some View {
        if colorStats.isEmpty {
            EmptyStateView(icon: "paintpalette", title: "No Colors", message: "Colors will appear here after you log them.")
        } else {
            List(colorStats, id: \.name) { stat in
                HStack(spacing: 12) {
                    if let hex = stat.hex {
                        ColorDot(hex: hex)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(stat.name)
                            .font(.body.weight(.medium))
                        Text("Used \(stat.count) time\(stat.count == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundStyle(Color.theme.textSecondary)
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}

struct ClayHistoryTab: View {
    @Query private var allItems: [Item]

    private var clayStats: [(name: String, count: Int)] {
        let grouped = Dictionary(grouping: allItems.filter { $0.clayType != nil && !$0.clayType!.isEmpty }, by: \.clayType!)
        return grouped.map { (name, items) in
            (name: name, count: items.count)
        }
        .sorted { $0.name < $1.name }
    }

    var body: some View {
        if clayStats.isEmpty {
            EmptyStateView(icon: "circle.fill", title: "No Clays", message: "Clay types will appear here after you add them to your pieces.")
        } else {
            List(clayStats, id: \.name) { stat in
                VStack(alignment: .leading, spacing: 4) {
                    Text(stat.name)
                        .font(.body.weight(.medium))
                    Text("\(stat.count) piece\(stat.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(Color.theme.textSecondary)
                }
            }
            .listStyle(.plain)
        }
    }
}
