import SwiftData

extension ModelContext {
    @discardableResult
    func fetchOrCreateSettings() -> UserSettings {
        let descriptor = FetchDescriptor<UserSettings>()
        if let existing = try? fetch(descriptor).first {
            return existing
        }
        let settings = UserSettings()
        insert(settings)
        return settings
    }
}
