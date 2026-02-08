import Foundation
import SwiftData

enum MeasurementUnit: String, Codable, CaseIterable {
    case inches
    case centimeters

    var abbreviation: String {
        switch self {
        case .inches: "in"
        case .centimeters: "cm"
        }
    }

    var displayName: String {
        switch self {
        case .inches: "Inches"
        case .centimeters: "Centimeters"
        }
    }
}

enum ViewMode: String, Codable, CaseIterable {
    case grid
    case list
}

@Model
final class UserSettings {
    var id: UUID
    var measurementUnit: MeasurementUnit
    var defaultViewMode: ViewMode

    init(measurementUnit: MeasurementUnit = .inches, defaultViewMode: ViewMode = .grid) {
        self.id = UUID()
        self.measurementUnit = measurementUnit
        self.defaultViewMode = defaultViewMode
    }
}
