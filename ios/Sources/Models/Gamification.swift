import Foundation

// MARK: - Player Progress & Levels

struct PlayerProgress: Codable, Equatable {
    var totalXP: Int
    var level: Int
    var xpToNextLevel: Int
    var skillXP: [TacticalSkill: Int]
    var earnedBadges: [String] // Badge IDs
    var currentRank: PlayerRank
    var playingSince: Date
    var totalPlayTime: TimeInterval
    var streakDays: Int
    var lastPlayDate: Date?
    
    init() {
        self.totalXP = 0
        self.level = 1
        self.xpToNextLevel = 100
        self.skillXP = [:]
        self.earnedBadges = []
        self.currentRank = .rookie
        self.playingSince = Date()
        self.totalPlayTime = 0
        self.streakDays = 0
        self.lastPlayDate = nil
    }
    
    mutating func addXP(_ amount: Int, for skills: [TacticalSkill] = []) {
        totalXP += amount
        
        // Distribute XP to specific skills
        for skill in skills {
            skillXP[skill, default: 0] += amount / max(1, skills.count)
        }
        
        // Check for level up
        while totalXP >= xpForLevel(level + 1) {
            levelUp()
        }
        
        // Update XP to next level
        xpToNextLevel = xpForLevel(level + 1) - totalXP
        
        // Update rank
        updateRank()
        
        // Update play time tracking
        updatePlayTime()
    }
    
    private mutating func levelUp() {
        level += 1
        // Could trigger celebration animation
    }
    
    private mutating func updateRank() {
        currentRank = PlayerRank.fromLevel(level)
    }
    
    private mutating func updatePlayTime() {
        let now = Date()
        
        // Update streak
        if let lastPlay = lastPlayDate {
            let daysSince = Calendar.current.dateComponents([.day], from: lastPlay, to: now).day ?? 0
            if daysSince == 1 {
                streakDays += 1
            } else if daysSince > 1 {
                streakDays = 1
            }
        } else {
            streakDays = 1
        }
        
        lastPlayDate = now
    }
    
    private func xpForLevel(_ targetLevel: Int) -> Int {
        // Exponential XP curve: 100 * level^1.5
        return Int(100.0 * pow(Double(targetLevel), 1.5))
    }
    
    func skillLevel(for skill: TacticalSkill) -> Int {
        let xp = skillXP[skill] ?? 0
        return max(1, Int(sqrt(Double(xp) / 50.0)) + 1)
    }
    
    func skillProgress(for skill: TacticalSkill) -> Double {
        let currentLevel = skillLevel(for: skill)
        let currentLevelXP = Int(pow(Double(currentLevel - 1), 2.0) * 50.0)
        let nextLevelXP = Int(pow(Double(currentLevel), 2.0) * 50.0)
        let currentXP = skillXP[skill] ?? 0
        
        guard nextLevelXP > currentLevelXP else { return 1.0 }
        return Double(currentXP - currentLevelXP) / Double(nextLevelXP - currentLevelXP)
    }
}

enum PlayerRank: String, Codable, CaseIterable {
    case rookie = "Nybörjare"
    case apprentice = "Lärling"
    case player = "Spelare"
    case tactician = "Taktiker"
    case strategist = "Strateg"
    case mastermind = "Mästare"
    case legend = "Legend"
    
    var icon: String {
        switch self {
        case .rookie: return "🌱"
        case .apprentice: return "⚽"
        case .player: return "🥅"
        case .tactician: return "🧠"
        case .strategist: return "👑"
        case .mastermind: return "🏆"
        case .legend: return "⭐"
        }
    }
    
    var color: String {
        switch self {
        case .rookie: return "#90EE90"      // Light green
        case .apprentice: return "#87CEEB"  // Sky blue
        case .player: return "#FFD700"      // Gold
        case .tactician: return "#FF6347"   // Tomato
        case .strategist: return "#9370DB"  // Medium purple
        case .mastermind: return "#FF1493"  // Deep pink
        case .legend: return "#FF4500"      // Orange red
        }
    }
    
    static func fromLevel(_ level: Int) -> PlayerRank {
        switch level {
        case 1...5: return .rookie
        case 6...12: return .apprentice
        case 13...25: return .player
        case 26...45: return .tactician
        case 46...75: return .strategist
        case 76...120: return .mastermind
        default: return .legend
        }
    }
}

// MARK: - Badge System

struct Badge: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let category: BadgeCategory
    let rarity: BadgeRarity
    let requirements: BadgeRequirements
    let unlockedAt: Date?
    
    var isUnlocked: Bool { unlockedAt != nil }
}

enum BadgeCategory: String, Codable, CaseIterable {
    case skill = "Färdighet"
    case achievement = "Prestation"
    case milestone = "Milstolpe"
    case special = "Special"
    case daily = "Daglig"
    case seasonal = "Säsong"
}

enum BadgeRarity: String, Codable, CaseIterable {
    case common = "Vanlig"
    case uncommon = "Ovanlig"
    case rare = "Sällsynt"
    case epic = "Episk"
    case legendary = "Legendarisk"
    
    var color: String {
        switch self {
        case .common: return "#C0C0C0"      // Silver
        case .uncommon: return "#32CD32"    // Lime green
        case .rare: return "#1E90FF"        // Dodger blue
        case .epic: return "#9370DB"        // Medium purple
        case .legendary: return "#FFD700"   // Gold
        }
    }
}

struct BadgeRequirements: Codable, Equatable {
    let minLevel: Int?
    let minXP: Int?
    let skillRequirements: [TacticalSkill: Int]? // Skill: minimum level
    let scenarioCount: Int?
    let streakDays: Int?
    let specificActions: [BadgeAction]?
}

struct BadgeAction: Codable, Equatable {
    let action: TacticalAction
    let count: Int
    let quality: OutcomeType? // Minimum quality required
}

// MARK: - Achievements System

final class AchievementEngine {
    static let shared = AchievementEngine()
    
    private var badges: [Badge] = []
    
    private init() {
        setupBadges()
    }
    
    func checkForNewBadges(progress: PlayerProgress, recentSession: DrillSessionTelemetry?) -> [Badge] {
        var newBadges: [Badge] = []
        
        for badge in badges where !progress.earnedBadges.contains(badge.id) {
            if meetsRequirements(badge.requirements, progress: progress, session: recentSession) {
                newBadges.append(badge)
            }
        }
        
        return newBadges
    }
    
    func getAllBadges() -> [Badge] {
        return badges
    }
    
    func getBadge(by id: String) -> Badge? {
        return badges.first { $0.id == id }
    }
    
    private func meetsRequirements(_ requirements: BadgeRequirements, progress: PlayerProgress, session: DrillSessionTelemetry?) -> Bool {
        // Check level requirement
        if let minLevel = requirements.minLevel, progress.level < minLevel {
            return false
        }
        
        // Check XP requirement
        if let minXP = requirements.minXP, progress.totalXP < minXP {
            return false
        }
        
        // Check skill requirements
        if let skillReqs = requirements.skillRequirements {
            for (skill, minLevel) in skillReqs {
                if progress.skillLevel(for: skill) < minLevel {
                    return false
                }
            }
        }
        
        // Check streak days
        if let minStreak = requirements.streakDays, progress.streakDays < minStreak {
            return false
        }
        
        return true
    }
    
    private func setupBadges() {
        badges = [
            // Milestone badges
            Badge(
                id: "first_scenario",
                name: "Första Steget",
                description: "Genomför ditt första scenario",
                icon: "🎯",
                category: .milestone,
                rarity: .common,
                requirements: BadgeRequirements(minLevel: nil, minXP: 1, skillRequirements: nil, scenarioCount: 1, streakDays: nil, specificActions: nil),
                unlockedAt: nil
            ),
            
            Badge(
                id: "level_5",
                name: "Erfaren Spelare",
                description: "Nå nivå 5",
                icon: "⭐",
                category: .milestone,
                rarity: .uncommon,
                requirements: BadgeRequirements(minLevel: 5, minXP: nil, skillRequirements: nil, scenarioCount: nil, streakDays: nil, specificActions: nil),
                unlockedAt: nil
            ),
            
            Badge(
                id: "vision_master",
                name: "Spelöverskåd Mästare",
                description: "Nå nivå 5 i spelöverskåd",
                icon: "👁",
                category: .skill,
                rarity: .rare,
                requirements: BadgeRequirements(minLevel: nil, minXP: nil, skillRequirements: [.vision: 5], scenarioCount: nil, streakDays: nil, specificActions: nil),
                unlockedAt: nil
            ),
            
            Badge(
                id: "tactical_genius",
                name: "Taktisk Genius",
                description: "Nå nivå 5 i alla taktiska färdigheter",
                icon: "🧠",
                category: .achievement,
                rarity: .legendary,
                requirements: BadgeRequirements(
                    minLevel: nil,
                    minXP: nil,
                    skillRequirements: [
                        .vision: 5,
                        .positioning: 5,
                        .timing: 5,
                        .decisionMaking: 5,
                        .spatialAwareness: 5
                    ],
                    scenarioCount: nil,
                    streakDays: nil,
                    specificActions: nil
                ),
                unlockedAt: nil
            ),
            
            Badge(
                id: "streak_7",
                name: "Dedikerad Träning",
                description: "Träna 7 dagar i rad",
                icon: "🔥",
                category: .daily,
                rarity: .rare,
                requirements: BadgeRequirements(minLevel: nil, minXP: nil, skillRequirements: nil, scenarioCount: nil, streakDays: 7, specificActions: nil),
                unlockedAt: nil
            ),
            
            Badge(
                id: "scanner",
                name: "Ögon Överallt",
                description: "Använd scanning 50 gånger",
                icon: "👀",
                category: .skill,
                rarity: .uncommon,
                requirements: BadgeRequirements(
                    minLevel: nil,
                    minXP: nil,
                    skillRequirements: nil,
                    scenarioCount: nil,
                    streakDays: nil,
                    specificActions: [BadgeAction(action: .scan, count: 50, quality: nil)]
                ),
                unlockedAt: nil
            ),
            
            Badge(
                id: "perfectionist",
                name: "Perfektionist",
                description: "Få 10 'Utmärkt' bedömningar i rad",
                icon: "💎",
                category: .achievement,
                rarity: .epic,
                requirements: BadgeRequirements(minLevel: nil, minXP: nil, skillRequirements: nil, scenarioCount: nil, streakDays: nil, specificActions: nil),
                unlockedAt: nil
            )
        ]
    }
}

// MARK: - Progress Store Enhancement

final class GameProgressStore: ObservableObject {
    static let shared = GameProgressStore()
    
    @Published var progress: PlayerProgress
    @Published var unlockedBadges: [Badge] = []
    @Published var newBadgeAlert: Badge? = nil
    
    private let progressKey = "spelsmart.progress.v1"
    private let badgesKey = "spelsmart.badges.v1"
    
    private init() {
        // Load progress
        if let data = UserDefaults.standard.data(forKey: progressKey),
           let decoded = try? JSONDecoder().decode(PlayerProgress.self, from: data) {
            progress = decoded
        } else {
            progress = PlayerProgress()
        }
        
        // Load badges
        loadBadges()
    }
    
    func addXP(_ amount: Int, for skills: [TacticalSkill] = [], session: DrillSessionTelemetry? = nil) {
        progress.addXP(amount, for: skills)
        
        // Check for new badges
        let newBadges = AchievementEngine.shared.checkForNewBadges(progress: progress, recentSession: session)
        
        for badge in newBadges {
            unlockBadge(badge)
        }
        
        persist()
    }
    
    func unlockBadge(_ badge: Badge) {
        var unlockedBadge = badge
        unlockedBadge = Badge(
            id: badge.id,
            name: badge.name,
            description: badge.description,
            icon: badge.icon,
            category: badge.category,
            rarity: badge.rarity,
            requirements: badge.requirements,
            unlockedAt: Date()
        )
        
        unlockedBadges.append(unlockedBadge)
        progress.earnedBadges.append(badge.id)
        newBadgeAlert = unlockedBadge
        
        // Haptic feedback for badge unlock
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
        
        persist()
    }
    
    func getSkillRadarData() -> [SkillRadarPoint] {
        return TacticalSkill.allCases.map { skill in
            SkillRadarPoint(
                skill: skill,
                level: progress.skillLevel(for: skill),
                progress: progress.skillProgress(for: skill)
            )
        }
    }
    
    private func loadBadges() {
        if let data = UserDefaults.standard.data(forKey: badgesKey),
           let decoded = try? JSONDecoder().decode([Badge].self, from: data) {
            unlockedBadges = decoded
        }
    }
    
    private func persist() {
        // Save progress
        if let data = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(data, forKey: progressKey)
        }
        
        // Save badges
        if let data = try? JSONEncoder().encode(unlockedBadges) {
            UserDefaults.standard.set(data, forKey: badgesKey)
        }
    }
}

// MARK: - Skill Radar Data

struct SkillRadarPoint: Identifiable, Equatable {
    let id = UUID()
    let skill: TacticalSkill
    let level: Int
    let progress: Double
    
    var displayName: String {
        switch skill {
        case .vision: return "Spelöverskåd"
        case .positioning: return "Positionering"
        case .timing: return "Timing"
        case .communication: return "Kommunikation"
        case .decisionMaking: return "Beslut"
        case .spatialAwareness: return "Rumsuppfattning"
        case .pressureHandling: return "Presshantering"
        case .teamwork: return "Lagarbete"
        }
    }
    
    var maxLevel: Int { 10 }
    var normalizedValue: Double { Double(level) / Double(maxLevel) }
}

// MARK: - XP Events

struct XPEvent: Identifiable {
    let id = UUID()
    let amount: Int
    let reason: String
    let skills: [TacticalSkill]
    let timestamp: Date
    
    init(amount: Int, reason: String, skills: [TacticalSkill] = []) {
        self.amount = amount
        self.reason = reason
        self.skills = skills
        self.timestamp = Date()
    }
}

// MARK: - Level Rewards

struct LevelReward: Identifiable, Equatable {
    let id = UUID()
    let level: Int
    let title: String
    let description: String
    let rewardType: RewardType
    let icon: String
}

enum RewardType: String, CaseIterable {
    case badge = "badge"
    case avatarItem = "avatar_item"
    case scenarioUnlock = "scenario_unlock"
    case title = "title"
}

final class RewardSystem {
    static let shared = RewardSystem()
    
    private let levelRewards: [LevelReward] = [
        LevelReward(level: 5, title: "Första Framstegen", description: "Du har lärt dig grunderna!", rewardType: .badge, icon: "🌟"),
        LevelReward(level: 10, title: "Tröjfärger", description: "Låser upp nya tröjfärger", rewardType: .avatarItem, icon: "👕"),
        LevelReward(level: 15, title: "Avancerade Scenarier", description: "Tillgång till svårare situationer", rewardType: .scenarioUnlock, icon: "🏟️"),
        LevelReward(level: 20, title: "Taktisk Expert", description: "Du förstår spelet på en djupare nivå", rewardType: .title, icon: "🧠"),
        LevelReward(level: 30, title: "Matchanalytiker", description: "Kan analysera komplexa matchsituationer", rewardType: .title, icon: "📊")
    ]
    
    private init() {}
    
    func getRewardsForLevel(_ level: Int) -> [LevelReward] {
        return levelRewards.filter { $0.level == level }
    }
    
    func getAllRewards() -> [LevelReward] {
        return levelRewards
    }
}