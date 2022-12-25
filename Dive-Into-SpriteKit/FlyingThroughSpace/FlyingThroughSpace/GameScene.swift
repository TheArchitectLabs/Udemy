//
//  GameScene.swift
//  FlyingThroughSpace
//
//  Created by Michael & Diana Pascucci on 12/25/22.
//

import SpriteKit
import GameplayKit
import CoreMotion //- Needed for tilt movement control

class GameScene: SKScene {
    
    // MARK: - PROPERTIES
    let player = SKSpriteNode(imageNamed: "player-rocket")
    var touchingPlayer: Bool = false
    
    let motionManager = CMMotionManager()
        
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
        player.position.x = -300
        player.zPosition = 1
        addChild(player)
        
        motionManager.startAccelerometerUpdates()
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
        
        if let accelerometerData = motionManager.accelerometerData {
            let changeX = CGFloat(accelerometerData.acceleration.y) * 100
            let changeY = CGFloat(accelerometerData.acceleration.x) * 100
            
            player.position.x -= changeX
            player.position.y += changeY
        }
    }
}
