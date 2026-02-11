import Testing
import SwiftData
@testable import Claybook

@Suite("Data Persistence Tests")
struct DataPersistenceTests {

    @Test("Explicit save persists data across contexts")
    func explicitSavePersistsAcrossContexts() throws {
        let container = try ModelContainerTestHelper.makeTestContainer()

        // Write in one context
        let writeContext = ModelContext(container)
        let item = Item(title: "Persisted Vase", type: .vase)
        writeContext.insert(item)
        try writeContext.save()

        // Read in a new context
        let readContext = ModelContext(container)
        let descriptor = FetchDescriptor<Item>()
        let fetched = try readContext.fetch(descriptor)
        #expect(fetched.count == 1)
        #expect(fetched.first?.title == "Persisted Vase")
    }

    @Test("Archive flag persists")
    func archiveFlagPersists() throws {
        let container = try ModelContainerTestHelper.makeTestContainer()
        let context = ModelContext(container)

        let item = Item(title: "Archive Me", type: .plate)
        context.insert(item)
        #expect(item.isArchived == false, "New items should not be archived")

        item.isArchived = true
        try context.save()

        let readContext = ModelContext(container)
        let descriptor = FetchDescriptor<Item>()
        let fetched = try readContext.fetch(descriptor).first!
        #expect(fetched.isArchived == true, "Archive flag should persist")
    }

    @Test("fetchOrCreateSettings is idempotent")
    func fetchOrCreateSettingsIdempotent() throws {
        let container = try ModelContainerTestHelper.makeTestContainer()
        let context = ModelContext(container)

        let first = context.fetchOrCreateSettings()
        let second = context.fetchOrCreateSettings()

        #expect(first.id == second.id, "Should return the same settings instance")

        let descriptor = FetchDescriptor<UserSettings>()
        let all = try context.fetch(descriptor)
        #expect(all.count == 1, "Should have exactly one UserSettings row")
    }

    @Test("Cascade delete removes children")
    func cascadeDeleteRemovesChildren() throws {
        let container = try ModelContainerTestHelper.makeTestContainer()
        let context = ModelContext(container)

        let item = Item(title: "Delete Me", type: .sculpture)
        context.insert(item)

        let stageLog = StageLog(stage: .made)
        context.insert(stageLog)
        item.stageLogs.append(stageLog)

        let photo = Photo(fileName: "delete_test.jpg")
        context.insert(photo)
        stageLog.photos.append(photo)

        try context.save()

        // Delete the item — should cascade to stageLog and photo
        context.delete(item)
        try context.save()

        let items = try context.fetch(FetchDescriptor<Item>())
        let logs = try context.fetch(FetchDescriptor<StageLog>())
        let photos = try context.fetch(FetchDescriptor<Photo>())

        #expect(items.isEmpty, "Item should be deleted")
        #expect(logs.isEmpty, "Stage log should be cascade-deleted")
        #expect(photos.isEmpty, "Photo should be cascade-deleted")
    }
}
