import Foundation

enum AgeBand: String, Codable, CaseIterable, Identifiable {
    case sixToEight = "6-8"
    case nineToEleven = "9-11"
    case twelveToThirteen = "12-13"
    case fourteenToFifteen = "14-15"
    case sixteenToNineteen = "16-19"

    var id: String { rawValue }

    static func from(ageYears: Int) -> AgeBand {
        switch ageYears {
        case ..<9: return .sixToEight
        case 9...11: return .nineToEleven
        case 12...13: return .twelveToThirteen
        case 14...15: return .fourteenToFifteen
        default: return .sixteenToNineteen
        }
    }
}

enum FavoritePosition: String, Codable, CaseIterable, Identifiable {
    case goalkeeper
    case defender
    case midfielder
    case forward

    var id: String { rawValue }
}

enum HairStyle: String, Codable, CaseIterable, Identifiable {
    case short
    case medium
    case long
    case ponytail
    case curly
    case shaved

    var id: String { rawValue }
}

struct Avatar: Codable, Equatable, Identifiable {
    let id: UUID
    var name: String
    var birthDate: Date?
    var ageBand: AgeBand
    var favoritePosition: FavoritePosition
    var jerseyColorHex: String
    var skinToneHex: String
    var hairStyle: HairStyle

    init(id: UUID = UUID(), name: String, birthDate: Date? = nil, ageBand: AgeBand, favoritePosition: FavoritePosition, jerseyColorHex: String, skinToneHex: String, hairStyle: HairStyle) {
        self.id = id
        self.name = name
        self.birthDate = birthDate
        self.ageBand = ageBand
        self.favoritePosition = favoritePosition
        self.jerseyColorHex = jerseyColorHex
        self.skinToneHex = skinToneHex
        self.hairStyle = hairStyle
    }

    var computedAgeYears: Int? {
        guard let birthDate else { return nil }
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.year], from: birthDate, to: Date())
        return comps.year
    }

    func derivedAgeBand(now: Date = Date()) -> AgeBand? {
        guard let birthDate else { return nil }
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.year], from: birthDate, to: now)
        let age = comps.year ?? 0
        return AgeBand.from(ageYears: age)
    }
}

