import Foundation

// MARK: - Core Models

struct GameScenario: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let description: String
    let ageBand: AgeBand
    let situation: MatchSituation
    let gameState: GameState
    let decisions: [DecisionOption]
    let learningObjectives: [String]
    let difficulty: Int // 1-5
    let tags: [String]
}

struct MatchSituation: Codable, Equatable {
    let context: SituationContext
    let ballPosition: Position
    let playerWithBall: PlayerRole
    let teammates: [PlayerPosition]
    let opponents: [PlayerPosition]
    let timeRemaining: Int? // seconds
    let score: GameScore?
}

enum SituationContext: String, Codable, CaseIterable {
    case attack = "anfall"
    case defence = "försvar"
    case transition = "omställning"
    case setpiece = "fasta_situationer"
    case counterAttack = "kontring"
    case buildUp = "uppspel"
}

struct Position: Codable, Equatable {
    let x: Double // 0-100 (% of field width)
    let y: Double // 0-100 (% of field length)
    
    init(x: Double, y: Double) {
        self.x = max(0, min(100, x))
        self.y = max(0, min(100, y))
    }
}

struct PlayerPosition: Codable, Identifiable, Equatable {
    let id: String
    let role: PlayerRole
    let position: Position
    let isMoving: Bool
    let movementDirection: MovementDirection?
}

enum PlayerRole: String, Codable, CaseIterable {
    case goalkeeper = "målvakt"
    case defender = "försvarare"
    case midfielder = "mittfältare"
    case forward = "anfallare"
    case you = "du"
}

enum MovementDirection: String, Codable, CaseIterable {
    case forward = "framåt"
    case backward = "bakåt"
    case left = "vänster"
    case right = "höger"
    case diagonal = "diagonalt"
}

struct GameState: Codable, Equatable {
    let phase: GamePhase
    let intensity: GameIntensity
    let formation: Formation?
    let possession: TeamSide
}

enum GamePhase: String, Codable, CaseIterable {
    case earlyGame = "tidigt_i_matchen"
    case midGame = "mitten_av_matchen"
    case lateGame = "sent_i_matchen"
    case extraTime = "förlängning"
}

enum GameIntensity: String, Codable, CaseIterable {
    case low = "låg"
    case medium = "medium"
    case high = "hög"
    case critical = "kritisk"
}

enum Formation: String, Codable, CaseIterable {
    case fourFourTwo = "4-4-2"
    case fourThreeThree = "4-3-3"
    case threeFiveTwo = "3-5-2"
    case fourTwoThreeOne = "4-2-3-1"
}

enum TeamSide: String, Codable, CaseIterable {
    case home = "hemma"
    case away = "borta"
    case neutral = "neutral"
}

struct GameScore: Codable, Equatable {
    let home: Int
    let away: Int
    let yourTeamIsHome: Bool
}

// MARK: - Decision System

struct DecisionOption: Codable, Identifiable, Equatable {
    let id: String
    let action: TacticalAction
    let description: String
    let reasoning: String
    let outcome: DecisionOutcome
    let skillsUsed: [TacticalSkill]
    let xpReward: Int
}

enum TacticalAction: String, Codable, CaseIterable {
    case pass = "passa"
    case dribble = "dribbla"
    case shoot = "skjuta"
    case cross = "slå_inspel"
    case defend = "försvara"
    case press = "pressa"
    case support = "stötta"
    case move = "flytta_sig"
    case communicate = "kommunicera"
    case scan = "scanna"
}

enum TacticalSkill: String, Codable, CaseIterable {
    case vision = "spelöverskåd"
    case positioning = "positionering"
    case timing = "timing"
    case communication = "kommunikation"
    case decisionMaking = "beslutsfattande"
    case spatialAwareness = "rumsuppfattning"
    case pressureHandling = "presshantering"
    case teamwork = "lagarbete"
}

struct DecisionOutcome: Codable, Equatable {
    let success: OutcomeType
    let feedback: String
    let consequence: String?
    let nextScenario: String? // ID of follow-up scenario
    let skillDevelopment: [TacticalSkill: Int] // XP gained per skill
}

enum OutcomeType: String, Codable, CaseIterable {
    case excellent = "utmärkt"
    case good = "bra"
    case okay = "okej"
    case poor = "dåligt"
    case terrible = "mycket_dåligt"
    
    var xpMultiplier: Double {
        switch self {
        case .excellent: return 2.0
        case .good: return 1.5
        case .okay: return 1.0
        case .poor: return 0.5
        case .terrible: return 0.1
        }
    }
    
    var emoji: String {
        switch self {
        case .excellent: return "🌟"
        case .good: return "👍"
        case .okay: return "👌"
        case .poor: return "😕"
        case .terrible: return "😞"
        }
    }
}

// MARK: - Scenario Collections

struct ScenarioLibrary: Codable {
    let scenarios: [GameScenario]
    let collections: [ScenarioCollection]
}

struct ScenarioCollection: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let description: String
    let scenarioIds: [String]
    let ageBand: AgeBand
    let difficulty: Int
    let theme: CollectionTheme
}

enum CollectionTheme: String, Codable, CaseIterable {
    case attacking = "anfallsspel"
    case defending = "försvarsspel"
    case transition = "omställningar"
    case setpieces = "fasta_situationer"
    case positioning = "positionering"
    case teamwork = "lagarbete"
    case decisionMaking = "beslutsfattande"
}