import Foundation

struct DailyChallenge: Codable, Identifiable, Equatable {
    let id: String
    let date: Date
    let title: String
    let description: String
    let scenario: GameScenario
    let bonusXP: Int
    let specialReward: String?
    let ageBand: AgeBand
    let difficulty: Int
    let isCompleted: Bool
    
    init(date: Date, ageBand: AgeBand) {
        self.id = "daily_\(date.formatted(.iso8601.year().month().day()))"
        self.date = date
        self.ageBand = ageBand
        
        // Generate challenge based on day
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        let challengeType = ChallengeType.allCases[dayOfYear % ChallengeType.allCases.count]
        
        switch challengeType {
        case .masterScanner:
            self.title = "Mäster Skannare"
            self.description = "Använd scanning innan varje beslut idag"
            self.bonusXP = 50
            self.specialReward = "👁 Scanning Specialist Badge"
            self.difficulty = 2
            
        case .tacticalGenius:
            self.title = "Taktisk Genius"
            self.description = "Få minst 2 'Utmärkt' bedömningar"
            self.bonusXP = 75
            self.specialReward = "🧠 Tactical Mind Badge"
            self.difficulty = 3
            
        case .teamPlayer:
            self.title = "Lagspelare"
            self.description = "Fokusera på lagarbete och kommunikation"
            self.bonusXP = 60
            self.specialReward = "🤝 Team Spirit Badge"
            self.difficulty = 2
            
        case .speedyDecisions:
            self.title = "Snabba Beslut"
            self.description = "Fatta beslut snabbt i alla scenarier"
            self.bonusXP = 40
            self.specialReward = nil
            self.difficulty = 1
            
        case .defenseExpert:
            self.title = "Försvarsexpert"
            self.description = "Mästra försvarssituationer idag"
            self.bonusXP = 65
            self.specialReward = "🛡 Defense Master Badge"
            self.difficulty = 3
        }
        
        // Generate scenario for the challenge
        self.scenario = Self.generateChallengeScenario(type: challengeType, ageBand: ageBand)
        self.isCompleted = false
    }
    
    private static func generateChallengeScenario(type: ChallengeType, ageBand: AgeBand) -> GameScenario {
        switch type {
        case .masterScanner:
            return createScanningChallenge(ageBand: ageBand)
        case .tacticalGenius:
            return createComplexTacticalChallenge(ageBand: ageBand)
        case .teamPlayer:
            return createTeamworkChallenge(ageBand: ageBand)
        case .speedyDecisions:
            return createSpeedChallenge(ageBand: ageBand)
        case .defenseExpert:
            return createDefenseChallenge(ageBand: ageBand)
        }
    }
    
    private static func createScanningChallenge(ageBand: AgeBand) -> GameScenario {
        let situation = MatchSituation(
            context: .attack,
            ballPosition: Position(x: 40, y: 50),
            playerWithBall: .you,
            teammates: [
                PlayerPosition(id: "teammate1", role: .midfielder, position: Position(x: 60, y: 30), isMoving: true, movementDirection: .forward),
                PlayerPosition(id: "teammate2", role: .forward, position: Position(x: 80, y: 70), isMoving: false, movementDirection: nil),
                PlayerPosition(id: "teammate3", role: .midfielder, position: Position(x: 30, y: 70), isMoving: true, movementDirection: .right)
            ],
            opponents: [
                PlayerPosition(id: "opponent1", role: .defender, position: Position(x: 55, y: 60), isMoving: false, movementDirection: nil),
                PlayerPosition(id: "opponent2", role: .midfielder, position: Position(x: 45, y: 40), isMoving: true, movementDirection: .left)
            ],
            timeRemaining: nil,
            score: nil
        )
        
        let decisions = [
            DecisionOption(
                id: "scan_first_challenge",
                action: .scan,
                description: "Scanna alla alternativ först (UTMANING!)",
                reasoning: "Samlar fullständig information innan beslut",
                outcome: DecisionOutcome(
                    success: .excellent,
                    feedback: "Perfekt! Du såg alla möjligheter innan du agerade.",
                    consequence: "Du hittar den optimala lösningen",
                    nextScenario: nil,
                    skillDevelopment: [.vision: 5, .spatialAwareness: 3]
                ),
                skillsUsed: [.vision, .spatialAwareness],
                xpReward: 30
            ),
            DecisionOption(
                id: "quick_pass_challenge",
                action: .pass,
                description: "Passa snabbt utan scanning",
                reasoning: "Agerar på instinkt",
                outcome: DecisionOutcome(
                    success: .poor,
                    feedback: "Du missade bättre alternativ. Scanning först nästa gång!",
                    consequence: "Förlorade möjlighet",
                    nextScenario: nil,
                    skillDevelopment: [.decisionMaking: 1]
                ),
                skillsUsed: [.decisionMaking],
                xpReward: 5
            )
        ]
        
        return GameScenario(
            id: "daily_scanning_challenge",
            title: "Daglig Utmaning: Scanning",
            description: "Idag fokuserar vi på scanning. Använd det innan varje beslut!",
            ageBand: ageBand,
            situation: situation,
            gameState: GameState(phase: .midGame, intensity: .medium, formation: .fourFourTwo, possession: .home),
            decisions: decisions,
            learningObjectives: ["Utveckla scanning-vana", "Förbättra spelöverskåd", "Samla information före beslut"],
            difficulty: 2,
            tags: ["daglig_utmaning", "scanning", "vision"]
        )
    }
    
    private static func createComplexTacticalChallenge(ageBand: AgeBand) -> GameScenario {
        // Complex multi-layered scenario
        let situation = MatchSituation(
            context: .transition,
            ballPosition: Position(x: 50, y: 40),
            playerWithBall: .you,
            teammates: [
                PlayerPosition(id: "teammate1", role: .forward, position: Position(x: 75, y: 80), isMoving: true, movementDirection: .diagonal),
                PlayerPosition(id: "teammate2", role: .midfielder, position: Position(x: 35, y: 60), isMoving: true, movementDirection: .forward),
                PlayerPosition(id: "teammate3", role: .defender, position: Position(x: 20, y: 20), isMoving: false, movementDirection: nil)
            ],
            opponents: [
                PlayerPosition(id: "opponent1", role: .defender, position: Position(x: 60, y: 70), isMoving: true, movementDirection: .backward),
                PlayerPosition(id: "opponent2", role: .midfielder, position: Position(x: 55, y: 50), isMoving: true, movementDirection: .left),
                PlayerPosition(id: "opponent3", role: .defender, position: Position(x: 80, y: 60), isMoving: false, movementDirection: nil)
            ],
            timeRemaining: nil,
            score: GameScore(home: 1, away: 1, yourTeamIsHome: true)
        )
        
        let decisions = [
            DecisionOption(
                id: "through_pass_challenge",
                action: .pass,
                description: "Genomskärningspass till anfallaren",
                reasoning: "Utnyttjar försvarslucka perfekt",
                outcome: DecisionOutcome(
                    success: .excellent,
                    feedback: "Fantastisk läsning av spelet! Perfekt genomskärning.",
                    consequence: "Skapar målchans",
                    nextScenario: nil,
                    skillDevelopment: [.vision: 4, .timing: 4, .decisionMaking: 3]
                ),
                skillsUsed: [.vision, .timing, .decisionMaking],
                xpReward: 45
            ),
            DecisionOption(
                id: "safe_pass_challenge",
                action: .pass,
                description: "Säker pass till medspelare",
                reasoning: "Behåller bollinnehav säkert",
                outcome: DecisionOutcome(
                    success: .okay,
                    feedback: "Säkert val, men du missade en fantastisk chans.",
                    consequence: "Behåller bollen men förlorar momentum",
                    nextScenario: nil,
                    skillDevelopment: [.decisionMaking: 1]
                ),
                skillsUsed: [.decisionMaking],
                xpReward: 15
            ),
            DecisionOption(
                id: "dribble_challenge",
                action: .dribble,
                description: "Dribbla förbi närmaste motståndare",
                reasoning: "Tar personligt ansvar",
                outcome: DecisionOutcome(
                    success: .good,
                    feedback: "Modigt! Men ett pass hade varit smartare här.",
                    consequence: "Skapar fart men riskerar bollförlust",
                    nextScenario: nil,
                    skillDevelopment: [.pressureHandling: 2]
                ),
                skillsUsed: [.pressureHandling],
                xpReward: 20
            )
        ]
        
        return GameScenario(
            id: "daily_tactical_challenge",
            title: "Taktisk Mästartest",
            description: "Komplicerad situation - visa din taktiska kunskap!",
            ageBand: ageBand,
            situation: situation,
            gameState: GameState(phase: .lateGame, intensity: .critical, formation: .fourThreeThree, possession: .home),
            decisions: decisions,
            learningObjectives: ["Avancerat taktiskt tänkande", "Läsa komplexa spelsituationer", "Optimala beslut under press"],
            difficulty: 4,
            tags: ["daglig_utmaning", "avancerat", "taktik"]
        )
    }
    
    // Add other challenge creation methods...
    private static func createTeamworkChallenge(ageBand: AgeBand) -> GameScenario {
        return ScenarioGenerator.shared.generateBuildUpScenario(ageBand: ageBand)
    }
    
    private static func createSpeedChallenge(ageBand: AgeBand) -> GameScenario {
        return ScenarioGenerator.shared.generateTransitionScenario(ageBand: ageBand)
    }
    
    private static func createDefenseChallenge(ageBand: AgeBand) -> GameScenario {
        return ScenarioGenerator.shared.generateDefenceScenario(ageBand: ageBand)
    }
}

enum ChallengeType: CaseIterable {
    case masterScanner
    case tacticalGenius  
    case teamPlayer
    case speedyDecisions
    case defenseExpert
}

final class DailyChallengeService: ObservableObject {
    static let shared = DailyChallengeService()
    
    @Published var todaysChallenge: DailyChallenge?
    @Published var challengeHistory: [DailyChallenge] = []
    
    private let challengeKey = "spelsmart.daily_challenges.v1"
    
    private init() {
        loadChallenges()
        generateTodaysChallenge()
    }
    
    func generateTodaysChallenge() {
        let today = Calendar.current.startOfDay(for: Date())
        
        // Check if we already have today's challenge
        if let existing = challengeHistory.first(where: { 
            Calendar.current.isDate($0.date, inSameDayAs: today) 
        }) {
            todaysChallenge = existing
            return
        }
        
        // Generate new challenge for today
        guard let avatar = AvatarStore.shared.avatar else { return }
        
        let newChallenge = DailyChallenge(date: today, ageBand: avatar.ageBand)
        challengeHistory.append(newChallenge)
        todaysChallenge = newChallenge
        
        persist()
    }
    
    func completeChallenge(_ challenge: DailyChallenge, with outcome: DecisionOutcome) {
        guard let index = challengeHistory.firstIndex(where: { $0.id == challenge.id }) else { return }
        
        var updatedChallenge = challenge
        updatedChallenge = DailyChallenge(
            id: challenge.id,
            date: challenge.date,
            title: challenge.title,
            description: challenge.description,
            scenario: challenge.scenario,
            bonusXP: challenge.bonusXP,
            specialReward: challenge.specialReward,
            ageBand: challenge.ageBand,
            difficulty: challenge.difficulty,
            isCompleted: true
        )
        
        challengeHistory[index] = updatedChallenge
        
        if todaysChallenge?.id == challenge.id {
            todaysChallenge = updatedChallenge
        }
        
        // Award bonus XP
        GameProgressStore.shared.addXP(challenge.bonusXP, for: [.decisionMaking])
        
        persist()
    }
    
    func getChallengeStreak() -> Int {
        let sortedChallenges = challengeHistory
            .filter { $0.isCompleted }
            .sorted { $0.date > $1.date }
        
        var streak = 0
        var currentDate = Calendar.current.startOfDay(for: Date())
        
        for challenge in sortedChallenges {
            let challengeDate = Calendar.current.startOfDay(for: challenge.date)
            
            if Calendar.current.isDate(challengeDate, inSameDayAs: currentDate) {
                streak += 1
                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return streak
    }
    
    private func loadChallenges() {
        if let data = UserDefaults.standard.data(forKey: challengeKey),
           let decoded = try? JSONDecoder().decode([DailyChallenge].self, from: data) {
            challengeHistory = decoded
        }
    }
    
    private func persist() {
        if let data = try? JSONEncoder().encode(challengeHistory) {
            UserDefaults.standard.set(data, forKey: challengeKey)
        }
    }
}

// Need to add this to DailyChallenge
extension DailyChallenge {
    init(id: String, date: Date, title: String, description: String, scenario: GameScenario, bonusXP: Int, specialReward: String?, ageBand: AgeBand, difficulty: Int, isCompleted: Bool) {
        self.id = id
        self.date = date
        self.title = title
        self.description = description
        self.scenario = scenario
        self.bonusXP = bonusXP
        self.specialReward = specialReward
        self.ageBand = ageBand
        self.difficulty = difficulty
        self.isCompleted = isCompleted
    }
}