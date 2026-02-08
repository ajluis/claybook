import SwiftUI
import SwiftData

@main
struct ClaybookApp: App {
    let modelContainer: ModelContainer

    init() {
        let schema = Schema(versionedSchema: ClaybookSchemaV1.self)
        let config = ModelConfiguration(schema: schema)
        do {
            modelContainer = try ModelContainer(for: schema, migrationPlan: ClaybookMigrationPlan.self, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}

struct ContentView: View {
    var body: some View {
        LibraryView()
    }
}
