import SwiftUI
import SwiftData

// MARK: - RemindersView

struct RemindersView: View {

    @Query(filter: #Predicate<PeptideEntry> { $0.reminderEnabled == true })
    private var remindersEnabled: [PeptideEntry]

    @Query(filter: #Predicate<PeptideEntry> { $0.isActiveProtocol == true })
    private var activeEntries: [PeptideEntry]

    @Environment(\.modelContext) private var context
    @State private var showPrompt: PeptideEntry? = nil

    var body: some View {
        NavigationStack {
            Group {
                if activeEntries.isEmpty {
                    emptyState
                } else {
                    reminderList
                }
            }
            .background(Color(hex: "080C18"))
            .navigationTitle(Text(LocalizedStringKey("reminders.title")))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(hex: "0D1220"), for: .navigationBar)
        }
        .sheet(item: $showPrompt) { entry in
            WeeklyReminderPrompt(
                peptideName: entry.peptideName,
                peptideID: entry.id,
                onActivate: { showPrompt = nil },
                onSkip: { showPrompt = nil }
            )
        }
    }

    // MARK: - Reminder list

    private var reminderList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(activeEntries) { entry in
                    reminderRow(entry)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
    }

    private func reminderRow(_ entry: PeptideEntry) -> some View {
        HStack(spacing: 14) {
            // Category icon
            let category = PeptideCategory(rawValue: entry.peptideCategory)
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: category?.glowHex ?? "1E2640"))
                    .frame(width: 40, height: 40)
                Image(systemName: category?.sfSymbol ?? "pills.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color(hex: category?.colorHex ?? "94A3B8"))
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.peptideName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(hex: "F1F5F9"))

                if entry.reminderEnabled,
                   let hour = entry.reminderHour,
                   let minute = entry.reminderMinute {
                    let timeStr = String(format: "%02d:%02d", hour, minute)
                    let dayStr = entry.reminderWeekday.map { weekdayName($0) } ?? ""
                    Text("\(dayStr) · \(timeStr)")
                        .font(.caption)
                        .foregroundStyle(Color(hex: "94A3B8"))
                } else {
                    Text(LocalizedStringKey("reminders.empty"))
                        .font(.caption)
                        .foregroundStyle(Color(hex: "64748B"))
                }
            }

            Spacer()

            Toggle(isOn: Binding(
                get: { entry.reminderEnabled },
                set: { on in
                    if on { showPrompt = entry }
                    else {
                        entry.reminderEnabled = false
                        Task {
                            await PeptidesNotificationManager.shared.removeReminder(for: entry.id)
                        }
                        try? context.save()
                    }
                }
            )) { EmptyView() }
            .tint(Color(hex: "06B6D4"))
            .labelsHidden()
            .accessibilityLabel(Text(entry.peptideName))
        }
        .padding(14)
        .darkCard(radius: 12)
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "bell.slash.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color(hex: "1E2640"))
                .accessibilityHidden(true)
            Text(LocalizedStringKey("reminders.empty"))
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color(hex: "64748B"))
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helper

    private func weekdayName(_ day: Int) -> String {
        guard day >= 1, day <= 7 else { return "" }
        return Calendar.current.weekdaySymbols[day - 1]
    }
}

#Preview {
    RemindersView()
        .modelContainer(for: PeptideEntry.self, inMemory: true)
}
