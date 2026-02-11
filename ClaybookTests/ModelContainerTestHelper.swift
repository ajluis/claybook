import SwiftData
@testable import Claybook

enum ModelContainerTestHelper {
    /// Creates an in-memory ModelContainer with the current schema for testing.
    static func makeTestContainer() throws -> ModelContainer {
        let schema = Schema(versionedSchema: ClaybookSchemaV4.self)
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: schema,
            migrationPlan: ClaybookMigrationPlan.self,
            configurations: [config]
        )
    }
}
