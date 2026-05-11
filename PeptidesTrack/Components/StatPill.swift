import SwiftUI

struct StatPill: View {
    let value: String
    let label: String
    let colorHex: String

    var body: some View {
        HStack(spacing: 4) {
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(Color(hex: colorHex))
                .fontDesign(.rounded)

            Text(label)
                .font(.caption)
                .foregroundStyle(Color(hex: "94A3B8"))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(hex: "131929"))
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(Color(hex: "1E2640"), lineWidth: 0.5))
    }
}

#Preview {
    HStack {
        StatPill(value: "42", label: "doses", colorHex: "06B6D4")
        StatPill(value: "7d", label: "streak", colorHex: "F59E0B")
        StatPill(value: "0.5mg", label: "avg", colorHex: "34D399")
    }
    .padding()
    .background(Color(hex: "080C18"))
}
