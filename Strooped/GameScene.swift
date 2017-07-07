//
//  GameScene.swift
//  Strooped
//
//  Created by Wes Ong on 2017-07-03.
//  Copyright © 2017 Wes Ong. All rights reserved.
//

import SpriteKit
import GameplayKit

/* Tracking enum for current game state */
enum GameState {
    case title, ready, playing, gameOver
}

class GameScene: SKScene {
    
    /* Initialize game elements and game state */
    var tileGrid: TileGrid!
    var scoreLabel: SKLabelNode!
    var highScoreLabel: SKLabelNode!
    var background: SKSpriteNode!
    static var gameState: GameState = .ready
    
    /* Initialize tile rumble actions */
    let tileRumble:SKAction = SKAction.init(named: "TileRumble")!
    let tileRumble1:SKAction = SKAction.init(named: "TileRumble1")!
    let subtleRumble:SKAction = SKAction.init(named: "SubtleRumble")!
    let subtleRumble1:SKAction = SKAction.init(named: "SubtleRumble1")!
    
    /* Game Over Items */
    var gameOverScreen: SKNode!
    let bringDown:SKAction = SKAction.init(named: "BringDown")!
    let bringUp:SKAction = SKAction.init(named: "BringUp")!
    var restartButton: MSButtonNode!
    
    /* Array of tile node children for rumble action */
    var tileNodes = [SKNode]()
    
    /* Health components */
    var healthBar: SKSpriteNode!
    /* Variable to determine speed of health decrease */
    var healthIncrement: CGFloat = 0.005
    
    /* Scoring */
    var score: Int = 0 {
        didSet {
            scoreLabel.text = String(score)
        }
    }
    
    /* High Score */
    var highScore: Int {
        get {
            return UserDefaults.standard.integer(forKey: "highScore")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "highScore")
        }
    }
    
    /* Health */
    var health: CGFloat = 1.0 {
        didSet {
            /* Scale health bar between 0.0 -> 1.0 e.g 0 -> 100% */
            healthBar.xScale = health
            
            /* Cap Health */
            if health > 1.0 { health = 1.0 }
        }
    }
    
    
    override func didMove(to view: SKView) {
        tileGrid = TileGrid()
        self.addChild(tileGrid)
        
        /* Set up scoring labels */
        scoreLabel = childNode(withName: "scoreLabel") as! SKLabelNode
        highScoreLabel = childNode(withName: "highScoreLabel") as! SKLabelNode
        highScoreLabel.text = String(highScore)
        
        /* Set up health bar */
        healthBar = childNode(withName: "healthBar") as! SKSpriteNode
        
        /* Set up background */
        background = childNode(withName: "background") as! SKSpriteNode
        
        /*Set up game over screen */
        gameOverScreen = childNode(withName: "gameOverScreen")!
        gameOverScreen.isUserInteractionEnabled = true
        for node in gameOverScreen.children {
            node.isUserInteractionEnabled = true
        }
        
         restartButton = childNode(withName: "//restartButton") as! MSButtonNode
        
        /* Set up restart button selection handler */
        restartButton.selectedHandler = {
            self.gameOverScreen.run(self.bringUp)
            self.gameReset()
        }

        
        /* Get tile nodes */
        tileNodes = tileGrid.getTileNodes()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if GameScene.gameState == .gameOver {
            return
        }
        
        /* Bool to check if tile was tapped */
        var hitTile = false
        
        /* Iterate touch through TileGrid and ColorTile child nodes */
        for node in nodes(at: touches.first!.location(in: self)) {
            node.touchesBegan(touches, with: event)
            if String(describing: type(of: node)) == "ColorTile" {
                hitTile = true
            }
        }
        
        if GameScene.gameState != .gameOver && hitTile{
            if ColorTile.selectedColor != .null {
                /* Increment Score */
                score += 1
                
                /* Reset Health */
                health = 1
                
                /* Increase speed of health decrease every 5 score */
                if score % 5 == 0 && score != 0 && score <= 75{
                    healthIncrement += 0.002
                }
            }
        }
        else if GameScene.gameState == .gameOver{
            if score > highScore {
                saveHighScore()
            }
            gameOver()
        }
        
        /* Update tile nodes */
        tileNodes = tileGrid.getTileNodes()
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        if GameScene.gameState == .ready || GameScene.gameState == .gameOver {
            return
        }
        
        /* Fade background */
        background.alpha = health*2
        
        /* Decrease Health with fading out */
        if health > 0.15 {
            health -= healthIncrement
        }
        else if health < 0.05 {
            health -= 0.003
        }
        else if health < 0.10{
            health -= healthIncrement/2
        }
        else{
            health -= healthIncrement*0.75
        }
        
        if health < 0.25 {
            for tile in tileNodes {
                if !tile.hasActions() {
                    if arc4random_uniform(2) < 1 {
                        tile.run(tileRumble)
                    }
                    else {
                        tile.run(tileRumble1)
                    }
                }
            }
        }
        else if health < 0.5 {
            for tile in tileNodes {
                if !tile.hasActions() {
                    if arc4random_uniform(2) < 1 {
                        tile.run(subtleRumble)
                    }
                    else {
                        tile.run(subtleRumble1)
                    }
                }
            }
        }
        
        /* Has the player ran out of health? */
        if health < 0 {
            GameScene.gameState = .gameOver
            if score > highScore {
                saveHighScore()
            }
            gameOver()
            return
        }
    }
    
    func gameOver() {
        gameOverScreen.run(bringDown)
    }
    
    
    func gameReset() {
        /* Reset score */
        score = 0
        
        /* Reset GameState */
        GameScene.gameState = .ready
        
        /* Reset HealthIncrement */
        healthIncrement = 0.005
        
        /*Reset Background */
        background.alpha = 1
        
        /* Reset Health */
        health = 1
    }
    
    func saveHighScore() {
        UserDefaults.standard.set(score, forKey: "highScore")
        highScoreLabel.text = String(highScore)
    }
    
    func resetHighScore() {
        //Sets the integer value for the key "highscore" to be equal to 0
        UserDefaults.standard.set(0, forKey: "highScore")
        //Synchronizes the NSUserDefaults
        UserDefaults.standard.synchronize()
        highScoreLabel.text = String(highScore)
    }
}
