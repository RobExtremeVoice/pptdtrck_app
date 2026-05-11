import SwiftUI
import SwiftData

// MARK: - PeptideHistoryView

struct PeptideHistoryView: View {

    @Query(sort: \PeptideEntry.loggedAt, order: .reverse) private var allEntries: [PeptideEntry]
    @Environment(\.modelContext) private var context
    @State private var selectedPeptide: String? = nil
    @State private var editTarget: PeptideEntry? = nil

    private var uniquePeptideNames: [String] {
        Array(Set(allEntries.map { $0.peptideName })).sorted()
    }

    private var filteredEntries: [PeptideEntry] {
        guard let name = selectedPeptide else { return allEntries }
        return allEntries.filter { $0.peptideName == name }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter pills
                if !uniquePeptideNames.isEmpty {
                    filterStrip
                }

                if filteredEntries.isEmpty {
                    emptyState
                } else {
                    // Stats row
                    statsRow.padding(.horizontal, 16).padding(.vertical, 12)

                    // List
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(filteredEntries) { entry in
                                PeptideDoseHistoryRow(entry: entry, onEdit: { editTarget = entry })
                                    .padding(.horizontal, 16)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive, action: { delete(entry) }) {
                                            Label(LocalizedStringKey("button.delete"),
                                                  systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding(.bottom, 32)
                    }
                    .background(Color(hex: "080C18"))
                }
            }
            .background(Color(hex: "080C18"))
            .navigationTitle(Text(LocalizedStringKey("history.title")))
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color(hex: "0D1220"), for: .navigationBar)
        }
        .sheet(item: $editTarget) { entry in
            LogDoseView(entry: entry)
        }
    }

    // MARK: - Filter strip

    private var filterStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(name: nil, label: NSLocalizedString("history.title", comment: ""))
                ForEach(uniquePeptideNames, id: \.self) { name in
                    filterChip(name: name, label: name)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color(hex: "0D1220"))
    }

    private func filterChip(name: String?, label: String) -> some View {
        let isSelected = selectedPeptide == name
        return Button(action: { selectedPeptide = name }) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(isSelected ? Color(hex: "031820") : Color(hex: "94A3B8"))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color(hex: "06B6D4") : Color(hex: "131929"))
                .clipShape(Capsule())
        }
    }

    // MARK: - Stats row

    private var statsRow: some View {
        HStack(spacing: 10) {
            StatPill(
                value: "\(filteredEntries.count)",
                label: NSLocalizedString("history.stat.doses", comment: ""),
                colorHex: "06B6D4"
            )
            StatPill(
                value: "\(weekStreak)",
                label: NSLocalizedString("history.stat.streak", comment: ""),
                colorHex: "F59E0B"
            )
            if let avg = averageDose {
                StatPill(
                    value: String(format: "%g", avg),
                    label: NSLocalizedString("history.stat.avg", comment: ""),
                    colorHex: "34D399"
                )
            }
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "calendar")
                .font(.system(size: 48))
                .foregroundStyle(Color(hex: "1E2640"))
                .accessibilityHidden(true)
            Text(LocalizedStringKey("history.empty.title"))
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color(hex: "64748B"))
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Computed

    private var weekStreak: Int {
        var streak = 0
        var week = Calendar.current.component(.weekOfYear, from: Date())
        var year = Calendar.current.component(.year, from: Date())
        while true {
            let hasLog = filteredEntries.contains {
                let eWeek = Calendar.current.component(.weekOfYear, from: $0.loggedAt)
                let eYear = Calendar.current.component(.year, from: $0.loggedAt)
                return eWeek == week && eYear == year
            }
            if hasLog {
                streak += 1
                if week == 1 { week = 52; year -= 1 } else { week -= 1 }
            } else { break }
        }
        return streak
    }

    private var averageDose: Double? {
        guard !filteredEntries.isEmpty else { return nil }
        let total = filteredEntries.reduce(0) { $0 + $1.doseAmount }
        return total / Double(filteredEntries.count)
    }

    private func delete(_ entry: PeptideEntry) {
        context.delete(entry)
        try? context.save()
    }
}

#Preview {
    PeptideHistoryView()
        .modelContainer(for: PeptideEntry.self, inMemory: true)
}
