import SwiftData
import Foundation

// MARK: - SideEffectLog

@Model
final class SideEffectLog {
    var id: UUID
    var loggedAt: Date
    // Stored as JSON-encoded [SideEffectEntry] — SwiftData doesn't support Codable arrays directly
    var entriesData: Data

    init(id: UUID = UUID(), loggedAt: Date = Date(), entries: [SideEffectEntry] = []) {
        self.id = id
        self.loggedAt = loggedAt
        self.entriesData = (try? JSONEncoder().encode(entries)) ?? Data()
    }

    var entries: [SideEffectEntry] {
        get { (try? JSONDecoder().decode([SideEffectEntry].self, from: entriesData)) ?? [] }
        set { entriesData = (try? JSONEncoder().encode(newValue)) ?? Data() }
    }
}

// MARK: - SideEffectEntry

struct SideEffectEntry: Codable, Identifiable {
    var id: UUID = UUID()
    var effectKey: String   // matches "effect.<key>" localization suffix
    var intensity: Int      // 0–10
    var isPositive: Bool
}
