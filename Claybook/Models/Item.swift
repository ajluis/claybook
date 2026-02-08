import Foundation
import SwiftData

@Model
final class Item {
    var id: UUID
    var title: String
    var type: ItemType
    var otherTypeName: String?
    var clayType: String?

    // Measurements (all optional)
    var heightMeasurement: Decimal?
    var widthMeasurement: Decimal?
    var topDiameter: Decimal?
    var bottomDiameter: Decimal?

    var coverPhotoID: UUID?
    var isFavorite: Bool
    var isArchived: Bool
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \StageLog.item)
    var stageLogs: [StageLog] = []

    var currentStage: StageType {
        stageLogs
            .sorted { $0.stage.rawValue > $1.stage.rawValue }
            .first?.stage ?? .made
    }

    var latestStageLog: StageLog? {
        stageLogs.sorted { $0.stage.rawValue > $1.stage.rawValue }.first
    }

    var coverPhoto: Photo? {
        guard let coverPhotoID else { return nil }
        return stageLogs
            .flatMap { $0.photos }
            .first { $0.id == coverPhotoID }
    }

    var mostRecentPhoto: Photo? {
        stageLogs
            .sorted { $0.stage.rawValue > $1.stage.rawValue }
            .flatMap { $0.photos }
            .first
    }

    var displayPhoto: Photo? {
        coverPhoto ?? mostRecentPhoto
    }

    init(
        title: String,
        type: ItemType = .other,
        otherTypeName: String? = nil,
        clayType: String? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.type = type
        self.otherTypeName = otherTypeName
        self.clayType = clayType
        self.isFavorite = false
        self.isArchived = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
