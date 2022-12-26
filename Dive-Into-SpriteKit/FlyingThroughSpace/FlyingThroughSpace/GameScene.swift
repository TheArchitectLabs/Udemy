//
//  GameScene.swift
//  FlyingThroughSpace
//
//  Created by Michael & Diana Pascucci on 12/25/22.
//

import SpriteKit
import GameplayKit

@objcMembers
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - PROPERTIES
    let player = SKSpriteNode(imageNamed: "player-rocket")
    var touchingPlayer: Bool = false
    var gameTimer: Timer?
    let scoreLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
    let music = SKAudioNode(fileNamed: "cyborg-ninja.mp3")
    var score = 0 {
        didSet {
            scoreLabel.text = "SCORE: \(score)"
        }
    }
        
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
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.45, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        
        physicsWorld.contactDelegate = self
        
        // Music
        addChild(music)
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
        
        for node in children {
            if node.position.x < -700 {
                node.removeFromParent()
            }
        }
    
        if player.position.x < -400 {
            player.position.x = -400
        } else if player.position.x > 400 {
            player.position.x = 400
        }
        
        if player.position.y < -300 {
            player.position.y = -300
        } else if player.position.y > 300 {
            player.position.y = 300
        }
    }
    
    func createEnemy() {
        let randomDistribution = GKRandomDistribution(lowestValue: -350, highestValue: 350)
        
        let enemySprite = SKSpriteNode(imageNamed: "enemy-ship")
        enemySprite.position = CGPoint(x: 1200, y: randomDistribution.nextInt())
        enemySprite.name = "enemy"
        enemySprite.zPosition = 1
        addChild(enemySprite)
        
        enemySprite.physicsBody = SKPhysicsBody(texture: enemySprite.texture!, size: enemySprite.size)
        enemySprite.physicsBody?.velocity = CGVector(dx: -400, dy: 0)
        enemySprite.physicsBody?.linearDamping = 0
        enemySprite.physicsBody?.affectedByGravity = false
        enemySprite.physicsBody?.categoryBitMask = 0
        
        enemySprite.physicsBody?.contactTestBitMask = 1
        
        createBonus()
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
        
        if node.name == "bonus" {
            score += 1
            let bonusSound = SKAction.playSoundFileNamed("bonus.wav", waitForCompletion: false)
            run(bonusSound)
            node.removeFromParent()
            return
        }
        
        if let particles = SKEmitterNode(fileNamed: "Explosion.sks") {
            particles.position = player.position
            particles.zPosition = 3
            addChild(particles)
        }
        
        player.removeFromParent()
        music.removeFromParent()
        
        let gameOver = SKSpriteNode(imageNamed: "gameOver-2")
        gameOver.zPosition = 10
        addChild(gameOver)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            
            if let scene = GameScene(fileNamed: "GameScene") {
                scene.scaleMode = .aspectFill
                self.view?.presentScene(scene)
            }
        }
        
        let explosion = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
        run(explosion)
    }
    
    func createBonus() {
        let randomDistribution = GKRandomDistribution(lowestValue: -350, highestValue: 350)
        
        let bonusSprite = SKSpriteNode(imageNamed: "energy")
        bonusSprite.position = CGPoint(x: 1200, y: randomDistribution.nextInt())
        bonusSprite.name = "bonus"
        bonusSprite.zPosition = 1
        addChild(bonusSprite)
        
        bonusSprite.physicsBody = SKPhysicsBody(texture: bonusSprite.texture!, size: bonusSprite.size)
        bonusSprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        bonusSprite.physicsBody?.linearDamping = 0
        bonusSprite.physicsBody?.affectedByGravity = false
        bonusSprite.physicsBody?.categoryBitMask = 0
        bonusSprite.physicsBody?.collisionBitMask = 0
        
        bonusSprite.physicsBody?.contactTestBitMask = 1
    }
}
