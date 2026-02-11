import SwiftUI
import SwiftData

struct ItemDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var item: Item
    @Query private var allSettings: [UserSettings]

    @State private var showLogStage = false
    @State private var showEditItem = false
    @State private var showPhotoComparison = false
    @State private var showShareCard = false
    @State private var showDeleteConfirmation = false
    @State private var showDuplicate = false
    @State private var editingStageLog: StageLog?

    private var settings: UserSettings? { allSettings.first }
    private var unit: MeasurementUnit { settings?.measurementUnit ?? .inches }

    private var nextStage: StageType? {
        item.currentStage.next
    }

    private var sortedStageLogs: [StageLog] {
        item.stageLogs.sorted { $0.stage.rawValue < $1.stage.rawValue }
    }

    private var hasMultipleStagePhotos: Bool {
        item.stageLogs.filter { !$0.photos.isEmpty }.count >= 2
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero photo
                heroSection

                // Quick facts
                quickFactsSection

                // Primary action
                if let nextStage {
                    LargeButton(
                        title: "Log \(nextStage.shortName)",
                        icon: "plus.circle.fill"
                    ) {
                        showLogStage = true
                    }
                    .padding(.horizontal, Constants.Layout.horizontalPadding)
                    .padding(.top, Constants.Layout.sectionSpacing)
                }

                // Stage timeline
                VStack(alignment: .leading, spacing: 12) {
                    Text("Timeline")
                        .sectionHeader()
                        .padding(.horizontal, Constants.Layout.horizontalPadding)

                    StageTimeline(
                        stageLogs: item.stageLogs,
                        currentStage: item.currentStage,
                        onStageTapped: { log in
                            editingStageLog = log
                        }
                    )
                    .padding(.horizontal, Constants.Layout.horizontalPadding)
                }
                .padding(.top, Constants.Layout.sectionSpacing)

                // Photo strips per stage
                ForEach(sortedStageLogs, id: \.id) { log in
                    if !log.photos.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(log.stage.shortName) Photos")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(Color.theme.textSecondary)
                                .padding(.horizontal, Constants.Layout.horizontalPadding)

                            PhotoStrip(photos: log.photos)
                        }
                        .padding(.top, 12)
                    }
                }

                // Glaze info for glazed stages
                ForEach(sortedStageLogs.filter { $0.stage.isGlazedStage }, id: \.id) { log in
                    if !log.glazesUsed.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Glazes Applied")
                                .sectionHeader()
                                .padding(.horizontal, Constants.Layout.horizontalPadding)

                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(log.glazesUsed.sorted { $0.order < $1.order }, id: \.id) { glaze in
                                    HStack(spacing: 8) {
                                        Text("\(glaze.order).")
                                            .font(.caption)
                                            .foregroundStyle(Color.theme.textTertiary)
                                            .frame(width: 20)
                                        Text(glaze.name)
                                            .font(.body)
                                            .foregroundStyle(Color.theme.textPrimary)
                                    }
                                }
                            }
                            .padding(.horizontal, Constants.Layout.horizontalPadding)
                        }
                        .padding(.top, 12)
                    }

                    if !log.colorsUsed.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Colors")
                                .sectionHeader()
                                .padding(.horizontal, Constants.Layout.horizontalPadding)

                            HStack(spacing: 8) {
                                ForEach(log.colorsUsed, id: \.id) { color in
                                    HStack(spacing: 4) {
                                        if let hex = color.paletteColor {
                                            ColorDot(hex: hex, size: 16)
                                        }
                                        Text(color.name)
                                            .font(.caption)
                                            .foregroundStyle(Color.theme.textPrimary)
                                    }
                                }
                            }
                            .padding(.horizontal, Constants.Layout.horizontalPadding)
                        }
                        .padding(.top, 8)
                    }
                }

                // Action buttons
                actionButtons
                    .padding(.top, Constants.Layout.sectionSpacing)
                    .padding(.bottom, 40)
            }
        }
        .background(Color.theme.background)
        .navigationTitle(item.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    item.isFavorite.toggle()
                    item.updatedAt = Date()
                    modelContext.saveQuietly()
                } label: {
                    Image(systemName: item.isFavorite ? "star.fill" : "star")
                        .foregroundStyle(item.isFavorite ? .yellow : Color.theme.textSecondary)
                }
            }
        }
        .sheet(isPresented: $showLogStage) {
            if let nextStage {
                LogStageView(item: item, stage: nextStage)
            }
        }
        .sheet(item: $editingStageLog) { log in
            LogStageView(item: item, stage: log.stage, existingLog: log)
        }
        .sheet(isPresented: $showEditItem) {
            EditItemView(item: item)
        }
        .sheet(isPresented: $showPhotoComparison) {
            PhotoComparisonView(item: item)
        }
        .sheet(isPresented: $showShareCard) {
            ShareCardView(item: item)
        }
        .sheet(isPresented: $showDuplicate) {
            NewItemView(
                prefillTitle: "\(item.title) (Copy)",
                prefillType: item.type,
                prefillClay: item.clayType ?? "",
                prefillHeight: item.heightMeasurement.map { "\($0)" } ?? "",
                prefillWidth: item.widthMeasurement.map { "\($0)" } ?? ""
            )
        }
        .alert("Archive this piece?", isPresented: $showDeleteConfirmation) {
            Button("Archive", role: .destructive) {
                item.isArchived = true
                item.updatedAt = Date()
                modelContext.saveQuietly()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("It will be hidden from your library but can be recovered.")
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            if let photo = item.displayPhoto {
                PhotoThumbnail(fileName: photo.fileName)
                    .aspectRatio(4/3, contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.theme.surfaceSecondary)
                    .frame(height: 280)
                    .overlay {
                        VStack(spacing: 8) {
                            Image(systemName: item.type.icon)
                                .font(.system(size: 48))
                            Text("No Photos Yet")
                                .font(.subheadline)
                        }
                        .foregroundStyle(Color.theme.textTertiary)
                    }
            }

            // Gradient overlay
            LinearGradient(
                colors: [.clear, .black.opacity(0.4)],
                startPoint: .center,
                endPoint: .bottom
            )

            // Title + badge overlay
            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)
                StageBadge(stage: item.currentStage)
            }
            .padding(Constants.Layout.horizontalPadding)
        }
    }

    // MARK: - Quick Facts

    private var quickFactsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if let clay = item.clayType, !clay.isEmpty {
                    factChip(icon: "circle.fill", text: clay)
                }
                factChip(icon: "tag", text: item.type.displayName)
                if let h = item.heightMeasurement {
                    factChip(icon: "arrow.up.and.down", text: "\(h) \(unit.abbreviation) H")
                }
                if let w = item.widthMeasurement {
                    factChip(icon: "arrow.left.and.right", text: "\(w) \(unit.abbreviation) W")
                }
                factChip(icon: "calendar", text: item.createdAt.monthDayDisplay)
            }
            .padding(.horizontal, Constants.Layout.horizontalPadding)
            .padding(.vertical, 12)
        }
    }

    private func factChip(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption)
        }
        .foregroundStyle(Color.theme.textSecondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.theme.surfaceSecondary)
        .clipShape(Capsule())
    }

    // MARK: - Actions

    private var actionButtons: some View {
        VStack(spacing: 12) {
            if hasMultipleStagePhotos {
                LargeButton(title: "View Transformation", icon: "photo.stack", style: .secondary) {
                    showPhotoComparison = true
                }
            }

            HStack(spacing: 12) {
                Button {
                    showShareCard = true
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color.theme.surfaceSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                Button {
                    showEditItem = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color.theme.surfaceSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .foregroundStyle(Color.theme.textPrimary)

            Button {
                showDuplicate = true
            } label: {
                Label("Duplicate", systemImage: "doc.on.doc")
                    .font(.subheadline)
                    .foregroundStyle(Color.theme.textSecondary)
            }
            .largeTapTarget()

            Button {
                showDeleteConfirmation = true
            } label: {
                Label("Archive", systemImage: "archivebox")
                    .font(.subheadline)
                    .foregroundStyle(Color.theme.textTertiary)
            }
            .largeTapTarget()
        }
        .padding(.horizontal, Constants.Layout.horizontalPadding)
    }
}
