import SwiftUI

// MARK: - SettingsView

struct SettingsView: View {

    @EnvironmentObject private var store: StoreManager
    @State private var showSideEffectsEditor = false
    @State private var showPaywall = false

    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    var body: some View {
        NavigationStack {
            List {
                // Account
                Section {
                    subscriptionRow
                } header: {
                    sectionHeader("settings.section.account")
                }

                // Notifications
                Section {
                    NavigationLink(destination: RemindersView()) {
                        settingsRow(icon: "bell.fill", iconColor: "06B6D4", labelKey: "settings.row.reminders")
                    }
                } header: {
                    sectionHeader("settings.section.notifications")
                }

                // Data
                Section {
                    Button(action: { showSideEffectsEditor = true }) {
                        settingsRow(icon: "waveform.path.ecg", iconColor: "8B5CF6", labelKey: "settings.row.sideeffects")
                    }

                    settingsRow(icon: "square.and.arrow.up", iconColor: "34D399", labelKey: "settings.row.export")
                } header: {
                    sectionHeader("settings.section.data")
                }

                // Support
                Section {
                    settingsRow(icon: "hand.raised.fill", iconColor: "94A3B8", labelKey: "settings.row.privacy")
                    settingsRow(icon: "doc.text.fill", iconColor: "94A3B8", labelKey: "settings.row.terms")
                    settingsRow(icon: "envelope.fill", iconColor: "94A3B8", labelKey: "settings.row.feedback")

                    HStack {
                        settingsRow(icon: "info.circle.fill", iconColor: "4A5580", labelKey: "settings.row.version")
                        Spacer()
                        Text("\(appVersion) (\(buildNumber))")
                            .font(.subheadline)
                            .foregroundStyle(Color(hex: "64748B"))
                    }
                } header: {
                    sectionHeader("settings.section.support")
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color(hex: "080C18"))
            .navigationTitle(Text(LocalizedStringKey("settings.title")))
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color(hex: "0D1220"), for: .navigationBar)
        }
        .sheet(isPresented: $showSideEffectsEditor) {
            SideEffectsEditorView()
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    // MARK: - Subscription row

    private var subscriptionRow: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: "1C1500"))
                    .frame(width: 32, height: 32)
                Image(systemName: "crown.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: "F59E0B"))
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(LocalizedStringKey("settings.row.subscription"))
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: "F1F5F9"))

                Text(subscriptionStatusKey)
                    .font(.caption)
                    .foregroundStyle(Color(hex: "94A3B8"))
            }

            Spacer()

            if !store.isPro && !store.isInTrial {
                Button(action: { showPaywall = true }) {
                    Text(LocalizedStringKey("button.upgrade"))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(hex: "031820"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(hex: "06B6D4"))
                        .clipShape(Capsule())
                }
            }
        }
        .listRowBackground(Color(hex: "131929"))
    }

    private var subscriptionStatusKey: LocalizedStringKey {
        if store.isPro && store.isInTrial {
            return LocalizedStringKey(String(format: NSLocalizedString("settings.pro.trial", comment: ""), store.trialDaysRemaining))
        } else if store.isPro {
            return LocalizedStringKey("settings.pro.active")
        } else {
            return LocalizedStringKey("settings.pro.expired")
        }
    }

    // MARK: - Helpers

    private func settingsRow(icon: String, iconColor: String, labelKey: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: iconColor).opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: iconColor))
                    .accessibilityHidden(true)
            }
            Text(LocalizedStringKey(labelKey))
                .font(.subheadline)
                .foregroundStyle(Color(hex: "F1F5F9"))
        }
        .listRowBackground(Color(hex: "131929"))
    }

    private func sectionHeader(_ key: String) -> some View {
        Text(LocalizedStringKey(key))
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(Color(hex: "4A5580"))
            .textCase(.none)
    }
}

#Preview {
    SettingsView()
        .environmentObject(StoreManager())
}
