import SwiftUI

// MARK: - PeptideCategory

enum PeptideCategory: String, CaseIterable, Codable {
    case glp1
    case healing
    case growthHormone
    case cognitive
    case other

    var localizationKey: String { "peptide.category.\(rawValue)" }

    var sfSymbol: String {
        switch self {
        case .glp1:          return "pills.fill"
        case .healing:       return "bandage.fill"
        case .growthHormone: return "figure.strengthtraining.traditional"
        case .cognitive:     return "brain.head.profile"
        case .other:         return "testtube.2"
        }
    }

    var colorHex: String {
        switch self {
        case .glp1:          return "06B6D4"
        case .healing:       return "8B5CF6"
        case .growthHormone: return "34D399"
        case .cognitive:     return "F59E0B"
        case .other:         return "94A3B8"
        }
    }

    var glowHex: String {
        switch self {
        case .glp1:          return "061E2A"
        case .healing:       return "130F23"
        case .growthHormone: return "052016"
        case .cognitive:     return "1C1500"
        case .other:         return "1E2640"
        }
    }
}

// MARK: - PeptideInfo

struct PeptideInfo: Identifiable {
    let id = UUID()
    let name: String
    let category: PeptideCategory
    let defaultUnit: DoseUnit
    let commonDoses: [Double]
    let sfSymbol: String
    let brandNames: [String]
}

// MARK: - PeptideCatalog

enum PeptideCatalog {

    static let all: [PeptideInfo] = glp1 + healing + growthHormone + cognitive

    // MARK: GLP-1
    static let glp1: [PeptideInfo] = [
        PeptideInfo(
            name: "Semaglutide",
            category: .glp1,
            defaultUnit: .mg,
            commonDoses: [0.25, 0.5, 1.0, 2.0],
            sfSymbol: "syringe.fill",
            brandNames: ["Ozempic", "Wegovy"]
        ),
        PeptideInfo(
            name: "Tirzepatide",
            category: .glp1,
            defaultUnit: .mg,
            commonDoses: [2.5, 5.0, 7.5, 10.0, 12.5, 15.0],
            sfSymbol: "syringe.fill",
            brandNames: ["Mounjaro", "Zepbound"]
        ),
        PeptideInfo(
            name: "Liraglutide",
            category: .glp1,
            defaultUnit: .mg,
            commonDoses: [0.6, 1.2, 1.8],
            sfSymbol: "syringe.fill",
            brandNames: ["Victoza", "Saxenda"]
        ),
        PeptideInfo(
            name: "Dulaglutide",
            category: .glp1,
            defaultUnit: .mg,
            commonDoses: [0.75, 1.5, 3.0, 4.5],
            sfSymbol: "syringe.fill",
            brandNames: ["Trulicity"]
        ),
    ]

    // MARK: Healing
    static let healing: [PeptideInfo] = [
        PeptideInfo(
            name: "BPC-157",
            category: .healing,
            defaultUnit: .mcg,
            commonDoses: [250, 500],
            sfSymbol: "cross.vial.fill",
            brandNames: []
        ),
        PeptideInfo(
            name: "TB-500",
            category: .healing,
            defaultUnit: .mg,
            commonDoses: [2.0, 5.0],
            sfSymbol: "cross.vial.fill",
            brandNames: []
        ),
        PeptideInfo(
            name: "GHK-Cu",
            category: .healing,
            defaultUnit: .mg,
            commonDoses: [1.0, 2.0],
            sfSymbol: "cross.vial.fill",
            brandNames: []
        ),
        PeptideInfo(
            name: "PT-141",
            category: .healing,
            defaultUnit: .mg,
            commonDoses: [0.5, 1.0, 1.75, 2.0],
            sfSymbol: "cross.vial.fill",
            brandNames: ["Bremelanotide"]
        ),
    ]

    // MARK: Growth Hormone
    static let growthHormone: [PeptideInfo] = [
        PeptideInfo(
            name: "Ipamorelin",
            category: .growthHormone,
            defaultUnit: .mcg,
            commonDoses: [100, 200, 300],
            sfSymbol: "figure.strengthtraining.traditional",
            brandNames: []
        ),
        PeptideInfo(
            name: "CJC-1295",
            category: .growthHormone,
            defaultUnit: .mcg,
            commonDoses: [100, 200],
            sfSymbol: "figure.strengthtraining.traditional",
            brandNames: []
        ),
        PeptideInfo(
            name: "Sermorelin",
            category: .growthHormone,
            defaultUnit: .mcg,
            commonDoses: [200, 500],
            sfSymbol: "figure.strengthtraining.traditional",
            brandNames: []
        ),
        PeptideInfo(
            name: "Hexarelin",
            category: .growthHormone,
            defaultUnit: .mcg,
            commonDoses: [100, 200],
            sfSymbol: "figure.strengthtraining.traditional",
            brandNames: []
        ),
        PeptideInfo(
            name: "GHRP-6",
            category: .growthHormone,
            defaultUnit: .mcg,
            commonDoses: [100, 200, 300],
            sfSymbol: "figure.strengthtraining.traditional",
            brandNames: []
        ),
        PeptideInfo(
            name: "MK-677",
            category: .growthHormone,
            defaultUnit: .mg,
            commonDoses: [10, 15, 25],
            sfSymbol: "figure.strengthtraining.traditional",
            brandNames: ["Ibutamoren"]
        ),
    ]

    // MARK: Cognitive
    static let cognitive: [PeptideInfo] = [
        PeptideInfo(
            name: "Selank",
            category: .cognitive,
            defaultUnit: .mcg,
            commonDoses: [250, 500],
            sfSymbol: "brain.head.profile",
            brandNames: []
        ),
        PeptideInfo(
            name: "Semax",
            category: .cognitive,
            defaultUnit: .mcg,
            commonDoses: [300, 600],
            sfSymbol: "brain.head.profile",
            brandNames: []
        ),
        PeptideInfo(
            name: "Dihexa",
            category: .cognitive,
            defaultUnit: .mg,
            commonDoses: [10, 20],
            sfSymbol: "brain.head.profile",
            brandNames: []
        ),
        PeptideInfo(
            name: "Cerebrolysin",
            category: .cognitive,
            defaultUnit: .ml,
            commonDoses: [5, 10],
            sfSymbol: "brain.head.profile",
            brandNames: []
        ),
    ]

    static func peptides(for category: PeptideCategory) -> [PeptideInfo] {
        all.filter { $0.category == category }
    }
}
