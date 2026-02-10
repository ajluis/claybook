import SwiftData
import UserNotifications

extension ModelContext {
    @discardableResult
    func fetchOrCreateSettings() -> UserSettings {
        let descriptor = FetchDescriptor<UserSettings>()
        if let existing = try? fetch(descriptor).first {
            return existing
        }
        let settings = UserSettings()
        insert(settings)
        return settings
    }
}

enum PotteryReminderService {
    private static let weekendReminderIdentifier = "com.claybook.weekendPotteryReminder"

    static func syncWeekendReminder(enabled: Bool) {
        let center = UNUserNotificationCenter.current()

        guard enabled else {
            center.removePendingNotificationRequests(withIdentifiers: [weekendReminderIdentifier])
            return
        }

        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                scheduleWeekendReminder(in: center)
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    guard granted else { return }
                    scheduleWeekendReminder(in: center)
                }
            case .denied:
                center.removePendingNotificationRequests(withIdentifiers: [weekendReminderIdentifier])
            @unknown default:
                break
            }
        }
    }

    private static func scheduleWeekendReminder(in center: UNUserNotificationCenter) {
        let content = UNMutableNotificationContent()
        content.title = "Pottery tomorrow"
        content.body = "Excited for pottery tomorrow?"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.weekday = 7 // Saturday
        dateComponents.hour = 18   // 6:00 PM
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: weekendReminderIdentifier,
            content: content,
            trigger: trigger
        )

        center.removePendingNotificationRequests(withIdentifiers: [weekendReminderIdentifier])
        center.add(request)
    }
}
