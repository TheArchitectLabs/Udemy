//
//  GameScene.swift
//  CrashyPlane
//
//  Created by Michael & Diana Pascucci on 12/30/22.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // MARK: - PROPERTIES
    // Images, fonts, and sounds
    let player = SKSpriteNode(imageNamed: "plane")
    
    // Other
    var touchingScreen = false
    
    // MARK: - METHODS
    override func didMove(to view: SKView) {
        player.position = CGPoint(x: -400, y: 250)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.texture!.size())
        addChild(player)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -5)
        
        parallaxScroll(image: "sky", y: 0, z: -3, duration: 10, needsPhysics: false)
        parallaxScroll(image: "ground", y: -315, z: -1, duration: 6, needsPhysics: true)
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
            
            let move = SKAction.moveBy(x: -1024, y: 0, duration: duration)
            let wrap = SKAction.moveBy(x: 1024, y: 0, duration: 0)
            
            let sequence = SKAction.sequence([move, wrap])
            let forever = SKAction.repeatForever(sequence)
            
            node.run(forever)
        }
    }
    
    func createObstacle() {
        
    }
}
