import SwiftUI

struct SkillRadarChart: View {
    let data: [SkillRadarPoint]
    
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = min(geometry.size.width, geometry.size.height) / 2 - 40
            
            ZStack {
                // Background circles (levels)
                ForEach(1...5, id: \.self) { level in
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        .frame(width: radius * 2 * Double(level) / 5, height: radius * 2 * Double(level) / 5)
                }
                
                // Skill axes
                ForEach(data.indices, id: \.self) { index in
                    let angle = Double(index) * 2 * .pi / Double(data.count) - .pi / 2
                    let endPoint = CGPoint(
                        x: center.x + cos(angle) * radius,
                        y: center.y + sin(angle) * radius
                    )
                    
                    Path { path in
                        path.move(to: center)
                        path.addLine(to: endPoint)
                    }
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                }
                
                // Skill labels
                ForEach(data.indices, id: \.self) { index in
                    let skillData = data[index]
                    let angle = Double(index) * 2 * .pi / Double(data.count) - .pi / 2
                    let labelDistance = radius + 25
                    let labelPosition = CGPoint(
                        x: center.x + cos(angle) * labelDistance,
                        y: center.y + sin(angle) * labelDistance
                    )
                    
                    Text(skillData.displayName)
                        .font(.caption)
                        .bold()
                        .foregroundColor(.primary)
                        .position(labelPosition)
                }
                
                // Player skill polygon
                Path { path in
                    for (index, skillData) in data.enumerated() {
                        let angle = Double(index) * 2 * .pi / Double(data.count) - .pi / 2
                        let distance = radius * skillData.normalizedValue
                        let point = CGPoint(
                            x: center.x + cos(angle) * distance,
                            y: center.y + sin(angle) * distance
                        )
                        
                        if index == 0 {
                            path.move(to: point)
                        } else {
                            path.addLine(to: point)
                        }
                    }
                    path.closeSubpath()
                }
                .fill(LinearGradient(
                    colors: [
                        Color(red: 0.66, green: 0.88, blue: 0.39).opacity(0.3),
                        Color(red: 0.12, green: 0.47, blue: 0.90).opacity(0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .stroke(LinearGradient(
                    colors: [
                        Color(red: 0.66, green: 0.88, blue: 0.39),
                        Color(red: 0.12, green: 0.47, blue: 0.90)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ), lineWidth: 2)
                
                // Skill level dots
                ForEach(data.indices, id: \.self) { index in
                    let skillData = data[index]
                    let angle = Double(index) * 2 * .pi / Double(data.count) - .pi / 2
                    let distance = radius * skillData.normalizedValue
                    let point = CGPoint(
                        x: center.x + cos(angle) * distance,
                        y: center.y + sin(angle) * distance
                    )
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                        .overlay(
                            Circle()
                                .stroke(Color.accentColor, lineWidth: 2)
                        )
                        .position(point)
                }
            }
        }
    }
}

struct BadgesCollectionView: View {
    @ObservedObject private var progressStore = GameProgressStore.shared
    private let achievementEngine = AchievementEngine.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(achievementEngine.getAllBadges()) { badge in
                        BadgeCardView(
                            badge: badge,
                            isUnlocked: progressStore.unlockedBadges.contains { $0.id == badge.id }
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Badge Samling")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct BadgeCardView: View {
    let badge: Badge
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(badge.icon)
                .font(.system(size: 32))
                .grayscale(isUnlocked ? 0 : 1)
                .opacity(isUnlocked ? 1.0 : 0.5)
            
            Text(badge.name)
                .font(.caption)
                .bold()
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .foregroundColor(isUnlocked ? .primary : .secondary)
            
            Text(badge.description)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
            
            if isUnlocked {
                Text(badge.rarity.rawValue)
                    .font(.caption2)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(hex: badge.rarity.color))
                    .cornerRadius(4)
            }
        }
        .frame(height: 140)
        .padding()
        .background(
            isUnlocked
                ? Color(hex: badge.rarity.color)?.opacity(0.1) ?? Color.gray.opacity(0.1)
                : Color.gray.opacity(0.05)
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isUnlocked
                        ? Color(hex: badge.rarity.color) ?? .gray
                        : Color.gray.opacity(0.3),
                    lineWidth: isUnlocked ? 2 : 1
                )
        )
        .scaleEffect(isUnlocked ? 1.0 : 0.95)
        .animation(.easeInOut(duration: 0.2), value: isUnlocked)
    }
}

struct SkillDetailView: View {
    let skill: TacticalSkill
    @ObservedObject private var progressStore = GameProgressStore.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Skill icon and name
                VStack(spacing: 12) {
                    Text(skillIcon)
                        .font(.system(size: 64))
                    
                    Text(skillDisplayName)
                        .font(.title)
                        .bold()
                }
                
                // Current level and progress
                VStack(spacing: 16) {
                    Text("Nivå \(progressStore.progress.skillLevel(for: skill))")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.accentColor)
                    
                    // Progress bar to next level
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 12)
                                .cornerRadius(6)
                            
                            Rectangle()
                                .fill(Color.accentColor)
                                .frame(width: geometry.size.width * progressStore.progress.skillProgress(for: skill), height: 12)
                                .cornerRadius(6)
                        }
                    }
                    .frame(height: 12)
                    
                    Text("Framsteg till nästa nivå")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Skill description
                Text(skillDescription)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .padding()
            .navigationTitle(skillDisplayName)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var skillDisplayName: String {
        switch skill {
        case .vision: return "Spelöverskåd"
        case .positioning: return "Positionering"
        case .timing: return "Timing"
        case .communication: return "Kommunikation"
        case .decisionMaking: return "Beslutsfattande"
        case .spatialAwareness: return "Rumsuppfattning"
        case .pressureHandling: return "Presshantering"
        case .teamwork: return "Lagarbete"
        }
    }
    
    private var skillIcon: String {
        switch skill {
        case .vision: return "👁"
        case .positioning: return "📍"
        case .timing: return "⏰"
        case .communication: return "💬"
        case .decisionMaking: return "🧠"
        case .spatialAwareness: return "🗺️"
        case .pressureHandling: return "💪"
        case .teamwork: return "🤝"
        }
    }
    
    private var skillDescription: String {
        switch skill {
        case .vision:
            return "Förmågan att se hela spelplanen och upptäcka möjligheter före andra spelare. Utvecklas genom scanning och situationsmedvetenhet."
        case .positioning:
            return "Att alltid vara på rätt plats vid rätt tidpunkt. Fundamental för både anfall och försvar."
        case .timing:
            return "Känslan för när man ska agera - passning, löpning eller tackling. Timing är allt i fotboll."
        case .communication:
            return "Att effektivt kommunicera med lagkamrater genom röst, gester och kroppsspråk."
        case .decisionMaking:
            return "Snabbt och korrekt beslutsfattande under press. Kärnan i modern fotboll."
        case .spatialAwareness:
            return "Förståelse för avstånd, ytor och geometri på planen. Hjälper dig att skapa och hitta utrymmen."
        case .pressureHandling:
            return "Att behålla lugnet och prestationsförmågan under press från motståndare."
        case .teamwork:
            return "Samarbetsförmåga och förståelse för hur man fungerar som en del av laget."
        }
    }
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