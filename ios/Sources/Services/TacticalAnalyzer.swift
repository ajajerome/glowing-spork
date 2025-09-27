import Foundation

final class TacticalAnalyzer {
    static let shared = TacticalAnalyzer()
    
    private init() {}
    
    func analyzeDecision(_ decision: DecisionOption, in scenario: GameScenario, playerProgress: PlayerProgress) -> DetailedFeedback {
        let contextAnalysis = analyzeContext(scenario.situation.context, decision: decision)
        let skillAnalysis = analyzeSkillUsage(decision.skillsUsed, playerProgress: playerProgress)
        let tacticalAnalysis = analyzeTacticalSoundness(decision, in: scenario)
        
        return DetailedFeedback(
            contextAnalysis: contextAnalysis,
            skillAnalysis: skillAnalysis,
            tacticalAnalysis: tacticalAnalysis,
            overallRating: decision.outcome.success,
            improvementTips: generateImprovementTips(decision, scenario, playerProgress),
            nextLevelAdvice: generateNextLevelAdvice(playerProgress)
        )
    }
    
    func generateMatchReport(session: [DecisionOption], scenarios: [GameScenario]) -> MatchReport {
        let strengths = identifyStrengths(from: session)
        let weaknesses = identifyWeaknesses(from: session)
        let keyMoments = identifyKeyMoments(session, scenarios)
        let developmentAreas = suggestDevelopmentAreas(from: session)
        
        return MatchReport(
            overallPerformance: calculateOverallPerformance(session),
            strengths: strengths,
            weaknesses: weaknesses,
            keyMoments: keyMoments,
            developmentAreas: developmentAreas,
            nextSessionFocus: determineNextSessionFocus(weaknesses, developmentAreas)
        )
    }
    
    // MARK: - Analysis Methods
    
    private func analyzeContext(_ context: SituationContext, decision: DecisionOption) -> ContextAnalysis {
        let appropriateActions = getAppropriateActions(for: context)
        let isContextAppropriate = appropriateActions.contains(decision.action)
        
        return ContextAnalysis(
            context: context,
            isAppropriate: isContextAppropriate,
            explanation: getContextExplanation(context, action: decision.action, isAppropriate: isContextAppropriate)
        )
    }
    
    private func analyzeSkillUsage(_ skills: [TacticalSkill], playerProgress: PlayerProgress) -> SkillAnalysis {
        var skillAssessment: [TacticalSkill: SkillAssessment] = [:]
        
        for skill in skills {
            let currentLevel = playerProgress.skillLevel(for: skill)
            let isStrength = currentLevel >= 3
            let needsDevelopment = currentLevel <= 2
            
            skillAssessment[skill] = SkillAssessment(
                currentLevel: currentLevel,
                isStrength: isStrength,
                needsDevelopment: needsDevelopment,
                advice: getSkillAdvice(skill, level: currentLevel)
            )
        }
        
        return SkillAnalysis(skillAssessment: skillAssessment)
    }
    
    private func analyzeTacticalSoundness(_ decision: DecisionOption, in scenario: GameScenario) -> TacticalAnalysis {
        let riskLevel = assessRiskLevel(decision, scenario)
        let rewardPotential = assessRewardPotential(decision, scenario)
        let timingAppropriate = assessTiming(decision, scenario)
        
        return TacticalAnalysis(
            riskLevel: riskLevel,
            rewardPotential: rewardPotential,
            timingAppropriate: timingAppropriate,
            tacticalReasoning: generateTacticalReasoning(decision, scenario, riskLevel, rewardPotential)
        )
    }
    
    // MARK: - Helper Methods
    
    private func getAppropriateActions(for context: SituationContext) -> [TacticalAction] {
        switch context {
        case .attack:
            return [.pass, .dribble, .shoot, .cross, .scan, .move]
        case .defence:
            return [.defend, .press, .communicate, .move]
        case .transition:
            return [.pass, .dribble, .move, .scan]
        case .buildUp:
            return [.pass, .support, .move, .communicate]
        case .counterAttack:
            return [.pass, .dribble, .move, .scan]
        case .setpiece:
            return [.pass, .move, .communicate, .scan]
        }
    }
    
    private func getContextExplanation(_ context: SituationContext, action: TacticalAction, isAppropriate: Bool) -> String {
        if isAppropriate {
            switch context {
            case .attack:
                return "Bra val för anfallssituation - fokusera på att skapa chanser!"
            case .defence:
                return "Perfekt för försvarsspel - säkerhet och organisation först!"
            case .transition:
                return "Utmärkt för omställning - snabbhet och precision!"
            default:
                return "Lämpligt val för situationen!"
            }
        } else {
            switch context {
            case .attack:
                return "I anfall bör du fokusera mer på kreativa och framåtriktade aktioner."
            case .defence:
                return "I försvar är säkerhet och positionering viktigare än risker."
            case .transition:
                return "I omställningar räknas hastighet och enkla lösningar."
            default:
                return "Tänk på vad situationen kräver av dig."
            }
        }
    }
    
    private func getSkillAdvice(_ skill: TacticalSkill, level: Int) -> String {
        switch skill {
        case .vision:
            if level >= 4 { return "Din spelöverskåd är stark - fortsätt utveckla den!" }
            else { return "Träna mer på scanning och att se hela planen." }
        case .positioning:
            if level >= 4 { return "Utmärkt positionering - du vet var du ska vara!" }
            else { return "Fokusera på att alltid vara på rätt plats vid rätt tid." }
        case .timing:
            if level >= 4 { return "Din timing är spot on!" }
            else { return "Arbeta med att förstå när det är rätt tid att agera." }
        case .communication:
            if level >= 4 { return "Du kommunicerar effektivt med laget!" }
            else { return "Träna på att dirigera och kommunicera med medspelare." }
        case .decisionMaking:
            if level >= 4 { return "Dina beslut är genomtänkta och smarta!" }
            else { return "Övning på beslutsfattande under press kommer hjälpa dig." }
        case .spatialAwareness:
            if level >= 4 { return "Du har utmärkt rumsuppfattning!" }
            else { return "Arbeta med att förstå avstånd och ytor på planen." }
        case .pressureHandling:
            if level >= 4 { return "Du hanterar press som en mästare!" }
            else { return "Träna på att behålla lugnet när det blir intensivt." }
        case .teamwork:
            if level >= 4 { return "Du är en fantastisk lagspelare!" }
            else { return "Fokusera på hur dina handlingar hjälper hela laget." }
        }
    }
    
    private func assessRiskLevel(_ decision: DecisionOption, _ scenario: GameScenario) -> RiskLevel {
        switch decision.action {
        case .dribble, .shoot:
            return .high
        case .pass:
            return scenario.situation.context == .defence ? .medium : .low
        case .defend, .support, .communicate:
            return .low
        default:
            return .medium
        }
    }
    
    private func assessRewardPotential(_ decision: DecisionOption, _ scenario: GameScenario) -> RewardPotential {
        switch decision.outcome.success {
        case .excellent: return .high
        case .good: return .medium
        case .okay: return .low
        case .poor, .terrible: return .none
        }
    }
    
    private func assessTiming(_ decision: DecisionOption, _ scenario: GameScenario) -> Bool {
        // Complex logic would go here in real implementation
        return decision.outcome.success != .terrible
    }
    
    private func generateTacticalReasoning(_ decision: DecisionOption, _ scenario: GameScenario, _ risk: RiskLevel, _ reward: RewardPotential) -> String {
        switch (risk, reward) {
        case (.low, .high):
            return "Perfekt balans mellan säkerhet och belöning!"
        case (.high, .high):
            return "Riskabelt men kan ge stor utdelning - bra i rätt situation!"
        case (.low, .low):
            return "Säkert val som behåller kontrollen."
        case (.high, .low):
            return "Hög risk med låg belöning - tänk om nästa gång!"
        default:
            return "Balanserat beslut med tanke på situationen."
        }
    }
    
    private func generateImprovementTips(_ decision: DecisionOption, _ scenario: GameScenario, _ progress: PlayerProgress) -> [String] {
        var tips: [String] = []
        
        // Add tips based on weak skills
        for skill in decision.skillsUsed {
            if progress.skillLevel(for: skill) <= 2 {
                tips.append(getSkillAdvice(skill, level: progress.skillLevel(for: skill)))
            }
        }
        
        // Add context-specific tips
        switch scenario.situation.context {
        case .attack:
            if !decision.skillsUsed.contains(.vision) {
                tips.append("Använd scanning oftare i anfall för att se alla alternativ.")
            }
        case .defence:
            if !decision.skillsUsed.contains(.communication) {
                tips.append("Kommunikation är nyckeln till bra försvarsspel.")
            }
        default:
            break
        }
        
        return Array(tips.prefix(3)) // Max 3 tips
    }
    
    private func generateNextLevelAdvice(_ progress: PlayerProgress) -> String {
        let weakestSkill = TacticalSkill.allCases.min { skill1, skill2 in
            progress.skillLevel(for: skill1) < progress.skillLevel(for: skill2)
        }
        
        if let skill = weakestSkill {
            return "För att nå nästa nivå, fokusera på att utveckla din \(skill.rawValue)."
        } else {
            return "Fortsätt träna brett för att utveckla alla aspekter av ditt spel!"
        }
    }
    
    // Implementation stubs for complex methods
    private func identifyStrengths(from session: [DecisionOption]) -> [String] { ["Bra spelöverskåd", "Smart beslutsfattande"] }
    private func identifyWeaknesses(from session: [DecisionOption]) -> [String] { ["Kan förbättra timing"] }
    private func identifyKeyMoments(_ session: [DecisionOption], _ scenarios: [GameScenario]) -> [String] { ["Avgörande pass i 23:a minuten"] }
    private func suggestDevelopmentAreas(from session: [DecisionOption]) -> [TacticalSkill] { [.timing, .communication] }
    private func calculateOverallPerformance(_ session: [DecisionOption]) -> OverallPerformance { .good }
    private func determineNextSessionFocus(_ weaknesses: [String], _ areas: [TacticalSkill]) -> String { "Fokusera på timing nästa gång" }
}

// MARK: - Analysis Data Models

struct DetailedFeedback {
    let contextAnalysis: ContextAnalysis
    let skillAnalysis: SkillAnalysis  
    let tacticalAnalysis: TacticalAnalysis
    let overallRating: OutcomeType
    let improvementTips: [String]
    let nextLevelAdvice: String
}

struct ContextAnalysis {
    let context: SituationContext
    let isAppropriate: Bool
    let explanation: String
}

struct SkillAnalysis {
    let skillAssessment: [TacticalSkill: SkillAssessment]
}

struct SkillAssessment {
    let currentLevel: Int
    let isStrength: Bool
    let needsDevelopment: Bool
    let advice: String
}

struct TacticalAnalysis {
    let riskLevel: RiskLevel
    let rewardPotential: RewardPotential
    let timingAppropriate: Bool
    let tacticalReasoning: String
}

enum RiskLevel: String, CaseIterable {
    case low = "Låg"
    case medium = "Medium" 
    case high = "Hög"
}

enum RewardPotential: String, CaseIterable {
    case none = "Ingen"
    case low = "Låg"
    case medium = "Medium"
    case high = "Hög"
}

struct MatchReport {
    let overallPerformance: OverallPerformance
    let strengths: [String]
    let weaknesses: [String]
    let keyMoments: [String]
    let developmentAreas: [TacticalSkill]
    let nextSessionFocus: String
}

enum OverallPerformance: String, CaseIterable {
    case excellent = "Utmärkt"
    case good = "Bra"
    case average = "Medel"
    case needsWork = "Behöver arbete"
    
    var color: String {
        switch self {
        case .excellent: return "#32CD32"
        case .good: return "#1E90FF"
        case .average: return "#FFD700"
        case .needsWork: return "#FF6347"
        }
    }
    
    var icon: String {
        switch self {
        case .excellent: return "🌟"
        case .good: return "👍"
        case .average: return "👌"
        case .needsWork: return "📈"
        }
    }
}