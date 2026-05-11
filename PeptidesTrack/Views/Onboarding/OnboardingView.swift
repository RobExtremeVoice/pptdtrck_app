import SwiftUI

// MARK: - OnboardingView

struct OnboardingView: View {

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @State private var showPaywall = false

    private let slides: [OnboardingSlideData] = [
        OnboardingSlideData(
            titleKey: "onboarding.slide1.title",
            subtitleKey: "onboarding.slide1.subtitle",
            sfSymbol: "atom",
            symbolColor: "06B6D4",
            symbolGlow: "061E2A"
        ),
        OnboardingSlideData(
            titleKey: "onboarding.slide2.title",
            subtitleKey: "onboarding.slide2.subtitle",
            sfSymbol: "figure.stand",
            symbolColor: "8B5CF6",
            symbolGlow: "130F23"
        ),
        OnboardingSlideData(
            titleKey: "onboarding.slide3.title",
            subtitleKey: "onboarding.slide3.subtitle",
            sfSymbol: "waveform.path.ecg",
            symbolColor: "34D399",
            symbolGlow: "052016"
        ),
    ]

    var body: some View {
        ZStack(alignment: .top) {
            Color(hex: "080C18").ignoresSafeArea()

            // Skip button — slides 0 and 1 only
            if currentPage < 2 {
                HStack {
                    Spacer()
                    Button(action: { showPaywall = true }) {
                        Text(LocalizedStringKey("onboarding.cta.skip"))
                            .font(.subheadline)
                            .foregroundStyle(Color(hex: "64748B"))
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                }
            }

            VStack(spacing: 0) {
                // Slides
                TabView(selection: $currentPage) {
                    ForEach(Array(slides.enumerated()), id: \.offset) { index, slide in
                        OnboardingSlide(data: slide)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.3), value: currentPage)

                // Dots + CTA
                VStack(spacing: 28) {
                    // Dot indicator
                    HStack(spacing: 8) {
                        ForEach(0..<slides.count, id: \.self) { index in
                            Capsule()
                                .fill(index == currentPage
                                      ? Color(hex: "06B6D4")
                                      : Color(hex: "1E2640"))
                                .frame(width: index == currentPage ? 20 : 6, height: 6)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }

                    // Primary CTA
                    Button(action: advanceOrFinish) {
                        Text(LocalizedStringKey(currentPage < slides.count - 1
                             ? "onboarding.cta.continue"
                             : "onboarding.cta.start"))
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(hex: "031820"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color(hex: "06B6D4"))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: Color(hex: "06B6D4").opacity(0.3), radius: 12, y: 4)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    // MARK: - Actions

    private func advanceOrFinish() {
        if currentPage < slides.count - 1 {
            withAnimation(.spring(response: 0.3)) { currentPage += 1 }
        } else {
            showPaywall = true
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView()
}
