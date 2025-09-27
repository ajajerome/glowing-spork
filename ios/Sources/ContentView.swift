import SwiftUI
import SpriteKit

struct ContentView: View {
    var body: some View {
        TabView {
            ScenarioGameView()
                .tabItem { Label("SpelSmart", systemImage: "brain.head.profile") }
            DailyChallengeView()
                .tabItem { Label("Utmaningar", systemImage: "flame.fill") }
            ProfileView()
                .tabItem { Label("Profil", systemImage: "person.crop.square") }
            TrainingView()
                .tabItem { Label("Träna", systemImage: "sportscourt") }
            AvatarView()
                .tabItem { Label("Avatar", systemImage: "person.crop.circle") }
        }
        .tint(Color(red: 0.66, green: 0.88, blue: 0.39)) // SpelSmart lime green
    }
}

