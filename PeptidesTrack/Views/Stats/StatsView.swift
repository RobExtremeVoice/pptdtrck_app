import SwiftUI
import SwiftData

// MARK: - StatsView

struct StatsView: View {

    @EnvironmentObject private var store: StoreManager
    @Query(sort: \PeptideEntry.loggedAt, order: .reverse) private var allEntries: [PeptideEntry]
    @Query(sort: \SideEffectLog.loggedAt, order: .reverse) private var allLogs: [SideEffectLog]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    overviewSection

                    if store.isPro || store.isInTrial {
                        doseChartSection
                        sideEffectsTrendSection
                        adherenceSection
                    } else {
                        proGateCard
                    }
                }
                .padding(16)
                .padding(.bottom, 32)
            }
            .background(Color(hex: "080C18"))
            .navigationTitle(Text(LocalizedStringKey("stats.title")))
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color(hex: "0D1220"), for: .navigationBar)
        }
    }

    // MARK: - Overview

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("stats.section.overview")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                overviewCard(value: "\(allEntries.count)",
                             labelKey: "stats.card.totaldoses",
                             colorHex: "06B6D4",
                             symbol: "syringe.fill")
                overviewCard(value: "\(currentStreak)d",
                             labelKey: "stats.card.streak",
                             colorHex: "F59E0B",
                             symbol: "flame.fill")
                overviewCard(value: "\(bestStreak)d",
                             labelKey: "stats.card.beststreak",
                             colorHex: "34D399",
                             symbol: "crown.fill")
                overviewCard(value: "\(activeProtocols)",
                             labelKey: "stats.card.protocols",
                             colorHex: "8B5CF6",
                             symbol: "cross.vial.fill")
            }
        }
    }

    private func overviewCard(value: String, labelKey: String, colorHex: String, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 18))
                .foregroundStyle(Color(hex: colorHex))
                .accessibilityHidden(true)

            Text(value)
                .font(.system(.title, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(Color(hex: "F1F5F9"))

            Text(LocalizedStringKey(labelKey))
                .font(.caption)
                .foregroundStyle(Color(hex: "64748B"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .darkCard()
    }

    // MARK: - Dose chart

    private var doseChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("stats.section.dosechart")

            let weeks = last8WeeksCounts
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(weeks.indices, id: \.self) { i in
                    let count = weeks[i]
                    let maxVal = weeks.max() ?? 1
                    let ratio = maxVal > 0 ? CGFloat(count) / CGFloat(maxVal) : 0

                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "06B6D4").opacity(0.3 + 0.7 * ratio))
                            .frame(height: max(8, 80 * ratio))

                        Text("\(count)")
                            .font(.caption2)
                            .foregroundStyle(Color(hex: "4A5580"))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 100)
            .padding(16)
            .darkCard()
        }
    }

    // MARK: - Side effects trend

    private var sideEffectsTrendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("stats.section.sideeffects")

            let averages = sideEffectAverages
            if averages.isEmpty {
                Text(LocalizedStringKey("history.empty.title"))
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: "64748B"))
                    .padding(16)
                    .darkCard()
            } else {
                VStack(spacing: 10) {
                    ForEach(averages.prefix(6), id: \.key) { item in
                        HStack(spacing: 12) {
                            Text(LocalizedStringKey("effect.\(item.key)"))
                                .font(.caption)
                                .foregroundStyle(Color(hex: "94A3B8"))
                                .frame(width: 120, alignment: .leading)

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(hex: "1E2640"))
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(hex: "06B6D4"))
                                        .frame(width: geo.size.width * CGFloat(item.avg) / 10)
                                }
                                .frame(height: 6)
                            }
                            .frame(height: 6)

                            Text(String(format: "%.1f", item.avg))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color(hex: "F1F5F9"))
                                .frame(width: 30, alignment: .trailing)
                        }
                    }
                }
                .padding(16)
                .darkCard()
            }
        }
    }

    // MARK: - Adherence

    private var adherenceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("stats.section.adherence")

            let pct = adherencePercent

            HStack {
                ZStack {
                    Circle()
                        .stroke(Color(hex: "1E2640"), lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: CGFloat(pct) / 100)
                        .stroke(Color(hex: "06B6D4"), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.5), value: pct)
                }
                .frame(width: 80, height: 80)

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(pct)%")
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(Color(hex: "F1F5F9"))
                    Text(LocalizedStringKey("stats.section.adherence"))
                        .font(.subheadline)
                        .foregroundStyle(Color(hex: "94A3B8"))
                }
                .padding(.leading, 16)
                Spacer()
            }
            .padding(16)
            .darkCard()
        }
    }

    // MARK: - PRO gate

    private var proGateCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.fill")
                .font(.system(size: 32))
                .foregroundStyle(Color(hex: "4A5580"))
                .accessibilityHidden(true)
            Text(LocalizedStringKey("stats.pro.locked"))
                .font(.subheadline)
                .foregroundStyle(Color(hex: "94A3B8"))
                .multilineTextAlignment(.center)

            Button(action: { }) {
                Text(LocalizedStringKey("button.upgrade"))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(hex: "031820"))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color(hex: "06B6D4"))
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .darkCard(radius: 20)
    }

    // MARK: - Section header

    private func sectionHeader(_ key: String) -> some View {
        Text(LocalizedStringKey(key))
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(Color(hex: "4A5580"))
    }

    // MARK: - Computed

    private var currentStreak: Int {
        var streak = 0
        var date = Calendar.current.startOfDay(for: Date())
        for _ in 0..<365 {
            let hasLog = allEntries.contains {
                Calendar.current.isDate($0.loggedAt, inSameDayAs: date)
            }
            if hasLog { streak += 1 } else { break }
            date = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date
        }
        return streak
    }

    private var bestStreak: Int {
        var best = 0, current = 0
        let sorted = allEntries.sorted { $0.loggedAt < $1.loggedAt }
        var lastDate: Date? = nil
        for entry in sorted {
            let day = Calendar.current.startOfDay(for: entry.loggedAt)
            if let last = lastDate, Calendar.current.dateComponents([.day], from: last, to: day).day == 1 {
                current += 1
            } else if lastDate == nil || day != lastDate {
                current = 1
            }
            best = max(best, current)
            lastDate = day
        }
        return best
    }

    private var activeProtocols: Int {
        Set(allEntries.filter { $0.isActiveProtocol }.map { $0.peptideName }).count
    }

    private var last8WeeksCounts: [Int] {
        (0..<8).reversed().map { weeksAgo in
            let startDate = Calendar.current.date(byAdding: .weekOfYear, value: -weeksAgo, to: Date()) ?? Date()
            let weekStart = Calendar.current.dateInterval(of: .weekOfYear, for: startDate)?.start ?? startDate
            let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: weekStart) ?? weekStart
            return allEntries.filter { $0.loggedAt >= weekStart && $0.loggedAt < weekEnd }.count
        }
    }

    private var adherencePercent: Int {
        guard !allEntries.isEmpty else { return 0 }
        let activePeptides = Set(allEntries.filter { $0.isActiveProtocol }.map { $0.peptideName })
        guard !activePeptides.isEmpty else { return 100 }
        let days30 = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let recent = allEntries.filter { $0.loggedAt >= days30 }
        let expected = activePeptides.count * 4   // rough: weekly = ~4 doses/month
        let actual = min(recent.count, expected)
        return Int((Double(actual) / Double(expected)) * 100)
    }

    private var sideEffectAverages: [(key: String, avg: Double)] {
        let all = allLogs.flatMap { $0.entries }
        let grouped = Dictionary(grouping: all, by: { $0.effectKey })
        return grouped.map { key, entries in
            (key: key, avg: Double(entries.reduce(0) { $0 + $1.intensity }) / Double(entries.count))
        }
        .sorted { $0.avg > $1.avg }
    }
}

#Preview {
    StatsView()
        .environmentObject(StoreManager())
        .modelContainer(for: [PeptideEntry.self, SideEffectLog.self], inMemory: true)
}
