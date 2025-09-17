import SwiftUI
import SpriteKit

protocol TrainingSceneDelegate: AnyObject {
    func trainingDidEnd(score: Int)
}

final class DelegatingTrainingScene: TrainingScene {
    weak var trainingDelegate: TrainingSceneDelegate?
    private var lastRunningState: Bool = false

    override func update(_ currentTime: TimeInterval) {
        let wasRunning = lastRunningState
        super.update(currentTime)
        let isRunning = Mirror(reflecting: self).children.first { $0.label == "isRunning" }?.value as? Bool ?? true
        if wasRunning && !isRunning {
            let scoreValue = Mirror(reflecting: self).children.first { $0.label == "score" }?.value as? Int ?? 0
            trainingDelegate?.trainingDidEnd(score: scoreValue)
        }
        lastRunningState = isRunning
    }
}

struct TrainingView: View, TrainingSceneDelegate {
    @ObservedObject private var avatarStore = AvatarStore.shared
    @State private var scene = DelegatingTrainingScene()
    @State private var showQuestion = false
    @State private var currentQuestion: QuestionItem? = nil

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Träning").font(.title2).bold()
                Spacer()
                if let a = avatarStore.avatar {
                    Text(a.name).font(.subheadline)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                }
            }

            HStack(spacing: 12) {
                Button("Start") { scene.startDrill() }
                    .buttonStyle(.borderedProminent)
                Button("Reset") { scene.resetDrill() }
                    .buttonStyle(.bordered)
            }

            SpriteView(scene: scene)
                .ignoresSafeArea()
        }
        .onAppear {
            scene.size = CGSize(width: 390, height: 844)
            scene.scaleMode = .resizeFill
            scene.trainingDelegate = self
        }
        .sheet(isPresented: $showQuestion) {
            if let q = currentQuestion {
                QuestionView(question: q) { _ in
                    showQuestion = false
                }
            }
        }
    }

    // MARK: - TrainingSceneDelegate
    func trainingDidEnd(score: Int) {
        guard let ageBand = avatarStore.avatar?.derivedAgeBand() ?? avatarStore.avatar?.ageBand else {
            currentQuestion = QuestionService.shared.oneRandom(for: .nineToEleven)
            showQuestion = currentQuestion != nil
            return
        }
        currentQuestion = QuestionService.shared.oneRandom(for: ageBand)
        showQuestion = currentQuestion != nil
    }
}

