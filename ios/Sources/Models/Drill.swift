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
    let objectives: [String]?
    let methodology: String?
    let sources: [String]?
}

struct DrillCatalog: Codable {
    let drills: [DrillDefinition]
}

