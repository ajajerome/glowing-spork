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
            header

            HStack(spacing: 12) {
                Button("Start") { scene.startDrill() }
                    .buttonStyle(.borderedProminent)
                Button("Reset") { scene.resetDrill() }
                    .buttonStyle(.bordered)
                Button("Demo") { runDemo() }
                    .buttonStyle(.bordered)
            }

            SpriteView(scene: scene)
                .ignoresSafeArea()
        }
        .onAppear {
            scene.size = CGSize(width: 390, height: 844)
            scene.scaleMode = .resizeFill
            scene.trainingDelegate = self
            applyAvatar()
        }
        .sheet(isPresented: $showQuestion) {
            if let q = currentQuestion {
                QuestionView(question: q) { _ in
                    showQuestion = false
                }
            }
        }
    }

    private var header: some View {
        HStack {
            if let a = avatarStore.avatar {
                Circle().fill(Color(hex: a.jerseyColorHex) ?? .blue)
                    .frame(width: 36, height: 36)
                    .overlay(Text("\(a.jerseyNumber)").font(.footnote).bold().foregroundColor(.white))
                VStack(alignment: .leading, spacing: 2) {
                    Text(a.name).font(.headline)
                    Text("\(a.ageBand.rawValue)").font(.caption).foregroundColor(.secondary)
                }
            } else {
                Text("Träning").font(.title2).bold()
            }
            Spacer()
        }
        .padding(.horizontal)
    }

    private func applyAvatar() {
        if let a = avatarStore.avatar {
            scene.applyAvatarStyling(name: a.name, number: a.jerseyNumber, jerseyHex: a.jerseyColorHex)
        }
    }

    private func runDemo() {
        scene.resetDrill()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            scene.startDrill()
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

