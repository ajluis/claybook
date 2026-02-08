import Foundation

extension Date {
    var shortDisplay: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: self)
    }

    var mediumDisplay: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }

    var relativeDisplay: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    var monthDayDisplay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: self)
    }

    var fullDisplay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: self)
    }
}
