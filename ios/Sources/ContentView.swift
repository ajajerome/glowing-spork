import SwiftUI
import SpriteKit

struct PitchScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .green
        let center = SKShapeNode(circleOfRadius: 40)
        center.fillColor = .white
        center.strokeColor = .white
        center.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(center)
    }
}

struct ContentView: View {
    var scene: SKScene {
        let scene = PitchScene()
        scene.size = CGSize(width: 390, height: 844)
        scene.scaleMode = .resizeFill
        return scene
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("Learnfotball MVP").font(.title2).bold()
            SpriteView(scene: scene)
                .ignoresSafeArea()
        }
    }
}

