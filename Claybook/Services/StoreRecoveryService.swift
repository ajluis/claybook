import Foundation
import SwiftData

enum StoreRecoveryService {
    enum StoreState {
        case healthy(ModelContainer)
        case recoveredFromBackup(ModelContainer)
        case failed(Error)
    }

    static func storeURL() -> URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return appSupport.appendingPathComponent("default.store", isDirectory: false)
    }

    /// Returns the store file plus its WAL and SHM companions.
    /// SQLite companion files use a hyphen suffix (default.store-wal), not a dot extension.
    static func storeFiles() -> [URL] {
        let base = storeURL()
        let dir = base.deletingLastPathComponent()
        let baseName = base.lastPathComponent
        return [
            base,
            dir.appendingPathComponent("\(baseName)-wal"),
            dir.appendingPathComponent("\(baseName)-shm")
        ]
    }

    static func openStore() -> StoreState {
        let schema = Schema(versionedSchema: ClaybookSchemaV4.self)
        let url = storeURL()
        let configuration = ModelConfiguration(schema: schema, url: url)

        // Tier 1: Try normal open
        do {
            let container = try ModelContainer(
                for: schema,
                migrationPlan: ClaybookMigrationPlan.self,
                configurations: [configuration]
            )
            return .healthy(container)
        } catch {
            NSLog("Claybook: store open failed — \(error). Attempting backup & recovery.")
        }

        // Tier 2: Back up corrupt files, delete, create fresh
        do {
            try backupStoreFiles()
            try deleteStoreFiles()

            let freshConfiguration = ModelConfiguration(schema: schema, url: url)
            let container = try ModelContainer(
                for: schema,
                migrationPlan: ClaybookMigrationPlan.self,
                configurations: [freshConfiguration]
            )
            return .recoveredFromBackup(container)
        } catch {
            NSLog("Claybook: recovery failed — \(error)")
            return .failed(error)
        }
    }

    // MARK: - Private Helpers

    private static func backupStoreFiles() throws {
        let fm = FileManager.default
        let appSupport = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let backupDir = appSupport.appendingPathComponent("Backups", isDirectory: true)
        try fm.createDirectory(at: backupDir, withIntermediateDirectories: true)

        let timestamp = ISO8601DateFormatter().string(from: Date())
            .replacingOccurrences(of: ":", with: "-")

        for file in storeFiles() where fm.fileExists(atPath: file.path) {
            let backupName = "\(timestamp)_\(file.lastPathComponent)"
            let dest = backupDir.appendingPathComponent(backupName)
            try fm.copyItem(at: file, to: dest)
            NSLog("Claybook: backed up \(file.lastPathComponent) → Backups/\(backupName)")
        }
    }

    private static func deleteStoreFiles() throws {
        let fm = FileManager.default
        for file in storeFiles() where fm.fileExists(atPath: file.path) {
            try fm.removeItem(at: file)
        }
    }
}
