import Foundation

final class QuestionService {
    static let shared = QuestionService()
    private var bank: QuestionBank = QuestionBank(questions: [])

    private init() {
        bank = loadBundled()
    }

    func questions(for ageBand: AgeBand) -> [QuestionItem] {
        return bank.questions.filter { $0.ageBand == ageBand }
    }

    func oneRandom(for ageBand: AgeBand) -> QuestionItem? {
        let list = questions(for: ageBand)
        return list.randomElement()
    }

    private func loadBundled() -> QuestionBank {
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json") else {
            return QuestionBank(questions: [])
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys
            return try decoder.decode(QuestionBank.self, from: data)
        } catch {
            print("QuestionService load error: \(error)")
            return QuestionBank(questions: [])
        }
    }
}

