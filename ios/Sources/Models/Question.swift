import Foundation

struct QuestionItem: Codable, Identifiable, Equatable {
    let id: String
    let ageBand: AgeBand
    let domain: String
    let skillTags: [String]
    let stem: String
    let choices: [String]?
    let correctIndex: Int?
    let rationale: String?
    let difficulty: Int
}

struct QuestionBank: Codable {
    let questions: [QuestionItem]
}

