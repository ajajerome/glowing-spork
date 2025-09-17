import Foundation

final class ProgressStore: ObservableObject {
    static let shared = ProgressStore()
    @Published private(set) var sessions: [DrillSessionTelemetry] = []
    private let key = "progress.sessions.v1"

    private init() {
        if let data = UserDefaults.standard.data(forKey: key), let decoded = try? JSONDecoder().decode([DrillSessionTelemetry].self, from: data) {
            sessions = decoded
        }
    }

    func add(_ session: DrillSessionTelemetry) {
        var s = session
        s = s.finalized()
        sessions.append(s)
        persist()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

