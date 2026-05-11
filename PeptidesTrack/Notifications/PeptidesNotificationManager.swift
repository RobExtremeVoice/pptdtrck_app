import UserNotifications
import Foundation

// MARK: - PeptidesNotificationManager

@MainActor
final class PeptidesNotificationManager {

    static let shared = PeptidesNotificationManager()
    private init() {}

    // MARK: - Permission

    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    // MARK: - Register Categories

    func registerCategories() {
        let logAction = UNNotificationAction(
            identifier: PTNotificationAction.logDose,
            title: NSLocalizedString("notification.action.log", comment: ""),
            options: .foreground
        )
        let skipAction = UNNotificationAction(
            identifier: PTNotificationAction.skip,
            title: NSLocalizedString("notification.action.skip", comment: ""),
            options: []
        )
        let category = UNNotificationCategory(
            identifier: PTNotificationCategory.doseReminder,
            actions: [logAction, skipAction],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    // MARK: - Schedule Dose Reminder

    func scheduleReminder(
        for peptideName: String,
        peptideID: UUID,
        weekday: Int,     // 1=Sun … 7=Sat
        hour: Int,
        minute: Int
    ) async {
        let id = notificationID(for: peptideID)
        await removeReminder(for: peptideID)

        let content = UNMutableNotificationContent()
        content.title = String(
            format: NSLocalizedString("notification.reminder.title", comment: ""),
            peptideName
        )
        content.body = NSLocalizedString("notification.reminder.body", comment: "")
        content.sound = .default
        content.categoryIdentifier = PTNotificationCategory.doseReminder
        content.userInfo = [
            PTNotificationKey.peptideID: peptideID.uuidString,
            PTNotificationKey.peptideName: peptideName
        ]

        var components = DateComponents()
        components.weekday = weekday
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        try? await UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Remove Reminder

    func removeReminder(for peptideID: UUID) async {
        let id = notificationID(for: peptideID)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }

    // MARK: - Remove All

    func removeAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // MARK: - Helpers

    private func notificationID(for peptideID: UUID) -> String {
        "reminder-\(peptideID.uuidString)"
    }
}
