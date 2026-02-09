import SwiftUI
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

enum AppearanceMode: String, Codable, CaseIterable {
    case system
    case light
    case dark

    var displayName: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

@Model
final class UserSettings {
    var id: UUID
    var measurementUnit: MeasurementUnit
    var defaultViewMode: ViewMode
    @Attribute(originalName: "appearanceMode")
    private var appearanceModeRaw: String?

    var appearanceMode: AppearanceMode {
        get {
            guard let appearanceModeRaw else { return .system }
            return AppearanceMode(rawValue: appearanceModeRaw) ?? .system
        }
        set {
            appearanceModeRaw = newValue.rawValue
        }
    }

    init(measurementUnit: MeasurementUnit = .inches, defaultViewMode: ViewMode = .grid, appearanceMode: AppearanceMode = .system) {
        self.id = UUID()
        self.measurementUnit = measurementUnit
        self.defaultViewMode = defaultViewMode
        self.appearanceModeRaw = appearanceMode.rawValue
    }
}
