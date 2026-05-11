import SwiftUI

// MARK: - DisclaimerModal

struct DisclaimerModal: View {

    @AppStorage("hasSeenDisclaimer") private var hasSeenDisclaimer = false

    var body: some View {
        VStack(spacing: 24) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color(hex: "061E2A"))
                    .frame(width: 72, height: 72)

                Image(systemName: "cross.vial.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(Color(hex: "06B6D4"))
                    .accessibilityHidden(true)
            }
            .padding(.top, 32)

            // Title
            Text(LocalizedStringKey("disclaimer.title"))
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color(hex: "F1F5F9"))
                .multilineTextAlignment(.center)

            // Body
            Text(LocalizedStringKey("disclaimer.body"))
                .font(.subheadline)
                .foregroundStyle(Color(hex: "94A3B8"))
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()

            // CTA
            Button(action: { hasSeenDisclaimer = true }) {
                Text(LocalizedStringKey("disclaimer.cta"))
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(hex: "031820"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(hex: "06B6D4"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.bottom, 32)
        }
        .padding(.horizontal, 24)
        .background(Color(hex: "0D1220"))
        .presentationDetents([.height(500)])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color(hex: "0D1220"))
        .interactiveDismissDisabled()
    }
}

#Preview {
    DisclaimerModal()
}
