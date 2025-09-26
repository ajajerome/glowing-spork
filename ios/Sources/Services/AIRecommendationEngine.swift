import Foundation

protocol RecommendationEngine {
    func recommendDrills(for avatar: Avatar, progressHistory: [DrillSessionTelemetry]) -> [DrillRecommendation]
    func adaptDifficulty(for drill: DrillDefinition, based on: [DrillSessionTelemetry]) -> DifficultyAdaptation
    func generateFeedback(for session: DrillSessionTelemetry) -> TrainingFeedback
}

struct DrillRecommendation: Identifiable, Equatable {
    let id = UUID()
    let drill: DrillDefinition
    let reason: String
    let priority: RecommendationPriority
    let adaptedSettings: DifficultyAdaptation?
}

enum RecommendationPriority: Int, CaseIterable {
    case high = 3
    case medium = 2
    case low = 1
    
    var description: String {
        switch self {
        case .high: return "Prioritet: Hög"
        case .medium: return "Prioritet: Medium"
        case .low: return "Prioritet: Låg"
        }
    }
}

struct DifficultyAdaptation: Equatable {
    let timeAdjustment: Double // Multiplier for time limit (0.5 = half time, 2.0 = double time)
    let coneAdjustment: Int // Additional cones (+/-)
    let reason: String
}

struct TrainingFeedback: Identifiable, Equatable {
    let id = UUID()
    let overallRating: FeedbackRating
    let strengths: [String]
    let areasForImprovement: [String]
    let specificTips: [String]
    let nextSteps: String
}

enum FeedbackRating: String, CaseIterable {
    case excellent = "Utmärkt!"
    case good = "Bra jobbat!"
    case needsWork = "Fortsätt träna!"
    case beginner = "Bra början!"
}

final class AIRecommendationEngine: RecommendationEngine {
    static let shared = AIRecommendationEngine()
    
    private init() {}
    
    func recommendDrills(for avatar: Avatar, progressHistory: [DrillSessionTelemetry]) -> [DrillRecommendation] {
        let availableDrills = DrillService.shared.drills(for: avatar.ageBand)
        var recommendations: [DrillRecommendation] = []
        
        // Analyze recent performance
        let recentSessions = Array(progressHistory.suffix(10))
        let averageScore = recentSessions.isEmpty ? 0 : recentSessions.map(\.score).reduce(0, +) / recentSessions.count
        
        // Get drills by domain performance
        let domainPerformance = analyzeDomainPerformance(recentSessions)
        
        for drill in availableDrills {
            let priority = calculatePriority(for: drill, avatar: avatar, domainPerformance: domainPerformance, averageScore: averageScore)
            let reason = generateRecommendationReason(for: drill, priority: priority, domainPerformance: domainPerformance)
            let adaptation = adaptDifficulty(for: drill, based: recentSessions)
            
            if priority != .low || recommendations.count < 3 {
                recommendations.append(DrillRecommendation(
                    drill: drill,
                    reason: reason,
                    priority: priority,
                    adaptedSettings: adaptation
                ))
            }
        }
        
        return recommendations.sorted { $0.priority.rawValue > $1.priority.rawValue }
    }
    
    func adaptDifficulty(for drill: DrillDefinition, based sessions: [DrillSessionTelemetry]) -> DifficultyAdaptation {
        let drillSessions = sessions.filter { $0.drillId == drill.id }
        
        guard !drillSessions.isEmpty else {
            return DifficultyAdaptation(timeAdjustment: 1.0, coneAdjustment: 0, reason: "Första gången - standardinställningar")
        }
        
        let averageScore = drillSessions.map(\.score).reduce(0, +) / drillSessions.count
        let successRate = Double(averageScore) / Double(max(drill.conesCount, 1))
        
        if successRate > 0.8 {
            // Too easy - make harder
            return DifficultyAdaptation(
                timeAdjustment: 0.8,
                coneAdjustment: 2,
                reason: "Höjer svårighetsgraden - du klarar detta bra!"
            )
        } else if successRate < 0.3 {
            // Too hard - make easier
            return DifficultyAdaptation(
                timeAdjustment: 1.3,
                coneAdjustment: -1,
                reason: "Sänker svårighetsgraden för bättre inlärning"
            )
        } else {
            // Just right
            return DifficultyAdaptation(
                timeAdjustment: 1.0,
                coneAdjustment: 0,
                reason: "Perfekt svårighetsgrad för din utveckling"
            )
        }
    }
    
    func generateFeedback(for session: DrillSessionTelemetry) -> TrainingFeedback {
        var strengths: [String] = []
        var improvements: [String] = []
        var tips: [String] = []
        
        // Analyze performance metrics
        if session.scansCount > 3 {
            strengths.append("Bra användning av scanning")
        } else if session.scansCount < 2 {
            improvements.append("Använd scanning mer frekvent")
            tips.append("Tryck på 'Scan'-knappen innan du rör bollen")
        }
        
        if session.conesCollected >= 3 {
            strengths.append("Effektiv konsamling")
        } else {
            improvements.append("Fokusera på precision vid konträff")
            tips.append("Sikta på konernas mitt för bästa resultat")
        }
        
        let rating: FeedbackRating
        if session.score >= 8 {
            rating = .excellent
        } else if session.score >= 5 {
            rating = .good
        } else if session.score >= 2 {
            rating = .needsWork
        } else {
            rating = .beginner
        }
        
        let nextSteps = generateNextSteps(for: session, strengths: strengths, improvements: improvements)
        
        return TrainingFeedback(
            overallRating: rating,
            strengths: strengths,
            areasForImprovement: improvements,
            specificTips: tips,
            nextSteps: nextSteps
        )
    }
    
    // MARK: - Private Helper Methods
    
    private func analyzeDomainPerformance(_ sessions: [DrillSessionTelemetry]) -> [String: Double] {
        var domainScores: [String: [Int]] = [:]
        
        for session in sessions {
            guard let drillId = session.drillId,
                  let drill = DrillService.shared.byId(drillId) else { continue }
            
            if domainScores[drill.domain] == nil {
                domainScores[drill.domain] = []
            }
            domainScores[drill.domain]?.append(session.score)
        }
        
        return domainScores.mapValues { scores in
            scores.isEmpty ? 0.0 : Double(scores.reduce(0, +)) / Double(scores.count)
        }
    }
    
    private func calculatePriority(for drill: DrillDefinition, avatar: Avatar, domainPerformance: [String: Double], averageScore: Int) -> RecommendationPriority {
        // Priority based on position preference
        let positionBonus = drill.skillTags.contains { tag in
            switch avatar.favoritePosition {
            case .goalkeeper: return tag.contains("målvakt")
            case .defender: return tag.contains("försvar") || tag.contains("press")
            case .midfielder: return tag.contains("pass") || tag.contains("scanning")
            case .forward: return tag.contains("mål") || tag.contains("anfall")
            }
        }
        
        // Priority based on weak domains
        let domainScore = domainPerformance[drill.domain] ?? 0.0
        let needsWork = domainScore < Double(averageScore) * 0.8
        
        if positionBonus && needsWork {
            return .high
        } else if positionBonus || needsWork {
            return .medium
        } else {
            return .low
        }
    }
    
    private func generateRecommendationReason(for drill: DrillDefinition, priority: RecommendationPriority, domainPerformance: [String: Double]) -> String {
        switch priority {
        case .high:
            return "Passar din position och utvecklingsområde"
        case .medium:
            return "Bra för din övergripande utveckling"
        case .low:
            return "Variationsträning för allround förmåga"
        }
    }
    
    private func generateNextSteps(for session: DrillSessionTelemetry, strengths: [String], improvements: [String]) -> String {
        if improvements.isEmpty {
            return "Fortsätt med mer avancerade övningar för att utmana dig själv"
        } else {
            return "Fokusera på \(improvements.first ?? "grundtekniker") i nästa träningspass"
        }
    }
}