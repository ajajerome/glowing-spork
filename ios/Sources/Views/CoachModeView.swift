import SwiftUI

struct CoachModeView: View {
    @ObservedObject private var progressTracker = ProgressTracker.shared
    @ObservedObject private var progressStore = GameProgressStore.shared
    @ObservedObject private var avatarStore = AvatarStore.shared
    @State private var selectedPlayer: Avatar?
    @State private var showingPlayerSelector = false
    @State private var coachMode: CoachMode = .overview
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Coach mode selector
                coachModeSelector
                
                // Content based on selected mode
                Group {
                    switch coachMode {
                    case .overview:
                        CoachOverviewView()
                    case .progress:
                        CoachProgressView()
                    case .planning:
                        CoachPlanningView()
                    case .analysis:
                        CoachAnalysisView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("Coach-läge")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Välj Spelare") {
                        showingPlayerSelector = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingPlayerSelector) {
            PlayerSelectorView { player in
                selectedPlayer = player
                showingPlayerSelector = false
            }
        }
    }
    
    private var coachModeSelector: some View {
        Picker("Coach Mode", selection: $coachMode) {
            ForEach(CoachMode.allCases) { mode in
                Text(mode.displayName).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .padding()
        .background(Color(.secondarySystemBackground))
    }
}

// MARK: - Coach Mode Views

struct CoachOverviewView: View {
    @ObservedObject private var progressTracker = ProgressTracker.shared
    @ObservedObject private var progressStore = GameProgressStore.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Player summary card
                playerSummaryCard
                
                // Recent activity
                recentActivitySection
                
                // Key insights for coaches
                coachInsightsSection
                
                // Recommended focus areas
                recommendedFocusSection
            }
            .padding()
        }
    }
    
    private var playerSummaryCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Spelaröversikt")
                    .font(.headline)
                    .bold()
                Spacer()
                Text("Senaste 7 dagarna")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            let insights = progressTracker.getWeeklyInsights()
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                CoachStatCard(
                    title: "Träningspass",
                    value: "\(insights.totalSessions)",
                    icon: "figure.run",
                    color: .blue
                )
                
                CoachStatCard(
                    title: "Genomsnitt",
                    value: String(format: "%.1f", insights.averageScore),
                    icon: "chart.bar",
                    color: .green
                )
                
                CoachStatCard(
                    title: "Nivå",
                    value: "\(progressStore.progress.level)",
                    icon: "star",
                    color: .orange
                )
            }
            
            // Skill overview
            HStack {
                Text("Färdighetsöversikt:")
                    .font(.subheadline)
                    .bold()
                Spacer()
            }
            
            SkillRadarChart(data: progressStore.getSkillRadarData())
                .frame(height: 150)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Senaste Aktivitet")
                .font(.headline)
                .bold()
            
            if progressTracker.weeklyProgress.sessions.isEmpty {
                Text("Ingen aktivitet denna vecka")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(Array(progressTracker.weeklyProgress.sessions.suffix(3).enumerated()), id: \.offset) { index, session in
                    ActivityRow(session: session)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var coachInsightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tränarinsikter")
                .font(.headline)
                .bold()
            
            let insights = generateCoachInsights()
            
            ForEach(insights, id: \.title) { insight in
                CoachInsightCard(insight: insight)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var recommendedFocusSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Rekommenderat Fokus")
                .font(.headline)
                .bold()
            
            let recommendations = progressTracker.getPersonalizedRecommendations()
            
            if recommendations.isEmpty {
                Text("Spelaren presterar bra inom alla områden!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(recommendations.prefix(3)) { recommendation in
                    CoachRecommendationCard(recommendation: recommendation)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private func generateCoachInsights() -> [CoachInsight] {
        let insights = progressTracker.getWeeklyInsights()
        var coachInsights: [CoachInsight] = []
        
        // Consistency insight
        if insights.consistencyScore > 0.8 {
            coachInsights.append(CoachInsight(
                title: "Hög Konsistens",
                description: "Spelaren visar stabil prestation över tid",
                type: .positive,
                actionable: "Fortsätt uppmuntra regelbunden träning"
            ))
        } else if insights.consistencyScore < 0.4 {
            coachInsights.append(CoachInsight(
                title: "Varierande Prestation",
                description: "Prestationen varierar mycket mellan pass",
                type: .attention,
                actionable: "Fokusera på grundtekniker och rutiner"
            ))
        }
        
        // Progress insight
        if insights.weekOverWeekGrowth > 15 {
            coachInsights.append(CoachInsight(
                title: "Snabb Utveckling",
                description: "Spelaren utvecklas snabbt (\(Int(insights.weekOverWeekGrowth))% ökning)",
                type: .positive,
                actionable: "Utmana med svårare scenarier"
            ))
        } else if insights.weekOverWeekGrowth < -10 {
            coachInsights.append(CoachInsight(
                title: "Nedgång i Prestation",
                description: "Prestation har minskat denna vecka",
                type: .concern,
                actionable: "Kolla om spelaren behöver vila eller motivation"
            ))
        }
        
        // Skill balance insight
        if let strongest = insights.strongestSkill, let weakest = insights.improvementArea {
            let strongLevel = progressStore.progress.skillLevel(for: strongest)
            let weakLevel = progressStore.progress.skillLevel(for: weakest)
            
            if strongLevel - weakLevel > 3 {
                coachInsights.append(CoachInsight(
                    title: "Obalanserad Utveckling",
                    description: "\(strongest.displayName) är mycket starkare än \(weakest.displayName)",
                    type: .attention,
                    actionable: "Fokusera träning på \(weakest.displayName)"
                ))
            }
        }
        
        return coachInsights
    }
}

struct CoachProgressView: View {
    @ObservedObject private var progressStore = GameProgressStore.shared
    @State private var selectedTimeframe: ProgressTimeframe = .month
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Timeframe selector
                Picker("Tidsperiod", selection: $selectedTimeframe) {
                    ForEach(ProgressTimeframe.allCases) { timeframe in
                        Text(timeframe.displayName).tag(timeframe)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Progress charts and metrics
                progressMetricsSection
                
                // Skill development over time
                skillDevelopmentSection
                
                // Achievement timeline
                achievementTimelineSection
            }
            .padding()
        }
    }
    
    private var progressMetricsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Utvecklingsmått")
                .font(.headline)
                .bold()
            
            // Placeholder for progress metrics
            Text("Detaljerade utvecklingsmått kommer snart...")
                .font(.body)
                .foregroundColor(.secondary)
                .italic()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var skillDevelopmentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Färdighetsutveckling")
                .font(.headline)
                .bold()
            
            // Current skill levels
            ForEach(TacticalSkill.allCases, id: \.self) { skill in
                SkillProgressRow(
                    skill: skill,
                    level: progressStore.progress.skillLevel(for: skill),
                    progress: progressStore.progress.skillProgress(for: skill)
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var achievementTimelineSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Prestationshistorik")
                .font(.headline)
                .bold()
            
            if progressStore.unlockedBadges.isEmpty {
                Text("Inga prestationer ännu")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(progressStore.unlockedBadges.sorted { $0.unlockedAt ?? Date.distantPast > $1.unlockedAt ?? Date.distantPast }) { badge in
                    AchievementTimelineRow(badge: badge)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

struct CoachPlanningView: View {
    @State private var selectedFocus: TrainingFocus = .balanced
    @State private var sessionDuration: Double = 15
    @State private var difficultyLevel: Int = 3
    @State private var generatedPlan: TrainingPlan?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Training plan generator
                trainingPlanGenerator
                
                // Generated plan display
                if let plan = generatedPlan {
                    generatedPlanSection(plan)
                }
                
                // Quick training suggestions
                quickSuggestionsSection
            }
            .padding()
        }
    }
    
    private var trainingPlanGenerator: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Skapa Träningsplan")
                .font(.headline)
                .bold()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Träningsfokus:")
                    .font(.subheadline)
                    .bold()
                
                Picker("Fokus", selection: $selectedFocus) {
                    ForEach(TrainingFocus.allCases) { focus in
                        Text(focus.displayName).tag(focus)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Sessionslängd: \(Int(sessionDuration)) minuter")
                    .font(.subheadline)
                    .bold()
                
                Slider(value: $sessionDuration, in: 5...30, step: 5)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Svårighetsgrad: \(difficultyLevel)/5")
                    .font(.subheadline)
                    .bold()
                
                Slider(value: Binding(
                    get: { Double(difficultyLevel) },
                    set: { difficultyLevel = Int($0) }
                ), in: 1...5, step: 1)
            }
            
            Button("Generera Träningsplan") {
                generateTrainingPlan()
            }
            .buttonStyle(SpelSmartButtonStyle(style: .primary))
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private func generatedPlanSection(_ plan: TrainingPlan) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Genererad Träningsplan")
                .font(.headline)
                .bold()
            
            Text(plan.title)
                .font(.title3)
                .bold()
            
            Text(plan.description)
                .font(.body)
                .foregroundColor(.secondary)
            
            ForEach(plan.activities) { activity in
                TrainingActivityCard(activity: activity)
            }
            
            HStack {
                Text("Uppskattad tid: \(plan.estimatedDuration) min")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Svårighet: \(plan.difficulty)/5")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var quickSuggestionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Snabbförslag")
                .font(.headline)
                .bold()
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickSuggestionCard(
                    title: "Spelöverskåd",
                    description: "5 min scanning-träning",
                    icon: "eye",
                    color: .blue
                )
                
                QuickSuggestionCard(
                    title: "Beslutsfattande",
                    description: "10 min taktiska val",
                    icon: "brain",
                    color: .purple
                )
                
                QuickSuggestionCard(
                    title: "Positionering",
                    description: "8 min rumsuppfattning",
                    icon: "location",
                    color: .green
                )
                
                QuickSuggestionCard(
                    title: "Lagarbete",
                    description: "12 min kommunikation",
                    icon: "person.2",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private func generateTrainingPlan() {
        // Generate a training plan based on selections
        generatedPlan = TrainingPlan(
            title: "\(selectedFocus.displayName) Träning",
            description: "En \(Int(sessionDuration))-minuters träningsplan fokuserad på \(selectedFocus.displayName.lowercased())",
            activities: generateActivities(),
            estimatedDuration: Int(sessionDuration),
            difficulty: difficultyLevel,
            focus: selectedFocus
        )
    }
    
    private func generateActivities() -> [TrainingActivity] {
        // Generate activities based on focus and duration
        switch selectedFocus {
        case .balanced:
            return [
                TrainingActivity(title: "Uppvärmning", description: "Grundläggande scanning", duration: 3, type: .warmup),
                TrainingActivity(title: "Huvudträning", description: "Blandade scenarier", duration: Int(sessionDuration) - 6, type: .main),
                TrainingActivity(title: "Avslutning", description: "Reflektion och feedback", duration: 3, type: .cooldown)
            ]
        case .attack:
            return [
                TrainingActivity(title: "Anfallsscenarier", description: "Fokus på kreativitet", duration: Int(sessionDuration), type: .main)
            ]
        case .defense:
            return [
                TrainingActivity(title: "Försvarspositioner", description: "Positionering och press", duration: Int(sessionDuration), type: .main)
            ]
        case .transition:
            return [
                TrainingActivity(title: "Omställningar", description: "Snabba beslut", duration: Int(sessionDuration), type: .main)
            ]
        }
    }
}

struct CoachAnalysisView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Avancerad Analys")
                    .font(.title2)
                    .bold()
                
                Text("Här kommer detaljerad spelanalys för tränare...")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                // Placeholder for advanced analytics
                VStack(alignment: .leading, spacing: 12) {
                    Text("Kommande funktioner:")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Jämförelse med åldersgrupp")
                        Text("• Utvecklingsprognoser")
                        Text("• Detaljerad beslutsanalys")
                        Text("• Rekommendationer för fysisk träning")
                        Text("• Rapporter för föräldrar")
                    }
                    .font(.body)
                    .foregroundColor(.secondary)
                }
            }
            .padding()
        }
    }
}

// MARK: - Supporting Views and Models

struct CoachStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .bold()
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
}

struct ActivityRow: View {
    let session: SessionSummary
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(session.date.formatted(.dateTime.month().day().hour().minute()))
                    .font(.subheadline)
                    .bold()
                
                Text("\(Int(session.duration))s träning")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(session.score)) poäng")
                    .font(.subheadline)
                    .bold()
                
                Text("\(session.excellentCount) utmärkta")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct CoachInsightCard: View {
    let insight: CoachInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: insight.type.icon)
                    .foregroundColor(insight.type.color)
                
                Text(insight.title)
                    .font(.subheadline)
                    .bold()
                
                Spacer()
            }
            
            Text(insight.description)
                .font(.caption)
                .foregroundColor(.secondary)
            
            if !insight.actionable.isEmpty {
                Text("💡 \(insight.actionable)")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .italic()
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
}

struct CoachRecommendationCard: View {
    let recommendation: PersonalizedRecommendation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(recommendation.title)
                .font(.subheadline)
                .bold()
            
            Text(recommendation.description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
}

struct CoachSkillProgressRow: View {
    let skill: TacticalSkill
    let level: Int
    let progress: Double
    
    var body: some View {
        HStack {
            Text(skill.displayName)
                .font(.subheadline)
            
            Spacer()
            
            Text("Nv. \(level)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * progress, height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(width: 60, height: 6)
        }
    }
}

struct AchievementTimelineRow: View {
    let badge: Badge
    
    var body: some View {
        HStack {
            Text(badge.icon)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(badge.name)
                    .font(.subheadline)
                    .bold()
                
                if let date = badge.unlockedAt {
                    Text(date.formatted(.dateTime.month().day()))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct TrainingActivityCard: View {
    let activity: TrainingActivity
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.subheadline)
                    .bold()
                
                Text(activity.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(activity.duration) min")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(8)
    }
}

struct QuickSuggestionCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.subheadline)
                .bold()
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
}

struct PlayerSelectorView: View {
    let onPlayerSelected: (Avatar) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Välj spelare att analysera")
                    .font(.title2)
                    .padding()
                
                // For now, just show current avatar
                if let avatar = AvatarStore.shared.avatar {
                    Button(action: {
                        onPlayerSelected(avatar)
                    }) {
                        HStack {
                            Circle()
                                .fill(Color(hex: avatar.jerseyColorHex) ?? .blue)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text("\(avatar.jerseyNumber)")
                                        .font(.caption)
                                        .bold()
                                        .foregroundColor(.white)
                                )
                            
                            VStack(alignment: .leading) {
                                Text(avatar.name)
                                    .font(.headline)
                                Text(avatar.ageBand.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Välj Spelare")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Stäng") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Enums and Models

enum CoachMode: String, CaseIterable, Identifiable {
    case overview = "overview"
    case progress = "progress"
    case planning = "planning"
    case analysis = "analysis"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .overview: return "Översikt"
        case .progress: return "Framsteg"
        case .planning: return "Planering"
        case .analysis: return "Analys"
        }
    }
}

enum ProgressTimeframe: String, CaseIterable, Identifiable {
    case week = "week"
    case month = "month"
    case quarter = "quarter"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .week: return "Vecka"
        case .month: return "Månad"
        case .quarter: return "Kvartal"
        }
    }
}

enum TrainingFocus: String, CaseIterable, Identifiable {
    case balanced = "balanced"
    case attack = "attack"
    case defense = "defense"
    case transition = "transition"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .balanced: return "Balanserad"
        case .attack: return "Anfall"
        case .defense: return "Försvar"
        case .transition: return "Omställning"
        }
    }
}

struct CoachInsight {
    let title: String
    let description: String
    let type: InsightType
    let actionable: String
}

enum InsightType {
    case positive
    case attention
    case concern
    
    var icon: String {
        switch self {
        case .positive: return "checkmark.circle"
        case .attention: return "exclamationmark.triangle"
        case .concern: return "xmark.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .positive: return .green
        case .attention: return .orange
        case .concern: return .red
        }
    }
}

struct TrainingPlan: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let activities: [TrainingActivity]
    let estimatedDuration: Int
    let difficulty: Int
    let focus: TrainingFocus
}

struct TrainingActivity: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let duration: Int
    let type: ActivityType
}

enum ActivityType {
    case warmup
    case main
    case cooldown
}

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