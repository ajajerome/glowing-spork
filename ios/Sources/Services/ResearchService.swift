import Foundation

struct ResearchSource: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let org: String
    let year: Int
}

struct ResearchRegistry: Codable {
    let sources: [ResearchSource]
}

final class ResearchService {
    static let shared = ResearchService()
    private var registry: ResearchRegistry = ResearchRegistry(sources: [])

    private init() {
        registry = loadBundled()
    }

    func resolve(ids: [String]?) -> [ResearchSource] {
        guard let ids, !ids.isEmpty else { return [] }
        return ids.compactMap { id in registry.sources.first { $0.id == id } }
    }

    private func loadBundled() -> ResearchRegistry {
        guard let url = Bundle.main.url(forResource: "sources", withExtension: "json") else {
            return ResearchRegistry(sources: [])
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(ResearchRegistry.self, from: data)
        } catch {
            print("ResearchService load error: \(error)")
            return ResearchRegistry(sources: [])
        }
    }
}

