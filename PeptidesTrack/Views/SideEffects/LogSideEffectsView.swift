import SwiftUI
import SwiftData

// MARK: - LogSideEffectsView

struct LogSideEffectsView: View {

    @Environment(\.modelContext) private var context
    @AppStorage("activeEffectKeys") private var activeEffectKeysData = Data()
    @State private var intensities: [String: Double] = [:]
    @State private var showEditor = false
    @State private var isSaved = false

    private var activeDefinitions: [SideEffectDefinition] {
        let keys = (try? JSONDecoder().decode(Set<String>.self, from: activeEffectKeysData))
                   ?? SideEffectsEditorView.defaultActiveKeys
        return SideEffectsCatalog.all.filter { keys.contains($0.key) }
    }

    private var positiveEffects: [SideEffectDefinition] {
        activeDefinitions.filter { $0.isPositive }
    }

    private var negativeEffects: [SideEffectDefinition] {
        activeDefinitions.filter { !$0.isPositive }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Subtitle
                        Text(LocalizedStringKey("effects.log.subtitle"))
                            .font(.subheadline)
                            .foregroundStyle(Color(hex: "94A3B8"))
                            .padding(.horizontal, 16)
                            .padding(.top, 8)

                        if !positiveEffects.isEmpty {
                            effectSection(
                                headerKey: "effects.section.positive",
                                headerColor: "34D399",
                                effects: positiveEffects
                            )
                        }

                        if !negativeEffects.isEmpty {
                            effectSection(
                                headerKey: "effects.section.negative",
                                headerColor: "F43F5E",
                                effects: negativeEffects
                            )
                        }

                        // Bottom padding for save bar
                        Color.clear.frame(height: 100)
                    }
                }
                .background(Color(hex: "080C18"))

                // Save bar
                saveBar
            }
            .navigationTitle(Text(LocalizedStringKey("effects.log.title")))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(hex: "0D1220"), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showEditor = true }) {
                        Image(systemName: "pencil")
                            .foregroundStyle(Color(hex: "94A3B8"))
                            .accessibilityLabel(Text(LocalizedStringKey("effects.editor.title")))
                    }
                }
            }
        }
        .sheet(isPresented: $showEditor) {
            SideEffectsEditorView()
        }
    }

    // MARK: - Section

    private func effectSection(headerKey: String, headerColor: String, effects: [SideEffectDefinition]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(LocalizedStringKey(headerKey))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color(hex: headerColor))
                .padding(.horizontal, 16)

            LazyVStack(spacing: 10) {
                ForEach(effects) { effect in
                    SideEffectSliderCard(
                        definition: effect,
                        intensity: Binding(
                            get: { intensities[effect.key, default: 0] },
                            set: { intensities[effect.key] = $0 }
                        )
                    )
                    .padding(.horizontal, 16)
                }
            }
        }
    }

    // MARK: - Save bar

    private var saveBar: some View {
        VStack(spacing: 0) {
            Divider().background(Color(hex: "1E2640"))

            VStack(spacing: 8) {
                Button(action: saveLog) {
                    Text(LocalizedStringKey(isSaved ? "button.done" : "button.save"))
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(hex: "031820"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(hex: isSaved ? "34D399" : "06B6D4"))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Text(LocalizedStringKey("disclaimer.tracking.footnote"))
                    .font(.caption2)
                    .foregroundStyle(Color(hex: "334155"))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 32)
            .background(.ultraThinMaterial)
        }
    }

    // MARK: - Save

    private func saveLog() {
        let entries = intensities.map { key, value in
            SideEffectEntry(
                effectKey: key,
                intensity: Int(value),
                isPositive: SideEffectsCatalog.definition(for: key)?.isPositive ?? false
            )
        }
        let log = SideEffectLog(entries: entries)
        context.insert(log)
        try? context.save()
        withAnimation { isSaved = true }
    }
}

#Preview {
    LogSideEffectsView()
        .modelContainer(for: SideEffectLog.self, inMemory: true)
}
