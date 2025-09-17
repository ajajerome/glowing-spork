import Foundation

struct DrillDefinition: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let description: String
    let ageBands: [AgeBand]
    let timeLimitSeconds: Int
    let conesCount: Int
    let domain: String
    let skillTags: [String]
}

struct DrillCatalog: Codable {
    let drills: [DrillDefinition]
}

