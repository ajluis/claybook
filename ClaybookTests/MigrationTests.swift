import Testing
import SwiftData
@testable import Claybook

@Suite("Migration Tests")
struct MigrationTests {

    @Test("Container creation succeeds with current schema")
    func containerCreationSucceeds() throws {
        let container = try ModelContainerTestHelper.makeTestContainer()
        #expect(container.schema.entities.count > 0, "Schema should have entities")
    }

    @Test("Insert and fetch round-trip for Item")
    func insertAndFetchItem() throws {
        let container = try ModelContainerTestHelper.makeTestContainer()
        let context = ModelContext(container)

        let item = Item(title: "Test Mug", type: .mug)
        context.insert(item)
        try context.save()

        let descriptor = FetchDescriptor<Item>()
        let fetched = try context.fetch(descriptor)
        #expect(fetched.count == 1, "Should fetch exactly one item")
        #expect(fetched.first?.title == "Test Mug")
        #expect(fetched.first?.type == .mug)
    }

    @Test("Relationships work correctly")
    func relationshipsWork() throws {
        let container = try ModelContainerTestHelper.makeTestContainer()
        let context = ModelContext(container)

        let item = Item(title: "Test Bowl", type: .bowl)
        context.insert(item)

        let stageLog = StageLog(stage: .made)
        context.insert(stageLog)
        item.stageLogs.append(stageLog)

        let photo = Photo(fileName: "test.jpg")
        context.insert(photo)
        stageLog.photos.append(photo)

        let glaze = GlazeEntry(name: "Clear Glaze", order: 1)
        context.insert(glaze)
        stageLog.glazesUsed.append(glaze)

        try context.save()

        let descriptor = FetchDescriptor<Item>()
        let fetched = try context.fetch(descriptor).first!
        #expect(fetched.stageLogs.count == 1, "Item should have 1 stage log")
        #expect(fetched.stageLogs.first?.photos.count == 1, "Stage log should have 1 photo")
        #expect(fetched.stageLogs.first?.glazesUsed.count == 1, "Stage log should have 1 glaze")
    }
}
