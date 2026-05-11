import SwiftUI
import SwiftData

// MARK: - PeptideCardRow

struct PeptideCardRow: View {

    let entry: PeptideEntry
    var onLog: (() -> Void)? = nil

    private var category: PeptideCategory? {
        PeptideCategory(rawValue: entry.peptideCategory)
    }

    var body: some View {
        HStack(spacing: 16) {
            // Category icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: category?.glowHex ?? "1E2640"))
                    .frame(width: 48, height: 48)

                Image(systemName: category?.sfSymbol ?? "pills.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color(hex: category?.colorHex ?? "94A3B8"))
                    .accessibilityHidden(true)
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.peptideName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(hex: "F1F5F9"))

                Text(lastDoseText)
                    .font(.caption)
                    .foregroundStyle(Color(hex: "94A3B8"))
            }

            Spacer()

            // Log button
            Button(action: { onLog?() }) {
                Text(LocalizedStringKey("card.button.log"))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(hex: "031820"))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Color(hex: "06B6D4"))
                    .clipShape(Capsule())
            }
            .accessibilityLabel(Text(LocalizedStringKey("card.button.log")))
        }
        .padding(16)
        .darkCard()
    }

    // MARK: - Last dose text

    private var lastDoseText: String {
        let cal = Calendar.current
        if cal.isDateInToday(entry.loggedAt) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return String(format: NSLocalizedString("card.lastdose.today", comment: ""),
                          formatter.string(from: entry.loggedAt))
        } else if cal.isDateInYesterday(entry.loggedAt) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return String(format: NSLocalizedString("card.lastdose.yesterday", comment: ""),
                          formatter.string(from: entry.loggedAt))
        } else {
            let days = cal.dateComponents([.day], from: entry.loggedAt, to: Date()).day ?? 0
            let doseStr = "\(String(format: "%g", entry.doseAmount)) \(entry.doseUnit)"
            return String(format: NSLocalizedString("card.lastdose.daysago", comment: ""),
                          days, doseStr)
        }
    }
}
