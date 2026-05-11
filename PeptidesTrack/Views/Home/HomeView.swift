import SwiftUI
import SwiftData

// MARK: - HomeView

struct HomeView: View {

    @EnvironmentObject private var store: StoreManager
    @Environment(\.modelContext) private var context
    @Query(filter: #Predicate<PeptideEntry> { $0.isActiveProtocol == true },
           sort: \PeptideEntry.loggedAt, order: .reverse)
    private var activeEntries: [PeptideEntry]

    @State private var showWizard = false
    @State private var logTarget: PeptideEntry? = nil

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    streakSection
                    protocolsSection
                    sideEffectsCard
                    missedDoseBanner
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .background(Color(hex: "080C18"))
            .navigationBarHidden(true)
            .overlay(alignment: .bottomTrailing) { fab }
        }
        .sheet(isPresented: $showWizard) {
            AddPeptideWizardView()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedStringKey(greetingKey))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(hex: "F1F5F9"))

                if let firstEntry = activeEntries.first {
                    let days = daysSinceFirstLog(firstEntry)
                    Text(String(format: NSLocalizedString("home.day.protocol", comment: ""), days))
                        .font(.subheadline)
                        .foregroundStyle(Color(hex: "94A3B8"))
                }
            }

            Spacer()

            HStack(spacing: 12) {
                if store.isPro { ProBadgeView() }
                else if store.isInTrial { TrialBadgeView() }

                NavigationLink(destination: RemindersView()) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color(hex: "94A3B8"))
                        .accessibilityLabel(Text(LocalizedStringKey("reminders.title")))
                }
            }
        }
    }

    // MARK: - Streak strip

    private var streakSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                streakPill
                loggedTodayPill
            }
        }
    }

    private var streakPill: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .foregroundStyle(Color(hex: "F59E0B"))
                .accessibilityHidden(true)
            Text(String(format: NSLocalizedString("home.pill.streak", comment: ""), currentStreak))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color(hex: "F59E0B"))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color(hex: "1C1500"))
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(Color(hex: "F59E0B").opacity(0.3), lineWidth: 0.5))
    }

    private var loggedTodayPill: some View {
        let loggedToday = activeEntries.contains { Calendar.current.isDateInToday($0.loggedAt) }
        return HStack(spacing: 6) {
            Image(systemName: loggedToday ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .foregroundStyle(loggedToday ? Color(hex: "34D399") : Color(hex: "FB923C"))
                .accessibilityHidden(true)
            Text(LocalizedStringKey(loggedToday ? "home.pill.logged" : "home.pill.logtoday"))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(loggedToday ? Color(hex: "34D399") : Color(hex: "FB923C"))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(loggedToday ? Color(hex: "052016") : Color(hex: "1E1205"))
        .clipShape(Capsule())
    }

    // MARK: - Protocols section

    private var protocolsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizedStringKey("home.section.protocols"))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color(hex: "4A5580"))

            if activeEntries.isEmpty {
                emptyProtocolsCard
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(activeEntries) { entry in
                        PeptideCardRow(entry: entry, onLog: { logTarget = entry })
                    }
                }
            }

            // Add button or upgrade prompt
            if !store.isPro && !store.isInTrial && activeEntries.count >= StoreManager.freePeptideLimit {
                upgradePromptButton
            } else {
                addPeptideButton
            }
        }
    }

    private var emptyProtocolsCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "cross.vial.fill")
                .font(.system(size: 32))
                .foregroundStyle(Color(hex: "06B6D4"))
                .accessibilityHidden(true)
            Text(LocalizedStringKey("card.lastdose.never"))
                .font(.subheadline)
                .foregroundStyle(Color(hex: "64748B"))
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .surfaceCard()
    }

    private var addPeptideButton: some View {
        Button(action: { showWizard = true }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(Color(hex: "06B6D4"))
                    .accessibilityHidden(true)
                Text(LocalizedStringKey("home.button.addpeptide"))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color(hex: "06B6D4"))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .overlay(RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color(hex: "06B6D4").opacity(0.4), lineWidth: 1, antialiased: true))
        }
    }

    private var upgradePromptButton: some View {
        Button(action: { }) {
            Text(LocalizedStringKey("home.upgrade.prompt"))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(Color(hex: "F59E0B"))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .overlay(RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color(hex: "F59E0B").opacity(0.4), lineWidth: 1))
        }
    }

    // MARK: - Side effects card

    private var sideEffectsCard: some View {
        NavigationLink(destination: LogSideEffectsView()) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "061E2A"))
                        .frame(width: 44, height: 44)
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 18))
                        .foregroundStyle(Color(hex: "06B6D4"))
                        .accessibilityHidden(true)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizedStringKey("card.sideeffects.title"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(hex: "F1F5F9"))
                    Text(LocalizedStringKey("card.sideeffects.subtitle"))
                        .font(.caption)
                        .foregroundStyle(Color(hex: "94A3B8"))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color(hex: "64748B"))
                    .accessibilityHidden(true)
            }
            .padding(16)
            .darkCard()
        }
    }

    // MARK: - Missed dose banner

    @ViewBuilder
    private var missedDoseBanner: some View {
        if let missed = missedEntry {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(Color(hex: "FB923C"))
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(LocalizedStringKey("misseddose.title"))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(hex: "FB923C"))
                    Text(String(format: NSLocalizedString("misseddose.body", comment: ""),
                                missed.peptideName,
                                daysMissed(missed)))
                        .font(.caption)
                        .foregroundStyle(Color(hex: "94A3B8"))
                }
                Spacer()
                Button(action: { logTarget = missed }) {
                    Text(LocalizedStringKey("misseddose.cta.log"))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(hex: "031820"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(hex: "FB923C"))
                        .clipShape(Capsule())
                }
            }
            .padding(14)
            .background(Color(hex: "1E1205"))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color(hex: "FB923C").opacity(0.4), lineWidth: 0.5))
        }
    }

    // MARK: - FAB

    private var fab: some View {
        Button(action: { showWizard = true }) {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color(hex: "031820"))
                .frame(width: 56, height: 56)
                .background(Color(hex: "06B6D4"))
                .clipShape(Circle())
                .shadow(color: Color(hex: "06B6D4").opacity(0.4), radius: 12, y: 4)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 20)
        .accessibilityLabel(Text(LocalizedStringKey("home.button.addpeptide")))
    }

    // MARK: - Computed helpers

    private var greetingKey: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "home.greeting.morning"
        case 12..<17: return "home.greeting.afternoon"
        default:      return "home.greeting.evening"
        }
    }

    private var currentStreak: Int {
        var streak = 0
        var date = Calendar.current.startOfDay(for: Date())
        for _ in 0..<365 {
            let hasLog = activeEntries.contains {
                Calendar.current.isDate($0.loggedAt, inSameDayAs: date)
            }
            if hasLog { streak += 1 } else { break }
            date = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date
        }
        return streak
    }

    private func daysSinceFirstLog(_ entry: PeptideEntry) -> Int {
        Calendar.current.dateComponents([.day], from: entry.loggedAt, to: Date()).day ?? 0
    }

    private var missedEntry: PeptideEntry? {
        activeEntries.first { entry in
            guard let freq = FrequencyType(rawValue: entry.frequencyType) else { return false }
            let intervalDays = entry.customFrequencyDays ?? freq.defaultIntervalDays
            let daysSinceLast = Calendar.current.dateComponents(
                [.day], from: entry.loggedAt, to: Date()
            ).day ?? 0
            return daysSinceLast > intervalDays + 1
        }
    }

    private func daysMissed(_ entry: PeptideEntry) -> Int {
        Calendar.current.dateComponents([.day], from: entry.loggedAt, to: Date()).day ?? 0
    }
}

// MARK: - Preview

#Preview {
    HomeView()
        .environmentObject(StoreManager())
        .modelContainer(for: [PeptideEntry.self, SideEffectLog.self], inMemory: true)
}
