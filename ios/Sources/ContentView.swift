import SwiftUI
import SpriteKit

struct ContentView: View {
    @State private var trainingScene = TrainingScene()

    var body: some View {
        VStack(spacing: 12) {
            Text("Learnfotball MVP").font(.title2).bold()
            HStack(spacing: 12) {
                Button("Start") { trainingScene.startDrill() }
                    .buttonStyle(.borderedProminent)
                Button("Reset") { trainingScene.resetDrill() }
                    .buttonStyle(.bordered)
            }
            SpriteView(scene: trainingScene)
                .ignoresSafeArea()
        }
        .onAppear {
            trainingScene.size = CGSize(width: 390, height: 844)
            trainingScene.scaleMode = .resizeFill
        }
    }
}

