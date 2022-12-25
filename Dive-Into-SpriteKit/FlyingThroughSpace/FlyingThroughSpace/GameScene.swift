//
//  GameScene.swift
//  FlyingThroughSpace
//
//  Created by Michael & Diana Pascucci on 12/25/22.
//

import SpriteKit
import GameplayKit
//import CoreMotion //- Needed for tilt movement control

@objcMembers
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - PROPERTIES
    let player = SKSpriteNode(imageNamed: "player-rocket")
    var touchingPlayer: Bool = false
    var gameTimer: Timer?
    let scoreLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
    var score = 0 {
        didSet {
            scoreLabel.text = "SCORE: \(score)"
        }
    }
    
//    let motionManager = CMMotionManager()
        
    // MARK: - METHODS
    override func didMove(to view: SKView) {
        // this method is called when your game scene is ready to run
        
        // Background (Space Picture)
        let background = SKSpriteNode(imageNamed: "space.jpg")
        background.zPosition = -1
        addChild(background)
        
        // Particles (Space Dust)
        if let particles = SKEmitterNode(fileNamed: "SpaceDust") {
            particles.position.x = 512
            particles.advanceSimulationTime(10)
            addChild(particles)
        }
        
        // Player (Rocket Ship)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.categoryBitMask = 1
        player.physicsBody?.affectedByGravity = false
        player.position.x = -300
        player.zPosition = 1
        addChild(player)
        
        // Score Label
        scoreLabel.zPosition = 2
        scoreLabel.position.y = 200
        addChild(scoreLabel)
        score = 0
        
//        motionManager.startAccelerometerUpdates()
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        
        physicsWorld.contactDelegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // this method is called when the user touches the screen
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        if tappedNodes.contains(player) {
            touchingPlayer = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // this method is called when the user moves their finger after touchesBegan but before touchesEnded
        
        guard touchingPlayer else { return }
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        player.position = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // this method is called when the user stops touching the screen
        
        touchingPlayer = false
    }
    
    override func update(_ currentTime: TimeInterval) {
        // this method is called before each frame is rendered
        
        // Uncomment this code to implement tilt controls
//        if let accelerometerData = motionManager.accelerometerData {
//            let changeX = CGFloat(accelerometerData.acceleration.y) * 100
//            let changeY = CGFloat(accelerometerData.acceleration.x) * 100
//
//            player.position.x -= changeX
//            player.position.y += changeY
//        }
    }
    
    func createEnemy() {
        let randomDistribution = GKRandomDistribution(lowestValue: -350, highestValue: 350)
        
        let enemySprite = SKSpriteNode(imageNamed: "enemy-ship")
        enemySprite.position = CGPoint(x: 1200, y: randomDistribution.nextInt())
        enemySprite.name = "enemy"
        enemySprite.zPosition = 1
        addChild(enemySprite)
        
        enemySprite.physicsBody = SKPhysicsBody(texture: enemySprite.texture!, size: enemySprite.size)
        enemySprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        enemySprite.physicsBody?.linearDamping = 0
        enemySprite.physicsBody?.affectedByGravity = false
        enemySprite.physicsBody?.categoryBitMask = 0
        
        enemySprite.physicsBody?.contactTestBitMask = 1
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA == player {
            playerHit(nodeB)
        } else {
            playerHit(nodeA)
        }
    }
    
    func playerHit(_ node: SKNode) {
        player.removeFromParent()
    }
}
