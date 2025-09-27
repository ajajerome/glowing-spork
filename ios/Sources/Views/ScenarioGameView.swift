import SwiftUI
import SpriteKit

struct ScenarioGameView: View, TacticalPitchDelegate {
    @ObservedObject private var avatarStore = AvatarStore.shared
    @ObservedObject private var progressStore = GameProgressStore.shared
    @State private var currentScenario: GameScenario?
    @State private var scene = TacticalPitchScene()
    @State private var showingScenarioSelector = false
    @State private var gameScore = 0
    @State private var xpEarned = 0
    @State private var skillsImproved: [TacticalSkill] = []
    @State private var showingResults = false
    @State private var scenarios: [GameScenario] = []
    @State private var recentXPEvents: [XPEvent] = []
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.66, green: 0.88, blue: 0.39), // Lime green
                    Color(red: 0.12, green: 0.47, blue: 0.90)  // Deep blue
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Game Scene
                SpriteView(scene: scene)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .cornerRadius(20)
                    .padding(.horizontal)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                
                // Bottom Controls
                bottomControls
            }
        }
        .onAppear {
            setupScene()
            loadScenarios()
        }
        .sheet(isPresented: $showingScenarioSelector) {
            ScenarioSelectorView(
                scenarios: scenarios,
                onScenarioSelected: { scenario in
                    startScenario(scenario)
                    showingScenarioSelector = false
                }
            )
        }
        .sheet(isPresented: $showingResults) {
            ScenarioResultsView(
                score: gameScore,
                xpEarned: xpEarned,
                skillsImproved: skillsImproved,
                onContinue: {
                    showingResults = false
                    showingScenarioSelector = true
                }
            )
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("SpelSmart Taktik")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                
                if let scenario = currentScenario {
                    Text(scenario.title)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            Spacer()
            
            // Avatar and stats
            if let avatar = avatarStore.avatar {
                HStack(spacing: 12) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Nv. \(progressStore.progress.level)")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.white)
                        Text("XP: +\(xpEarned)")
                            .font(.caption)
                            .foregroundColor(.white)
                        Text("Poäng: \(gameScore)")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.white)
                    }
                    
                    Circle()
                        .fill(Color(hex: avatar.jerseyColorHex) ?? .blue)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text("\(avatar.jerseyNumber)")
                                .font(.caption)
                                .bold()
                                .foregroundColor(.white)
                        )
                }
            }
        }
        .padding()
    }
    
    private var bottomControls: some View {
        HStack(spacing: 16) {
            Button("Välj Scenario") {
                showingScenarioSelector = true
            }
            .buttonStyle(SpelSmartButtonStyle(style: .secondary))
            
            if currentScenario != nil {
                Button("Ny Situation") {
                    generateRandomScenario()
                }
                .buttonStyle(SpelSmartButtonStyle(style: .primary))
            }
            
            Button("Resultat") {
                showingResults = true
            }
            .buttonStyle(SpelSmartButtonStyle(style: .accent))
        }
        .padding()
    }
    
    // MARK: - Scene Setup
    
    private func setupScene() {
        scene.size = CGSize(width: 400, height: 600)
        scene.scaleMode = .aspectFit
        scene.tacticalDelegate = self
    }
    
    private func loadScenarios() {
        scenarios = ScenarioService.shared.getScenarios(for: avatarStore.avatar?.ageBand)
        
        // Start with a sample scenario if none loaded
        if scenarios.isEmpty {
            scenarios = createSampleScenarios()
        }
        
        // Auto-start first scenario
        if let firstScenario = scenarios.first {
            startScenario(firstScenario)
        }
    }
    
    private func startScenario(_ scenario: GameScenario) {
        currentScenario = scenario
        scene.presentScenario(scenario)
    }
    
    private func generateRandomScenario() {
        guard let ageBand = avatarStore.avatar?.ageBand else { return }
        let randomScenario = ScenarioGenerator.shared.generateRandomScenario(for: ageBand)
        startScenario(randomScenario)
    }
    
    // MARK: - TacticalPitchDelegate
    
    func decisionSelected(_ decision: DecisionOption, in scenario: GameScenario) {
        // Process decision
        let xpGained = Int(Double(decision.xpReward) * decision.outcome.success.xpMultiplier)
        xpEarned += xpGained
        
        // Add XP to global progress with skills
        progressStore.addXP(xpGained, for: decision.skillsUsed)
        
        // Create XP event for animation
        let xpEvent = XPEvent(amount: xpGained, reason: decision.description, skills: decision.skillsUsed)
        recentXPEvents.append(xpEvent)
        
        // Update score based on outcome
        switch decision.outcome.success {
        case .excellent: gameScore += 3
        case .good: gameScore += 2
        case .okay: gameScore += 1
        case .poor: break
        case .terrible: gameScore = max(0, gameScore - 1)
        }
        
        // Track skills improved
        for skill in decision.skillsUsed {
            if !skillsImproved.contains(skill) {
                skillsImproved.append(skill)
            }
        }
        
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
    
    func scenarioCompleted(_ scenario: GameScenario, outcome: DecisionOutcome) {
        // Check if there's a follow-up scenario
        if let nextScenarioId = outcome.nextScenario,
           let nextScenario = scenarios.first(where: { $0.id == nextScenarioId }) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                startScenario(nextScenario)
            }
        } else {
            // Show results after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                showingResults = true
            }
        }
    }
}

// MARK: - Supporting Views

struct ScenarioSelectorView: View {
    let scenarios: [GameScenario]
    let onScenarioSelected: (GameScenario) -> Void
    
    var body: some View {
        NavigationView {
            List(scenarios) { scenario in
                ScenarioRow(scenario: scenario) {
                    onScenarioSelected(scenario)
                }
            }
            .navigationTitle("Välj Scenario")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct ScenarioRow: View {
    let scenario: GameScenario
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(scenario.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    DifficultyIndicator(level: scenario.difficulty)
                }
                
                Text(scenario.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Label(scenario.situation.context.rawValue.capitalized, systemImage: "target")
                    Spacer()
                    Text("Ålder: \(scenario.ageBand.rawValue)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .font(.caption)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

struct DifficultyIndicator: View {
    let level: Int
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { index in
                Circle()
                    .fill(index <= level ? Color.orange : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }
}

struct ScenarioResultsView: View {
    let score: Int
    let xpEarned: Int
    let skillsImproved: [TacticalSkill]
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Fantastiskt!")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.primary)
            
            VStack(spacing: 16) {
                ResultCard(
                    title: "Poäng",
                    value: "\(score)",
                    icon: "star.fill",
                    color: .orange
                )
                
                ResultCard(
                    title: "XP Earned",
                    value: "+\(xpEarned)",
                    icon: "bolt.fill",
                    color: .blue
                )
                
                if !skillsImproved.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Förbättrade färdigheter:")
                            .font(.headline)
                        
                        ForEach(skillsImproved, id: \.self) { skill in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(skill.rawValue.capitalized)
                                    .font(.body)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
            }
            
            Button("Fortsätt träna") {
                onContinue()
            }
            .buttonStyle(SpelSmartButtonStyle(style: .primary))
        }
        .padding()
    }
}

struct ResultCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.title2)
                    .bold()
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Custom Button Style

struct SpelSmartButtonStyle: ButtonStyle {
    enum Style {
        case primary, secondary, accent
    }
    
    let style: Style
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(backgroundColor)
            .cornerRadius(25)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return Color(red: 0.12, green: 0.47, blue: 0.90) // Deep blue
        case .secondary:
            return Color.gray
        case .accent:
            return Color(red: 0.66, green: 0.88, blue: 0.39) // Lime green
        }
    }
}

// MARK: - Extensions

private extension Color {
    init?(hex: String) {
        var hexString = hex
        if hexString.hasPrefix("#") { hexString.removeFirst() }
        guard hexString.count == 6, let intVal = Int(hexString, radix: 16) else { return nil }
        let r = Double((intVal >> 16) & 0xFF) / 255.0
        let g = Double((intVal >> 8) & 0xFF) / 255.0
        let b = Double(intVal & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}