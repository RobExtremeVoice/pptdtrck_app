import SwiftUI
import SwiftData

// MARK: - AddPeptideWizardView

struct AddPeptideWizardView: View {

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: StoreManager

    // MARK: Wizard state
    @State private var step = 0
    @State private var selectedCategory: PeptideCategory?
    @State private var selectedPeptide: PeptideInfo?
    @State private var customPeptideName = ""
    @State private var doseAmount = ""
    @State private var selectedUnit: DoseUnit = .mg
    @State private var selectedFrequency: FrequencyType = .weekly
    @State private var customDays = 7
    @State private var selectedSite: InjectionSite?
    @State private var logDate = Date()
    @State private var notes = ""
    @State private var showReminderPrompt = false
    @State private var savedEntry: PeptideEntry?

    private let totalSteps = 5

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                progressBar
                stepContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                navigationButtons
            }
            .background(Color(hex: "080C18"))
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showReminderPrompt) {
            if let entry = savedEntry {
                WeeklyReminderPrompt(
                    peptideName: entry.peptideName,
                    peptideID: entry.id,
                    onActivate: { showReminderPrompt = false; dismiss() },
                    onSkip: { showReminderPrompt = false; dismiss() }
                )
            }
        }
    }

    // MARK: - Progress bar

    private var progressBar: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(hex: "64748B"))
                }
                .accessibilityLabel(Text(LocalizedStringKey("button.cancel")))
                Spacer()
                Text("\(step + 1)/\(totalSteps)")
                    .font(.caption)
                    .foregroundStyle(Color(hex: "64748B"))
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: "1E2640"))
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: "06B6D4"))
                        .frame(width: geo.size.width * CGFloat(step + 1) / CGFloat(totalSteps))
                        .animation(.spring(response: 0.3), value: step)
                }
                .frame(height: 3)
            }
            .frame(height: 3)
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
    }

    // MARK: - Step content

    @ViewBuilder
    private var stepContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                switch step {
                case 0: step1Category
                case 1: step2Peptide
                case 2: step3Dose
                case 3: step4Frequency
                case 4: step5Confirm
                default: EmptyView()
                }
            }
            .padding(20)
        }
    }

    // MARK: - Step 1: Category

    private var step1Category: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepTitle("wizard.step1.title")

            LazyVStack(spacing: 10) {
                ForEach(PeptideCategory.allCases, id: \.self) { category in
                    categoryRow(category)
                }
            }
        }
    }

    private func categoryRow(_ category: PeptideCategory) -> some View {
        Button(action: { selectedCategory = category }) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: selectedCategory == category ? category.colorHex : "0A0E1A"))
                        .frame(width: 40, height: 40)
                    Image(systemName: category.sfSymbol)
                        .font(.system(size: 18))
                        .foregroundStyle(Color(hex: category.colorHex))
                        .accessibilityHidden(true)
                }

                Text(LocalizedStringKey(category.localizationKey))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color(hex: "F1F5F9"))

                Spacer()

                if selectedCategory == category {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color(hex: "06B6D4"))
                        .accessibilityHidden(true)
                }
            }
            .padding(14)
            .background(selectedCategory == category ? Color(hex: "061E2A") : Color(hex: "131929"))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(selectedCategory == category
                                  ? Color(hex: "06B6D4")
                                  : Color(hex: "1E2640"), lineWidth: 1)
            )
        }
    }

    // MARK: - Step 2: Peptide

    private var step2Peptide: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let cat = selectedCategory {
                stepTitle(String(format: NSLocalizedString("wizard.step2.title", comment: ""),
                                 NSLocalizedString(cat.localizationKey, comment: "")))
            }

            let peptides = selectedCategory.map { PeptideCatalog.peptides(for: $0) } ?? []

            LazyVStack(spacing: 10) {
                ForEach(peptides) { peptide in
                    peptideRow(peptide)
                }

                // Custom / Other
                customPeptideRow
            }
        }
    }

    private func peptideRow(_ peptide: PeptideInfo) -> some View {
        Button(action: { selectedPeptide = peptide; customPeptideName = "" }) {
            HStack {
                Text(peptide.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color(hex: "F1F5F9"))

                if !peptide.brandNames.isEmpty {
                    Text(peptide.brandNames.joined(separator: "/"))
                        .font(.caption)
                        .foregroundStyle(Color(hex: "64748B"))
                }

                Spacer()

                if selectedPeptide?.name == peptide.name {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color(hex: "06B6D4"))
                        .accessibilityHidden(true)
                }
            }
            .padding(14)
            .background(selectedPeptide?.name == peptide.name ? Color(hex: "061E2A") : Color(hex: "131929"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(selectedPeptide?.name == peptide.name
                                  ? Color(hex: "06B6D4")
                                  : Color(hex: "1E2640"), lineWidth: 0.5)
            )
        }
    }

    private var customPeptideRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: { selectedPeptide = nil }) {
                HStack {
                    Text(LocalizedStringKey("peptide.category.other"))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color(hex: "F1F5F9"))
                    Spacer()
                    if selectedPeptide == nil {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color(hex: "06B6D4"))
                            .accessibilityHidden(true)
                    }
                }
                .padding(14)
                .background(selectedPeptide == nil ? Color(hex: "061E2A") : Color(hex: "131929"))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(selectedPeptide == nil
                                      ? Color(hex: "06B6D4")
                                      : Color(hex: "1E2640"), lineWidth: 0.5)
                )
            }

            if selectedPeptide == nil {
                TextField(
                    NSLocalizedString("wizard.custom.placeholder", comment: ""),
                    text: $customPeptideName
                )
                .font(.body)
                .foregroundStyle(Color(hex: "F1F5F9"))
                .padding(14)
                .background(Color(hex: "131929"))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color(hex: "06B6D4"), lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Step 3: Dose

    private var step3Dose: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepTitle("wizard.step3.title")
            Text(LocalizedStringKey("wizard.step3.subtitle"))
                .font(.subheadline)
                .foregroundStyle(Color(hex: "94A3B8"))

            // Dose input
            HStack(spacing: 0) {
                TextField("0", text: $doseAmount)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "F1F5F9"))
                    .multilineTextAlignment(.center)

                // Unit picker
                HStack(spacing: 0) {
                    ForEach(DoseUnit.allCases, id: \.self) { unit in
                        Button(action: { selectedUnit = unit }) {
                            Text(LocalizedStringKey(unit.localizationKey))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(selectedUnit == unit
                                                 ? Color(hex: "031820")
                                                 : Color(hex: "64748B"))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(selectedUnit == unit ? Color(hex: "06B6D4") : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .padding(4)
                .background(Color(hex: "131929"))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(16)
            .surfaceCard()

            // Quick-dose chips
            if let peptide = selectedPeptide, !peptide.commonDoses.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(peptide.commonDoses, id: \.self) { dose in
                            Button(action: { doseAmount = String(format: "%g", dose); selectedUnit = peptide.defaultUnit }) {
                                Text(String(format: "%g %@", dose, NSLocalizedString(peptide.defaultUnit.localizationKey, comment: "")))
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color(hex: "06B6D4"))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Color(hex: "061E2A"))
                                    .clipShape(Capsule())
                                    .overlay(Capsule().strokeBorder(Color(hex: "0891B2"), lineWidth: 0.5))
                            }
                        }
                    }
                }
            }

            disclaimerFootnote
        }
    }

    // MARK: - Step 4: Frequency

    private var step4Frequency: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepTitle("wizard.step4.title")

            LazyVStack(spacing: 10) {
                ForEach(FrequencyType.allCases, id: \.self) { freq in
                    Button(action: { selectedFrequency = freq }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(LocalizedStringKey(freq.localizationKey))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color(hex: "F1F5F9"))
                            }
                            Spacer()
                            if selectedFrequency == freq {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color(hex: "06B6D4"))
                                    .accessibilityHidden(true)
                            }
                        }
                        .padding(14)
                        .background(selectedFrequency == freq ? Color(hex: "061E2A") : Color(hex: "131929"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(selectedFrequency == freq
                                              ? Color(hex: "06B6D4")
                                              : Color(hex: "1E2640"), lineWidth: 0.5)
                        )
                    }
                }

                // Custom stepper
                if selectedFrequency == .custom {
                    HStack {
                        Text(LocalizedStringKey("frequency.custom.label"))
                            .font(.subheadline)
                            .foregroundStyle(Color(hex: "94A3B8"))
                        Spacer()
                        Stepper(value: $customDays, in: 2...30) {
                            Text("\(customDays)")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color(hex: "06B6D4"))
                        }
                        .tint(Color(hex: "06B6D4"))
                    }
                    .padding(14)
                    .surfaceCard()
                }
            }
        }
    }

    // MARK: - Step 5: Confirm

    private var step5Confirm: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepTitle("wizard.step5.title")

            LazyVStack(spacing: 10) {
                confirmRow(labelKey: "confirm.field.peptide", value: peptideName)
                confirmRow(labelKey: "confirm.field.dose", value: "\(doseAmount) \(NSLocalizedString(selectedUnit.localizationKey, comment: ""))")
                confirmRow(labelKey: "confirm.field.site", value: selectedSite.map { NSLocalizedString($0.localizationKey, comment: "") } ?? "—")
                confirmRow(labelKey: "confirm.field.date", value: logDate.formatted(date: .abbreviated, time: .shortened))
                if !notes.isEmpty {
                    confirmRow(labelKey: "confirm.field.notes", value: notes)
                }
            }

            disclaimerFootnote
        }
    }

    private func confirmRow(labelKey: String, value: String) -> some View {
        HStack {
            Text(LocalizedStringKey(labelKey))
                .font(.subheadline)
                .foregroundStyle(Color(hex: "94A3B8"))
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(Color(hex: "F1F5F9"))
                .multilineTextAlignment(.trailing)
        }
        .padding(14)
        .darkCard(radius: 12)
    }

    // MARK: - Navigation buttons

    private var navigationButtons: some View {
        VStack(spacing: 12) {
            Divider().background(Color(hex: "1E2640"))

            HStack(spacing: 12) {
                if step > 0 {
                    Button(action: { withAnimation { step -= 1 } }) {
                        Text(LocalizedStringKey("wizard.button.back"))
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(Color(hex: "94A3B8"))
                            .frame(width: 80, height: 52)
                            .background(Color(hex: "131929"))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }

                Button(action: nextAction) {
                    Text(LocalizedStringKey(step == totalSteps - 1
                         ? "wizard.button.logdose"
                         : "wizard.button.next"))
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(hex: "031820"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(hex: "06B6D4").opacity(isNextEnabled ? 1.0 : 0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(!isNextEnabled)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .background(Color(hex: "080C18"))
    }

    // MARK: - Helpers

    private var peptideName: String {
        selectedPeptide?.name ?? customPeptideName
    }

    private var isNextEnabled: Bool {
        switch step {
        case 0: return selectedCategory != nil
        case 1: return selectedPeptide != nil || !customPeptideName.trimmingCharacters(in: .whitespaces).isEmpty
        case 2: return Double(doseAmount) != nil && Double(doseAmount)! > 0
        case 3: return true
        case 4: return true
        default: return false
        }
    }

    private func nextAction() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        if step < totalSteps - 1 {
            withAnimation { step += 1 }
        } else {
            saveEntry()
        }
    }

    private func saveEntry() {
        let dose = Double(doseAmount) ?? 0
        let entry = PeptideEntry(
            peptideName: peptideName,
            peptideCategory: selectedCategory?.rawValue ?? PeptideCategory.other.rawValue,
            doseAmount: dose,
            doseUnit: selectedUnit.rawValue,
            injectionSite: selectedSite?.rawValue,
            loggedAt: logDate,
            notes: notes.isEmpty ? nil : notes,
            isActiveProtocol: true,
            frequencyType: selectedFrequency.rawValue,
            customFrequencyDays: selectedFrequency == .custom ? customDays : nil
        )
        context.insert(entry)
        try? context.save()
        savedEntry = entry
        showReminderPrompt = true
    }

    private func stepTitle(_ key: String) -> some View {
        Text(LocalizedStringKey(key))
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundStyle(Color(hex: "F1F5F9"))
    }

    private var disclaimerFootnote: some View {
        Text(LocalizedStringKey("wizard.disclaimer"))
            .font(.caption2)
            .foregroundStyle(Color(hex: "334155"))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 4)
    }
}

#Preview {
    AddPeptideWizardView()
        .environmentObject(StoreManager())
        .modelContainer(for: [PeptideEntry.self, SideEffectLog.self], inMemory: true)
}
