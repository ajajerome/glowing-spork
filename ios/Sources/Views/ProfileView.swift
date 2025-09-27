import SwiftUI

struct ProfileView: View {
    @ObservedObject private var progressStore = GameProgressStore.shared
    @ObservedObject private var avatarStore = AvatarStore.shared
    @State private var showingBadges = false
    @State private var showingSkillDetails = false
    @State private var selectedSkill: TacticalSkill?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with avatar and basic stats
                    profileHeader
                    
                    // Level progress
                    levelProgressCard
                    
                    // Skill radar
                    skillRadarCard
                    
                    // Recent achievements
                    recentBadgesCard
                    
                    // Stats overview
                    statsOverviewCard
                    
                    // Daily streak
                    dailyStreakCard
                }
                .padding()
            }
            .navigationTitle("Min Profil")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Badges") {
                        showingBadges = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingBadges) {
            BadgesCollectionView()
        }
        .sheet(isPresented: $showingSkillDetails) {
            if let skill = selectedSkill {
                SkillDetailView(skill: skill)
            }
        }
        .alert("Ny Badge Upplåst! 🎉", isPresented: .constant(progressStore.newBadgeAlert != nil)) {
            Button("Fantastiskt!") {
                progressStore.newBadgeAlert = nil
            }
        } message: {
            if let badge = progressStore.newBadgeAlert {
                Text("\(badge.icon) \(badge.name)\n\(badge.description)")
            }
        }
    }
    
    private var profileHeader: some View {
        HStack(spacing: 16) {
            // Avatar circle
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [
                            Color(hex: progressStore.progress.currentRank.color) ?? .blue,
                            Color(hex: progressStore.progress.currentRank.color)?.opacity(0.6) ?? .blue
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                
                Text(progressStore.progress.currentRank.icon)
                    .font(.system(size: 32))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(avatarStore.avatar?.name ?? "Spelare")
                    .font(.title2)
                    .bold()
                
                Text(progressStore.progress.currentRank.rawValue)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("Nivå \(progressStore.progress.level)")
                        .font(.subheadline)
                        .bold()
                    
                    Spacer()
                    
                    Text("\(progressStore.progress.totalXP) XP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var levelProgressCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Nivå Framsteg")
                    .font(.headline)
                    .bold()
                
                Spacer()
                
                Text("\(progressStore.progress.xpToNextLevel) XP kvar")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(LinearGradient(
                            colors: [
                                Color(red: 0.66, green: 0.88, blue: 0.39),
                                Color(red: 0.12, green: 0.47, blue: 0.90)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: geometry.size.width * progressToNextLevel, height: 8)
                        .cornerRadius(4)
                        .animation(.easeInOut(duration: 0.5), value: progressToNextLevel)
                }
            }
            .frame(height: 8)
            
            Text("Nästa nivå: \(progressStore.progress.level + 1)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var progressToNextLevel: Double {
        let currentLevelXP = progressStore.progress.totalXP - progressStore.progress.xpToNextLevel
        let nextLevelXP = progressStore.progress.totalXP + progressStore.progress.xpToNextLevel
        let totalNeeded = nextLevelXP - currentLevelXP
        
        guard totalNeeded > 0 else { return 1.0 }
        return Double(progressStore.progress.totalXP - currentLevelXP) / Double(totalNeeded)
    }
    
    private var skillRadarCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Färdigheter")
                .font(.headline)
                .bold()
            
            SkillRadarChart(data: progressStore.getSkillRadarData())
                .frame(height: 200)
            
            // Skill list
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(progressStore.getSkillRadarData()) { skillData in
                    SkillProgressRow(skillData: skillData) {
                        selectedSkill = skillData.skill
                        showingSkillDetails = true
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var recentBadgesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Senaste Badges")
                    .font(.headline)
                    .bold()
                
                Spacer()
                
                Button("Visa alla") {
                    showingBadges = true
                }
                .font(.caption)
                .foregroundColor(.accentColor)
            }
            
            if progressStore.unlockedBadges.isEmpty {
                Text("Inga badges ännu - fortsätt träna!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(progressStore.unlockedBadges.suffix(5))) { badge in
                            BadgeMiniView(badge: badge)
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
    
    private var statsOverviewCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistik")
                .font(.headline)
                .bold()
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatItem(title: "Spelade Dagar", value: "\(daysSincePlaying)", icon: "calendar")
                StatItem(title: "Total Speltid", value: formatPlayTime(progressStore.progress.totalPlayTime), icon: "clock")
                StatItem(title: "Badges", value: "\(progressStore.unlockedBadges.count)", icon: "award")
                StatItem(title: "Rank", value: progressStore.progress.currentRank.rawValue, icon: "star")
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var dailyStreakCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Träningsstreak")
                    .font(.headline)
                    .bold()
                
                Spacer()
                
                Text("🔥 \(progressStore.progress.streakDays) dagar")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.orange)
            }
            
            if progressStore.progress.streakDays > 0 {
                Text("Fortsätt träna för att behålla din streak!")
                    .font(.body)
                    .foregroundColor(.secondary)
            } else {
                Text("Starta din träningsstreak idag!")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(LinearGradient(
            colors: [Color.orange.opacity(0.1), Color.red.opacity(0.1)],
            startPoint: .leading,
            endPoint: .trailing
        ))
        .cornerRadius(16)
    }
    
    private var daysSincePlaying: Int {
        Calendar.current.dateComponents([.day], from: progressStore.progress.playingSince, to: Date()).day ?? 0
    }
    
    private func formatPlayTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Supporting Views

struct SkillProgressRow: View {
    let skillData: SkillRadarPoint
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(skillData.displayName)
                        .font(.caption)
                        .bold()
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("Nv. \(skillData.level)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 4)
                            .cornerRadius(2)
                        
                        Rectangle()
                            .fill(Color.accentColor)
                            .frame(width: geometry.size.width * skillData.progress, height: 4)
                            .cornerRadius(2)
                    }
                }
                .frame(height: 4)
            }
        }
        .buttonStyle(.plain)
        .frame(height: 40)
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
            
            Text(value)
                .font(.title3)
                .bold()
            
            Text(title)
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

struct BadgeMiniView: View {
    let badge: Badge
    
    var body: some View {
        VStack(spacing: 4) {
            Text(badge.icon)
                .font(.title2)
            
            Text(badge.name)
                .font(.caption2)
                .bold()
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 60, height: 60)
        .padding(8)
        .background(Color(hex: badge.rarity.color)?.opacity(0.2) ?? Color.gray.opacity(0.2))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: badge.rarity.color) ?? .gray, lineWidth: 2)
        )
    }
}

// Color extension
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