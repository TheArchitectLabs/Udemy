//
//  EndScene.swift
//  WhoForgotToFlash
//
//  Created by Michael & Diana Pascucci on 12/28/22.
//

import SpriteKit

class EndScene: SKScene {
    
    // MARK: - PROPERTIES
    // Images, Sprites, and Fonts
    let gameOver = SKSpriteNode(imageNamed: "gameOver1")
    let home = SKLabelNode(fontNamed: "Optima-ExtraBlack")
    let play = SKLabelNode(fontNamed: "Optima-ExtraBlack")
    let hiScoreLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
    
    var hiScore: Int = 0
    
    // MARK: - METHODS
    override func didMove(to view: SKView) {
        
        hiScore = UserDefaults.standard.integer(forKey: "hiScore")
        
        gameOver.zPosition = 1
        addChild(gameOver)
        
        home.zPosition = 1
        home.position = CGPoint(x: -200, y: -250)
        home.horizontalAlignmentMode = .left
        home.name = "home"
        home.text = "HOME"
        addChild(home)
        
        play.zPosition = 1
        play.position = CGPoint(x: 200, y: -250)
        play.horizontalAlignmentMode = .right
        play.name = "play"
        play.text = "PLAY AGAIN"
        addChild(play)
        
        hiScoreLabel.position = CGPoint(x: 0, y: -330)
        hiScoreLabel.text = "High Score: \(hiScore)"
        hiScoreLabel.zPosition = 1
        addChild(hiScoreLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        let tappedNodes = nodes(at: location)
        guard let tapped = tappedNodes.first else { return }
        
        if tapped.name == "home" {
            if let startScene = StartScene(fileNamed: "StartScene")  {
                let transition = SKTransition.fade(withDuration: 0.5)
                startScene.scaleMode = .aspectFill
                self.view?.presentScene(startScene, transition: transition)
            }
        } else if tapped.name == "play" {
            if let gameScene = GameScene(fileNamed: "GameScene") {
                let transition = SKTransition.reveal(with: SKTransitionDirection.down, duration: 0.5)
                gameScene.scaleMode = .aspectFill
                self.view?.presentScene(gameScene, transition: transition)
            }
        }
    }
}
