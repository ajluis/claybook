import SwiftUI
import SwiftData

struct LibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Item> { !$0.isArchived },
           sort: \Item.updatedAt, order: .reverse) private var items: [Item]
    @Query private var allSettings: [UserSettings]

    @State private var searchText = ""
    @State private var showNewItem = false
    @State private var filterChips: [FilterChip] = StageType.allCases.map { FilterChip(label: $0.shortName) }
    @State private var showFavoritesOnly = false
    @State private var viewMode: ViewMode = .grid

    private var settings: UserSettings? { allSettings.first }

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
        let selectedStages = filterChips.enumerated()
            .filter { $0.element.isSelected }
            .map { StageType.allCases[$0.offset] }
        if !selectedStages.isEmpty {
            result = result.filter { selectedStages.contains($0.currentStage) }
        }

        // Favorites filter
        if showFavoritesOnly {
            result = result.filter(\.isFavorite)
        }

        return result
    }

    private let gridColumns = [
        GridItem(.flexible(), spacing: Constants.Grid.spacing),
        GridItem(.flexible(), spacing: Constants.Grid.spacing)
    ]

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
                        // Filter bar
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                // Favorites toggle
                                Button {
                                    showFavoritesOnly.toggle()
                                } label: {
                                    Label("Favorites", systemImage: showFavoritesOnly ? "star.fill" : "star")
                                        .font(.subheadline)
                                        .foregroundStyle(showFavoritesOnly ? .white : Color.theme.textPrimary)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(showFavoritesOnly ? Color.theme.primary : Color.theme.surfaceSecondary)
                                        .clipShape(Capsule())
                                }

                                ForEach(filterChips.indices, id: \.self) { index in
                                    Button {
                                        for i in filterChips.indices {
                                            filterChips[i].isSelected = (i == index) ? !filterChips[i].isSelected : false
                                        }
                                    } label: {
                                        Text(filterChips[index].label)
                                            .font(.subheadline)
                                            .foregroundStyle(filterChips[index].isSelected ? .white : Color.theme.textPrimary)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(filterChips[index].isSelected ? Color.theme.primary : Color.theme.surfaceSecondary)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                            .padding(.horizontal, Constants.Layout.horizontalPadding)
                            .padding(.vertical, 8)
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
