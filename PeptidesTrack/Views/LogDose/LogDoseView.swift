import SwiftUI
import SwiftData

// MARK: - LogDoseView

struct LogDoseView: View {

    let entry: PeptideEntry
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \PeptideEntry.loggedAt, order: .reverse) private var allEntries: [PeptideEntry]

    @State private var doseAmount: Double
    @State private var selectedUnit: DoseUnit
    @State private var selectedSite: InjectionSite?
    @State private var logDate = Date()
    @State private var notes = ""
    @State private var showSiteMap = false
    @State private var showReminderPrompt = false

    private var recentSites: [InjectionSite] {
        allEntries
            .compactMap { $0.injectionSite.flatMap { InjectionSite(rawValue: $0) } }
            .prefix(2)
            .map { $0 }
    }

    init(entry: PeptideEntry) {
        self.entry = entry
        _doseAmount = State(initialValue: entry.doseAmount)
        _selectedUnit = State(initialValue: DoseUnit(rawValue: entry.doseUnit) ?? .mg)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Dose row
                    rowCard(labelKey: "confirm.field.dose") {
                        HStack {
                            TextField("0", value: $doseAmount, format: .number)
                                .keyboardType(.decimalPad)
                                .font(.body)
                                .foregroundStyle(Color(hex: "F1F5F9"))
                            Spacer()
                            Picker(selection: $selectedUnit, label: EmptyView()) {
                                ForEach(DoseUnit.allCases, id: \.self) { unit in
                                    Text(LocalizedStringKey(unit.localizationKey)).tag(unit)
                                }
                            }
                            .tint(Color(hex: "06B6D4"))
                        }
                    }

                    // Injection site
                    rowCard(labelKey: "confirm.field.site") {
                        Button(action: { showSiteMap = true }) {
                            HStack {
                                Text(selectedSite.map { LocalizedStringKey($0.localizationKey) }
                                     ?? LocalizedStringKey("site.map.title"))
                                    .font(.body)
                                    .foregroundStyle(selectedSite != nil
                                                     ? Color(hex: "F1F5F9")
                                                     : Color(hex: "64748B"))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(Color(hex: "4A5580"))
                            }
                        }
                    }

                    // Date & time
                    rowCard(labelKey: "confirm.field.date") {
                        DatePicker(selection: $logDate, displayedComponents: [.date, .hourAndMinute]) {
                            EmptyView()
                        }
                        .labelsHidden()
                        .tint(Color(hex: "06B6D4"))
                    }

                    // Notes
                    rowCard(labelKey: "confirm.field.notes") {
                        TextField(
                            NSLocalizedString("wizard.notes.placeholder", comment: ""),
                            text: $notes,
                            axis: .vertical
                        )
                        .font(.body)
                        .foregroundStyle(Color(hex: "F1F5F9"))
                        .lineLimit(3)
                    }

                    // Disclaimer footnote
                    Text(LocalizedStringKey("confirm.footnote"))
                        .font(.caption2)
                        .foregroundStyle(Color(hex: "334155"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
                .padding(16)
            }
            .background(Color(hex: "080C18"))
            .navigationTitle(entry.peptideName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(hex: "0D1220"), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Text(LocalizedStringKey("button.cancel"))
                            .foregroundStyle(Color(hex: "64748B"))
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: saveLog) {
                        Text(LocalizedStringKey("button.save"))
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(hex: "06B6D4"))
                    }
                }
            }
        }
        .sheet(isPresented: $showSiteMap) {
            InjectionSiteMapView(
                selectedSite: $selectedSite,
                recentSites: recentSites,
                onConfirm: { showSiteMap = false }
            )
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showReminderPrompt) {
            WeeklyReminderPrompt(
                peptideName: entry.peptideName,
                peptideID: entry.id,
                onActivate: { showReminderPrompt = false; dismiss() },
                onSkip: { showReminderPrompt = false; dismiss() }
            )
        }
    }

    // MARK: - Row card helper

    private func rowCard<Content: View>(labelKey: String, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Text(LocalizedStringKey(labelKey))
                .font(.subheadline)
                .foregroundStyle(Color(hex: "94A3B8"))
                .frame(width: 100, alignment: .leading)
            content()
        }
        .padding(14)
        .darkCard(radius: 12)
    }

    // MARK: - Save

    private func saveLog() {
        entry.doseAmount = doseAmount
        entry.doseUnit = selectedUnit.rawValue
        entry.injectionSite = selectedSite?.rawValue
        entry.loggedAt = logDate
        entry.notes = notes.isEmpty ? nil : notes
        try? context.save()

        if !entry.reminderEnabled {
            showReminderPrompt = true
        } else {
            dismiss()
        }
    }
}
