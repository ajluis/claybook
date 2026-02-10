import Foundation
import SwiftData
import SwiftUI

@main
struct ClaybookApp: App {
    let modelContainer: ModelContainer

    init() {
        let schema = Schema(versionedSchema: ClaybookSchemaV4.self)
        modelContainer = Self.makeResilientModelContainer(schema: schema)
    }

    private static func makeResilientModelContainer(schema: Schema) -> ModelContainer {
        let storeURL = defaultStoreURL()
        let diskConfiguration = ModelConfiguration(schema: schema, url: storeURL)

        do {
            return try makeModelContainer(schema: schema, configuration: diskConfiguration)
        } catch {
            NSLog("Claybook: failed to open persistent store, falling back to in-memory store. Error: \(String(describing: error))")
        }

        do {
            let inMemoryConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try makeModelContainer(schema: schema, configuration: inMemoryConfiguration)
        } catch {
            fatalError("Failed to create ModelContainer after all recovery attempts: \(error)")
        }
    }

    private static func makeModelContainer(schema: Schema, configuration: ModelConfiguration) throws -> ModelContainer {
        try ModelContainer(
            for: schema,
            migrationPlan: ClaybookMigrationPlan.self,
            configurations: [configuration]
        )
    }

    private static func defaultStoreURL() -> URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return appSupport.appendingPathComponent("default.store", isDirectory: false)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allSettings: [UserSettings]

    private var colorScheme: ColorScheme? {
        allSettings.first?.appearanceMode.colorScheme
    }

    var body: some View {
        LibraryView()
            .preferredColorScheme(colorScheme)
            .onAppear {
                let settings = modelContext.fetchOrCreateSettings()
                PotteryReminderService.syncWeekendReminder(enabled: settings.weekendReminderEnabled)
            }
    }
}
