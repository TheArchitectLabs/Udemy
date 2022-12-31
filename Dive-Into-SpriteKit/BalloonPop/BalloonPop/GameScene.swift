//
//  GameScene.swift
//  BalloonPop
//
//  Created by Michael & Diana Pascucci on 12/31/22.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // MARK: - PROPERTIES
    // Images, fonts, and sounds
    let background = SKSpriteNode(imageNamed: "clouds")
    let scoreLabel = SKLabelNode(fontNamed: "Noteworthy-Bold")
    let movesLabel = SKLabelNode(fontNamed: "Noteworthy-Bold")
    let music = SKAudioNode(fileNamed: "marty-gots-a-plan")
    
    // Other
    var cols = [[Item]]()
    let itemSize: CGFloat = 50
    let itemsPerColumn = 12
    let itemsPerRow = 18
    var currentMatches = Set<Item>()
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "SCORE: \(score)"
        }
    }
    var movesRemaining: Int = 100 {
        didSet {
            movesLabel.text = "MOVES: \(max(0,movesRemaining))"
        }
    }
    
    // MARK: - METHODS
    override func didMove(to view: SKView) {
        
        // Background
        background.zPosition = -3
        addChild(background)
        
        // Score Label
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: frame.maxX - 80, y: frame.maxY  - 80)
        addChild(scoreLabel)
        score = 0
        
        // Moves Label
        movesLabel.horizontalAlignmentMode = .left
        movesLabel.position = CGPoint(x: frame.minX + 80, y: frame.maxY - 80)
        addChild(movesLabel)
        movesRemaining = 100
        
        // Music
        addChild(music)
        
        for x in 0..<itemsPerRow {
            var col = [Item]()
            
            for y in 0..<itemsPerColumn {
                let item = createItem(row: y, col: x)
                col.append(item)
            }
            cols.append(col)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        guard let tappedItem = item(at: location) else { return }
        
        isUserInteractionEnabled = false
        currentMatches.removeAll()
        
        run(SKAction.playSoundFileNamed("match", waitForCompletion: false))
        
        movesRemaining -= 1
        
        if tappedItem.name == "bomb" {
            triggerSpecialItem(tappedItem)
        }
        match(item: tappedItem)
        removeMatches()
        moveDown()
        adjustScore()
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
    
    func position( for item: Item) -> CGPoint {
        let offsetX: CGFloat = -430
        let offsetY: CGFloat = -300
        let x = offsetX + itemSize * CGFloat(item.col)
        let y = offsetY + itemSize * CGFloat(item.row)
        
        return CGPoint(x: x, y: y)
    }
    
    func createItem(row: Int, col: Int, startOffScreen: Bool = false) -> Item {
        let itemImage: String
        if startOffScreen && GKRandomSource.sharedRandom().nextInt(upperBound: 25) == 0 {
            itemImage = "bomb"
        } else {
            let itemImages = ["balloon-black", "balloon-blue", "balloon-green", "balloon-orange", "balloon-purple", "balloon-red", "balloon-yellow"]
            itemImage = itemImages[GKRandomSource.sharedRandom().nextInt(upperBound: itemImages.count)]
        }
        let item = Item(imageNamed: itemImage)
        item.name = itemImage
        item.row = row
        item.col = col
        
        if startOffScreen {
            let finalPosition = position(for: item)
            item.position = finalPosition
            item.position.y = 600
            let action = SKAction.move(to: finalPosition, duration: 0.4)
            item.run(action)
            self.isUserInteractionEnabled = true
            if movesRemaining <= 0 {
                isUserInteractionEnabled = false
                endGame()
            }
        } else {
            item.position = position(for: item)
        }
        
        addChild(item)
        return item
    }
    
    func item(at point: CGPoint) -> Item? {
        let items = nodes(at: point).compactMap { $0 as? Item }
        return items.first
    }
    
    func match(item original: Item) {
        var checkItems = [Item?]()
        
        currentMatches.insert(original)
        let pos = original.position
        checkItems.append(item(at: CGPoint(x: pos.x, y: pos.y - itemSize)))
        checkItems.append(item(at: CGPoint(x: pos.x, y: pos.y + itemSize)))
        checkItems.append(item(at: CGPoint(x: pos.x - itemSize, y: pos.y)))
        checkItems.append(item(at: CGPoint(x: pos.x + itemSize, y: pos.y)))
        
        for case let check? in checkItems {
            if currentMatches.contains(check) { continue }
            if check.name == original.name || original.name == "bomb" {
                match(item: check)
            }
        }
    }
    
    func removeMatches() {
        
        let sortedMatches = currentMatches.sorted { $0.row > $1.row }
        for item in sortedMatches {
            cols[item.col].remove(at: item.row)
            item.removeFromParent()
        }
    }
    
    func moveDown() {
        for (columnIndex, col) in  cols.enumerated() {
            for (rowIndex, item) in col.enumerated() {
                item.row = rowIndex
                
                let action = SKAction.move(to: position(for: item), duration: 0.1)
                item.run(action)
            }
            
            while cols[columnIndex].count < itemsPerColumn {
                let item = createItem(row: cols[columnIndex].count, col: columnIndex, startOffScreen: true)
                cols[columnIndex].append(item)
            }
        }
    }
    
    func triggerSpecialItem(_ item: Item) {
        run(SKAction.playSoundFileNamed("smart-bomb", waitForCompletion: false))
        let multiBackground = SKSpriteNode(imageNamed: "multi-background")
        multiBackground.zPosition = -1
        multiBackground.name = "multi-background"
        addChild(multiBackground)
        
        let rotate = SKAction.rotate(byAngle: .pi, duration: 1)
        let duration = SKAction.repeat(rotate, count: 1)
        multiBackground.run(duration) {
            multiBackground.removeFromParent()
        }
    }
    
    func penalizePlayer() {
        let itemImages = ["balloon-black", "balloon-blue", "balloon-green", "balloon-orange", "balloon-purple", "balloon-red", "balloon-yellow"]
        
        for col in cols {
            for item in col {
                let randomNumber = GKRandomSource.sharedRandom().nextInt(upperBound: itemImages.count)
                let changeTo = itemImages[randomNumber]
                item.name = changeTo
                item.texture = SKTexture(imageNamed: changeTo)
            }
        }
    }
    
    func adjustScore() {
        let newScore = currentMatches.count
        
        if newScore == 1 {
            penalizePlayer()
        } else if newScore == 2 {
            // no change
        } else {
            let matchCount = min(newScore, 16)
            let scoreToAdd = pow(2, Double(matchCount))
            score += Int(scoreToAdd)
        }
    }
    
    func endGame() {
        let gameOver = SKSpriteNode(imageNamed: "game-over-1")
        gameOver.zPosition = 100
        addChild(gameOver)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if let scene = GameScene(fileNamed: "GameScene") {
                scene.scaleMode = .aspectFill
                self.view?.presentScene(scene)
            }
        }
    }
}
