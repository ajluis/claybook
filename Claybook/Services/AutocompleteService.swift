import SwiftData
import Foundation

final class AutocompleteService {
    static let shared = AutocompleteService()
    private init() {}

    func suggestions(for field: FieldType, matching query: String, in context: ModelContext) -> [String] {
        let allValues = distinctValues(for: field, in: context)
        guard !query.isEmpty else {
            return Array(allValues.prefix(5))
        }
        return allValues
            .filter { $0.localizedCaseInsensitiveContains(query) }
            .prefix(5)
            .map { $0 }
    }

    func distinctValues(for field: FieldType, in context: ModelContext) -> [String] {
        switch field {
        case .clay:
            let descriptor = FetchDescriptor<Item>()
            let items = (try? context.fetch(descriptor)) ?? []
            return Array(Set(items.compactMap(\.clayType).filter { !$0.isEmpty })).sorted()
        case .glaze:
            let descriptor = FetchDescriptor<GlazeEntry>()
            let entries = (try? context.fetch(descriptor)) ?? []
            return Array(Set(entries.map(\.name))).sorted()
        case .color:
            let descriptor = FetchDescriptor<ColorEntry>()
            let entries = (try? context.fetch(descriptor)) ?? []
            return Array(Set(entries.map(\.name))).sorted()
        case .kilnTag:
            let descriptor = FetchDescriptor<StageLog>()
            let logs = (try? context.fetch(descriptor)) ?? []
            return Array(Set(logs.compactMap(\.kilnLoadTag).filter { !$0.isEmpty })).sorted()
        }
    }

    enum FieldType {
        case clay, glaze, color, kilnTag
    }
}
