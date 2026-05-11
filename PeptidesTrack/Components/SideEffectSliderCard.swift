import SwiftUI

// MARK: - SideEffectSliderCard

struct SideEffectSliderCard: View {

    let definition: SideEffectDefinition
    @Binding var intensity: Double

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                // Icon + name
                HStack(spacing: 10) {
                    Image(systemName: definition.sfSymbol)
                        .font(.system(size: 16))
                        .foregroundStyle(intensityColor)
                        .frame(width: 20)
                        .accessibilityHidden(true)

                    Text(LocalizedStringKey("effect.\(definition.key)"))
                        .font(.subheadline)
                        .foregroundStyle(Color(hex: "F1F5F9"))
                }

                Spacer()

                // Positive badge
                if definition.isPositive {
                    Capsule()
                        .fill(Color(hex: "052016"))
                        .overlay(
                            Text(LocalizedStringKey("effects.section.positive"))
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundStyle(Color(hex: "34D399"))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                        )
                        .frame(height: 22)
                        .fixedSize()
                }

                // Intensity number
                Text("\(Int(intensity))")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(intensityColor)
                    .frame(width: 28, alignment: .trailing)
                    .accessibilityValue(Text("\(Int(intensity))"))
            }

            // Slider
            Slider(value: $intensity, in: 0...10, step: 1) {
                Text(LocalizedStringKey("effect.\(definition.key)"))
            }
            .tint(intensityColor)
            .onChange(of: intensity) { _, _ in
                let g = UIImpactFeedbackGenerator(style: .light)
                g.impactOccurred()
            }
            .accessibilityLabel(Text(LocalizedStringKey("effect.\(definition.key)")))
            .accessibilityValue(Text("\(Int(intensity))"))
        }
        .padding(16)
        .darkCard(radius: 14)
    }

    // MARK: - Color logic

    private var intensityColor: Color {
        let v = Int(intensity)
        if v == 0 { return Color(hex: "334155") }
        if definition.isPositive {
            return v <= 3 ? Color(hex: "94A3B8")
                 : v <= 6 ? Color(hex: "06B6D4")
                 : Color(hex: "34D399")
        } else {
            return v <= 3 ? Color(hex: "94A3B8")
                 : v <= 6 ? Color(hex: "FB923C")
                 : Color(hex: "F43F5E")
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        SideEffectSliderCard(
            definition: SideEffectDefinition(key: "energy", isPositive: true, sfSymbol: "bolt.fill"),
            intensity: .constant(7)
        )
        SideEffectSliderCard(
            definition: SideEffectDefinition(key: "nausea", isPositive: false, sfSymbol: "waveform.path.ecg"),
            intensity: .constant(4)
        )
    }
    .padding()
    .background(Color(hex: "080C18"))
}
