import SwiftUI
import SwiftData

struct NewItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allSettings: [UserSettings]

    // Pre-fill support for duplicate
    var prefillTitle: String = ""
    var prefillType: ItemType = .other
    var prefillClay: String = ""
    var prefillHeight: String = ""
    var prefillWidth: String = ""

    @State private var title = ""
    @State private var selectedType: ItemType = .other
    @State private var clayType = ""
    @State private var heightText = ""
    @State private var widthText = ""
    @State private var topDiameterText = ""
    @State private var bottomDiameterText = ""
    @State private var selectedImages: [UIImage] = []

    // Autocomplete
    @Query private var allItems: [Item]
    private var claySuggestions: [String] {
        Array(Set(allItems.compactMap(\.clayType).filter { !$0.isEmpty })).sorted()
    }

    private var settings: UserSettings? { allSettings.first }
    private var unit: MeasurementUnit { settings?.measurementUnit ?? .inches }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Title
                    TextField("What are you making?", text: $title)
                        .font(.title3)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 14)
                        .background(Color.theme.surfaceSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    // Photo section — compact buttons + thumbnails
                    PhotoPicker(selectedImages: $selectedImages)

                    // Type picker
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

                    // Clay type
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Clay")
                            .sectionHeader()
                        AutocompleteField(
                            title: "Clay type (e.g. Stoneware)",
                            text: $clayType,
                            suggestions: claySuggestions
                        )
                    }

                    // Measurements
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

                    // Save button
                    LargeButton(title: "Save", icon: "checkmark") {
                        saveItem()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(title.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
                }
                .padding(.horizontal, Constants.Layout.horizontalPadding)
                .padding(.vertical, Constants.Layout.horizontalPadding)
            }
            .background(Color.theme.background)
            .navigationTitle("New Piece")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .onAppear {
            if !prefillTitle.isEmpty {
                title = prefillTitle
                selectedType = prefillType
                clayType = prefillClay
                heightText = prefillHeight
                widthText = prefillWidth
            }
        }
    }

    private func saveItem() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else { return }

        let item = Item(
            title: trimmedTitle,
            type: selectedType,
            clayType: clayType.isEmpty ? nil : clayType
        )
        item.heightMeasurement = Decimal(string: heightText)
        item.widthMeasurement = Decimal(string: widthText)
        item.topDiameter = Decimal(string: topDiameterText)
        item.bottomDiameter = Decimal(string: bottomDiameterText)

        modelContext.insert(item)

        // Create initial "Made" stage log
        let stageLog = StageLog(stage: .made)
        modelContext.insert(stageLog)
        item.stageLogs.append(stageLog)

        // Save photos
        for image in selectedImages {
            if let fileName = PhotoStorageService.shared.savePhoto(image) {
                let photo = Photo(fileName: fileName)
                modelContext.insert(photo)
                stageLog.photos.append(photo)

                // Set first photo as cover
                if item.coverPhotoID == nil {
                    item.coverPhotoID = photo.id
                }
            }
        }

        item.updatedAt = Date()
        dismiss()
    }
}
