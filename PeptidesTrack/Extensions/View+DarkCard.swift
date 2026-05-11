import SwiftUI

extension View {
    func darkCard(radius: CGFloat = 16) -> some View {
        self
            .background(Color(hex: "131929"))
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .strokeBorder(Color(hex: "1E2640"), lineWidth: 0.5)
            )
    }

    func surfaceCard(radius: CGFloat = 16) -> some View {
        self
            .background(Color(hex: "0D1220"))
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .strokeBorder(Color(hex: "1E2640"), lineWidth: 0.5)
            )
    }
}
