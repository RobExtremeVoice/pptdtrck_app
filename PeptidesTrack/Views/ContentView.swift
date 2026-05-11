import SwiftUI

// MARK: - ContentView

struct ContentView: View {

    @EnvironmentObject private var store: StoreManager
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hasSeenDisclaimer") private var hasSeenDisclaimer = false
    @State private var selectedTab = 0

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView()
            } else {
                mainTabView
                    .sheet(isPresented: .constant(!hasSeenDisclaimer)) {
                        DisclaimerModal()
                    }
            }
        }
    }

    // MARK: - Tab View

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(LocalizedStringKey("tab.home"), systemImage: "house.fill")
                }
                .tag(0)

            PeptideHistoryView()
                .tabItem {
                    Label(LocalizedStringKey("tab.history"), systemImage: "calendar")
                }
                .tag(1)

            StatsView()
                .tabItem {
                    Label(LocalizedStringKey("tab.stats"), systemImage: "chart.bar.fill")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label(LocalizedStringKey("tab.settings"), systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .tint(Color(hex: "06B6D4"))
        .background(Color(hex: "080C18"))
        .toolbarBackground(Color(hex: "0D1220"), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(StoreManager())
}
