//
//  GameScene.swift
//  WhoForgotToFlash
//
//  Created by Michael & Diana Pascucci on 12/26/22.
//

import SpriteKit
import GameplayKit

@objcMembers
class GameScene: SKScene {
    
    // MARK: - PROPERTIES
    // Images, Sprites, and Fonts
    let background = SKSpriteNode(imageNamed: "background-metal")
    let correct = SKSpriteNode(imageNamed: "correct")
    let wrong = SKSpriteNode(imageNamed: "wrong")
    let scoreLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
    var timeLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
    let headerLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
    let hiScoreLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
    let gameOver = SKSpriteNode(imageNamed: "gameOver1")
    
    // Sounds
    let music = SKAudioNode(fileNamed: "lobby-time")
    
    // Other
    var level: Int = 1
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "SCORE: \(score)"
        }
    }
    var startTime = 0.0
    var isGameRunning = true
    var answerArray = [SKSpriteNode]()
    var itemsToShow = 0
    
    let defaults = UserDefaults.standard
    var hiScore: Int = 0
    
    
    // MARK: - METHODS
    override func didMove(to view: SKView) {
        // this method is called when your game scene is ready to run
        hiScore = UserDefaults.standard.integer(forKey: "hiScore")
        
        // Score, Header, and Time
        scoreLabel.position = CGPoint(x: -480, y:  330)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.zPosition = 1
        
        timeLabel.position = CGPoint(x: 480, y: 330)
        timeLabel.horizontalAlignmentMode = .right
        timeLabel.zPosition = 1
        
        headerLabel.position = CGPoint(x: 0, y: 330)
        headerLabel.text = "Who Forgot To Flash?"
        headerLabel.zPosition = 1
        
        hiScoreLabel.position = CGPoint(x: -480, y: -330)
        hiScoreLabel.horizontalAlignmentMode = .left
        hiScoreLabel.text = "High Score: \(hiScore)"
        hiScoreLabel.zPosition = 1

        // Background
        background.name = "background"
        background.zPosition = -1
        addChild(background)
        background.addChild(scoreLabel)
        background.addChild(headerLabel)
        background.addChild(timeLabel)
        background.addChild(music)
        background.addChild(hiScoreLabel)
                
        createGrid()
        createLevel()
        
        score = 0
        hiScore = defaults.integer(forKey: "hiscore")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // this method is called when the user touches the screen
        guard let touch = touches.first else { return }
        guard isGameRunning else { return }
        
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        guard let tapped = tappedNodes.first else { return }
        
        if tapped.name == "correct" {
            correctAnswer(node: tapped)
        } else if tapped.name == "wrong" {
            wrongAnswer(node: tapped)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // this method is called when the user stops touching the screen
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // this method is called before each frame is rendered
        if isGameRunning {
            if startTime == 0 {
                startTime = currentTime
            }
            let timePassed = currentTime - startTime
            let remainingTime = Int(ceil(10-timePassed))
            timeLabel.text = "TIME: \(remainingTime)"
            timeLabel.alpha = 1
            
            if remainingTime <= 0 {
                isGameRunning = false
                gameOver.zPosition = 100
                addChild(gameOver)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    if let scene = GameScene(fileNamed: "GameScene") {
                        scene.scaleMode = .aspectFill
                        self.view?.presentScene(scene)
                    }
                }
            }
        } else {
            timeLabel.alpha = 0
        }
    }
    
    func createGrid() {
        let offsetX = -440
        let offsetY = -320
        
        for row in 0..<8 {
            for col in 0..<12 {
                let item = SKSpriteNode(imageNamed: "red-light")
                item.position = CGPoint(x: offsetX + (col * 80), y: offsetY + (row * 80))
                addChild(item)
            }
        }
    }
    
    func createLevel() {
        itemsToShow = 4 + level
        itemsToShow = min(itemsToShow, 96)
        
        let items = children.filter { $0.name != "background" }
        
        //let shuffled = (items as NSArray).shuffled() as! [SKSpriteNode]
        answerArray = (items as NSArray).shuffled() as! [SKSpriteNode]
        
        for item in answerArray {
            item.alpha = 0
        }
        
        flashLights(answerArray: answerArray, itemsToShow: itemsToShow)
    }
    
    func flashLights(answerArray: [SKSpriteNode], itemsToShow: Int) {
        answerArray[0].name = "correct"
        answerArray[0].alpha = 1
        
        let lights = [SKTexture(imageNamed: "green-light"), SKTexture(imageNamed: "red-light")]
        let change = SKAction.animate(with: lights, timePerFrame: 0.2)
        var delay = 1.0
        
        for i in 1..<itemsToShow {
            let item = answerArray[i]
            item.name = "wrong"
            item.alpha = 1
            
            let ourPause = SKAction.wait(forDuration: delay)
            let sequence = SKAction.sequence([ourPause, change])
            item.run(sequence)
            
            delay += 0.5
        }
        
        isUserInteractionEnabled = true
    }
    
    func correctAnswer(node: SKNode) {
        if let sparks = SKEmitterNode(fileNamed: "Sparks") {
            sparks.position = node.position
            addChild(sparks)
            
            score += 1
            startTime += 10
            run(SKAction.playSoundFileNamed("correct-3", waitForCompletion: false))
            
            if score > hiScore {
                UserDefaults.standard.setValue(score, forKey: "hiScore")
                hiScoreLabel.text = "High Score: \(hiScore)"
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                sparks.removeFromParent()
                self.level += 1
                self.createLevel()
            }
        }
        
        isUserInteractionEnabled = false
        
        
    }
    
    func wrongAnswer(node: SKNode) {
        run(SKAction.playSoundFileNamed("wrong-3", waitForCompletion: false))
        wrong.position = node.position
        wrong.zPosition = 5
        addChild(wrong)
        
        score -= 1
        
        let wait = SKAction.wait(forDuration: 0.5)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([wait, remove])
        
        wrong.run(sequence)
        
        isUserInteractionEnabled = false
        
        flashLights(answerArray: answerArray, itemsToShow: itemsToShow)
    }
}
