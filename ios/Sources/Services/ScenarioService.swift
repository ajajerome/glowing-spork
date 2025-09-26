import Foundation

final class ScenarioService {
    static let shared = ScenarioService()
    
    private var library: ScenarioLibrary
    
    private init() {
        library = loadBundledScenarios()
    }
    
    func getScenarios(for ageBand: AgeBand?) -> [GameScenario] {
        guard let ageBand = ageBand else { return library.scenarios }
        return library.scenarios.filter { $0.ageBand == ageBand }
    }
    
    func getScenario(by id: String) -> GameScenario? {
        return library.scenarios.first { $0.id == id }
    }
    
    func getCollections(for ageBand: AgeBand?) -> [ScenarioCollection] {
        guard let ageBand = ageBand else { return library.collections }
        return library.collections.filter { $0.ageBand == ageBand }
    }
    
    private func loadBundledScenarios() -> ScenarioLibrary {
        // For now, return sample scenarios - in production this would load from bundle
        return ScenarioLibrary(
            scenarios: createSampleScenarios(),
            collections: createSampleCollections()
        )
    }
}

final class ScenarioGenerator {
    static let shared = ScenarioGenerator()
    
    private init() {}
    
    func generateRandomScenario(for ageBand: AgeBand) -> GameScenario {
        let contexts: [SituationContext] = [.attack, .defence, .transition, .buildUp]
        let context = contexts.randomElement()!
        
        switch context {
        case .attack:
            return generateAttackScenario(ageBand: ageBand)
        case .defence:
            return generateDefenceScenario(ageBand: ageBand)
        case .transition:
            return generateTransitionScenario(ageBand: ageBand)
        case .buildUp:
            return generateBuildUpScenario(ageBand: ageBand)
        default:
            return generateAttackScenario(ageBand: ageBand)
        }
    }
    
    private func generateAttackScenario(ageBand: AgeBand) -> GameScenario {
        let situation = MatchSituation(
            context: .attack,
            ballPosition: Position(x: 35, y: 60),
            playerWithBall: .you,
            teammates: [
                PlayerPosition(id: "teammate1", role: .midfielder, position: Position(x: 45, y: 40), isMoving: true, movementDirection: .forward),
                PlayerPosition(id: "teammate2", role: .forward, position: Position(x: 65, y: 80), isMoving: false, movementDirection: nil)
            ],
            opponents: [
                PlayerPosition(id: "opponent1", role: .defender, position: Position(x: 55, y: 70), isMoving: false, movementDirection: nil),
                PlayerPosition(id: "opponent2", role: .defender, position: Position(x: 70, y: 60), isMoving: true, movementDirection: .left)
            ],
            timeRemaining: nil,
            score: nil
        )
        
        let decisions = [
            DecisionOption(
                id: "pass_teammate",
                action: .pass,
                description: "Passa till medspelare i fritt läge",
                reasoning: "Skapar numerärt överläge",
                outcome: DecisionOutcome(
                    success: .good,
                    feedback: "Bra pass! Du hittade den fria medspelaren.",
                    consequence: "Laget behåller bollinnehav",
                    nextScenario: nil,
                    skillDevelopment: [.vision: 2, .decisionMaking: 1]
                ),
                skillsUsed: [.vision, .decisionMaking],
                xpReward: 15
            ),
            DecisionOption(
                id: "dribble_forward",
                action: .dribble,
                description: "Dribbla framåt mot målet",
                reasoning: "Tar initiativ och skapar fart",
                outcome: DecisionOutcome(
                    success: .okay,
                    feedback: "Modigt! Men riskabelt när det finns bättre alternativ.",
                    consequence: "Risk för bollförlust",
                    nextScenario: nil,
                    skillDevelopment: [.pressureHandling: 1]
                ),
                skillsUsed: [.pressureHandling],
                xpReward: 10
            ),
            DecisionOption(
                id: "scan_first",
                action: .scan,
                description: "Scanna omgivningen innan beslut",
                reasoning: "Samlar information för bättre beslut",
                outcome: DecisionOutcome(
                    success: .excellent,
                    feedback: "Perfekt! Scanning ger dig alla alternativ.",
                    consequence: "Du ser en ännu bättre passningsmöjlighet",
                    nextScenario: "follow_up_pass",
                    skillDevelopment: [.spatialAwareness: 3, .vision: 2]
                ),
                skillsUsed: [.spatialAwareness, .vision],
                xpReward: 20
            )
        ]
        
        return GameScenario(
            id: "attack_\(UUID().uuidString.prefix(8))",
            title: "Anfallssituation",
            description: "Du har bollen i anfall. Vad gör du?",
            ageBand: ageBand,
            situation: situation,
            gameState: GameState(phase: .midGame, intensity: .medium, formation: .fourFourTwo, possession: .home),
            decisions: decisions,
            learningObjectives: ["Utveckla spelöverskåd", "Fatta snabba beslut", "Känna igen passningslinjer"],
            difficulty: 2,
            tags: ["anfall", "beslutsfattande", "passing"]
        )
    }
    
    private func generateDefenceScenario(ageBand: AgeBand) -> GameScenario {
        let situation = MatchSituation(
            context: .defence,
            ballPosition: Position(x: 65, y: 30),
            playerWithBall: .midfielder,
            teammates: [
                PlayerPosition(id: "teammate1", role: .defender, position: Position(x: 25, y: 20), isMoving: false, movementDirection: nil),
                PlayerPosition(id: "you", role: .defender, position: Position(x: 45, y: 25), isMoving: false, movementDirection: nil)
            ],
            opponents: [
                PlayerPosition(id: "opponent1", role: .midfielder, position: Position(x: 65, y: 30), isMoving: true, movementDirection: .forward),
                PlayerPosition(id: "opponent2", role: .forward, position: Position(x: 75, y: 15), isMoving: true, movementDirection: .diagonal)
            ],
            timeRemaining: nil,
            score: nil
        )
        
        let decisions = [
            DecisionOption(
                id: "press_ball",
                action: .press,
                description: "Pressa bollföraren direkt",
                reasoning: "Stör motståndaren och vinner tid",
                outcome: DecisionOutcome(
                    success: .good,
                    feedback: "Bra press! Du tvingar motståndaren att fatta snabba beslut.",
                    consequence: "Motståndaren får mindre tid",
                    nextScenario: nil,
                    skillDevelopment: [.pressureHandling: 2, .positioning: 1]
                ),
                skillsUsed: [.pressureHandling, .positioning],
                xpReward: 15
            ),
            DecisionOption(
                id: "cover_space",
                action: .defend,
                description: "Täck farligt utrymme bakom",
                reasoning: "Förhindrar genombrott",
                outcome: DecisionOutcome(
                    success: .excellent,
                    feedback: "Utmärkt positionering! Du läser spelet perfekt.",
                    consequence: "Laget har kontroll över situationen",
                    nextScenario: nil,
                    skillDevelopment: [.positioning: 3, .spatialAwareness: 2]
                ),
                skillsUsed: [.positioning, .spatialAwareness],
                xpReward: 18
            ),
            DecisionOption(
                id: "communicate",
                action: .communicate,
                description: "Dirigera medspelare och organisera försvaret",
                reasoning: "Samordnar lagets försvar",
                outcome: DecisionOutcome(
                    success: .good,
                    feedback: "Bra kommunikation! Lagarbete är nyckeln.",
                    consequence: "Hela laget är bättre organiserat",
                    nextScenario: nil,
                    skillDevelopment: [.communication: 3, .teamwork: 2]
                ),
                skillsUsed: [.communication, .teamwork],
                xpReward: 16
            )
        ]
        
        return GameScenario(
            id: "defence_\(UUID().uuidString.prefix(8))",
            title: "Försvarssituation",
            description: "Motståndaren anfaller. Hur försvarar du?",
            ageBand: ageBand,
            situation: situation,
            gameState: GameState(phase: .midGame, intensity: .high, formation: .fourFourTwo, possession: .away),
            decisions: decisions,
            learningObjectives: ["Lära sig försvarspositionering", "Utveckla kommunikation", "Förstå press och täckning"],
            difficulty: 3,
            tags: ["försvar", "positionering", "kommunikation"]
        )
    }
    
    private func generateTransitionScenario(ageBand: AgeBand) -> GameScenario {
        let situation = MatchSituation(
            context: .transition,
            ballPosition: Position(x: 45, y: 45),
            playerWithBall: .you,
            teammates: [
                PlayerPosition(id: "teammate1", role: .midfielder, position: Position(x: 35, y: 35), isMoving: true, movementDirection: .forward),
                PlayerPosition(id: "teammate2", role: .forward, position: Position(x: 65, y: 70), isMoving: true, movementDirection: .forward)
            ],
            opponents: [
                PlayerPosition(id: "opponent1", role: .midfielder, position: Position(x: 55, y: 50), isMoving: true, movementDirection: .backward),
                PlayerPosition(id: "opponent2", role: .defender, position: Position(x: 70, y: 30), isMoving: false, movementDirection: nil)
            ],
            timeRemaining: nil,
            score: nil
        )
        
        let decisions = [
            DecisionOption(
                id: "quick_pass",
                action: .pass,
                description: "Snabb pass framåt i omställningen",
                reasoning: "Utnyttjar hastighet i omställning",
                outcome: DecisionOutcome(
                    success: .excellent,
                    feedback: "Perfekt timing! Omställningar handlar om hastighet.",
                    consequence: "Skapar farlig chans",
                    nextScenario: nil,
                    skillDevelopment: [.timing: 3, .vision: 2]
                ),
                skillsUsed: [.timing, .vision],
                xpReward: 20
            ),
            DecisionOption(
                id: "control_tempo",
                action: .move,
                description: "Ta kontroll och sakta ner tempot",
                reasoning: "Säkrar bollinnehav",
                outcome: DecisionOutcome(
                    success: .okay,
                    feedback: "Säkert val, men du missade chansen att utnyttja omställningen.",
                    consequence: "Behåller bollen men förlorar tempo",
                    nextScenario: nil,
                    skillDevelopment: [.decisionMaking: 1]
                ),
                skillsUsed: [.decisionMaking],
                xpReward: 8
            )
        ]
        
        return GameScenario(
            id: "transition_\(UUID().uuidString.prefix(8))",
            title: "Omställningssituation",
            description: "Ni vinner bollen! Hur utnyttjar ni omställningen?",
            ageBand: ageBand,
            situation: situation,
            gameState: GameState(phase: .midGame, intensity: .high, formation: .fourFourTwo, possession: .home),
            decisions: decisions,
            learningObjectives: ["Förstå omställningar", "Utveckla timing", "Lära sig läsa spelet"],
            difficulty: 4,
            tags: ["omställning", "timing", "hastighet"]
        )
    }
    
    private func generateBuildUpScenario(ageBand: AgeBand) -> GameScenario {
        let situation = MatchSituation(
            context: .buildUp,
            ballPosition: Position(x: 20, y: 50),
            playerWithBall: .defender,
            teammates: [
                PlayerPosition(id: "you", role: .midfielder, position: Position(x: 40, y: 45), isMoving: false, movementDirection: nil),
                PlayerPosition(id: "teammate1", role: .midfielder, position: Position(x: 30, y: 30), isMoving: true, movementDirection: .right),
                PlayerPosition(id: "teammate2", role: .forward, position: Position(x: 70, y: 70), isMoving: false, movementDirection: nil)
            ],
            opponents: [
                PlayerPosition(id: "opponent1", role: .forward, position: Position(x: 35, y: 55), isMoving: true, movementDirection: .backward)
            ],
            timeRemaining: nil,
            score: nil
        )
        
        let decisions = [
            DecisionOption(
                id: "show_for_ball",
                action: .support,
                description: "Visa dig för bollföraren",
                reasoning: "Erbjuder enkel passningsalternativ",
                outcome: DecisionOutcome(
                    success: .good,
                    feedback: "Bra! Du hjälper laget att bygga upp spelet.",
                    consequence: "Skapar passningsalternativ",
                    nextScenario: nil,
                    skillDevelopment: [.positioning: 2, .teamwork: 2]
                ),
                skillsUsed: [.positioning, .teamwork],
                xpReward: 12
            ),
            DecisionOption(
                id: "create_space",
                action: .move,
                description: "Skapa utrymme genom att röra dig",
                reasoning: "Öppnar upp spelet",
                outcome: DecisionOutcome(
                    success: .excellent,
                    feedback: "Perfekt! Genom att skapa utrymme hjälper du hela laget.",
                    consequence: "Öppnar nya passningslinjer",
                    nextScenario: nil,
                    skillDevelopment: [.spatialAwareness: 3, .positioning: 2]
                ),
                skillsUsed: [.spatialAwareness, .positioning],
                xpReward: 16
            )
        ]
        
        return GameScenario(
            id: "buildup_\(UUID().uuidString.prefix(8))",
            title: "Uppspelssituation",
            description: "Laget bygger upp spelet från eget straffområde. Hur hjälper du?",
            ageBand: ageBand,
            situation: situation,
            gameState: GameState(phase: .earlyGame, intensity: .low, formation: .fourFourTwo, possession: .home),
            decisions: decisions,
            learningObjectives: ["Förstå uppspel", "Utveckla positionering", "Lära sig skapa utrymme"],
            difficulty: 2,
            tags: ["uppspel", "positionering", "lagarbete"]
        )
    }
}

// Sample data for development
func createSampleScenarios() -> [GameScenario] {
    let generator = ScenarioGenerator.shared
    return [
        generator.generateAttackScenario(ageBand: .nineToEleven),
        generator.generateDefenceScenario(ageBand: .nineToEleven),
        generator.generateTransitionScenario(ageBand: .twelveToThirteen),
        generator.generateBuildUpScenario(ageBand: .nineToEleven)
    ]
}

func createSampleCollections() -> [ScenarioCollection] {
    return [
        ScenarioCollection(
            id: "beginner_attack",
            title: "Grundläggande anfall",
            description: "Lär dig grunderna i anfallsspel",
            scenarioIds: ["attack_basic1", "attack_basic2"],
            ageBand: .nineToEleven,
            difficulty: 1,
            theme: .attacking
        ),
        ScenarioCollection(
            id: "advanced_defence",
            title: "Avancerat försvarsspel",
            description: "Utveckla dina försvarskunskaper",
            scenarioIds: ["defence_adv1", "defence_adv2"],
            ageBand: .twelveToThirteen,
            difficulty: 4,
            theme: .defending
        )
    ]
}