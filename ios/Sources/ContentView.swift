import SwiftUI
import SpriteKit

struct ContentView: View {
    var body: some View {
        TabView {
            TrainingView()
                .tabItem { Label("Träna", systemImage: "sportscourt") }
            AvatarView()
                .tabItem { Label("Avatar", systemImage: "person.crop.circle") }
            TrainerEditorView()
                .tabItem { Label("Tränare", systemImage: "pencil") }
        }
    }
}

