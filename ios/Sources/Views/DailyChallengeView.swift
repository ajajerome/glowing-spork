import SwiftUI

struct DailyChallengeView: View {
    @ObservedObject private var challengeService = DailyChallengeService.shared
    @State private var showingChallenge = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Today's challenge card
                    if let challenge = challengeService.todaysChallenge {
                        TodaysChallengeCard(challenge: challenge) {
                            showingChallenge = true
                        }
                    }
                    
                    // Challenge streak
                    challengeStreakCard
                    
                    // Challenge history
                    challengeHistorySection
                }
                .padding()
            }
            .navigationTitle("Dagliga Utmaningar")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                challengeService.generateTodaysChallenge()
            }
        }
        .sheet(isPresented: $showingChallenge) {
            if let challenge = challengeService.todaysChallenge {
                ChallengeGameView(challenge: challenge)
            }
        }
    }
    
    private var challengeStreakCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Utmanings-streak")
                    .font(.headline)
                    .bold()
                
                Text("🔥 \(challengeService.getChallengeStreak()) dagar i rad")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.orange)
                
                Text("Fortsätt din streak genom att klara dagens utmaning!")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "flame.fill")
                .font(.system(size: 40))
                .foregroundColor(.orange)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    Color.orange.opacity(0.1),
                    Color.red.opacity(0.1)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(16)
    }
    
    private var challengeHistorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tidigare Utmaningar")
                .font(.headline)
                .bold()
            
            if challengeService.challengeHistory.isEmpty {
                Text("Inga tidigare utmaningar ännu")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(challengeService.challengeHistory.sorted { $0.date > $1.date }) { challenge in
                        ChallengeHistoryRow(challenge: challenge)
                    }
                }
            }
        }
    }
}

struct TodaysChallengeCard: View {
    let challenge: DailyChallenge
    let onStart: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dagens Utmaning")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.secondary)
                    
                    Text(challenge.title)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                if challenge.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.green)
                } else {
                    DifficultyIndicator(level: challenge.difficulty)
                }
            }
            
            Text(challenge.description)
                .font(.body)
                .foregroundColor(.secondary)
            
            HStack {
                Label("+\(challenge.bonusXP) Bonus XP", systemImage: "bolt.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
                
                Spacer()
                
                if let reward = challenge.specialReward {
                    Text(reward)
                        .font(.caption)
                        .foregroundColor(.purple)
                }
            }
            
            if !challenge.isCompleted {
                Button(action: onStart) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Starta Utmaning")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(SpelSmartButtonStyle(style: .accent))
            } else {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Utmaning Klar!")
                        .bold()
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.66, green: 0.88, blue: 0.39).opacity(0.1),
                    Color(red: 0.12, green: 0.47, blue: 0.90).opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 0.66, green: 0.88, blue: 0.39),
                            Color(red: 0.12, green: 0.47, blue: 0.90)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
    }
}

struct ChallengeHistoryRow: View {
    let challenge: DailyChallenge
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(challenge.title)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(challenge.isCompleted ? .primary : .secondary)
                
                Text(challenge.date.formatted(.dateTime.month().day()))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if challenge.isCompleted {
                HStack(spacing: 8) {
                    Text("+\(challenge.bonusXP)")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.orange)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            } else {
                Text("Ej klar")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
        .opacity(challenge.isCompleted ? 1.0 : 0.6)
    }
}

struct ChallengeGameView: View {
    let challenge: DailyChallenge
    @State private var scene = TacticalPitchScene()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Challenge header
                VStack(spacing: 12) {
                    Text(challenge.title)
                        .font(.title)
                        .bold()
                    
                    Text(challenge.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    HStack {
                        Label("+\(challenge.bonusXP) Bonus XP", systemImage: "bolt.fill")
                            .foregroundColor(.orange)
                        
                        Spacer()
                        
                        if let reward = challenge.specialReward {
                            Text(reward)
                                .font(.caption)
                                .foregroundColor(.purple)
                        }
                    }
                    .font(.caption)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                
                // Game scene
                SpriteView(scene: scene)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Stäng") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            scene.size = CGSize(width: 400, height: 600)
            scene.scaleMode = .aspectFit
            scene.presentScenario(challenge.scenario)
        }
    }
}