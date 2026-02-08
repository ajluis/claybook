import Foundation

enum StageType: Int, Codable, CaseIterable, Identifiable {
    case made = 0
    case drying = 1
    case bisqueKiln = 2
    case glazed = 3
    case glazeKiln = 4
    case finished = 5

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .made: "Made"
        case .drying: "Drying"
        case .bisqueKiln: "Bisque Kiln (1st Firing)"
        case .glazed: "Glazed"
        case .glazeKiln: "Glaze Kiln (2nd Firing)"
        case .finished: "Finished"
        }
    }

    var shortName: String {
        switch self {
        case .made: "Made"
        case .drying: "Drying"
        case .bisqueKiln: "Bisque"
        case .glazed: "Glazed"
        case .glazeKiln: "Glaze Kiln"
        case .finished: "Finished"
        }
    }

    var next: StageType? {
        StageType(rawValue: rawValue + 1)
    }

    var isKilnStage: Bool {
        self == .bisqueKiln || self == .glazeKiln
    }

    var isGlazedStage: Bool {
        self == .glazed
    }
}
