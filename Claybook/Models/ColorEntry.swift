import Foundation
import SwiftData

@Model
final class ColorEntry {
    var id: UUID
    var name: String
    var paletteColor: String?  // hex from preset palette

    var stageLog: StageLog?

    init(name: String, paletteColor: String? = nil) {
        self.id = UUID()
        self.name = name
        self.paletteColor = paletteColor
    }
}
