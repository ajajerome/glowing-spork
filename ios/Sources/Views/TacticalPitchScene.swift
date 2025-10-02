import SpriteKit
import SwiftUI

protocol TacticalPitchDelegate: AnyObject {
    func decisionSelected(_ decision: DecisionOption, in scenario: GameScenario)
}

final class TacticalPitchScene: SKScene {
    var tacticalDelegate: TacticalPitchDelegate?
    
    // Colors
    private let fieldColor = SKColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0)
    private let lineColor = SKColor.white
    private let playerColor = SKColor(red: 0.12, green: 0.47, blue: 0.90, alpha: 1.0)
    private let opponentColor = SKColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
    
    // Game state
    private var currentScenario: GameScenario?
    private var playerNodes: [SKShapeNode] = []
    private var opponentNodes: [SKShapeNode] = []
    private var ballNode: SKShapeNode?
    
    override func didMove(to view: SKView) {
        setupField()
        setupUI()
    }
    
    private func setupField() {
        // Background
        backgroundColor = fieldColor
        
        // Field boundaries
        let fieldRect = CGRect(x: 50, y: 50, width: size.width - 100, height: size.height - 100)
        let fieldBorder = SKShapeNode(rect: fieldRect)
        fieldBorder.strokeColor = lineColor
        fieldBorder.lineWidth = 3
        fieldBorder.fillColor = .clear
        addChild(fieldBorder)
        
        // Center circle
        let centerCircle = SKShapeNode(circleOfRadius: 50)
        centerCircle.position = CGPoint(x: size.width / 2, y: size.height / 2)
        centerCircle.strokeColor = lineColor
        centerCircle.lineWidth = 2
        centerCircle.fillColor = .clear
        addChild(centerCircle)
    }
    
    private func setupUI() {
        // Title label
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "Taktisk Situation"
        titleLabel.fontSize = 24
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height - 40)
        addChild(titleLabel)
    }
    
    func loadScenario(_ scenario: GameScenario) {
        currentScenario = scenario
        clearField()
        setupScenario(scenario)
    }
    
    private func clearField() {
        playerNodes.forEach { $0.removeFromParent() }
        opponentNodes.forEach { $0.removeFromParent() }
        ballNode?.removeFromParent()
        
        playerNodes.removeAll()
        opponentNodes.removeAll()
        ballNode = nil
    }
    
    private func setupScenario(_ scenario: GameScenario) {
        // Add ball
        let ball = SKShapeNode(circleOfRadius: 8)
        ball.fillColor = .white
        ball.strokeColor = .black
        ball.lineWidth = 1
        ball.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(ball)
        ballNode = ball
        
        // Add players (simplified)
        for i in 0..<3 {
            let player = createPlayerNode(color: playerColor, number: i + 1)
            player.position = CGPoint(
                x: size.width / 4 + CGFloat(i * 50),
                y: size.height / 2
            )
            addChild(player)
            playerNodes.append(player)
        }
        
        // Add opponents (simplified)
        for i in 0..<2 {
            let opponent = createPlayerNode(color: opponentColor, number: i + 1)
            opponent.position = CGPoint(
                x: 3 * size.width / 4 + CGFloat(i * 40),
                y: size.height / 2 + CGFloat(i * 30 - 15)
            )
            addChild(opponent)
            opponentNodes.append(opponent)
        }
    }
    
    private func createPlayerNode(color: SKColor, number: Int) -> SKShapeNode {
        let node = SKShapeNode(circleOfRadius: 15)
        node.fillColor = color
        node.strokeColor = .white
        node.lineWidth = 2
        
        let numberLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        numberLabel.text = "\(number)"
        numberLabel.fontSize = 12
        numberLabel.fontColor = .white
        numberLabel.verticalAlignmentMode = .center
        node.addChild(numberLabel)
        
        return node
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let scenario = currentScenario else { return }
        
        let location = touch.location(in: self)
        
        // Simple decision selection based on touch location
        if location.x < size.width / 3 {
            // Left side - defensive decision
            if let decision = scenario.options.first {
                tacticalDelegate?.decisionSelected(decision, in: scenario)
            }
        } else if location.x > 2 * size.width / 3 {
            // Right side - attacking decision
            if let decision = scenario.options.last {
                tacticalDelegate?.decisionSelected(decision, in: scenario)
            }
        } else {
            // Center - neutral decision
            if scenario.options.count > 1 {
                let decision = scenario.options[1]
                tacticalDelegate?.decisionSelected(decision, in: scenario)
            }
        }
    }
}