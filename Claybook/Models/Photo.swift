import Foundation
import SwiftData

@Model
final class Photo {
    var id: UUID
    var fileName: String  // file path ref, not image data
    var capturedAt: Date

    var stageLog: StageLog?

    init(fileName: String, capturedAt: Date = Date()) {
        self.id = UUID()
        self.fileName = fileName
        self.capturedAt = capturedAt
    }
}
