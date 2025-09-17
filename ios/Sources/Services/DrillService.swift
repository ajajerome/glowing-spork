import Foundation

final class DrillService {
    static let shared = DrillService()
    private var catalog: DrillCatalog = DrillCatalog(drills: [])

    private init() {
        catalog = loadBundled()
    }

    func drills(for ageBand: AgeBand?) -> [DrillDefinition] {
        guard let ageBand else { return catalog.drills }
        return catalog.drills.filter { $0.ageBands.contains(ageBand) }
    }

    func byId(_ id: String) -> DrillDefinition? {
        return catalog.drills.first { $0.id == id }
    }

    private func loadBundled() -> DrillCatalog {
        guard let url = Bundle.main.url(forResource: "drills", withExtension: "json") else {
            return DrillCatalog(drills: [])
        }
        do {
            let data = try Data(contentsOf: url)
            let dec = JSONDecoder()
            dec.keyDecodingStrategy = .useDefaultKeys
            return try dec.decode(DrillCatalog.self, from: data)
        } catch {
            print("DrillService load error: \(error)")
            return DrillCatalog(drills: [])
        }
    }
}

