import SwiftUI
import SwiftData

struct LibraryView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Item> { !$0.isArchived },
           sort: \Item.updatedAt, order: .reverse) private var items: [Item]
    @Query private var allSettings: [UserSettings]

    @State private var searchText = ""
    @State private var showNewItem = false
    @State private var stageFilterMode: StageFilterMode = .all
    @State private var showFavoritesOnly = false
    @State private var viewMode: ViewMode = .grid

    private var settings: UserSettings? { allSettings.first }
    private let queueStages: Set<StageType> = [.drying, .bisqueKiln, .glazeKiln]

    private enum StageFilterMode: Equatable {
        case all
        case queue
        case custom(Set<StageType>)
    }

    private enum ActiveFilterToken: Hashable {
        case queue
        case favorites
        case stage(StageType)
    }

    private var selectedStages: Set<StageType> {
        switch stageFilterMode {
        case .all: []
        case .queue: queueStages
        case .custom(let stages): stages
        }
    }

    private var isCustomStageFilter: Bool {
        if case .custom = stageFilterMode { return true }
        return false
    }

    private var activeFilterTokens: [ActiveFilterToken] {
        var tokens: [ActiveFilterToken] = []
        switch stageFilterMode {
        case .all:
            break
        case .queue:
            tokens.append(.queue)
        case .custom(let stages):
            tokens.append(contentsOf: stages.sorted { $0.rawValue < $1.rawValue }.map { .stage($0) })
        }

        if showFavoritesOnly {
            tokens.append(.favorites)
        }
        return tokens
    }

    private var filteredItems: [Item] {
        var result = items

        // Search filter
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter { item in
                item.title.lowercased().contains(query)
                || (item.clayType?.lowercased().contains(query) ?? false)
                || item.stageLogs.flatMap(\.glazesUsed).contains { $0.name.lowercased().contains(query) }
                || item.stageLogs.flatMap(\.colorsUsed).contains { $0.name.lowercased().contains(query) }
                || item.stageLogs.compactMap(\.notes).contains { $0.lowercased().contains(query) }
            }
        }

        // Stage filter
        if !selectedStages.isEmpty {
            result = result.filter { selectedStages.contains($0.currentStage) }
        }

        // Favorites filter
        if showFavoritesOnly {
            result = result.filter(\.isFavorite)
        }

        return result
    }

    private var gridColumns: [GridItem] {
        let minWidth: CGFloat
        if dynamicTypeSize.isAccessibilitySize {
            minWidth = 300
        } else if horizontalSizeClass == .compact {
            minWidth = 170
        } else {
            minWidth = 220
        }

        return [
            GridItem(.adaptive(minimum: minWidth, maximum: 320), spacing: Constants.Grid.spacing, alignment: .top)
        ]
    }

    private func clearAllFilters() {
        stageFilterMode = .all
        showFavoritesOnly = false
    }

    private func toggleQueueFilter() {
        stageFilterMode = (stageFilterMode == .queue) ? .all : .queue
    }

    private func toggleStage(_ stage: StageType) {
        var stages = selectedStages
        if stages.contains(stage) {
            stages.remove(stage)
        } else {
            stages.insert(stage)
        }

        if stages.isEmpty {
            stageFilterMode = .all
        } else if stages == queueStages {
            stageFilterMode = .queue
        } else {
            stageFilterMode = .custom(stages)
        }
    }

    private func removeToken(_ token: ActiveFilterToken) {
        switch token {
        case .queue:
            if stageFilterMode == .queue {
                stageFilterMode = .all
            }
        case .favorites:
            showFavoritesOnly = false
        case .stage(let stage):
            guard case .custom(var stages) = stageFilterMode else { return }
            stages.remove(stage)
            if stages.isEmpty {
                stageFilterMode = .all
            } else if stages == queueStages {
                stageFilterMode = .queue
            } else {
                stageFilterMode = .custom(stages)
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background.ignoresSafeArea()

                if items.isEmpty {
                    EmptyStateView(
                        icon: "cup.and.saucer",
                        title: "No Pieces Yet",
                        message: "Start tracking your pottery by adding your first piece.",
                        buttonTitle: "Add Your First Piece",
                        action: { showNewItem = true }
                    )
                } else {
                    VStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 8) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    Button("All") {
                                        clearAllFilters()
                                    }
                                    .font(.subheadline)
                                    .lineLimit(1)
                                    .foregroundStyle(stageFilterMode == .all && !showFavoritesOnly ? .white : Color.theme.textPrimary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(stageFilterMode == .all && !showFavoritesOnly ? Color.theme.primary : Color.theme.surfaceSecondary)
                                    .clipShape(Capsule())
                                    .fixedSize(horizontal: true, vertical: false)

                                    Button("Queue") {
                                        toggleQueueFilter()
                                    }
                                    .font(.subheadline)
                                    .lineLimit(1)
                                    .foregroundStyle(stageFilterMode == .queue ? .white : Color.theme.textPrimary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(stageFilterMode == .queue ? Color.theme.primary : Color.theme.surfaceSecondary)
                                    .clipShape(Capsule())
                                    .fixedSize(horizontal: true, vertical: false)

                                    Button {
                                        showFavoritesOnly.toggle()
                                    } label: {
                                        Label("Favs", systemImage: showFavoritesOnly ? "star.fill" : "star")
                                            .font(.subheadline)
                                            .lineLimit(1)
                                            .foregroundStyle(showFavoritesOnly ? .white : Color.theme.textPrimary)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(showFavoritesOnly ? Color.theme.primary : Color.theme.surfaceSecondary)
                                            .clipShape(Capsule())
                                            .fixedSize(horizontal: true, vertical: false)
                                    }

                                    Menu {
                                        Button {
                                            stageFilterMode = .all
                                        } label: {
                                            HStack {
                                                Text("All Stages")
                                                if selectedStages.isEmpty {
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                        }

                                        Divider()

                                        ForEach(StageType.allCases) { stage in
                                            Button {
                                                toggleStage(stage)
                                            } label: {
                                                HStack {
                                                    Text(stage.displayName)
                                                    if selectedStages.contains(stage) {
                                                        Image(systemName: "checkmark")
                                                    }
                                                }
                                            }
                                        }
                                    } label: {
                                        Label("Stages", systemImage: "chevron.down")
                                            .font(.subheadline)
                                            .lineLimit(1)
                                            .foregroundStyle(isCustomStageFilter ? .white : Color.theme.textPrimary)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(isCustomStageFilter ? Color.theme.primary : Color.theme.surfaceSecondary)
                                            .clipShape(Capsule())
                                            .fixedSize(horizontal: true, vertical: false)
                                    }
                                }
                                .padding(.horizontal, Constants.Layout.horizontalPadding)
                            }
                            .padding(.vertical, 8)

                            if !activeFilterTokens.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(activeFilterTokens, id: \.self) { token in
                                            Button {
                                                removeToken(token)
                                            } label: {
                                                HStack(spacing: 4) {
                                                    Text({
                                                        switch token {
                                                        case .queue:
                                                            "Queue"
                                                        case .favorites:
                                                            "Favorites"
                                                        case .stage(let stage):
                                                            stage.shortName
                                                        }
                                                    }())
                                                    Image(systemName: "xmark")
                                                        .font(.caption2)
                                                }
                                                .font(.caption.weight(.semibold))
                                                .foregroundStyle(Color.theme.primaryDark)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 6)
                                                .background(Color.theme.primary.opacity(0.14))
                                                .clipShape(Capsule())
                                            }
                                        }

                                        Button("Clear") {
                                            clearAllFilters()
                                        }
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(Color.theme.textSecondary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.theme.surfaceSecondary)
                                        .clipShape(Capsule())
                                    }
                                    .padding(.horizontal, Constants.Layout.horizontalPadding)
                                    .padding(.bottom, 8)
                                }
                            }
                        }

                        if filteredItems.isEmpty {
                            EmptyStateView(
                                icon: "magnifyingglass",
                                title: "No Results",
                                message: "Try adjusting your search or filters."
                            )
                        } else if viewMode == .grid {
                            ScrollView {
                                LazyVGrid(columns: gridColumns, spacing: Constants.Grid.spacing) {
                                    ForEach(filteredItems, id: \.id) { item in
                                        NavigationLink(value: item) {
                                            ItemCard(item: item)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, Constants.Layout.horizontalPadding)
                                .padding(.bottom, 80) // space for FAB
                            }
                        } else {
                            List {
                                ForEach(filteredItems, id: \.id) { item in
                                    NavigationLink(value: item) {
                                        ItemRow(item: item)
                                    }
                                }
                            }
                            .listStyle(.plain)
                        }
                    }
                }

                // Floating action button
                if !items.isEmpty {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button {
                                showNewItem = true
                            } label: {
                                Image(systemName: "plus")
                                    .font(.title2.weight(.semibold))
                                    .foregroundStyle(.white)
                                    .frame(width: Constants.Layout.fabSize, height: Constants.Layout.fabSize)
                                    .background(Color.theme.primary)
                                    .clipShape(Circle())
                                    .shadow(color: Color.theme.primary.opacity(0.3), radius: 8, y: 4)
                            }
                            .padding(.trailing, Constants.Layout.horizontalPadding)
                            .padding(.bottom, 16)
                        }
                    }
                }
            }
            .navigationTitle("My Pottery")
            .searchable(text: $searchText, prompt: "Search pieces...")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Picker("View", selection: $viewMode) {
                        Image(systemName: "square.grid.2x2").tag(ViewMode.grid)
                        Image(systemName: "list.bullet").tag(ViewMode.list)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 100)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .navigationDestination(for: Item.self) { item in
                ItemDetailView(item: item)
            }
            .sheet(isPresented: $showNewItem) {
                NewItemView()
            }
            .onAppear {
                if let settings {
                    viewMode = settings.defaultViewMode
                }
            }
        }
    }
}
