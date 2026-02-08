import Foundation
import SwiftData

@Model
final class GlazeEntry {
    var id: UUID
    var name: String
    var order: Int  // 1 = bottom layer

    var stageLog: StageLog?

    init(name: String, order: Int) {
        self.id = UUID()
        self.name = name
        self.order = order
    }
}
