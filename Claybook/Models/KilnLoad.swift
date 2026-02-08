import Foundation
import SwiftData

@Model
final class KilnLoad {
    var id: UUID
    var tag: String
    var date: Date
    var stageType: StageType  // bisqueKiln or glazeKiln
    var notes: String?

    init(tag: String, date: Date = Date(), stageType: StageType) {
        self.id = UUID()
        self.tag = tag
        self.date = date
        self.stageType = stageType
    }
}
