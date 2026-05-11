import Foundation

// MARK: - SideEffectDefinition

struct SideEffectDefinition: Identifiable {
    let id = UUID()
    let key: String       // matches "effect.<key>" localization key
    let isPositive: Bool
    let sfSymbol: String
}

// MARK: - SideEffectsCatalog

enum SideEffectsCatalog {

    static let positive: [SideEffectDefinition] = [
        SideEffectDefinition(key: "reduced_food_noise",      isPositive: true,  sfSymbol: "fork.knife.circle"),
        SideEffectDefinition(key: "reduced_joint_pain",      isPositive: true,  sfSymbol: "figure.walk"),
        SideEffectDefinition(key: "ease_of_exercise",        isPositive: true,  sfSymbol: "figure.run"),
        SideEffectDefinition(key: "feelings_of_fullness",    isPositive: true,  sfSymbol: "circle.fill"),
        SideEffectDefinition(key: "energy",                  isPositive: true,  sfSymbol: "bolt.fill"),
        SideEffectDefinition(key: "reduced_sugar_cravings",  isPositive: true,  sfSymbol: "xmark.circle"),
        SideEffectDefinition(key: "reduced_salty_cravings",  isPositive: true,  sfSymbol: "xmark.circle"),
        SideEffectDefinition(key: "reduced_fatty_cravings",  isPositive: true,  sfSymbol: "xmark.circle"),
        SideEffectDefinition(key: "improved_sleep",          isPositive: true,  sfSymbol: "moon.fill"),
        SideEffectDefinition(key: "improved_mood",           isPositive: true,  sfSymbol: "face.smiling"),
    ]

    static let negative: [SideEffectDefinition] = [
        SideEffectDefinition(key: "nausea",                   isPositive: false, sfSymbol: "waveform.path.ecg"),
        SideEffectDefinition(key: "vomiting",                 isPositive: false, sfSymbol: "waveform.path.ecg"),
        SideEffectDefinition(key: "diarrhea",                 isPositive: false, sfSymbol: "waveform.path.ecg"),
        SideEffectDefinition(key: "constipation",             isPositive: false, sfSymbol: "waveform.path.ecg"),
        SideEffectDefinition(key: "abdominal_pain",           isPositive: false, sfSymbol: "waveform.path.ecg"),
        SideEffectDefinition(key: "reduced_appetite",         isPositive: false, sfSymbol: "minus.circle"),
        SideEffectDefinition(key: "injection_site_reaction",  isPositive: false, sfSymbol: "bandage"),
        SideEffectDefinition(key: "acid_reflux",              isPositive: false, sfSymbol: "flame"),
        SideEffectDefinition(key: "bloating",                 isPositive: false, sfSymbol: "circle"),
        SideEffectDefinition(key: "burping",                  isPositive: false, sfSymbol: "arrow.up.circle"),
        SideEffectDefinition(key: "gas",                      isPositive: false, sfSymbol: "wind"),
        SideEffectDefinition(key: "hair_loss",                isPositive: false, sfSymbol: "person.fill"),
        SideEffectDefinition(key: "dehydration",              isPositive: false, sfSymbol: "drop"),
        SideEffectDefinition(key: "dizziness",                isPositive: false, sfSymbol: "arrow.triangle.2.circlepath"),
        SideEffectDefinition(key: "headache",                 isPositive: false, sfSymbol: "brain.head.profile"),
        SideEffectDefinition(key: "fatigue",                  isPositive: false, sfSymbol: "battery.25"),
        SideEffectDefinition(key: "irritability",             isPositive: false, sfSymbol: "exclamationmark.triangle"),
    ]

    static let all: [SideEffectDefinition] = positive + negative

    static func definition(for key: String) -> SideEffectDefinition? {
        all.first { $0.key == key }
    }
}
