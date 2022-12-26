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
    
    // Sprites
    let background = SKSpriteNode(imageNamed: "space.jpg")
    let player = SKSpriteNode(imageNamed: "player-rocket")
    let objects: [String] = ["enemy-ship", "asteroid", "space-junk", "energy", "star"]
    let gameOver = SKSpriteNode(imageNamed: "gameOver-2")
    
    // Sounds
    let music = SKAudioNode(fileNamed: "cyborg-ninja.mp3")
    let bonusSound = SKAction.playSoundFileNamed("bonus.wav", waitForCompletion: false)
    let explosion = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
    
    
    var touchingPlayer: Bool = false
    var gameTimer: Timer?
    let scoreLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
    
    var score = 0 {
        didSet {
            scoreLabel.text = "SCORE: \(score)"
        }
    }
        
    // MARK: - METHODS
    override func didMove(to view: SKView) {
        // this method is called when your game scene is ready to run
        
        // Background (Space Picture)
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
        
        // Music
        addChild(music)

        // Timer
        gameTimer = Timer.scheduledTimer(timeInterval: 0.45, target: self, selector: #selector(createObject), userInfo: nil, repeats: true)
        
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
    
    func createObject() {
        let randomEnemyDistribution = GKRandomDistribution(lowestValue: -350, highestValue: 350)
        let randomSpriteChosen = Int.random(in: 0...4)
        let Sprite = SKSpriteNode(imageNamed: objects[randomSpriteChosen])
    
        Sprite.position = CGPoint(x: 1200, y: randomEnemyDistribution.nextInt())
                                                      
        if objects[randomSpriteChosen] == "star" {
            Sprite.name = "star"
        } else if objects[randomSpriteChosen] == "energy" {
            Sprite.name = "energy"
        } else {
            Sprite.name = "enemy"
        }

        Sprite.zPosition = 1
        addChild(Sprite)
        
        Sprite.physicsBody = SKPhysicsBody(texture: Sprite.texture!, size: Sprite.size)
        Sprite.physicsBody?.velocity = CGVector(dx: -400, dy: 0)
        Sprite.physicsBody?.linearDamping = 0
        Sprite.physicsBody?.affectedByGravity = false
        Sprite.physicsBody?.categoryBitMask = 0
        
        Sprite.physicsBody?.contactTestBitMask = 1
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
        
        if node.name == "star" {
            score += 2
            run(bonusSound)
            node.removeFromParent()
            return
        }
        
        if node.name == "energy" {
            score += 1
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
        
        gameOver.zPosition = 10
        addChild(gameOver)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if let scene = GameScene(fileNamed: "GameScene") {
                scene.scaleMode = .aspectFill
                self.view?.presentScene(scene)
            }
        }
    
        run(explosion)
    }
}
