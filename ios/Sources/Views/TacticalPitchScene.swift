import SpriteKit
import SwiftUI

protocol TacticalPitchDelegate: AnyObject {
    func decisionSelected(_ decision: DecisionOption, in scenario: GameScenario)
    func scenarioCompleted(_ scenario: GameScenario, outcome: DecisionOutcome)
}

final class TacticalPitchScene: SKScene {
    
    // MARK: - Properties
    weak var tacticalDelegate: TacticalPitchDelegate?
    
    private var currentScenario: GameScenario?
    private var playerNodes: [String: SKNode] = [:]
    private var ballNode: SKShapeNode?
    private var fieldLines: SKNode?
    private var decisionButtons: [SKNode] = []
    
    // Colors matching SpelSmart theme
    private let fieldColor = SKColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0) // Dark green
    private let lineColor = SKColor.white
    private let ballColor = SKColor.white
    private let playerColor = SKColor(red: 0.12, green: 0.47, blue: 0.90, alpha: 1.0) // Deep blue
    private let opponentColor = SKColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0) // Red
    private let highlightColor = SKColor(red: 0.66, green: 0.88, blue: 0.39, alpha: 1.0) // Lime green
    
    // MARK: - Setup
    
    override func didMove(to view: SKView) {
        setupField()
        setupCamera()
    }
    
    private func setupField() {
        backgroundColor = fieldColor
        
        // Create field lines
        fieldLines = createFieldLines()
        fieldLines?.zPosition = 1
        addChild(fieldLines!)
    }
    
    private func setupCamera() {
        let camera = SKCameraNode()
        self.camera = camera
        addChild(camera)
        
        // Position camera to show full field
        camera.position = CGPoint(x: size.width/2, y: size.height/2)
    }
    
    private func createFieldLines() -> SKNode {
        let lines = SKNode()
        
        // Field outline
        let fieldRect = CGRect(x: 50, y: 50, width: size.width - 100, height: size.height - 100)
        let outline = SKShapeNode(rect: fieldRect)
        outline.strokeColor = lineColor
        outline.lineWidth = 3
        outline.fillColor = .clear
        lines.addChild(outline)
        
        // Center line
        let centerLine = SKShapeNode(rect: CGRect(x: fieldRect.midX - 1.5, y: fieldRect.minY, width: 3, height: fieldRect.height))
        centerLine.fillColor = lineColor
        lines.addChild(centerLine)
        
        // Center circle
        let centerCircle = SKShapeNode(circleOfRadius: 40)
        centerCircle.position = CGPoint(x: fieldRect.midX, y: fieldRect.midY)
        centerCircle.strokeColor = lineColor
        centerCircle.lineWidth = 3
        centerCircle.fillColor = .clear
        lines.addChild(centerCircle)
        
        // Penalty areas
        let penaltyWidth: CGFloat = 80
        let penaltyHeight: CGFloat = 120
        
        // Left penalty area
        let leftPenalty = SKShapeNode(rect: CGRect(
            x: fieldRect.minX,
            y: fieldRect.midY - penaltyHeight/2,
            width: penaltyWidth,
            height: penaltyHeight
        ))
        leftPenalty.strokeColor = lineColor
        leftPenalty.lineWidth = 2
        leftPenalty.fillColor = .clear
        lines.addChild(leftPenalty)
        
        // Right penalty area
        let rightPenalty = SKShapeNode(rect: CGRect(
            x: fieldRect.maxX - penaltyWidth,
            y: fieldRect.midY - penaltyHeight/2,
            width: penaltyWidth,
            height: penaltyHeight
        ))
        rightPenalty.strokeColor = lineColor
        rightPenalty.lineWidth = 2
        rightPenalty.fillColor = .clear
        lines.addChild(rightPenalty)
        
        return lines
    }
    
    // MARK: - Scenario Management
    
    func presentScenario(_ scenario: GameScenario) {
        currentScenario = scenario
        clearField()
        setupScenario(scenario)
        showDecisionOptions(scenario.decisions)
    }
    
    private func clearField() {
        // Remove existing players and ball
        playerNodes.values.forEach { $0.removeFromParent() }
        playerNodes.removeAll()
        ballNode?.removeFromParent()
        ballNode = nil
        clearDecisionButtons()
    }
    
    private func setupScenario(_ scenario: GameScenario) {
        // Place ball
        placeBall(at: scenario.situation.ballPosition)
        
        // Place teammates
        for teammate in scenario.situation.teammates {
            placePlayer(teammate, isTeammate: true)
        }
        
        // Place opponents
        for opponent in scenario.situation.opponents {
            placePlayer(opponent, isTeammate: false)
        }
        
        // Highlight player with ball if applicable
        if let playerWithBall = playerNodes[scenario.situation.playerWithBall.rawValue] {
            highlightPlayer(playerWithBall)
        }
        
        // Add movement animations
        animatePlayerMovements(scenario.situation)
    }
    
    private func placeBall(at position: Position) {
        let ballPosition = convertToScenePosition(position)
        
        ballNode = SKShapeNode(circleOfRadius: 8)
        ballNode?.fillColor = ballColor
        ballNode?.strokeColor = .black
        ballNode?.lineWidth = 1
        ballNode?.position = ballPosition
        ballNode?.zPosition = 10
        
        // Add shadow
        let shadow = SKShapeNode(circleOfRadius: 8)
        shadow.fillColor = .black
        shadow.alpha = 0.3
        shadow.position = CGPoint(x: 2, y: -2)
        shadow.zPosition = -1
        ballNode?.addChild(shadow)
        
        addChild(ballNode!)
    }
    
    private func placePlayer(_ playerPos: PlayerPosition, isTeammate: Bool) {
        let position = convertToScenePosition(playerPos.position)
        
        let player = createPlayerNode(
            role: playerPos.role,
            isTeammate: isTeammate,
            isMoving: playerPos.isMoving
        )
        
        player.position = position
        player.zPosition = 5
        player.name = playerPos.id
        
        playerNodes[playerPos.id] = player
        addChild(player)
        
        // Add role label
        let roleLabel = SKLabelNode(text: playerPos.role.rawValue.prefix(1).uppercased())
        roleLabel.fontSize = 12
        roleLabel.fontColor = .white
        roleLabel.verticalAlignmentMode = .center
        roleLabel.horizontalAlignmentMode = .center
        roleLabel.zPosition = 1
        player.addChild(roleLabel)
        
        // Add movement indicator if moving
        if playerPos.isMoving, let direction = playerPos.movementDirection {
            addMovementArrow(to: player, direction: direction)
        }
    }
    
    private func createPlayerNode(role: PlayerRole, isTeammate: Bool, isMoving: Bool) -> SKNode {
        let container = SKNode()
        
        let radius: CGFloat = role == .goalkeeper ? 20 : 16
        let playerCircle = SKShapeNode(circleOfRadius: radius)
        
        // Color based on team and role
        if role == .you {
            playerCircle.fillColor = highlightColor
            playerCircle.strokeColor = .white
            playerCircle.lineWidth = 3
        } else if isTeammate {
            playerCircle.fillColor = playerColor
            playerCircle.strokeColor = .white
            playerCircle.lineWidth = 2
        } else {
            playerCircle.fillColor = opponentColor
            playerCircle.strokeColor = .white
            playerCircle.lineWidth = 2
        }
        
        container.addChild(playerCircle)
        
        // Add pulsing animation if moving
        if isMoving {
            let pulseAction = SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.5),
                SKAction.scale(to: 1.0, duration: 0.5)
            ])
            container.run(SKAction.repeatForever(pulseAction))
        }
        
        return container
    }
    
    private func addMovementArrow(to player: SKNode, direction: MovementDirection) {
        let arrow = SKShapeNode()
        let path = CGMutablePath()
        
        // Create arrow shape
        path.move(to: CGPoint(x: 0, y: 25))
        path.addLine(to: CGPoint(x: -8, y: 35))
        path.addLine(to: CGPoint(x: -3, y: 35))
        path.addLine(to: CGPoint(x: -3, y: 45))
        path.addLine(to: CGPoint(x: 3, y: 45))
        path.addLine(to: CGPoint(x: 3, y: 35))
        path.addLine(to: CGPoint(x: 8, y: 35))
        path.closeSubpath()
        
        arrow.path = path
        arrow.fillColor = .yellow
        arrow.strokeColor = .black
        arrow.lineWidth = 1
        arrow.alpha = 0.8
        arrow.zPosition = 1
        
        // Rotate based on direction
        let rotation: CGFloat
        switch direction {
        case .forward: rotation = 0
        case .backward: rotation = .pi
        case .left: rotation = -.pi/2
        case .right: rotation = .pi/2
        case .diagonal: rotation = .pi/4
        }
        arrow.zRotation = rotation
        
        player.addChild(arrow)
        
        // Animate arrow
        let fadeInOut = SKAction.sequence([
            SKAction.fadeAlpha(to: 1.0, duration: 0.3),
            SKAction.fadeAlpha(to: 0.5, duration: 0.3)
        ])
        arrow.run(SKAction.repeatForever(fadeInOut))
    }
    
    private func highlightPlayer(_ player: SKNode) {
        let highlight = SKShapeNode(circleOfRadius: 25)
        highlight.strokeColor = highlightColor
        highlight.lineWidth = 4
        highlight.fillColor = .clear
        highlight.alpha = 0.0
        highlight.zPosition = -1
        
        player.addChild(highlight)
        
        // Animate highlight
        let pulseAction = SKAction.sequence([
            SKAction.group([
                SKAction.fadeAlpha(to: 1.0, duration: 0.5),
                SKAction.scale(to: 1.2, duration: 0.5)
            ]),
            SKAction.group([
                SKAction.fadeAlpha(to: 0.3, duration: 0.5),
                SKAction.scale(to: 1.0, duration: 0.5)
            ])
        ])
        highlight.run(SKAction.repeatForever(pulseAction))
    }
    
    private func animatePlayerMovements(_ situation: MatchSituation) {
        // Add subtle animations to show dynamic nature of the game
        for (_, playerNode) in playerNodes {
            let wobble = SKAction.sequence([
                SKAction.moveBy(x: CGFloat.random(in: -2...2), y: CGFloat.random(in: -2...2), duration: 1.0),
                SKAction.moveBy(x: CGFloat.random(in: -2...2), y: CGFloat.random(in: -2...2), duration: 1.0)
            ])
            playerNode.run(SKAction.repeatForever(wobble))
        }
    }
    
    // MARK: - Decision UI
    
    private func showDecisionOptions(_ decisions: [DecisionOption]) {
        clearDecisionButtons()
        
        let buttonWidth: CGFloat = 280
        let buttonHeight: CGFloat = 60
        let spacing: CGFloat = 20
        let startY = size.height - 150
        
        for (index, decision) in decisions.enumerated() {
            let button = createDecisionButton(
                decision: decision,
                size: CGSize(width: buttonWidth, height: buttonHeight)
            )
            
            button.position = CGPoint(
                x: size.width/2,
                y: startY - CGFloat(index) * (buttonHeight + spacing)
            )
            
            decisionButtons.append(button)
            addChild(button)
        }
    }
    
    private func createDecisionButton(decision: DecisionOption, size: CGSize) -> SKNode {
        let container = SKNode()
        container.name = "decision_\(decision.id)"
        
        // Background
        let background = SKShapeNode(rectOf: size, cornerRadius: 10)
        background.fillColor = SKColor.white.withAlphaComponent(0.9)
        background.strokeColor = playerColor
        background.lineWidth = 2
        container.addChild(background)
        
        // Action icon
        let icon = createActionIcon(for: decision.action)
        icon.position = CGPoint(x: -size.width/2 + 30, y: 0)
        container.addChild(icon)
        
        // Text
        let label = SKLabelNode(text: decision.description)
        label.fontSize = 16
        label.fontColor = .black
        label.fontName = "AvenirNext-Medium"
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .left
        label.position = CGPoint(x: -size.width/2 + 60, y: 0)
        label.preferredMaxLayoutWidth = size.width - 80
        container.addChild(label)
        
        return container
    }
    
    private func createActionIcon(for action: TacticalAction) -> SKNode {
        let iconSize: CGFloat = 20
        let icon = SKShapeNode(circleOfRadius: iconSize/2)
        icon.fillColor = highlightColor
        icon.strokeColor = .white
        icon.lineWidth = 2
        
        // Add emoji or symbol based on action
        let symbol = SKLabelNode(text: symbolFor(action: action))
        symbol.fontSize = 14
        symbol.verticalAlignmentMode = .center
        symbol.horizontalAlignmentMode = .center
        icon.addChild(symbol)
        
        return icon
    }
    
    private func symbolFor(action: TacticalAction) -> String {
        switch action {
        case .pass: return "→"
        case .dribble: return "↗"
        case .shoot: return "⚽"
        case .cross: return "↖"
        case .defend: return "🛡"
        case .press: return "↗"
        case .support: return "+"
        case .move: return "↗"
        case .communicate: return "💬"
        case .scan: return "👁"
        }
    }
    
    private func clearDecisionButtons() {
        decisionButtons.forEach { $0.removeFromParent() }
        decisionButtons.removeAll()
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Check if a decision button was tapped
        let touchedNodes = nodes(at: location)
        for node in touchedNodes {
            if let name = node.name, name.hasPrefix("decision_") {
                handleDecisionTap(node)
                break
            }
        }
    }
    
    private func handleDecisionTap(_ node: SKNode) {
        guard let scenario = currentScenario,
              let name = node.name,
              let decisionId = name.components(separatedBy: "_").last,
              let decision = scenario.decisions.first(where: { $0.id == decisionId }) else {
            return
        }
        
        // Animate button press
        let pressAnimation = SKAction.sequence([
            SKAction.scale(to: 0.95, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        node.run(pressAnimation)
        
        // Notify delegate
        tacticalDelegate?.decisionSelected(decision, in: scenario)
        
        // Show outcome
        showDecisionOutcome(decision.outcome, after: 0.3)
    }
    
    private func showDecisionOutcome(_ outcome: DecisionOutcome, after delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.displayOutcome(outcome)
        }
    }
    
    private func displayOutcome(_ outcome: DecisionOutcome) {
        clearDecisionButtons()
        
        // Create outcome display
        let container = SKNode()
        
        let background = SKShapeNode(rectOf: CGSize(width: 300, height: 150), cornerRadius: 15)
        background.fillColor = getOutcomeColor(outcome.success)
        background.strokeColor = .white
        background.lineWidth = 3
        container.addChild(background)
        
        // Outcome emoji and text
        let emojiLabel = SKLabelNode(text: outcome.success.emoji)
        emojiLabel.fontSize = 40
        emojiLabel.position = CGPoint(x: 0, y: 30)
        container.addChild(emojiLabel)
        
        let feedbackLabel = SKLabelNode(text: outcome.feedback)
        feedbackLabel.fontSize = 16
        feedbackLabel.fontColor = .white
        feedbackLabel.fontName = "AvenirNext-Bold"
        feedbackLabel.position = CGPoint(x: 0, y: -10)
        feedbackLabel.preferredMaxLayoutWidth = 280
        feedbackLabel.numberOfLines = 3
        container.addChild(feedbackLabel)
        
        if let consequence = outcome.consequence {
            let consequenceLabel = SKLabelNode(text: consequence)
            consequenceLabel.fontSize = 14
            consequenceLabel.fontColor = .white
            consequenceLabel.position = CGPoint(x: 0, y: -40)
            consequenceLabel.preferredMaxLayoutWidth = 280
            consequenceLabel.numberOfLines = 2
            container.addChild(consequenceLabel)
        }
        
        container.position = CGPoint(x: size.width/2, y: size.height/2)
        container.zPosition = 100
        
        addChild(container)
        
        // Auto-dismiss after 4 seconds
        let dismissAction = SKAction.sequence([
            SKAction.wait(forDuration: 4.0),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ])
        container.run(dismissAction)
        
        // Notify delegate
        if let scenario = currentScenario {
            tacticalDelegate?.scenarioCompleted(scenario, outcome: outcome)
        }
    }
    
    private func getOutcomeColor(_ success: OutcomeType) -> SKColor {
        switch success {
        case .excellent: return SKColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 0.9)
        case .good: return SKColor(red: 0.6, green: 0.8, blue: 0.2, alpha: 0.9)
        case .okay: return SKColor(red: 0.8, green: 0.8, blue: 0.2, alpha: 0.9)
        case .poor: return SKColor(red: 0.8, green: 0.6, blue: 0.2, alpha: 0.9)
        case .terrible: return SKColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 0.9)
        }
    }
    
    // MARK: - Utility Methods
    
    private func convertToScenePosition(_ position: Position) -> CGPoint {
        let fieldRect = CGRect(x: 50, y: 50, width: size.width - 100, height: size.height - 100)
        
        return CGPoint(
            x: fieldRect.minX + (position.x / 100.0) * fieldRect.width,
            y: fieldRect.minY + (position.y / 100.0) * fieldRect.height
        )
    }
}