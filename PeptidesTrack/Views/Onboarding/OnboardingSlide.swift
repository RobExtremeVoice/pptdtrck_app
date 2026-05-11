import SwiftUI

// MARK: - OnboardingSlideData

struct OnboardingSlideData {
    let titleKey: String
    let subtitleKey: String
    let sfSymbol: String
    let symbolColor: String
    let symbolGlow: String
}

// MARK: - OnboardingSlide

struct OnboardingSlide: View {

    let data: OnboardingSlideData

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(Color(hex: data.symbolGlow))
                    .frame(width: 120, height: 120)

                Image(systemName: data.sfSymbol)
                    .font(.system(size: 52, weight: .medium))
                    .foregroundStyle(Color(hex: data.symbolColor))
                    .accessibilityHidden(true)
            }

            // Text
            VStack(spacing: 16) {
                Text(LocalizedStringKey(data.titleKey))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(hex: "F1F5F9"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                Text(LocalizedStringKey(data.subtitleKey))
                    .font(.body)
                    .foregroundStyle(Color(hex: "94A3B8"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 8)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Preview

#Preview {
    OnboardingSlide(data: OnboardingSlideData(
        titleKey: "onboarding.slide1.title",
        subtitleKey: "onboarding.slide1.subtitle",
        sfSymbol: "atom",
        symbolColor: "06B6D4",
        symbolGlow: "061E2A"
    ))
    .background(Color(hex: "080C18"))
}
