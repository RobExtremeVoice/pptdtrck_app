import Foundation

extension Notification.Name {
    static let didLogDose          = Notification.Name("com.peptidestrack.didLogDose")
    static let didUpdateSubscription = Notification.Name("com.peptidestrack.didUpdateSubscription")
    static let didActivateReminder = Notification.Name("com.peptidestrack.didActivateReminder")
}

// MARK: - Notification user info keys
enum PTNotificationKey {
    static let peptideID   = "peptideID"
    static let peptideName = "peptideName"
}

// MARK: - UNNotification category/action identifiers
enum PTNotificationCategory {
    static let doseReminder = "DOSE_REMINDER"
}

enum PTNotificationAction {
    static let logDose = "LOG_DOSE"
    static let skip    = "SKIP"
}
