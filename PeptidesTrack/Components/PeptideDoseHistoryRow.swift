import SwiftUI

// MARK: - PeptideDoseHistoryRow

struct PeptideDoseHistoryRow: View {

    let entry: PeptideEntry
    var onEdit: (() -> Void)? = nil

    private var category: PeptideCategory? {
        PeptideCategory(rawValue: entry.peptideCategory)
    }

    var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: category?.glowHex ?? "1E2640"))
                    .frame(width: 40, height: 40)
                Image(systemName: category?.sfSymbol ?? "pills.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color(hex: category?.colorHex ?? "94A3B8"))
                    .accessibilityHidden(true)
            }

            // Details
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(entry.peptideName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(hex: "F1F5F9"))

                    Text(String(format: "%g %@", entry.doseAmount,
                                NSLocalizedString(DoseUnit(rawValue: entry.doseUnit)?.localizationKey ?? "unit.mg", comment: "")))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(hex: category?.colorHex ?? "94A3B8"))
                        .fontDesign(.rounded)
                }

                HStack(spacing: 8) {
                    Text(entry.loggedAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(Color(hex: "64748B"))

                    if let site = entry.injectionSite.flatMap({ InjectionSite(rawValue: $0) }) {
                        Text("·")
                            .foregroundStyle(Color(hex: "334155"))
                        Text(LocalizedStringKey(site.localizationKey))
                            .font(.caption)
                            .foregroundStyle(Color(hex: "64748B"))
                    }
                }
            }

            Spacer()

            // Edit
            Button(action: { onEdit?() }) {
                Image(systemName: "pencil")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: "4A5580"))
            }
            .accessibilityLabel(Text(LocalizedStringKey("button.edit")))
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .surfaceCard(radius: 12)
    }
}
