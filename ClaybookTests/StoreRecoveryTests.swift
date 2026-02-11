import Testing
import Foundation
@testable import Claybook

@Suite("Store Recovery Tests")
struct StoreRecoveryTests {

    @Test("Store URL is in Application Support directory")
    func storeURLIsInAppSupport() {
        let url = StoreRecoveryService.storeURL()
        #expect(url.path.contains("Application Support"), "Store should be in Application Support")
        #expect(url.lastPathComponent == "default.store", "Store file should be named default.store")
    }

    @Test("storeFiles returns 3 paths")
    func storeFilesReturnsThreePaths() {
        let files = StoreRecoveryService.storeFiles()
        #expect(files.count == 3, "Should return main store + WAL + SHM")

        let names = files.map(\.lastPathComponent)
        #expect(names.contains("default.store"))
        #expect(names.contains("default.store-wal"))
        #expect(names.contains("default.store-shm"))
    }

    @Test("openStore returns healthy for fresh store")
    func openStoreReturnsHealthy() {
        let result = StoreRecoveryService.openStore()
        switch result {
        case .healthy:
            // Expected — fresh store opens fine
            break
        case .recoveredFromBackup:
            Issue.record("Fresh store should not need recovery")
        case .failed(let error):
            Issue.record("Fresh store should not fail: \(error)")
        }
    }
}
