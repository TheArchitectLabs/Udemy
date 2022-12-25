//
//  GameScene.swift
//  FlyingThroughSpace
//
//  Created by Michael & Diana Pascucci on 12/25/22.
//

import SpriteKit
import GameplayKit

let player = SKSpriteNode(imageNamed: "player-rocket")

class GameScene: SKScene {
        
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
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // this method is called when the user touches the screen

    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // this method is called when the user stops touching the screen
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // this method is called before each frame is rendered
    }
}
