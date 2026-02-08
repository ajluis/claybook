import Foundation
import SwiftData

@Model
final class StageLog {
    var id: UUID
    var stage: StageType
    var date: Date
    var notes: String?

    // Kiln stages only
    var coneNumber: String?
    var kilnLoadTag: String?

    // Glazed stage only
    var usedUnderglaze: Bool?

    var item: Item?

    @Relationship(deleteRule: .cascade, inverse: \Photo.stageLog)
    var photos: [Photo] = []

    @Relationship(deleteRule: .cascade, inverse: \GlazeEntry.stageLog)
    var glazesUsed: [GlazeEntry] = []

    @Relationship(deleteRule: .cascade, inverse: \ColorEntry.stageLog)
    var colorsUsed: [ColorEntry] = []

    init(stage: StageType, date: Date = Date()) {
        self.id = UUID()
        self.stage = stage
        self.date = date
    }
}
