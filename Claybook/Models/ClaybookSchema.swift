import Foundation
import SwiftData

// MARK: - V1 (frozen — matches on-disk schema before appearanceMode was added)
enum ClaybookSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            V1Item.self,
            V1StageLog.self,
            V1GlazeEntry.self,
            V1ColorEntry.self,
            V1Photo.self,
            V1KilnLoad.self,
            V1UserSettings.self
        ]
    }

    @Model final class V1Item {
        var id: UUID
        var title: String
        var type: ItemType
        var otherTypeName: String?
        var clayType: String?
        var heightMeasurement: Decimal?
        var widthMeasurement: Decimal?
        var topDiameter: Decimal?
        var bottomDiameter: Decimal?
        var coverPhotoID: UUID?
        var isFavorite: Bool
        var isArchived: Bool
        var createdAt: Date
        var updatedAt: Date
        @Relationship(deleteRule: .cascade, inverse: \V1StageLog.item)
        var stageLogs: [V1StageLog] = []
        init() {
            self.id = UUID()
            self.title = ""
            self.type = .other
            self.isFavorite = false
            self.isArchived = false
            self.createdAt = Date()
            self.updatedAt = Date()
        }
    }

    @Model final class V1StageLog {
        var id: UUID
        var stage: StageType
        var date: Date
        var notes: String?
        var coneNumber: String?
        var kilnLoadTag: String?
        var usedUnderglaze: Bool?
        var item: V1Item?
        @Relationship(deleteRule: .cascade, inverse: \V1Photo.stageLog)
        var photos: [V1Photo] = []
        @Relationship(deleteRule: .cascade, inverse: \V1GlazeEntry.stageLog)
        var glazesUsed: [V1GlazeEntry] = []
        @Relationship(deleteRule: .cascade, inverse: \V1ColorEntry.stageLog)
        var colorsUsed: [V1ColorEntry] = []
        init() {
            self.id = UUID()
            self.stage = .made
            self.date = Date()
        }
    }

    @Model final class V1GlazeEntry {
        var id: UUID
        var name: String
        var order: Int
        var stageLog: V1StageLog?
        init() {
            self.id = UUID()
            self.name = ""
            self.order = 0
        }
    }

    @Model final class V1ColorEntry {
        var id: UUID
        var name: String
        var paletteColor: String?
        var stageLog: V1StageLog?
        init() {
            self.id = UUID()
            self.name = ""
        }
    }

    @Model final class V1Photo {
        var id: UUID
        var fileName: String
        var capturedAt: Date
        var stageLog: V1StageLog?
        init() {
            self.id = UUID()
            self.fileName = ""
            self.capturedAt = Date()
        }
    }

    @Model final class V1KilnLoad {
        var id: UUID
        var tag: String
        var date: Date
        var stageType: StageType
        var notes: String?
        init() {
            self.id = UUID()
            self.tag = ""
            self.date = Date()
            self.stageType = .bisqueKiln
        }
    }

    // V1 UserSettings — no appearanceMode property
    @Model final class V1UserSettings {
        var id: UUID
        var measurementUnit: MeasurementUnit
        var defaultViewMode: ViewMode
        init() {
            self.id = UUID()
            self.measurementUnit = .inches
            self.defaultViewMode = .grid
        }
    }
}

// MARK: - V2 (frozen — adds appearanceMode to UserSettings)
enum ClaybookSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            V2Item.self,
            V2StageLog.self,
            V2GlazeEntry.self,
            V2ColorEntry.self,
            V2Photo.self,
            V2KilnLoad.self,
            V2UserSettings.self
        ]
    }

    @Model final class V2Item {
        var id: UUID
        var title: String
        var type: ItemType
        var otherTypeName: String?
        var clayType: String?
        var heightMeasurement: Decimal?
        var widthMeasurement: Decimal?
        var topDiameter: Decimal?
        var bottomDiameter: Decimal?
        var coverPhotoID: UUID?
        var isFavorite: Bool
        var isArchived: Bool
        var createdAt: Date
        var updatedAt: Date
        @Relationship(deleteRule: .cascade, inverse: \V2StageLog.item)
        var stageLogs: [V2StageLog] = []
        init() {
            self.id = UUID()
            self.title = ""
            self.type = .other
            self.isFavorite = false
            self.isArchived = false
            self.createdAt = Date()
            self.updatedAt = Date()
        }
    }

    @Model final class V2StageLog {
        var id: UUID
        var stage: StageType
        var date: Date
        var notes: String?
        var coneNumber: String?
        var kilnLoadTag: String?
        var usedUnderglaze: Bool?
        var item: V2Item?
        @Relationship(deleteRule: .cascade, inverse: \V2Photo.stageLog)
        var photos: [V2Photo] = []
        @Relationship(deleteRule: .cascade, inverse: \V2GlazeEntry.stageLog)
        var glazesUsed: [V2GlazeEntry] = []
        @Relationship(deleteRule: .cascade, inverse: \V2ColorEntry.stageLog)
        var colorsUsed: [V2ColorEntry] = []
        init() {
            self.id = UUID()
            self.stage = .made
            self.date = Date()
        }
    }

    @Model final class V2GlazeEntry {
        var id: UUID
        var name: String
        var order: Int
        var stageLog: V2StageLog?
        init() {
            self.id = UUID()
            self.name = ""
            self.order = 0
        }
    }

    @Model final class V2ColorEntry {
        var id: UUID
        var name: String
        var paletteColor: String?
        var stageLog: V2StageLog?
        init() {
            self.id = UUID()
            self.name = ""
        }
    }

    @Model final class V2Photo {
        var id: UUID
        var fileName: String
        var capturedAt: Date
        var stageLog: V2StageLog?
        init() {
            self.id = UUID()
            self.fileName = ""
            self.capturedAt = Date()
        }
    }

    @Model final class V2KilnLoad {
        var id: UUID
        var tag: String
        var date: Date
        var stageType: StageType
        var notes: String?
        init() {
            self.id = UUID()
            self.tag = ""
            self.date = Date()
            self.stageType = .bisqueKiln
        }
    }

    @Model final class V2UserSettings {
        var id: UUID
        var measurementUnit: MeasurementUnit
        var defaultViewMode: ViewMode
        var appearanceMode: AppearanceMode?

        init() {
            self.id = UUID()
            self.measurementUnit = .inches
            self.defaultViewMode = .grid
            self.appearanceMode = .system
        }
    }
}

// MARK: - V3 (frozen — stores appearance as raw string)
enum ClaybookSchemaV3: VersionedSchema {
    static var versionIdentifier = Schema.Version(3, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            V3Item.self,
            V3StageLog.self,
            V3GlazeEntry.self,
            V3ColorEntry.self,
            V3Photo.self,
            V3KilnLoad.self,
            V3UserSettings.self
        ]
    }

    @Model final class V3Item {
        var id: UUID
        var title: String
        var type: ItemType
        var otherTypeName: String?
        var clayType: String?
        var heightMeasurement: Decimal?
        var widthMeasurement: Decimal?
        var topDiameter: Decimal?
        var bottomDiameter: Decimal?
        var coverPhotoID: UUID?
        var isFavorite: Bool
        var isArchived: Bool
        var createdAt: Date
        var updatedAt: Date
        @Relationship(deleteRule: .cascade, inverse: \V3StageLog.item)
        var stageLogs: [V3StageLog] = []
        init() {
            self.id = UUID()
            self.title = ""
            self.type = .other
            self.isFavorite = false
            self.isArchived = false
            self.createdAt = Date()
            self.updatedAt = Date()
        }
    }

    @Model final class V3StageLog {
        var id: UUID
        var stage: StageType
        var date: Date
        var notes: String?
        var coneNumber: String?
        var kilnLoadTag: String?
        var usedUnderglaze: Bool?
        var item: V3Item?
        @Relationship(deleteRule: .cascade, inverse: \V3Photo.stageLog)
        var photos: [V3Photo] = []
        @Relationship(deleteRule: .cascade, inverse: \V3GlazeEntry.stageLog)
        var glazesUsed: [V3GlazeEntry] = []
        @Relationship(deleteRule: .cascade, inverse: \V3ColorEntry.stageLog)
        var colorsUsed: [V3ColorEntry] = []
        init() {
            self.id = UUID()
            self.stage = .made
            self.date = Date()
        }
    }

    @Model final class V3GlazeEntry {
        var id: UUID
        var name: String
        var order: Int
        var stageLog: V3StageLog?
        init() {
            self.id = UUID()
            self.name = ""
            self.order = 0
        }
    }

    @Model final class V3ColorEntry {
        var id: UUID
        var name: String
        var paletteColor: String?
        var stageLog: V3StageLog?
        init() {
            self.id = UUID()
            self.name = ""
        }
    }

    @Model final class V3Photo {
        var id: UUID
        var fileName: String
        var capturedAt: Date
        var stageLog: V3StageLog?
        init() {
            self.id = UUID()
            self.fileName = ""
            self.capturedAt = Date()
        }
    }

    @Model final class V3KilnLoad {
        var id: UUID
        var tag: String
        var date: Date
        var stageType: StageType
        var notes: String?
        init() {
            self.id = UUID()
            self.tag = ""
            self.date = Date()
            self.stageType = .bisqueKiln
        }
    }

    @Model final class V3UserSettings {
        var id: UUID
        var measurementUnit: MeasurementUnit
        var defaultViewMode: ViewMode
        var appearanceMode: String?

        init() {
            self.id = UUID()
            self.measurementUnit = .inches
            self.defaultViewMode = .grid
            self.appearanceMode = AppearanceMode.system.rawValue
        }
    }
}

// MARK: - V4 (current — adds weekend reminder setting)
enum ClaybookSchemaV4: VersionedSchema {
    static var versionIdentifier = Schema.Version(4, 0, 0)

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

// MARK: - Migration Plan
enum ClaybookMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [ClaybookSchemaV1.self, ClaybookSchemaV2.self, ClaybookSchemaV3.self, ClaybookSchemaV4.self]
    }

    static var stages: [MigrationStage] {
        [migrateV1toV2, migrateV2toV3, migrateV3toV4]
    }

    static let migrateV1toV2 = MigrationStage.lightweight(
        fromVersion: ClaybookSchemaV1.self,
        toVersion: ClaybookSchemaV2.self
    )

    static let migrateV2toV3 = MigrationStage.lightweight(
        fromVersion: ClaybookSchemaV2.self,
        toVersion: ClaybookSchemaV3.self
    )

    static let migrateV3toV4 = MigrationStage.lightweight(
        fromVersion: ClaybookSchemaV3.self,
        toVersion: ClaybookSchemaV4.self
    )
}
