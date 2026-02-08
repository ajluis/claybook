import Foundation

enum ItemType: String, Codable, CaseIterable, Identifiable {
    case mug
    case bowl
    case vase
    case plate
    case platter
    case cup
    case sculpture
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .mug: "Mug"
        case .bowl: "Bowl"
        case .vase: "Vase"
        case .plate: "Plate"
        case .platter: "Platter"
        case .cup: "Cup"
        case .sculpture: "Sculpture"
        case .other: "Other"
        }
    }

    var icon: String {
        switch self {
        case .mug: "cup.and.saucer"
        case .bowl: "circle.bottomhalf.filled"
        case .vase: "square.bottomhalf.filled"  // vase-like
        case .plate: "circle"
        case .platter: "oval"
        case .cup: "mug"
        case .sculpture: "cube"
        case .other: "questionmark.circle"
        }
    }
}
