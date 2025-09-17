import Foundation

struct DrillSessionTelemetry: Codable, Identifiable, Equatable {
    let id: UUID
    var drillId: String?
    var ageBand: AgeBand?
    var startAt: Date?
    var endAt: Date?
    var durationSec: Double?
    var score: Int
    var conesCollected: Int
    var scansCount: Int
    var touchesMovedCount: Int

    init(id: UUID = UUID(), drillId: String? = nil, ageBand: AgeBand? = nil) {
        self.id = id
        self.drillId = drillId
        self.ageBand = ageBand
        self.startAt = nil
        self.endAt = nil
        self.durationSec = nil
        self.score = 0
        self.conesCollected = 0
        self.scansCount = 0
        self.touchesMovedCount = 0
    }

    func finalized() -> DrillSessionTelemetry {
        var copy = self
        if let s = startAt, let e = endAt { copy.durationSec = e.timeIntervalSince(s) }
        return copy
    }
}

