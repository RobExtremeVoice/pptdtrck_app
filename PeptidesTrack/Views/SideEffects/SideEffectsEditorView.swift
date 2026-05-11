import SwiftUI

// MARK: - SideEffectsEditorView

struct SideEffectsEditorView: View {

    @AppStorage("activeEffectKeys") private var activeEffectKeysData = Data()
    @Environment(\.dismiss) private var dismiss

    @State private var activeKeys: Set<String> = []

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(SideEffectsCatalog.positive) { effect in
                        toggleRow(effect)
                    }
                } header: {
                    Text(LocalizedStringKey("effects.section.positive"))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(hex: "34D399"))
                        .textCase(.none)
                }

                Section {
                    ForEach(SideEffectsCatalog.negative) { effect in
                        toggleRow(effect)
                    }
                } header: {
                    Text(LocalizedStringKey("effects.section.negative"))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(hex: "F43F5E"))
                        .textCase(.none)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color(hex: "080C18"))
            .navigationTitle(Text(LocalizedStringKey("effects.editor.title")))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: save) {
                        Text(LocalizedStringKey("button.save"))
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(hex: "06B6D4"))
                    }
                }
            }
        }
        .onAppear { loadActiveKeys() }
    }

    // MARK: - Toggle row

    private func toggleRow(_ effect: SideEffectDefinition) -> some View {
        HStack(spacing: 12) {
            Image(systemName: effect.sfSymbol)
                .font(.system(size: 16))
                .foregroundStyle(effect.isPositive ? Color(hex: "34D399") : Color(hex: "F43F5E"))
                .frame(width: 20)
                .accessibilityHidden(true)

            Text(LocalizedStringKey("effect.\(effect.key)"))
                .font(.subheadline)
                .foregroundStyle(Color(hex: "F1F5F9"))

            Spacer()

            Toggle(isOn: Binding(
                get: { activeKeys.contains(effect.key) },
                set: { on in
                    if on { activeKeys.insert(effect.key) }
                    else { activeKeys.remove(effect.key) }
                }
            )) { EmptyView() }
            .tint(Color(hex: "06B6D4"))
            .labelsHidden()
            .accessibilityLabel(Text(LocalizedStringKey("effect.\(effect.key)")))
        }
        .listRowBackground(Color(hex: "131929"))
    }

    // MARK: - Persistence

    static var defaultActiveKeys: Set<String> {
        Set(["nausea", "energy", "reduced_food_noise", "fatigue", "headache", "improved_sleep"])
    }

    private func loadActiveKeys() {
        if let decoded = try? JSONDecoder().decode(Set<String>.self, from: activeEffectKeysData) {
            activeKeys = decoded
        } else {
            activeKeys = Self.defaultActiveKeys
        }
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(activeKeys) {
            activeEffectKeysData = encoded
        }
        dismiss()
    }
}

#Preview {
    SideEffectsEditorView()
}
