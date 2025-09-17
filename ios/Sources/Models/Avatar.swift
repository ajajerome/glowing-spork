import Foundation

enum AgeBand: String, Codable, CaseIterable, Identifiable {
    case sixToEight = "6-8"
    case nineToEleven = "9-11"
    case twelveToThirteen = "12-13"
    case fourteenToFifteen = "14-15"
    case sixteenToNineteen = "16-19"

    var id: String { rawValue }
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
    var ageBand: AgeBand
    var favoritePosition: FavoritePosition
    var jerseyColorHex: String
    var skinToneHex: String
    var hairStyle: HairStyle

    init(id: UUID = UUID(), name: String, ageBand: AgeBand, favoritePosition: FavoritePosition, jerseyColorHex: String, skinToneHex: String, hairStyle: HairStyle) {
        self.id = id
        self.name = name
        self.ageBand = ageBand
        self.favoritePosition = favoritePosition
        self.jerseyColorHex = jerseyColorHex
        self.skinToneHex = skinToneHex
        self.hairStyle = hairStyle
    }
}

