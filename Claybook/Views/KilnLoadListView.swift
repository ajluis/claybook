import SwiftUI
import SwiftData

struct KilnLoadListView: View {
    @Query(sort: \KilnLoad.date, order: .reverse) private var kilnLoads: [KilnLoad]

    var body: some View {
        Group {
            if kilnLoads.isEmpty {
                EmptyStateView(
                    icon: "flame",
                    title: "No Kiln Loads",
                    message: "Kiln loads appear here when you log bisque or glaze firings with a tag."
                )
            } else {
                List(kilnLoads, id: \.id) { load in
                    NavigationLink {
                        KilnLoadDetailView(kilnLoad: load)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(load.tag)
                                    .font(.body.weight(.medium))
                                HStack(spacing: 8) {
                                    StageBadge(stage: load.stageType)
                                    Text(load.date.mediumDisplay)
                                        .font(.caption)
                                        .foregroundStyle(Color.theme.textSecondary)
                                }
                            }
                            Spacer()
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Kiln Loads")
    }
}
