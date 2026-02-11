import SwiftUI
import SwiftData

struct EditItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var item: Item
    @Query private var allSettings: [UserSettings]
    @Query private var allItems: [Item]

    @State private var title = ""
    @State private var selectedType: ItemType = .other
    @State private var clayType = ""
    @State private var heightText = ""
    @State private var widthText = ""
    @State private var topDiameterText = ""
    @State private var bottomDiameterText = ""

    private var settings: UserSettings? { allSettings.first }
    private var unit: MeasurementUnit { settings?.measurementUnit ?? .inches }

    private var claySuggestions: [String] {
        Array(Set(allItems.compactMap(\.clayType).filter { !$0.isEmpty })).sorted()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Constants.Layout.sectionSpacing) {
                    // Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .sectionHeader()
                        TextField("Piece name", text: $title)
                            .font(.title3)
                            .textFieldStyle(.roundedBorder)
                    }

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

                    // Cover photo selection
                    if !item.stageLogs.flatMap(\.photos).isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Cover Photo")
                                .sectionHeader()
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(item.stageLogs.flatMap(\.photos), id: \.id) { photo in
                                        let isSelected = item.coverPhotoID == photo.id
                                        PhotoThumbnail(fileName: photo.fileName)
                                            .frame(width: 80, height: 80)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(isSelected ? Color.theme.primary : .clear, lineWidth: 3)
                                            )
                                            .onTapGesture {
                                                item.coverPhotoID = photo.id
                                            }
                                    }
                                }
                            }
                        }
                    }

                    LargeButton(title: "Save Changes", icon: "checkmark") {
                        saveChanges()
                    }
                }
                .padding(.horizontal, Constants.Layout.horizontalPadding)
                .padding(.vertical, Constants.Layout.horizontalPadding)
            }
            .background(Color.theme.background)
            .navigationTitle("Edit Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                title = item.title
                selectedType = item.type
                clayType = item.clayType ?? ""
                if let h = item.heightMeasurement { heightText = "\(h)" }
                if let w = item.widthMeasurement { widthText = "\(w)" }
                if let td = item.topDiameter { topDiameterText = "\(td)" }
                if let bd = item.bottomDiameter { bottomDiameterText = "\(bd)" }
            }
        }
    }

    private func saveChanges() {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        item.title = trimmed
        item.type = selectedType
        item.clayType = clayType.isEmpty ? nil : clayType
        item.heightMeasurement = Decimal(string: heightText)
        item.widthMeasurement = Decimal(string: widthText)
        item.topDiameter = Decimal(string: topDiameterText)
        item.bottomDiameter = Decimal(string: bottomDiameterText)
        item.updatedAt = Date()
        modelContext.saveQuietly()
        dismiss()
    }
}
