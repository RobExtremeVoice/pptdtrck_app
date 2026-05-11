import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - PeptidesTrack Palette

extension Color {
    // Backgrounds
    static let ptBackground      = Color(hex: "080C18")
    static let ptSurface         = Color(hex: "0D1220")
    static let ptSurfaceElevated = Color(hex: "131929")
    static let ptBorder          = Color(hex: "1E2640")

    // Brand — Cyan
    static let ptCyan            = Color(hex: "06B6D4")
    static let ptCyanDark        = Color(hex: "0891B2")
    static let ptCyanGlow        = Color(hex: "061E2A")

    // Brand — Violet
    static let ptViolet          = Color(hex: "8B5CF6")
    static let ptVioletDark      = Color(hex: "6D28D9")
    static let ptVioletGlow      = Color(hex: "130F23")

    // Semantic
    static let ptSuccess         = Color(hex: "34D399")
    static let ptSuccessBg       = Color(hex: "052016")
    static let ptWarning         = Color(hex: "FB923C")
    static let ptWarningBg       = Color(hex: "1E1205")
    static let ptDanger          = Color(hex: "F43F5E")
    static let ptDangerBg        = Color(hex: "1A0510")

    // Text
    static let ptTextPrimary     = Color(hex: "F1F5F9")
    static let ptTextSecondary   = Color(hex: "94A3B8")
    static let ptTextTertiary    = Color(hex: "64748B")
    static let ptTextDim         = Color(hex: "334155")
    static let ptTextMuted       = Color(hex: "4A5580")

    // Pro
    static let ptProGold         = Color(hex: "F59E0B")
    static let ptProGoldBg       = Color(hex: "1C1500")
}
