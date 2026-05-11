import Foundation

// MARK: - InjectionSite

enum InjectionSite: String, CaseIterable, Codable {
    case abdomenLowerLeft   = "abdomen_lower_left"
    case abdomenLowerMiddle = "abdomen_lower_middle"
    case abdomenLowerRight  = "abdomen_lower_right"
    case abdomenUpperLeft   = "abdomen_upper_left"
    case abdomenUpperMiddle = "abdomen_upper_middle"
    case abdomenUpperRight  = "abdomen_upper_right"
    case thighLeft          = "thigh_left"
    case thighRight         = "thigh_right"
    case upperArmLeft       = "upper_arm_left"
    case upperArmRight      = "upper_arm_right"

    // Localization key: "site.<rawValue>"
    var localizationKey: String { "site.\(rawValue)" }

    // Normalized coordinates (0–1) for body diagram overlay
    // Origin: top-left of the figure.stand bounding box
    var normalizedPosition: CGPoint {
        switch self {
        case .abdomenLowerLeft:   return CGPoint(x: 0.42, y: 0.55)
        case .abdomenLowerMiddle: return CGPoint(x: 0.50, y: 0.58)
        case .abdomenLowerRight:  return CGPoint(x: 0.58, y: 0.55)
        case .abdomenUpperLeft:   return CGPoint(x: 0.42, y: 0.46)
        case .abdomenUpperMiddle: return CGPoint(x: 0.50, y: 0.46)
        case .abdomenUpperRight:  return CGPoint(x: 0.58, y: 0.46)
        case .thighLeft:          return CGPoint(x: 0.38, y: 0.72)
        case .thighRight:         return CGPoint(x: 0.62, y: 0.72)
        case .upperArmLeft:       return CGPoint(x: 0.26, y: 0.36)
        case .upperArmRight:      return CGPoint(x: 0.74, y: 0.36)
        }
    }
}
