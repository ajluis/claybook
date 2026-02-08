import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allSettings: [UserSettings]

    @State private var measurementUnit: MeasurementUnit = .inches
    @State private var defaultViewMode: ViewMode = .grid
    @State private var didLoad = false

    private var settings: UserSettings {
        allSettings.first ?? modelContext.fetchOrCreateSettings()
    }

    var body: some View {
        List {
            Section("Display") {
                Picker("Measurement Units", selection: $measurementUnit) {
                    ForEach(MeasurementUnit.allCases, id: \.self) { unit in
                        Text(unit.displayName).tag(unit)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: measurementUnit) { _, newValue in
                    settings.measurementUnit = newValue
                }

                Picker("Default View", selection: $defaultViewMode) {
                    Text("Grid").tag(ViewMode.grid)
                    Text("List").tag(ViewMode.list)
                }
                .pickerStyle(.segmented)
                .onChange(of: defaultViewMode) { _, newValue in
                    settings.defaultViewMode = newValue
                }
            }

            Section("Library") {
                NavigationLink("Kiln Loads") {
                    KilnLoadListView()
                }
                NavigationLink("History") {
                    HistoryView()
                }
            }

            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(Color.theme.textSecondary)
                }
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            guard !didLoad else { return }
            measurementUnit = settings.measurementUnit
            defaultViewMode = settings.defaultViewMode
            didLoad = true
        }
    }
}
