import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allSettings: [UserSettings]

    @State private var measurementUnit: MeasurementUnit = .inches
    @State private var defaultViewMode: ViewMode = .grid
    @State private var appearanceMode: AppearanceMode = .system
    @State private var weekendReminderEnabled = true
    @State private var didLoad = false

    private var settings: UserSettings {
        allSettings.first ?? modelContext.fetchOrCreateSettings()
    }

    var body: some View {
        List {
            Section("Appearance") {
                Picker("Theme", selection: $appearanceMode) {
                    ForEach(AppearanceMode.allCases, id: \.self) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: appearanceMode) { _, newValue in
                    settings.appearanceMode = newValue
                }
            }

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

            Section("Notifications") {
                Toggle("Pottery reminder", isOn: $weekendReminderEnabled)
                    .onChange(of: weekendReminderEnabled) { _, newValue in
                        settings.weekendReminderEnabled = newValue
                        PotteryReminderService.syncWeekendReminder(enabled: newValue)
                    }

                Text("Sends a reminder on Saturday at 6:00 PM: \"Excited for pottery tomorrow?\"")
                    .font(.caption)
                    .foregroundStyle(Color.theme.textSecondary)
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
            appearanceMode = settings.appearanceMode
            weekendReminderEnabled = settings.weekendReminderEnabled
            PotteryReminderService.syncWeekendReminder(enabled: weekendReminderEnabled)
            didLoad = true
        }
    }
}
