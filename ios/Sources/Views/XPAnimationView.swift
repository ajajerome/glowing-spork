import SwiftUI

struct XPAnimationView: View {
    let xpEvents: [XPEvent]
    @Binding var isVisible: Bool
    
    var body: some View {
        ZStack {
            ForEach(Array(xpEvents.enumerated()), id: \.offset) { index, event in
                XPFloatingText(
                    event: event,
                    delay: Double(index) * 0.2
                )
                .opacity(isVisible ? 1 : 0)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: isVisible)
    }
}

struct XPFloatingText: View {
    let event: XPEvent
    let delay: Double
    
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var scale: Double = 0.5
    
    var body: some View {
        VStack(spacing: 4) {
            Text("+\(event.amount) XP")
                .font(.title2)
                .bold()
                .foregroundColor(.white)
                .shadow(color: .black, radius: 2, x: 1, y: 1)
            
            Text(event.reason)
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .shadow(color: .black, radius: 1, x: 0.5, y: 0.5)
            
            if !event.skills.isEmpty {
                HStack(spacing: 4) {
                    ForEach(event.skills.prefix(3), id: \.self) { skill in
                        Text(skillIcon(for: skill))
                            .font(.caption)
                    }
                }
            }
        }
        .padding(12)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.66, green: 0.88, blue: 0.39).opacity(0.9),
                    Color(red: 0.12, green: 0.47, blue: 0.90).opacity(0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .scaleEffect(scale)
        .opacity(opacity)
        .offset(y: offset)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(delay)) {
                offset = -50
                opacity = 1.0
                scale = 1.0
            }
            
            withAnimation(.easeIn(duration: 0.4).delay(delay + 2.0)) {
                offset = -100
                opacity = 0.0
                scale = 0.8
            }
        }
    }
    
    private func skillIcon(for skill: TacticalSkill) -> String {
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
}

struct LevelUpCelebration: View {
    let newLevel: Int
    @Binding var isShowing: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Celebration animation
                ZStack {
                    ForEach(0..<20) { _ in
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 6, height: 6)
                            .offset(
                                x: CGFloat.random(in: -100...100),
                                y: CGFloat.random(in: -100...100)
                            )
                            .opacity(isShowing ? 1 : 0)
                            .animation(
                                .easeOut(duration: 1.5)
                                .delay(Double.random(in: 0...0.5)),
                                value: isShowing
                            )
                    }
                    
                    Text("🎉")
                        .font(.system(size: 80))
                        .scaleEffect(isShowing ? 1.2 : 0.5)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6), value: isShowing)
                }
                
                VStack(spacing: 8) {
                    Text("LEVEL UP!")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .scaleEffect(isShowing ? 1 : 0.8)
                        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2), value: isShowing)
                    
                    Text("Nivå \(newLevel)")
                        .font(.title)
                        .bold()
                        .foregroundColor(.yellow)
                        .scaleEffect(isShowing ? 1 : 0.8)
                        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.4), value: isShowing)
                }
                
                Button("Fantastiskt!") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isShowing = false
                    }
                }
                .buttonStyle(SpelSmartButtonStyle(style: .accent))
                .scaleEffect(isShowing ? 1 : 0.8)
                .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.6), value: isShowing)
            }
        }
        .opacity(isShowing ? 1 : 0)
        .animation(.easeInOut(duration: 0.3), value: isShowing)
    }
}

struct BadgeUnlockNotification: View {
    let badge: Badge
    @Binding var isShowing: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Text(badge.icon)
                .font(.title)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Ny Badge!")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.secondary)
                
                Text(badge.name)
                    .font(.headline)
                    .bold()
                
                Text(badge.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    Color(hex: badge.rarity.color)?.opacity(0.8) ?? .gray,
                    Color(hex: badge.rarity.color)?.opacity(0.6) ?? .gray
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        .scaleEffect(isShowing ? 1 : 0.8)
        .opacity(isShowing ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isShowing)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                isShowing = false
            }
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