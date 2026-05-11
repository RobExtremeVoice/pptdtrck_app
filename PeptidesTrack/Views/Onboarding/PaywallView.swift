import SwiftUI
import StoreKit

// MARK: - PaywallView

struct PaywallView: View {

    @EnvironmentObject private var store: StoreManager
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(\.dismiss) private var dismiss

    private let features: [(iconKey: String, labelKey: String)] = [
        ("infinity",                        "paywall.feature.unlimited"),
        ("figure.stand",                    "paywall.feature.sitemap"),
        ("waveform.path.ecg",               "paywall.feature.sideeffects"),
        ("bell.fill",                       "paywall.feature.reminders"),
        ("chart.bar.fill",                  "paywall.feature.history"),
        ("flame.fill",                      "paywall.feature.streak"),
    ]

    var body: some View {
        ZStack {
            Color(hex: "080C18").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                    proCard
                    footerSection
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
            }
        }
        .task { await store.loadProducts() }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color(hex: "F59E0B"))
                .accessibilityHidden(true)
                .padding(.bottom, 8)

            Text(LocalizedStringKey("paywall.title"))
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Color(hex: "F1F5F9"))
                .multilineTextAlignment(.center)

            Text(LocalizedStringKey("paywall.subtitle"))
                .font(.subheadline)
                .foregroundStyle(Color(hex: "94A3B8"))
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 32)
    }

    // MARK: - PRO Card

    private var proCard: some View {
        VStack(spacing: 0) {
            // Badge
            ZStack {
                Capsule()
                    .fill(Color(hex: "06B6D4"))
                    .frame(height: 28)

                Text(LocalizedStringKey("paywall.badge"))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(hex: "031820"))
            }
            .frame(width: 120)
            .offset(y: -14)
            .padding(.top, 14)

            VStack(spacing: 20) {
                // Plan name + price
                VStack(spacing: 6) {
                    Text(LocalizedStringKey("paywall.plan.pro"))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(hex: "F1F5F9"))

                    if let product = store.proProduct {
                        Text(String(format: NSLocalizedString("paywall.price.monthly", comment: ""),
                                    product.displayPrice))
                            .font(.subheadline)
                            .foregroundStyle(Color(hex: "94A3B8"))
                    } else {
                        Text(LocalizedStringKey("paywall.price.monthly"))
                            .font(.subheadline)
                            .foregroundStyle(Color(hex: "94A3B8"))
                    }
                }

                Divider()
                    .background(Color(hex: "1E2640"))

                // Feature list
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(features, id: \.labelKey) { feature in
                        HStack(spacing: 12) {
                            Image(systemName: feature.iconKey)
                                .font(.system(size: 15))
                                .foregroundStyle(Color(hex: "06B6D4"))
                                .frame(width: 20)
                                .accessibilityHidden(true)

                            Text(LocalizedStringKey(feature.labelKey))
                                .font(.subheadline)
                                .foregroundStyle(Color(hex: "F1F5F9"))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // CTA
                Button(action: { Task { await store.purchase() } }) {
                    ZStack {
                        if store.isPurchasing {
                            ProgressView()
                                .tint(Color(hex: "031820"))
                        } else {
                            Text(LocalizedStringKey("paywall.cta.start"))
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color(hex: "031820"))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(hex: "06B6D4"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: Color(hex: "06B6D4").opacity(0.3), radius: 12, y: 4)
                }
                .disabled(store.isPurchasing)
            }
            .padding(24)
        }
        .background(Color(hex: "131929"))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color(hex: "06B6D4"), lineWidth: 1.5)
        )
        .padding(.bottom, 16)
    }

    // MARK: - Footer

    private var footerSection: some View {
        VStack(spacing: 16) {
            // Limited access
            Button(action: finishOnboarding) {
                Text(LocalizedStringKey("paywall.cta.limited"))
                    .font(.subheadline)
                    .foregroundStyle(Color(hex: "64748B"))
            }

            // Restore
            Button(action: { Task { await store.restorePurchases() } }) {
                Text(LocalizedStringKey("paywall.cta.restore"))
                    .font(.caption)
                    .foregroundStyle(Color(hex: "4A5580"))
            }

            // Footnote
            Text(LocalizedStringKey("paywall.footnote"))
                .font(.caption2)
                .foregroundStyle(Color(hex: "334155"))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    // MARK: - Actions

    private func finishOnboarding() {
        hasCompletedOnboarding = true
    }
}

// MARK: - Preview

#Preview {
    PaywallView()
        .environmentObject(StoreManager())
}
