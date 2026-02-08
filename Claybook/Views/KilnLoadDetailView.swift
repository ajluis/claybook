import SwiftUI
import SwiftData

struct KilnLoadDetailView: View {
    let kilnLoad: KilnLoad
    @Query private var allItems: [Item]

    private var matchingItems: [Item] {
        allItems.filter { item in
            item.stageLogs.contains { log in
                log.kilnLoadTag == kilnLoad.tag && log.stage == kilnLoad.stageType
            }
        }
    }

    private let columns = [
        GridItem(.flexible(), spacing: Constants.Grid.spacing),
        GridItem(.flexible(), spacing: Constants.Grid.spacing)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header info
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        StageBadge(stage: kilnLoad.stageType)
                        Text(kilnLoad.date.fullDisplay)
                            .font(.subheadline)
                            .foregroundStyle(Color.theme.textSecondary)
                    }

                    if let notes = kilnLoad.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.body)
                            .foregroundStyle(Color.theme.textSecondary)
                    }

                    Text("\(matchingItems.count) piece\(matchingItems.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(Color.theme.textTertiary)
                }
                .padding(.horizontal, Constants.Layout.horizontalPadding)

                // Items grid
                LazyVGrid(columns: columns, spacing: Constants.Grid.spacing) {
                    ForEach(matchingItems, id: \.id) { item in
                        NavigationLink(value: item) {
                            ItemCard(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Constants.Layout.horizontalPadding)
            }
            .padding(.vertical, 16)
        }
        .background(Color.theme.background)
        .navigationTitle(kilnLoad.tag)
        .navigationDestination(for: Item.self) { item in
            ItemDetailView(item: item)
        }
    }
}
