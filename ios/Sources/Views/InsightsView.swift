import SwiftUI

struct InsightsView: View {
    @ObservedObject private var progressTracker = ProgressTracker.shared
    @ObservedObject private var progressStore = GameProgressStore.shared
    @State private var selectedTimeframe: TimeFrame = .week
    @State private var showingDetailedAnalysis = false
    @State private var selectedSkill: TacticalSkill?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Time frame selector
                    timeFrameSelector
                    
                    // Weekly insights summary
                    weeklyInsightsSummary
                    
                    // Performance chart
                    performanceChart
                    
                    // Skill progression
                    skillProgressionSection
                    
                    // Monthly goals
                    monthlyGoalsSection
                    
                    // Personalized recommendations
                    recommendationsSection
                    
                    // Recent achievements
                    recentAchievementsSection
                }
                .padding()
            }
            .navigationTitle("Insikter")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Detaljanalys") {
                        showingDetailedAnalysis = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingDetailedAnalysis) {
            DetailedAnalysisView()
        }
    }
    
    private var timeFrameSelector: some View {
        Picker("Tidsperiod", selection: $selectedTimeframe) {
            ForEach(TimeFrame.allCases) { timeframe in
                Text(timeframe.displayName).tag(timeframe)
            }
        }
        .pickerStyle(.segmented)
    }
    
    private var weeklyInsightsSummary: some View {
        let insights = progressTracker.getWeeklyInsights()
        
        return VStack(alignment: .leading, spacing: 16) {
            Text("Veckans Sammanfattning")
                .font(.headline)
                .bold()
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                InsightCard(
                    title: "Träningspass",
                    value: "\(insights.totalSessions)",
                    subtitle: "denna vecka",
                    icon: "figure.run",
                    color: .blue
                )
                
                InsightCard(
                    title: "Genomsnitt",
                    value: String(format: "%.1f", insights.averageScore),
                    subtitle: "poäng per pass",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green
                )
                
                InsightCard(
                    title: "Konsistens",
                    value: "\(Int(insights.consistencyScore * 100))%",
                    subtitle: "stabilitet",
                    icon: "target",
                    color: .orange
                )
                
                InsightCard(
                    title: "Utveckling",
                    value: insights.weekOverWeekGrowth >= 0 ? "+\(Int(insights.weekOverWeekGrowth))%" : "\(Int(insights.weekOverWeekGrowth))%",
                    subtitle: "från förra veckan",
                    icon: insights.weekOverWeekGrowth >= 0 ? "arrow.up.right" : "arrow.down.right",
                    color: insights.weekOverWeekGrowth >= 0 ? .green : .red
                )
            }
            
            if let strongest = insights.strongestSkill {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("Starkaste område: \(strongest.displayName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            if let improvement = insights.improvementArea {
                HStack {
                    Image(systemName: "arrow.up.circle")
                        .foregroundColor(.blue)
                    Text("Utvecklingsområde: \(improvement.displayName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var performanceChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Prestationsutveckling")
                .font(.headline)
                .bold()
            
            // Simple performance overview
            VStack(spacing: 8) {
                HStack {
                    Text("Senaste sessioner:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                ForEach(progressTracker.weeklyProgress.sessions.prefix(5), id: \.date) { session in
                    HStack {
                        Text(session.date, style: .date)
                            .font(.caption)
                        Spacer()
                        Text("\(Int(session.score)) poäng")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical, 2)
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var skillProgressionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Färdighetsutveckling")
                .font(.headline)
                .bold()
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(progressTracker.skillTrends) { trend in
                    SkillTrendCard(trend: trend) {
                        selectedSkill = trend.skill
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var monthlyGoalsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Månadsmål")
                .font(.headline)
                .bold()
            
            ForEach(progressTracker.monthlyGoals) { goal in
                MonthlyGoalCard(goal: goal)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var recommendationsSection: some View {
        let recommendations = progressTracker.getPersonalizedRecommendations()
        
        return VStack(alignment: .leading, spacing: 16) {
            Text("Personliga Rekommendationer")
                .font(.headline)
                .bold()
            
            if recommendations.isEmpty {
                Text("Bra jobbat! Inga specifika rekommendationer just nu.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(recommendations) { recommendation in
                    InsightsRecommendationCard(recommendation: recommendation)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var recentAchievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Senaste Prestationer")
                .font(.headline)
                .bold()
            
            if progressTracker.achievements.isEmpty {
                Text("Inga prestationer ännu - fortsätt träna!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(progressTracker.achievements.suffix(5))) { achievement in
                            AchievementMiniCard(achievement: achievement)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - Supporting Views

struct InsightCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .bold()
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
}

struct SkillTrendCard: View {
    let trend: SkillTrend
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                HStack {
                    Text(trend.skill.displayName)
                        .font(.caption)
                        .bold()
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: trendIcon)
                        .font(.caption)
                        .foregroundColor(trendColor)
                }
                
                HStack {
                    Text("Nv. \(trend.currentLevel)")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if abs(trend.changePercent) > 0.1 {
                        Text("\(trend.changePercent >= 0 ? "+" : "")\(Int(trend.changePercent))%")
                            .font(.caption2)
                            .foregroundColor(trendColor)
                    }
                }
                
                // Mini progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 4)
                            .cornerRadius(2)
                        
                        Rectangle()
                            .fill(trendColor)
                            .frame(width: geometry.size.width * (Double(trend.currentLevel) / 10.0), height: 4)
                            .cornerRadius(2)
                    }
                }
                .frame(height: 4)
            }
        }
        .buttonStyle(.plain)
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
    
    private var trendIcon: String {
        if trend.isImproving {
            return "arrow.up.right"
        } else if trend.isDecreasing {
            return "arrow.down.right"
        } else {
            return "minus"
        }
    }
    
    private var trendColor: Color {
        if trend.isImproving {
            return .green
        } else if trend.isDecreasing {
            return .red
        } else {
            return .gray
        }
    }
}

struct MonthlyGoalCard: View {
    let goal: MonthlyGoal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(.subheadline)
                        .bold()
                    
                    Text(goal.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if goal.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                } else {
                    Text("\(goal.currentValue)/\(goal.targetValue)")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(goal.isCompleted ? .green : .blue)
                        .frame(width: geometry.size.width * goal.progress, height: 8)
                        .cornerRadius(4)
                        .animation(.easeInOut(duration: 0.5), value: goal.progress)
                }
            }
            .frame(height: 8)
            
            if !goal.reward.isEmpty {
                HStack {
                    Image(systemName: "gift")
                        .font(.caption)
                        .foregroundColor(.purple)
                    Text("Belöning: \(goal.reward)")
                        .font(.caption)
                        .foregroundColor(.purple)
                }
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
}

struct InsightsRecommendationCard: View {
    let recommendation: PersonalizedRecommendation
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        priorityIndicator
                        Text(recommendation.title)
                            .font(.subheadline)
                            .bold()
                    }
                    
                    Text(recommendation.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { isExpanded.toggle() }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if isExpanded && !recommendation.actionItems.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Åtgärder:")
                        .font(.caption)
                        .bold()
                    
                    ForEach(recommendation.actionItems, id: \.self) { item in
                        HStack {
                            Image(systemName: "checkmark.circle")
                                .font(.caption)
                                .foregroundColor(.blue)
                            Text(item)
                                .font(.caption)
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
    }
    
    private var priorityIndicator: some View {
        Circle()
            .fill(priorityColor)
            .frame(width: 8, height: 8)
    }
    
    private var priorityColor: Color {
        switch recommendation.priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
}

struct AchievementMiniCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            Text(achievement.icon)
                .font(.title)
            
            Text(achievement.title)
                .font(.caption)
                .bold()
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            Text(achievement.unlockedAt.formatted(.dateTime.month().day()))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(width: 80, height: 80)
        .padding(8)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
}

struct DetailedAnalysisView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Detaljerad analys kommer snart...")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    // Placeholder for advanced analytics
                    Text("Här kommer du att kunna se:")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Djupgående prestationsanalys")
                        Text("• Jämförelse med andra spelare")
                        Text("• Prediktiv utvecklingsmodell")
                        Text("• Personaliserade träningsplaner")
                        Text("• Avancerade statistik och trender")
                    }
                    .font(.body)
                    .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationTitle("Detaljanalys")
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

enum TimeFrame: String, CaseIterable, Identifiable {
    case week = "week"
    case month = "month"
    case quarter = "quarter"
    case year = "year"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .week: return "Vecka"
        case .month: return "Månad"
        case .quarter: return "Kvartal"
        case .year: return "År"
        }
    }
}