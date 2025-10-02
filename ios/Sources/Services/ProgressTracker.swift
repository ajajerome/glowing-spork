import Foundation
import SwiftUI

final class ProgressTracker: ObservableObject {
    static let shared = ProgressTracker()
    
    @Published var weeklyProgress: WeeklyProgress
    @Published var monthlyGoals: [MonthlyGoal] = []
    @Published var achievements: [Achievement] = []
    @Published var learningPath: LearningPath
    @Published var skillTrends: [SkillTrend] = []
    
    private let progressKey = "spelsmart.progress_tracker.v1"
    
    private init() {
        weeklyProgress = WeeklyProgress()
        learningPath = LearningPath()
        loadProgress()
        generateMonthlyGoals()
        updateSkillTrends()
    }
    
    func recordSession(_ session: DrillSessionTelemetry, decisions: [DecisionOption]) {
        // Update weekly progress
        weeklyProgress.addSession(session, decisions: decisions)
        
        // Update learning path
        learningPath.processSession(session, decisions: decisions)
        
        // Check for new achievements
        checkForAchievements(session, decisions)
        
        // Update skill trends
        updateSkillTrends()
        
        persist()
    }
    
    func getWeeklyInsights() -> WeeklyInsights {
        return WeeklyInsights(
            totalSessions: weeklyProgress.sessions.count,
            averageScore: weeklyProgress.averageScore,
            strongestSkill: weeklyProgress.strongestSkill,
            improvementArea: weeklyProgress.weakestSkill,
            consistencyScore: weeklyProgress.consistencyScore,
            weekOverWeekGrowth: calculateWeekOverWeekGrowth()
        )
    }
    
    func getPersonalizedRecommendations() -> [PersonalizedRecommendation] {
        var recommendations: [PersonalizedRecommendation] = []
        
        // Based on skill trends
        for trend in skillTrends {
            if trend.isDecreasing && trend.skill.isCore {
                recommendations.append(PersonalizedRecommendation(
                    type: .skillFocus,
                    title: "Fokusera på \(trend.skill.displayName)",
                    description: "Din \(trend.skill.displayName) har minskat med \(Int(trend.changePercent))% denna vecka",
                    priority: .high,
                    actionItems: getActionItems(for: trend.skill)
                ))
            }
        }
        
        // Based on learning path
        if let nextMilestone = learningPath.nextMilestone {
            recommendations.append(PersonalizedRecommendation(
                type: .milestone,
                title: "Nästa mål: \(nextMilestone.title)",
                description: nextMilestone.description,
                priority: .medium,
                actionItems: nextMilestone.actionItems
            ))
        }
        
        // Based on weekly performance
        let insights = getWeeklyInsights()
        if insights.consistencyScore < 0.6 {
            recommendations.append(PersonalizedRecommendation(
                type: .consistency,
                title: "Förbättra konsistens",
                description: "Träna lite varje dag för bättre resultat",
                priority: .medium,
                actionItems: ["Sätt upp dagliga påminnelser", "Starta med 10 min/dag", "Använd streak-systemet"]
            ))
        }
        
        return recommendations.sorted { $0.priority.rawValue > $1.priority.rawValue }
    }
    
    private func checkForAchievements(_ session: DrillSessionTelemetry, _ decisions: [DecisionOption]) {
        // Check for session-based achievements
        if session.score >= 10 {
            unlockAchievement(.perfectSession)
        }
        
        if decisions.allSatisfy({ $0.outcome.success == .excellent }) {
            unlockAchievement(.flawlessDecisions)
        }
        
        // Check for streak achievements
        if weeklyProgress.currentStreak >= 7 {
            unlockAchievement(.weekStreak)
        }
        
        if weeklyProgress.currentStreak >= 30 {
            unlockAchievement(.monthStreak)
        }
    }
    
    private func unlockAchievement(_ type: AchievementType) {
        guard !achievements.contains(where: { $0.type == type }) else { return }
        
        let achievement = Achievement(
            type: type,
            unlockedAt: Date(),
            title: type.title,
            description: type.description,
            icon: type.icon,
            xpReward: type.xpReward
        )
        
        achievements.append(achievement)
        
        // Award XP
        GameProgressStore.shared.addXP(achievement.xpReward)
        
        // Trigger celebration
        NotificationCenter.default.post(name: .achievementUnlocked, object: achievement)
    }
    
    private func generateMonthlyGoals() {
        let currentMonth = Calendar.current.component(.month, from: Date())
        
        monthlyGoals = [
            MonthlyGoal(
                id: "sessions_\(currentMonth)",
                title: "Månadsutmaning",
                description: "Genomför 20 träningspass denna månad",
                targetValue: 20,
                currentValue: weeklyProgress.sessions.count,
                category: .volume,
                reward: "Exklusiv 'Månadshjälte' badge"
            ),
            MonthlyGoal(
                id: "excellence_\(currentMonth)",
                title: "Excellens-mål",
                description: "Få 50 'Utmärkt' bedömningar",
                targetValue: 50,
                currentValue: weeklyProgress.excellentDecisions,
                category: .quality,
                reward: "Taktisk Mästare titel"
            ),
            MonthlyGoal(
                id: "skills_\(currentMonth)",
                title: "Allround utveckling",
                description: "Nå nivå 3 i alla färdigheter",
                targetValue: 8,
                currentValue: countSkillsAtLevel(3),
                category: .skills,
                reward: "Komplett Spelare badge"
            )
        ]
    }
    
    private func updateSkillTrends() {
        let progress = GameProgressStore.shared.progress
        
        skillTrends = TacticalSkill.allCases.map { skill in
            let currentLevel = progress.skillLevel(for: skill)
            let weekAgoLevel = getSkillLevelWeekAgo(skill) // Would need historical data
            let change = Double(currentLevel - weekAgoLevel)
            let changePercent = weekAgoLevel > 0 ? (change / Double(weekAgoLevel)) * 100 : 0
            
            return SkillTrend(
                skill: skill,
                currentLevel: currentLevel,
                previousLevel: weekAgoLevel,
                changePercent: changePercent,
                isImproving: change > 0,
                isDecreasing: change < 0
            )
        }
    }
    
    private func calculateWeekOverWeekGrowth() -> Double {
        // Simplified calculation - would need historical data
        return Double.random(in: -10...25) // Placeholder
    }
    
    private func getActionItems(for skill: TacticalSkill) -> [String] {
        switch skill {
        case .vision:
            return ["Träna scanning-scenarier", "Fokusera på spelöverskåd", "Använd 'Scan'-knappen oftare"]
        case .positioning:
            return ["Studera positioneringsscenarier", "Träna rumsuppfattning", "Analysera professionella matcher"]
        case .timing:
            return ["Träna timing-övningar", "Fokusera på när du agerar", "Studera matchrytm"]
        case .communication:
            return ["Träna kommunikationsscenarier", "Öva på att dirigera", "Studera lagkommunikation"]
        case .decisionMaking:
            return ["Träna beslutsscenarier", "Analysera dina val", "Studera olika alternativ"]
        case .spatialAwareness:
            return ["Träna rumsuppfattning", "Studera spelplanen", "Fokusera på avstånd och ytor"]
        case .pressureHandling:
            return ["Träna under tidspress", "Öva på att behålla lugnet", "Studera stresshantering"]
        case .teamwork:
            return ["Träna lagarbete", "Fokusera på medspelare", "Studera kollektiva rörelser"]
        }
    }
    
    private func countSkillsAtLevel(_ level: Int) -> Int {
        let progress = GameProgressStore.shared.progress
        return TacticalSkill.allCases.count { skill in
            progress.skillLevel(for: skill) >= level
        }
    }
    
    private func getSkillLevelWeekAgo(_ skill: TacticalSkill) -> Int {
        // Placeholder - would need historical data storage
        let currentLevel = GameProgressStore.shared.progress.skillLevel(for: skill)
        return max(1, currentLevel - Int.random(in: 0...2))
    }
    
    private func loadProgress() {
        if let data = UserDefaults.standard.data(forKey: progressKey),
           let decoded = try? JSONDecoder().decode(ProgressTrackerData.self, from: data) {
            weeklyProgress = decoded.weeklyProgress
            achievements = decoded.achievements
            learningPath = decoded.learningPath
        }
    }
    
    private func persist() {
        let data = ProgressTrackerData(
            weeklyProgress: weeklyProgress,
            achievements: achievements,
            learningPath: learningPath
        )
        
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: progressKey)
        }
    }
}

// MARK: - Data Models

struct WeeklyProgress: Codable {
    var sessions: [SessionSummary] = []
    var totalXP: Int = 0
    var excellentDecisions: Int = 0
    var currentStreak: Int = 0
    var skillProgress: [TacticalSkill: Int] = [:]
    
    var averageScore: Double {
        guard !sessions.isEmpty else { return 0 }
        return sessions.map(\.score).reduce(0, +) / Double(sessions.count)
    }
    
    var strongestSkill: TacticalSkill? {
        skillProgress.max(by: { $0.value < $1.value })?.key
    }
    
    var weakestSkill: TacticalSkill? {
        skillProgress.min(by: { $0.value < $1.value })?.key
    }
    
    var consistencyScore: Double {
        guard sessions.count >= 3 else { return 0 }
        let scores = sessions.map(\.score)
        let average = scores.reduce(0, +) / Double(scores.count)
        let variance = scores.map { pow($0 - average, 2) }.reduce(0, +) / Double(scores.count)
        return max(0, 1 - (variance / 100)) // Normalized consistency score
    }
    
    mutating func addSession(_ session: DrillSessionTelemetry, decisions: [DecisionOption]) {
        let summary = SessionSummary(
            date: session.startAt ?? Date(),
            score: Double(session.score),
            duration: session.durationSec ?? 0,
            excellentCount: decisions.count { $0.outcome.success == .excellent }
        )
        
        sessions.append(summary)
        excellentDecisions += summary.excellentCount
        
        // Update skill progress
        for decision in decisions {
            for skill in decision.skillsUsed {
                skillProgress[skill, default: 0] += decision.xpReward
            }
        }
        
        // Keep only last 7 days
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        sessions = sessions.filter { $0.date >= weekAgo }
    }
}

struct SessionSummary: Codable, Identifiable {
    let id = UUID()
    let date: Date
    let score: Double
    let duration: TimeInterval
    let excellentCount: Int
}

struct WeeklyInsights {
    let totalSessions: Int
    let averageScore: Double
    let strongestSkill: TacticalSkill?
    let improvementArea: TacticalSkill?
    let consistencyScore: Double
    let weekOverWeekGrowth: Double
}

struct PersonalizedRecommendation: Identifiable {
    let id = UUID()
    let type: RecommendationType
    let title: String
    let description: String
    let priority: RecommendationPriority
    let actionItems: [String]
}

enum RecommendationType {
    case skillFocus
    case milestone
    case consistency
    case challenge
}

struct MonthlyGoal: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let targetValue: Int
    let currentValue: Int
    let category: GoalCategory
    let reward: String
    
    var progress: Double {
        guard targetValue > 0 else { return 0 }
        return min(1.0, Double(currentValue) / Double(targetValue))
    }
    
    var isCompleted: Bool {
        currentValue >= targetValue
    }
}

enum GoalCategory: String, Codable, CaseIterable {
    case volume = "Volym"
    case quality = "Kvalitet"
    case skills = "Färdigheter"
    case consistency = "Konsistens"
}

struct Achievement: Identifiable, Codable {
    let id = UUID()
    let type: AchievementType
    let unlockedAt: Date
    let title: String
    let description: String
    let icon: String
    let xpReward: Int
}

enum AchievementType: String, Codable, CaseIterable {
    case perfectSession = "perfect_session"
    case flawlessDecisions = "flawless_decisions"
    case weekStreak = "week_streak"
    case monthStreak = "month_streak"
    case skillMaster = "skill_master"
    case tacticalGenius = "tactical_genius"
    
    var title: String {
        switch self {
        case .perfectSession: return "Perfekt Pass"
        case .flawlessDecisions: return "Felfri Taktiker"
        case .weekStreak: return "Veckokriget"
        case .monthStreak: return "Månadshjälte"
        case .skillMaster: return "Färdighetsmästare"
        case .tacticalGenius: return "Taktisk Genius"
        }
    }
    
    var description: String {
        switch self {
        case .perfectSession: return "Få 10+ poäng i ett träningspass"
        case .flawlessDecisions: return "Alla beslut bedömda som 'Utmärkt'"
        case .weekStreak: return "Träna 7 dagar i rad"
        case .monthStreak: return "Träna 30 dagar i rad"
        case .skillMaster: return "Nå nivå 5 i en färdighet"
        case .tacticalGenius: return "Nå nivå 5 i alla färdigheter"
        }
    }
    
    var icon: String {
        switch self {
        case .perfectSession: return "🎯"
        case .flawlessDecisions: return "💎"
        case .weekStreak: return "🔥"
        case .monthStreak: return "👑"
        case .skillMaster: return "⭐"
        case .tacticalGenius: return "🧠"
        }
    }
    
    var xpReward: Int {
        switch self {
        case .perfectSession: return 50
        case .flawlessDecisions: return 75
        case .weekStreak: return 100
        case .monthStreak: return 500
        case .skillMaster: return 200
        case .tacticalGenius: return 1000
        }
    }
}

struct LearningPath: Codable {
    var currentPhase: LearningPhase = .beginner
    var completedMilestones: [String] = []
    var nextMilestone: Milestone?
    
    mutating func processSession(_ session: DrillSessionTelemetry, decisions: [DecisionOption]) {
        // Update learning path based on performance
        let averageOutcome = decisions.map { $0.outcome.success.rawValue }.reduce("", +)
        
        // Simple progression logic
        if decisions.count { $0.outcome.success == .excellent } >= 3 {
            advanceIfReady()
        }
    }
    
    private mutating func advanceIfReady() {
        switch currentPhase {
        case .beginner:
            if completedMilestones.count >= 3 {
                currentPhase = .intermediate
                nextMilestone = Milestone.intermediateGoals.first
            }
        case .intermediate:
            if completedMilestones.count >= 8 {
                currentPhase = .advanced
                nextMilestone = Milestone.advancedGoals.first
            }
        case .advanced:
            if completedMilestones.count >= 15 {
                currentPhase = .expert
                nextMilestone = nil
            }
        case .expert:
            break
        }
    }
}

enum LearningPhase: String, Codable, CaseIterable {
    case beginner = "Nybörjare"
    case intermediate = "Medel"
    case advanced = "Avancerad"
    case expert = "Expert"
}

struct Milestone: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let actionItems: [String]
    let phase: LearningPhase
    
    static let beginnerGoals = [
        Milestone(id: "basic_scanning", title: "Grundläggande Scanning", description: "Lär dig att scanna före varje beslut", actionItems: ["Använd scanning i 10 scenarier", "Fokusera på spelöverskåd"], phase: .beginner),
        Milestone(id: "position_awareness", title: "Positionsmedvetenhet", description: "Förstå grundläggande positionering", actionItems: ["Träna positioneringsscenarier", "Studera spelplanen"], phase: .beginner)
    ]
    
    static let intermediateGoals = [
        Milestone(id: "tactical_decisions", title: "Taktiska Beslut", description: "Fatta smarta beslut under press", actionItems: ["Träna beslutsscenarier", "Analysera olika alternativ"], phase: .intermediate)
    ]
    
    static let advancedGoals = [
        Milestone(id: "game_reading", title: "Spelläsning", description: "Läs spelet som en professionell", actionItems: ["Analysera komplexa scenarier", "Förutse motståndares drag"], phase: .advanced)
    ]
}

struct SkillTrend: Identifiable {
    let id = UUID()
    let skill: TacticalSkill
    let currentLevel: Int
    let previousLevel: Int
    let changePercent: Double
    let isImproving: Bool
    let isDecreasing: Bool
}

extension TacticalSkill {
    var isCore: Bool {
        switch self {
        case .vision, .positioning, .decisionMaking: return true
        default: return false
        }
    }
    
    var displayName: String {
        switch self {
        case .vision: return "Spelöverskåd"
        case .positioning: return "Positionering"
        case .timing: return "Timing"
        case .communication: return "Kommunikation"
        case .decisionMaking: return "Beslutsfattande"
        case .spatialAwareness: return "Rumsuppfattning"
        case .pressureHandling: return "Presshantering"
        case .teamwork: return "Lagarbete"
        }
    }
}

struct ProgressTrackerData: Codable {
    let weeklyProgress: WeeklyProgress
    let achievements: [Achievement]
    let learningPath: LearningPath
}

// MARK: - Notifications

extension Notification.Name {
    static let achievementUnlocked = Notification.Name("achievementUnlocked")
    static let milestoneReached = Notification.Name("milestoneReached")
    static let weeklyInsightsReady = Notification.Name("weeklyInsightsReady")
}