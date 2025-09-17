import Foundation

struct TrainerQuestionDraft: Identifiable, Equatable, Codable {
    let id: UUID
    var stem: String
    var ageBand: AgeBand
    var choices: [String]
    var correctIndex: Int?
    var skillTags: [String]
    var domain: String

    init(id: UUID = UUID(), stem: String = "", ageBand: AgeBand = .nineToEleven, choices: [String] = ["", "", ""], correctIndex: Int? = nil, skillTags: [String] = [], domain: String = "attack") {
        self.id = id
        self.stem = stem
        self.ageBand = ageBand
        self.choices = choices
        self.correctIndex = correctIndex
        self.skillTags = skillTags
        self.domain = domain
    }
}

final class TrainerContentStore: ObservableObject {
    static let shared = TrainerContentStore()
    @Published var drafts: [TrainerQuestionDraft] = []
    private let key = "trainer.drafts.v1"

    private init() {
        if let data = UserDefaults.standard.data(forKey: key), let decoded = try? JSONDecoder().decode([TrainerQuestionDraft].self, from: data) {
            drafts = decoded
        }
    }

    func add(_ draft: TrainerQuestionDraft) {
        drafts.append(draft)
        persist()
    }

    func remove(_ draft: TrainerQuestionDraft) {
        drafts.removeAll { $0.id == draft.id }
        persist()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(drafts) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

