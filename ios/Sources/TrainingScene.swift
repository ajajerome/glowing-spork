import SpriteKit
import Foundation

final class TrainingScene: SKScene, SKPhysicsContactDelegate {
    // Physics categories
    private struct Category {
        static let none: UInt32 = 0
        static let ball: UInt32 = 1 << 0
        static let cone: UInt32 = 1 << 1
        static let bounds: UInt32 = 1 << 2
        static let player: UInt32 = 1 << 3
    }

    // UI nodes
    private let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let timerLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")

    // Game nodes
    private let playerNode = SKShapeNode(circleOfRadius: 18)
    private let numberLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let ballNode = SKShapeNode(circleOfRadius: 12)

    private var isRunning = false
    private var timeRemaining: TimeInterval = 30
    private var lastUpdateTime: TimeInterval = 0
    private var score: Int = 0 { didSet { updateScoreLabel() } }

    override func didMove(to view: SKView) {
        backgroundColor = .systemGreen

        physicsWorld.contactDelegate = self
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.categoryBitMask = Category.bounds
        physicsBody?.contactTestBitMask = Category.ball
        physicsBody?.collisionBitMask = Category.ball

        setupHUD()
        setupPlayer()
        setupBall()
        spawnCones(count: 5)
        centerCameraIfNeeded()
        resetDrill()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        // Keep edge loop in sync with scene size
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.categoryBitMask = Category.bounds
        physicsBody?.contactTestBitMask = Category.ball
        physicsBody?.collisionBitMask = Category.ball
        layoutHUD()
    }

    // MARK: - Setup
    private func setupHUD() {
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .top
        addChild(scoreLabel)

        timerLabel.fontSize = 24
        timerLabel.fontColor = .white
        timerLabel.horizontalAlignmentMode = .right
        timerLabel.verticalAlignmentMode = .top
        addChild(timerLabel)

        layoutHUD()
        updateScoreLabel()
        updateTimerLabel()
    }

    private func layoutHUD() {
        let inset: CGFloat = 16
        scoreLabel.position = CGPoint(x: frame.minX + inset, y: frame.maxY - inset)
        timerLabel.position = CGPoint(x: frame.maxX - inset, y: frame.maxY - inset)
    }

    private func updateScoreLabel() {
        scoreLabel.text = "Score: \(score)"
    }

    private func updateTimerLabel() {
        timerLabel.text = "Time: \(Int(ceil(max(0, timeRemaining))))s"
    }

    private func setupPlayer() {
        playerNode.fillColor = .blue
        playerNode.strokeColor = .white
        playerNode.lineWidth = 2
        playerNode.position = CGPoint(x: frame.midX, y: frame.minY + 100)
        playerNode.zPosition = 10
        playerNode.physicsBody = SKPhysicsBody(circleOfRadius: 18)
        playerNode.physicsBody?.isDynamic = false
        playerNode.physicsBody?.categoryBitMask = Category.player
        playerNode.physicsBody?.contactTestBitMask = Category.ball
        addChild(playerNode)

        numberLabel.fontSize = 16
        numberLabel.fontColor = .white
        numberLabel.verticalAlignmentMode = .center
        numberLabel.horizontalAlignmentMode = .center
        numberLabel.zPosition = 20
        numberLabel.text = "10"
        playerNode.addChild(numberLabel)
    }

    private func setupBall() {
        ballNode.fillColor = .white
        ballNode.strokeColor = .black
        ballNode.lineWidth = 2
        ballNode.position = CGPoint(x: frame.midX, y: frame.midY)
        ballNode.zPosition = 10
        ballNode.physicsBody = SKPhysicsBody(circleOfRadius: 12)
        ballNode.physicsBody?.affectedByGravity = false
        ballNode.physicsBody?.friction = 0.2
        ballNode.physicsBody?.restitution = 0.8
        ballNode.physicsBody?.linearDamping = 0.4
        ballNode.physicsBody?.angularDamping = 0.8
        ballNode.physicsBody?.categoryBitMask = Category.ball
        ballNode.physicsBody?.contactTestBitMask = Category.cone | Category.bounds | Category.player
        ballNode.physicsBody?.collisionBitMask = Category.bounds | Category.player
        addChild(ballNode)
    }

    private func spawnCones(count: Int) {
        let safeRect = frame.insetBy(dx: 40, dy: 120)
        for _ in 0..<count {
            let cone = SKShapeNode(circleOfRadius: 10)
            cone.fillColor = .orange
            cone.strokeColor = .white
            cone.lineWidth = 2
            var p = randomPoint(in: safeRect)
            // Avoid spawning on top of the ball
            if ballNode.parent != nil {
                while distance(p, ballNode.position) < 60 {
                    p = randomPoint(in: safeRect)
                }
            }
            cone.position = p
            cone.zPosition = 5
            cone.name = "cone"
            cone.physicsBody = SKPhysicsBody(circleOfRadius: 10)
            cone.physicsBody?.isDynamic = false
            cone.physicsBody?.categoryBitMask = Category.cone
            cone.physicsBody?.contactTestBitMask = Category.ball
            cone.physicsBody?.collisionBitMask = Category.none
            addChild(cone)
        }
    }

    private func randomPoint(in rect: CGRect) -> CGPoint {
        let x = CGFloat.random(in: rect.minX...rect.maxX)
        let y = CGFloat.random(in: rect.minY...rect.maxY)
        return CGPoint(x: x, y: y)
    }

    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let dx = a.x - b.x
        let dy = a.y - b.y
        return sqrt(dx*dx + dy*dy)
    }

    private func centerCameraIfNeeded() {
        // Placeholder in case camera is added later
    }

    // MARK: - Public Controls
    func startDrill() {
        guard !isRunning else { return }
        isRunning = true
        timeRemaining = max(1, timeRemaining)
        addInitialBallImpulse()
    }

    func resetDrill() {
        removeAllChildren()
        setupHUD()
        setupPlayer()
        setupBall()
        removeAllCones()
        spawnCones(count: 5)
        score = 0
        timeRemaining = 30
        lastUpdateTime = 0
        isRunning = false
        ballNode.physicsBody?.velocity = .zero
        ballNode.position = CGPoint(x: frame.midX, y: frame.midY)
        updateTimerLabel()
    }

    // Apply avatar styling
    func applyAvatarStyling(name: String?, number: Int?, jerseyHex: String?) {
        if let hex = jerseyHex, let color = UIColor(hex: hex) {
            playerNode.fillColor = SKColor(color)
        }
        if let number = number {
            numberLabel.text = "\(number)"
        }
    }

    private func addInitialBallImpulse() {
        let angle = CGFloat.random(in: 0..<(2 * .pi))
        let power: CGFloat = 180
        let dx = cos(angle) * power
        let dy = sin(angle) * power
        ballNode.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
    }

    private func removeAllCones() {
        enumerateChildNodes(withName: "cone") { node, _ in
            node.removeFromParent()
        }
    }

    // MARK: - Touch handling (drag player)
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else { return }
        let p = t.location(in: self)
        // Clamp within frame
        let clampedX = max(frame.minX + 20, min(p.x, frame.maxX - 20))
        let clampedY = max(frame.minY + 60, min(p.y, frame.maxY - 20))
        playerNode.position = CGPoint(x: clampedX, y: clampedY)
    }

    // MARK: - Game loop
    override func update(_ currentTime: TimeInterval) {
        guard isRunning else { return }
        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        timeRemaining -= dt
        if timeRemaining <= 0 {
            timeRemaining = 0
            isRunning = false
            ballNode.physicsBody?.velocity = .zero
        }
        updateTimerLabel()
    }

    // MARK: - Contacts
    func didBegin(_ contact: SKPhysicsContact) {
        let names = [contact.bodyA.node?.name, contact.bodyB.node?.name]
        if names.contains("cone") && (contact.bodyA.categoryBitMask == Category.ball || contact.bodyB.categoryBitMask == Category.ball) {
            if let cone = (contact.bodyA.node?.name == "cone" ? contact.bodyA.node : (contact.bodyB.node?.name == "cone" ? contact.bodyB.node : nil)) {
                cone.removeFromParent()
                score += 1
                run(SKAction.wait(forDuration: 0.4)) { [weak self] in
                    self?.spawnCones(count: 1)
                }
            }
        }
    }
}

