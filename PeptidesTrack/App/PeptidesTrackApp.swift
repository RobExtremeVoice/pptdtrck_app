import SwiftUI
import SwiftData

@main
struct PeptidesTrackApp: App {

    @StateObject private var store = StoreManager()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hasSeenDisclaimer") private var hasSeenDisclaimer = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
                .onAppear {
                    PeptidesNotificationManager.shared.registerCategories()
                }
                .task {
                    await store.loadProducts()
                    await store.checkSubscriptionStatus()
                }
        }
        .modelContainer(for: [PeptideEntry.self, SideEffectLog.self])
    }
}
