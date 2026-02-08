import SwiftData

enum ClaybookSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            Item.self,
            StageLog.self,
            GlazeEntry.self,
            ColorEntry.self,
            Photo.self,
            KilnLoad.self,
            UserSettings.self
        ]
    }
}

enum ClaybookMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [ClaybookSchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}
