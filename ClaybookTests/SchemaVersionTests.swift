import Testing
import SwiftData
@testable import Claybook

@Suite("Schema Version Tests")
struct SchemaVersionTests {

    @Test("V1 models are all frozen types, not live types")
    func v1UsesOnlyFrozenTypes() {
        let models = ClaybookSchemaV1.models
        let typeNames = models.map { String(describing: $0) }

        for name in typeNames {
            #expect(!name.hasPrefix("Item."), "V1 should not reference live Item type")
            #expect(name.contains("V1") || name == "V1Item" || name == "V1StageLog" || name == "V1GlazeEntry" || name == "V1ColorEntry" || name == "V1Photo" || name == "V1KilnLoad" || name == "V1UserSettings",
                    "V1 model '\(name)' should be a frozen V1 type")
        }
        #expect(models.count == 7, "V1 should have 7 model types")
    }

    @Test("V2 models are all frozen types, not live types")
    func v2UsesOnlyFrozenTypes() {
        let models = ClaybookSchemaV2.models
        let typeNames = models.map { String(describing: $0) }

        for name in typeNames {
            // Ensure no live types leak in
            #expect(name.contains("V2"), "V2 model '\(name)' should be a frozen V2 type")
        }
        #expect(models.count == 7, "V2 should have 7 model types")
    }

    @Test("V3 models are all frozen types, not live types")
    func v3UsesOnlyFrozenTypes() {
        let models = ClaybookSchemaV3.models
        let typeNames = models.map { String(describing: $0) }

        for name in typeNames {
            #expect(name.contains("V3"), "V3 model '\(name)' should be a frozen V3 type")
        }
        #expect(models.count == 7, "V3 should have 7 model types")
    }

    @Test("V4 uses live types (current schema)")
    func v4UsesLiveTypes() {
        let models = ClaybookSchemaV4.models
        let typeNames = models.map { String(describing: $0) }

        // V4 is the current version — it should use the live model types
        #expect(typeNames.contains { $0.contains("Item") }, "V4 should include Item")
        #expect(typeNames.contains { $0.contains("UserSettings") }, "V4 should include UserSettings")
        #expect(models.count == 7, "V4 should have 7 model types")
    }

    @Test("Migration plan includes all versions and stages")
    func migrationPlanIsComplete() {
        let schemas = ClaybookMigrationPlan.schemas
        #expect(schemas.count == 4, "Should have 4 schema versions")

        let stages = ClaybookMigrationPlan.stages
        #expect(stages.count == 3, "Should have 3 migration stages (V1→V2, V2→V3, V3→V4)")
    }
}
