import SwiftUI

struct CoachModeView: View {
    @ObservedObject private var progressStore = GameProgressStore.shared
    @ObservedObject private var avatarStore = AvatarStore.shared
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                // Overview Tab
                CoachOverviewView()
                    .tabItem {
                        Image(systemName: "chart.bar.fill")
                        Text("Översikt")
                    }
                    .tag(0)
                
                // Progress Tab  
                CoachProgressView()
                    .tabItem {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                        Text("Framsteg")
                    }
                    .tag(1)
                
                // Analysis Tab
                CoachAnalysisView()
                    .tabItem {
                        Image(systemName: "brain.head.profile")
                        Text("Analys")
                    }
                    .tag(2)
            }
            .navigationTitle("Coach-läge")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Sub Views

struct CoachOverviewView: View {
    @ObservedObject private var progressStore = GameProgressStore.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Current Level
                VStack {
                    Text("Nuvarande Nivå")
                        .font(.headline)
                    Text("\(progressStore.progress.currentLevel)")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                
                // XP Progress
                VStack {
                    Text("Erfarenhetspoäng")
                        .font(.headline)
                    Text("\(progressStore.progress.totalXP) XP")
                        .font(.title2)
                        .bold()
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                
                // Skills Overview
                VStack(alignment: .leading, spacing: 12) {
                    Text("Färdigheter")
                        .font(.headline)
                    
                    SkillRadarChart(data: progressStore.getSkillRadarData())
                        .frame(height: 200)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
            }
            .padding()
        }
    }
}

struct CoachProgressView: View {
    @ObservedObject private var progressStore = GameProgressStore.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Detaljerad framstegsspårning")
                    .font(.headline)
                
                ForEach(TacticalSkill.allCases, id: \.self) { skill in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(skill.displayName)
                                .font(.subheadline)
                                .bold()
                            Spacer()
                            Text("Nivå \(progressStore.progress.skillLevel(for: skill))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        ProgressView(value: progressStore.progress.skillProgress(for: skill))
                            .tint(.blue)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
    }
}

struct CoachAnalysisView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("AI-Analys")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Rekommendationer")
                        .font(.subheadline)
                        .bold()
                    
                    Text("• Fokusera på positionering nästa träning")
                    Text("• Öva spelöverskåd med fler scenarier")  
                    Text("• Utveckla beslutsfattande under press")
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Styrkor")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.green)
                    
                    Text("• Utmärkt timing i passningar")
                    Text("• Stark kommunikation med lagkamrater")
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Utvecklingsområden")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.orange)
                    
                    Text("• Rumsuppfattning behöver träning")
                    Text("• Presshantering kan förbättras")
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
            }
            .padding()
        }
    }
}

// MARK: - Extensions

// TacticalSkill.displayName extension finns redan i ProgressTracker.swift