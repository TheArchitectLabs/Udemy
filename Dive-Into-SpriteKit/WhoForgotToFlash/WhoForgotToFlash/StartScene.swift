//
//  StartScene.swift
//  WhoForgotToFlash
//
//  Created by Michael & Diana Pascucci on 12/28/22.
//

import SpriteKit

@objcMembers
class StartScene: SKScene {
    
    // MARK: - PROPERTIES
    // Images, Sprites, and Fonts
    let titleLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
    let startButton = SKSpriteNode(imageNamed: "green-light")
    let startLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
    
    override func didMove(to view: SKView) {
        titleLabel.zPosition = 1
        titleLabel.position = CGPoint(x: 0, y: 250)
        titleLabel.text = "Who Forgot To Flash?"
        titleLabel.fontSize = 60
        addChild(titleLabel)
        
        startLabel.zPosition = 1
        startLabel.position = CGPoint(x: 0, y: 0)
        startLabel.name = "start"
        startLabel.text = "START"
        addChild(startLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Do something when the buttons are touched
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        let tappedNodes = nodes(at: location)
        guard let tapped = tappedNodes.first else { return }
        
        if tapped.name == "start" {
            if let gameScene = GameScene(fileNamed: "GameScene")  {
                let transition = SKTransition.doorsOpenHorizontal(withDuration: 0.5)
                gameScene.scaleMode = .aspectFill
                self.view?.presentScene(gameScene, transition: transition)
            }
        }
    }
}
