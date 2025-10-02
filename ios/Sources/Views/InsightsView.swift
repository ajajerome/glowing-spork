import SwiftUI

struct InsightsView: View {
    @ObservedObject private var progressTracker = ProgressTracker.shared
    @ObservedObject private var progressStore = GameProgressStore.shared
    @State private var selectedTimeframe: TimeFrame = .week
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Time frame selector
                    timeFrameSelector
                    
                    // Weekly summary
                    weeklySummary
                    
                    // Performance overview
                    performanceOverview
                    
                    // Skill progression
                    skillProgression
                    
                    // Recent achievements
                    recentAchievements
                }
                .padding()
            }
            .navigationTitle("Insikter")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var timeFrameSelector: some View {
        Picker("Tidsperiod", selection: $selectedTimeframe) {
            ForEach(TimeFrame.allCases) { timeframe in
                Text(timeframe.displayName).tag(timeframe)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
    
    private var weeklySummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Veckans Sammanfattning")
                .font(.headline)
                .bold()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Sessioner")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(progressTracker.weeklyProgress.sessions.count)")
                        .font(.title2)
                        .bold()
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Genomsnitt")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(progressTracker.weeklyProgress.averageScore)) poäng")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var performanceOverview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Prestationsutveckling")
                .font(.headline)
                .bold()
            
            VStack(spacing: 8) {
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
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var skillProgression: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Färdighetsutveckling")
                .font(.headline)
                .bold()
            
            ForEach(TacticalSkill.allCases.prefix(4), id: \.self) { skill in
                HStack {
                    Text(skill.displayName)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("Nivå \(progressStore.progress.skillLevel(for: skill))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var recentAchievements: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Senaste Prestationer")
                .font(.headline)
                .bold()
            
            if progressStore.unlockedBadges.isEmpty {
                Text("Inga badges upplåsta ännu")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ForEach(progressStore.unlockedBadges.prefix(3)) { badge in
                    HStack {
                        Text(badge.icon)
                            .font(.title2)
                        
                        VStack(alignment: .leading) {
                            Text(badge.name)
                                .font(.subheadline)
                                .bold()
                            Text(badge.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - Supporting Types

enum TimeFrame: String, CaseIterable, Identifiable {
    case week = "week"
    case month = "month"
    case all = "all"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .week: return "Vecka"
        case .month: return "Månad"
        case .all: return "Alla"
        }
    }
}

private extension TacticalSkill {
    var displayName: String {
        switch self {
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
}