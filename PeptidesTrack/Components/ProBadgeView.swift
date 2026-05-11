import SwiftUI

struct ProBadgeView: View {
    var body: some View {
        Text(LocalizedStringKey("pro.badge"))
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundStyle(Color(hex: "1C1500"))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color(hex: "F59E0B"))
            .clipShape(Capsule())
    }
}

struct TrialBadgeView: View {
    var body: some View {
        Text(LocalizedStringKey("pro.trial.badge"))
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundStyle(Color(hex: "031820"))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color(hex: "06B6D4"))
            .clipShape(Capsule())
    }
}

#Preview {
    HStack(spacing: 8) {
        ProBadgeView()
        TrialBadgeView()
    }
    .padding()
    .background(Color(hex: "080C18"))
}
