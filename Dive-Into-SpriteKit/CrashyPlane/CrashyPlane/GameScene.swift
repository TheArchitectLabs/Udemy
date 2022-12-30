//
//  GameScene.swift
//  CrashyPlane
//
//  Created by Michael & Diana Pascucci on 12/30/22.
//

import SpriteKit
import GameplayKit

@objcMembers
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - PROPERTIES
    // Images, fonts, and sounds
    let player = SKSpriteNode(imageNamed: "plane")
    
    // Other
    var touchingScreen = false
    var timer: Timer?
    
    // MARK: - METHODS
    override func didMove(to view: SKView) {
        player.position = CGPoint(x: -400, y: 250)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.texture!.size())
        addChild(player)
        
        player.physicsBody?.categoryBitMask = 1
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -5)
        physicsWorld.contactDelegate = self
        
        parallaxScroll(image: "sky", y: 0, z: -3, duration: 10, needsPhysics: false)
        parallaxScroll(image: "ground", y: -315, z: -1, duration: 6, needsPhysics: true)
        
        timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(createObstacle), userInfo: nil, repeats: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchingScreen = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchingScreen = false
    }
    
    override func update(_ currentTime: TimeInterval) {
        if touchingScreen {
            player.physicsBody?.velocity = CGVector(dx: 0, dy: 300)
        }
        let value = player.physicsBody!.velocity.dy * 0.001
        let rotate = SKAction.rotate(toAngle: value, duration: 0.1)
        player.run(rotate)
    }
    
    func parallaxScroll(image: String, y: CGFloat, z: CGFloat, duration: Double, needsPhysics: Bool) {
        for i in 0...1 {
            let node = SKSpriteNode(imageNamed: image)
            
            node.position = CGPoint(x: 1023 * CGFloat(i), y: y)
            node.zPosition = z
            addChild(node)
            
            if needsPhysics {
                node.physicsBody = SKPhysicsBody(texture: node.texture!, size: node.texture!.size())
                node.physicsBody?.isDynamic = false
                node.physicsBody?.contactTestBitMask = 1
                node.name = "obstacle"
            }
            
            let move = SKAction.moveBy(x: -1024, y: 0, duration: duration)
            let wrap = SKAction.moveBy(x: 1024, y: 0, duration: 0)
            
            let sequence = SKAction.sequence([move, wrap])
            let forever = SKAction.repeatForever(sequence)
            
            node.run(forever)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA == player {
            playerHit(nodeB)
        } else if nodeB == player {
            playerHit(nodeA)
        }
    }
    
    func createObstacle() {
        let obstacle = SKSpriteNode(imageNamed: "enemy-balloon")
        obstacle.zPosition = -2
        obstacle.position.x = 768
        addChild(obstacle)
        
        obstacle.physicsBody = SKPhysicsBody(texture: obstacle.texture!, size: obstacle.texture!.size())
        obstacle.physicsBody?.isDynamic = false
        obstacle.physicsBody?.contactTestBitMask = 1
        obstacle.name = "obstacle"
        
        let rand = GKRandomDistribution(lowestValue: -300, highestValue: 350)
        obstacle.position.y = CGFloat(rand.nextInt())
        
        let action = SKAction.moveTo(x: -768, duration: 9)
        obstacle.run(action)
    }
    
    func playerHit(_ node: SKNode) {
        if node.name == "obstacle" {
            if let explosion = SKEmitterNode(fileNamed: "PlayerExplosion") {
                explosion.position = player.position
                addChild(explosion)
            }
            player.removeFromParent()
        }
    }
}
