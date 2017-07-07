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
    static var gameState: GameState = .ready
    
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
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
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
                if score % 5 == 0 && score != 0 && score <= 100{
                    healthIncrement += 0.002
                }
            }
        }
        else if GameScene.gameState == .gameOver{
            if score > highScore {
                saveHighScore()
            }
            /* Reset score */
            score = 0
            
            /* Reset GameState */
            GameScene.gameState = .ready
            
            /* Reset HealthIncrement */
            healthIncrement = 0.005
            
            /* Reset Health */
            health = 1
        }
        
        /* Update high score */
        highScoreLabel.text = String(highScore)
    }
      
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        if GameScene.gameState == .ready {
            return
        }
        
        /* Decrease Health with fading out */
        if health > 0.15 {
        health -= healthIncrement
        }
        else if health < 0.05 {
            health -= 0.005
        }
        else if health < 0.10{
            health -= healthIncrement/2
        }
        else{
            health -= healthIncrement*0.75
        }
        
        /* Has the player ran out of health? */
        if health < 0 {
            GameScene.gameState = .gameOver
            if score > highScore {
                saveHighScore()
            }
            
            /* Reset score */
            score = 0
            
            /* Reset GameState */
            GameScene.gameState = .ready
            
            /* Reset HealthIncrement */
            healthIncrement = 0.005
            
            /* Reset Health */
            health = 1
            return
        }

    }
    
    func saveHighScore() {
        UserDefaults.standard.set(score, forKey: "highScore")
    }
}
