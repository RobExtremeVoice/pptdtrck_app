import SwiftData
import Foundation

// MARK: - PeptideEntry

@Model
final class PeptideEntry {

    // MARK: - Properties

    var id: UUID
    var peptideName: String
    var peptideCategory: String       // PeptideCategory.rawValue
    var brandName: String?
    var doseAmount: Double
    var doseUnit: String              // DoseUnit.rawValue
    var injectionSite: String?        // InjectionSite.rawValue
    var loggedAt: Date
    var notes: String?
    var isActiveProtocol: Bool

    // MARK: - Protocol config
    var frequencyType: String         // FrequencyType.rawValue
    var customFrequencyDays: Int?

    // MARK: - Reminder
    var reminderEnabled: Bool
    var reminderWeekday: Int?         // 1=Sun … 7=Sat
    var reminderHour: Int?
    var reminderMinute: Int?

    // MARK: - Init

    init(
        id: UUID = UUID(),
        peptideName: String,
        peptideCategory: String,
        brandName: String? = nil,
        doseAmount: Double,
        doseUnit: String = DoseUnit.mg.rawValue,
        injectionSite: String? = nil,
        loggedAt: Date = Date(),
        notes: String? = nil,
        isActiveProtocol: Bool = true,
        frequencyType: String = FrequencyType.weekly.rawValue,
        customFrequencyDays: Int? = nil,
        reminderEnabled: Bool = false,
        reminderWeekday: Int? = nil,
        reminderHour: Int? = nil,
        reminderMinute: Int? = nil
    ) {
        self.id = id
        self.peptideName = peptideName
        self.peptideCategory = peptideCategory
        self.brandName = brandName
        self.doseAmount = doseAmount
        self.doseUnit = doseUnit
        self.injectionSite = injectionSite
        self.loggedAt = loggedAt
        self.notes = notes
        self.isActiveProtocol = isActiveProtocol
        self.frequencyType = frequencyType
        self.customFrequencyDays = customFrequencyDays
        self.reminderEnabled = reminderEnabled
        self.reminderWeekday = reminderWeekday
        self.reminderHour = reminderHour
        self.reminderMinute = reminderMinute
    }
}

// MARK: - DoseUnit

enum DoseUnit: String, CaseIterable, Codable {
    case mg, mcg, IU, ml

    var localizationKey: String { "unit.\(rawValue)" }
}

// MARK: - FrequencyType

enum FrequencyType: String, CaseIterable, Codable {
    case weekly       = "weekly"
    case twiceWeekly  = "twice_weekly"
    case daily        = "daily"
    case twiceDaily   = "twice_daily"
    case custom       = "custom"

    var localizationKey: String { "frequency.\(rawValue)" }

    var defaultIntervalDays: Int {
        switch self {
        case .weekly:      return 7
        case .twiceWeekly: return 4
        case .daily:       return 1
        case .twiceDaily:  return 1
        case .custom:      return 3
        }
    }
}
