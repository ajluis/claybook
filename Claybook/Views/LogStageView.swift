import SwiftUI
import SwiftData

struct LogStageView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allSettings: [UserSettings]

    let item: Item
    let stage: StageType
    var existingLog: StageLog? = nil

    // Common fields
    @State private var date = Date()
    @State private var notes = ""
    @State private var selectedImages: [UIImage] = []

    // Kiln fields
    @State private var coneNumber = ""
    @State private var kilnLoadTag = ""

    // Glaze fields
    @State private var glazeEntries: [(name: String, order: Int)] = []
    @State private var newGlazeName = ""
    @State private var selectedColors: [(name: String, hex: String)] = []
    @State private var usedUnderglaze = false

    // Made stage fields (for editing)
    @State private var title = ""
    @State private var selectedType: ItemType = .other
    @State private var clayType = ""
    @State private var heightText = ""
    @State private var widthText = ""
    @State private var topDiameterText = ""
    @State private var bottomDiameterText = ""

    // Batch kiln
    @State private var showBatchPrompt = false
    @State private var batchCandidates: [Item] = []
    @State private var selectedBatchItems: Set<UUID> = []

    // Autocomplete data
    @Query private var allStageLogs: [StageLog]
    @Query private var allItems: [Item]
    @Query private var allGlazeEntries: [GlazeEntry]

    private var settings: UserSettings? { allSettings.first }
    private var unit: MeasurementUnit { settings?.measurementUnit ?? .inches }

    private var glazeSuggestions: [String] {
        Array(Set(allGlazeEntries.map(\.name))).sorted()
    }

    private var kilnTagSuggestions: [String] {
        Array(Set(allStageLogs.compactMap(\.kilnLoadTag).filter { !$0.isEmpty })).sorted()
    }

    private var claySuggestions: [String] {
        Array(Set(allItems.compactMap(\.clayType).filter { !$0.isEmpty })).sorted()
    }

    var isEditing: Bool { existingLog != nil }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Constants.Layout.sectionSpacing) {
                    // Stage header
                    Text(stage.displayName)
                        .font(.title.weight(.bold))
                        .foregroundStyle(Color.theme.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Date picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date")
                            .sectionHeader()
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                    }

                    // Stage-specific fields
                    if stage == .made {
                        madeFields
                    }

                    if stage.isKilnStage {
                        kilnFields
                    }

                    if stage.isGlazedStage {
                        glazeFields
                    }

                    if stage == .finished {
                        finishedFields
                    }

                    // Photos
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Photos")
                            .sectionHeader()
                        Text("Add photos to track your progress")
                            .font(.caption)
                            .foregroundStyle(Color.theme.textSecondary)
                        PhotoPicker(selectedImages: $selectedImages)
                    }

                    // Notes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .sectionHeader()
                        TextEditor(text: $notes)
                            .frame(minHeight: 80)
                            .padding(8)
                            .background(Color.theme.surfaceSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    // Save
                    LargeButton(title: isEditing ? "Update" : "Save", icon: "checkmark") {
                        saveStageLog()
                    }
                }
                .padding(.horizontal, Constants.Layout.horizontalPadding)
                .padding(.vertical, Constants.Layout.horizontalPadding)
            }
            .background(Color.theme.background)
            .navigationTitle(isEditing ? "Edit \(stage.shortName)" : "Log \(stage.shortName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showBatchPrompt) {
                batchKilnSheet
            }
            .onAppear { loadExistingData() }
        }
    }

    // MARK: - Made Fields

    private var madeFields: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Type")
                    .sectionHeader()
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(ItemType.allCases) { type in
                            Button {
                                selectedType = type
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: type.icon)
                                        .font(.title3)
                                    Text(type.displayName)
                                        .font(.caption)
                                }
                                .foregroundStyle(selectedType == type ? .white : Color.theme.textPrimary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(selectedType == type ? Color.theme.primary : Color.theme.surfaceSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Clay")
                    .sectionHeader()
                AutocompleteField(
                    title: "Clay type (e.g. Stoneware)",
                    text: $clayType,
                    suggestions: claySuggestions
                )
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Measurements")
                    .sectionHeader()
                MeasurementFields(
                    height: $heightText,
                    width: $widthText,
                    topDiameter: $topDiameterText,
                    bottomDiameter: $bottomDiameterText,
                    unit: unit
                )
            }
        }
    }

    // MARK: - Kiln Fields

    private var kilnFields: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Cone Number")
                    .sectionHeader()
                TextField("e.g. 06, 6, 10", text: $coneNumber)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Kiln Load Tag")
                    .sectionHeader()
                AutocompleteField(
                    title: "e.g. March 15 Bisque",
                    text: $kilnLoadTag,
                    suggestions: kilnTagSuggestions
                )
                Text("Tag helps you group pieces from the same firing")
                    .font(.caption)
                    .foregroundStyle(Color.theme.textTertiary)
            }
        }
    }

    // MARK: - Glaze Fields

    private var glazeFields: some View {
        VStack(spacing: 16) {
            // Glaze layers
            VStack(alignment: .leading, spacing: 8) {
                Text("Glazes")
                    .sectionHeader()
                Text("Order matters — list from bottom layer to top")
                    .font(.caption)
                    .foregroundStyle(Color.theme.textTertiary)

                ForEach(glazeEntries.indices, id: \.self) { index in
                    HStack(spacing: 12) {
                        Image(systemName: "line.3.horizontal")
                            .foregroundStyle(Color.theme.textTertiary)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(glazeEntries[index].name)
                                .font(.body)
                            Text("Layer \(glazeEntries[index].order)")
                                .font(.caption)
                                .foregroundStyle(Color.theme.textSecondary)
                        }

                        Spacer()

                        Button {
                            glazeEntries.remove(at: index)
                            reorderGlazes()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Color.theme.textTertiary)
                        }
                        .largeTapTarget()
                    }
                    .padding(.vertical, 4)
                }

                // Add glaze
                HStack(spacing: 8) {
                    AutocompleteField(
                        title: "Add a glaze",
                        text: $newGlazeName,
                        suggestions: glazeSuggestions
                    )
                    Button {
                        addGlaze()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.theme.primary)
                    }
                    .largeTapTarget()
                    .disabled(newGlazeName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }

            // Underglaze toggle
            Toggle(isOn: $usedUnderglaze) {
                Text("Used underglaze")
                    .font(.body)
            }
            .tint(Color.theme.primary)

            // Color palette
            VStack(alignment: .leading, spacing: 8) {
                Text("Colors")
                    .sectionHeader()
                ColorPalettePicker(selectedColors: $selectedColors)
            }
        }
    }

    // MARK: - Finished Fields

    private var finishedFields: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Outcome")
                .sectionHeader()
            Text("How did it turn out? Any notes for next time?")
                .font(.caption)
                .foregroundStyle(Color.theme.textTertiary)
        }
    }

    // MARK: - Batch Kiln Sheet

    private var batchKilnSheet: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Apply this kiln date to other pieces?")
                    .font(.headline)
                    .padding(.top)

                List(batchCandidates, id: \.id, selection: $selectedBatchItems) { candidate in
                    HStack {
                        Text(candidate.title)
                        Spacer()
                        if selectedBatchItems.contains(candidate.id) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.theme.primary)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if selectedBatchItems.contains(candidate.id) {
                            selectedBatchItems.remove(candidate.id)
                        } else {
                            selectedBatchItems.insert(candidate.id)
                        }
                    }
                }
                .listStyle(.plain)

                HStack(spacing: 12) {
                    LargeButton(title: "Skip", style: .secondary) {
                        showBatchPrompt = false
                        dismiss()
                    }
                    LargeButton(title: "Apply") {
                        applyBatchKiln()
                        showBatchPrompt = false
                        dismiss()
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Batch Kiln")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
    }

    // MARK: - Data Loading

    private func loadExistingData() {
        guard let log = existingLog else {
            title = item.title
            selectedType = item.type
            clayType = item.clayType ?? ""
            if let h = item.heightMeasurement { heightText = "\(h)" }
            if let w = item.widthMeasurement { widthText = "\(w)" }
            if let td = item.topDiameter { topDiameterText = "\(td)" }
            if let bd = item.bottomDiameter { bottomDiameterText = "\(bd)" }
            return
        }
        date = log.date
        notes = log.notes ?? ""
        coneNumber = log.coneNumber ?? ""
        kilnLoadTag = log.kilnLoadTag ?? ""
        usedUnderglaze = log.usedUnderglaze ?? false
        glazeEntries = log.glazesUsed.sorted { $0.order < $1.order }.map { (name: $0.name, order: $0.order) }
        selectedColors = log.colorsUsed.map { (name: $0.name, hex: $0.paletteColor ?? "") }
    }

    // MARK: - Save

    private func saveStageLog() {
        let log: StageLog
        if let existing = existingLog {
            log = existing
        } else {
            log = StageLog(stage: stage, date: date)
            modelContext.insert(log)
            item.stageLogs.append(log)
        }

        log.date = date
        log.notes = notes.isEmpty ? nil : notes

        // Made stage: update item fields
        if stage == .made {
            item.type = selectedType
            item.clayType = clayType.isEmpty ? nil : clayType
            item.heightMeasurement = Decimal(string: heightText)
            item.widthMeasurement = Decimal(string: widthText)
            item.topDiameter = Decimal(string: topDiameterText)
            item.bottomDiameter = Decimal(string: bottomDiameterText)
        }

        // Kiln fields
        if stage.isKilnStage {
            log.coneNumber = coneNumber.isEmpty ? nil : coneNumber
            log.kilnLoadTag = kilnLoadTag.isEmpty ? nil : kilnLoadTag

            // Create/update KilnLoad record
            if !kilnLoadTag.isEmpty {
                let tag = kilnLoadTag
                let descriptor = FetchDescriptor<KilnLoad>(predicate: #Predicate { $0.tag == tag })
                if (try? modelContext.fetch(descriptor))?.first == nil {
                    let kilnLoad = KilnLoad(tag: kilnLoadTag, date: date, stageType: stage)
                    modelContext.insert(kilnLoad)
                }
            }
        }

        // Glaze fields
        if stage.isGlazedStage {
            log.usedUnderglaze = usedUnderglaze

            // Clear and re-add glazes
            for glaze in log.glazesUsed {
                modelContext.delete(glaze)
            }
            for entry in glazeEntries {
                let glaze = GlazeEntry(name: entry.name, order: entry.order)
                modelContext.insert(glaze)
                log.glazesUsed.append(glaze)
            }

            // Clear and re-add colors
            for color in log.colorsUsed {
                modelContext.delete(color)
            }
            for entry in selectedColors {
                let color = ColorEntry(name: entry.name, paletteColor: entry.hex.isEmpty ? nil : entry.hex)
                modelContext.insert(color)
                log.colorsUsed.append(color)
            }
        }

        // Save photos
        for image in selectedImages {
            if let fileName = PhotoStorageService.shared.savePhoto(image) {
                let photo = Photo(fileName: fileName)
                modelContext.insert(photo)
                log.photos.append(photo)

                // Auto-update cover photo to most recent
                item.coverPhotoID = photo.id
            }
        }

        item.updatedAt = Date()

        // Check for batch kiln opportunity
        if stage.isKilnStage && !kilnLoadTag.isEmpty && !isEditing {
            let priorStage: StageType = stage == .bisqueKiln ? .drying : .glazed
            let candidates = allItems.filter { otherItem in
                otherItem.id != item.id
                && !otherItem.isArchived
                && otherItem.currentStage == priorStage
            }
            if !candidates.isEmpty {
                batchCandidates = candidates
                showBatchPrompt = true
                return
            }
        }

        dismiss()
    }

    private func applyBatchKiln() {
        for candidate in batchCandidates where selectedBatchItems.contains(candidate.id) {
            let batchLog = StageLog(stage: stage, date: date)
            batchLog.coneNumber = coneNumber.isEmpty ? nil : coneNumber
            batchLog.kilnLoadTag = kilnLoadTag.isEmpty ? nil : kilnLoadTag
            modelContext.insert(batchLog)
            candidate.stageLogs.append(batchLog)
            candidate.updatedAt = Date()
        }
    }

    // MARK: - Glaze Helpers

    private func addGlaze() {
        let name = newGlazeName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        glazeEntries.append((name: name, order: glazeEntries.count + 1))
        newGlazeName = ""
    }

    private func reorderGlazes() {
        for i in glazeEntries.indices {
            glazeEntries[i].order = i + 1
        }
    }
}
