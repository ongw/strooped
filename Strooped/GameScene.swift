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
    case title, ready, playing, gameOver, inTransition
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
    
    /* Tutorial Items */
    var tutorialScreen: SKNode!
    var redButton: MSButtonNode!
    var blueButton: MSButtonNode!
    
    /* Array of tile node children for rumble action */
    var tileNodes = [SKNode]()
    
    /* Health components */
    var healthBar: SKSpriteNode!
    /* Variable to determine speed of health decrease */
    var healthIncrement: CGFloat = 0.005
    
    /* Hard mode boolean */
    static var hardMode = false
    var hardModeButton: MSButtonNode!
    
    /* Set up button handlers */
    var playButton: MSButtonNode!
    var homeButton: MSButtonNode!
    var restartButton: MSButtonNode!
    
    /* Set up camera node */
    var cameraNode: SKCameraNode!
    let moveCameraRight : SKAction = SKAction.init(named: "MoveCameraRight")!
    let moveCameraLeft : SKAction = SKAction.init(named: "MoveCameraLeft")!
    
    /* Scoring */
    var score: Int = 0 {
        didSet {
            scoreLabel.text = String(score)
        }
    }
    
    /* High Score */
    var highScore: Int {
        get {
            if GameScene.hardMode {
                return UserDefaults.standard.integer(forKey: "hardHighScore")
            }
            else {
                return UserDefaults.standard.integer(forKey: "highScore")
            }
        }
        set {
            if GameScene.hardMode {
                UserDefaults.standard.set(newValue, forKey: "hardHighScore")
            }
            else {
                UserDefaults.standard.set(newValue, forKey: "highScore")
            }
        }
    }
    
    /* User Default Objects */
    var tutorialPlayed: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "tutorialPlayed")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "tutorialPlayed")
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
    
    /* Scroll layers */
    var scrollLayer1: SKNode!
    var scrollLayer2: SKNode!
     var scrollLayer3: SKNode!
     var scrollLayer4: SKNode!
     var scrollLayer5: SKNode!
    var scrollLayer6: SKNode!
    var scrollLayer7: SKNode!
    var scrollLayer8: SKNode!
    var scrollLayer9: SKNode!
    var scrollLayer10: SKNode!
    
    
    override func didMove(to view: SKView) {
        tileGrid = TileGrid()
        self.addChild(tileGrid)
        
        /* Disable multitouch */
        self.view?.isMultipleTouchEnabled = false
        
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
        
        /* Set up tutorial screen */
        tutorialScreen = childNode(withName: "tutorialScreen")!
        redButton = tutorialScreen.childNode(withName: "redButton") as! MSButtonNode
        blueButton = tutorialScreen.childNode(withName: "blueButton") as! MSButtonNode
        
        redButton.selectedHandler = {
            self.tutorialScreen.childNode(withName: "rightLabel")?.run(SKAction.fadeIn(withDuration: 0.5)) {
                self.tutorialScreen.run(self.bringUp)
            }
        }
        
        blueButton.selectedHandler = {
            self.tutorialScreen.childNode(withName: "wrongLabel")?.run(SKAction.fadeIn(withDuration: 0.5))
        }
        
        /* Set up camera */
        cameraNode = self.childNode(withName: "camera") as! SKCameraNode
        self.camera = cameraNode
        
        /* Set up restart button */
        restartButton = gameOverScreen.childNode(withName: "restartButton") as! MSButtonNode
        
        /* Set up restart button selection handler */
        restartButton.selectedHandler = {
            self.gameOverScreen.run(self.bringUp)
            self.gameReset()
        }
        
        /* Set up play button */
        playButton = childNode(withName: "playButton") as! MSButtonNode
        
        /* Set up play button selection handler */
        playButton.selectedHandler = {
            self.gameOverScreen.run(self.bringUp)
            self.gameReset()
            self.cameraNode.run(self.moveCameraRight)
            if !self.tutorialPlayed {
                /* Bring down Tutorial */
                self.tutorialScreen.run(self.bringDown)
                self.tutorialPlayed = true
            }
        }
        
        /* Set up home button */
        homeButton = gameOverScreen.childNode(withName: "homeButton") as! MSButtonNode
        
        /* Set up home button selection handler */
        homeButton.selectedHandler = {
            self.cameraNode.run(self.moveCameraLeft) {
                self.gameOverScreen.run(self.bringUp)
                self.gameReset()
            }
        }
        
        /* Set up hard mode button */
        hardModeButton = childNode(withName: "hardModeButton") as! MSButtonNode
        
        /* Set up hard mode button selection handler */
        hardModeButton.selectedHandler = {
            GameScene.hardMode = !GameScene.hardMode
            self.highScoreLabel.text = String(self.highScore)
            if GameScene.hardMode {
                (self.hardModeButton.childNode(withName: "hardModeButtonVisual") as! SKSpriteNode).texture = SKTexture(imageNamed: "button_select")
            }
            else {
                (self.hardModeButton.childNode(withName: "hardModeButtonVisual") as! SKSpriteNode).texture = SKTexture(imageNamed: "button_deselect")
            }
        }
        
        /* Get tile nodes */
        tileNodes = tileGrid.getTileNodes()
        
        /* Set up scroll layers */
        scrollLayer1 = self.childNode(withName: "scrollLayer1")!
        scrollLayer2 = self.childNode(withName: "scrollLayer2")!
        scrollLayer3 = self.childNode(withName: "scrollLayer3")!
        scrollLayer4 = self.childNode(withName: "scrollLayer4")!
        scrollLayer5 = self.childNode(withName: "scrollLayer5")!
        scrollLayer6 = self.childNode(withName: "scrollLayer6")!
        scrollLayer7 = self.childNode(withName: "scrollLayer7")!
        scrollLayer8 = self.childNode(withName: "scrollLayer8")!
        scrollLayer9 = self.childNode(withName: "scrollLayer9")!
        scrollLayer10 = self.childNode(withName: "scrollLayer10")!
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
                if score % 5 == 0 && score != 0 && score <= 100{
                    healthIncrement += 0.001
                }
                if score % 20 == 0 && score != 0 && score <= 80 {
                    tileGrid.addColour()
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
        
        /* Scroll banners */
        self.scroll(scrollLayer: scrollLayer1, speedCoefficient: 0.6)
        self.scroll(scrollLayer: scrollLayer2, speedCoefficient: -0.5)
        self.scroll(scrollLayer: scrollLayer3, speedCoefficient: 0.4)
        self.scroll(scrollLayer: scrollLayer4, speedCoefficient: 0.6)
        self.scroll(scrollLayer: scrollLayer5, speedCoefficient: -0.4)
        self.scroll(scrollLayer: scrollLayer6, speedCoefficient: 0.6)
        self.scroll(scrollLayer: scrollLayer7, speedCoefficient: -0.4)
        self.scroll(scrollLayer: scrollLayer8, speedCoefficient: 0.5)
        self.scroll(scrollLayer: scrollLayer9, speedCoefficient: -0.6)
        self.scroll(scrollLayer: scrollLayer10, speedCoefficient: 0.4)
        
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
        
        /* Reset tiles */
        tileGrid.randomizeNormalTiles(forReset: true)
        tileGrid.changeMainTile()
        tileNodes = tileGrid.getTileNodes()
    }
    
    func saveHighScore() {
        if GameScene.hardMode {
            UserDefaults.standard.set(score, forKey: "hardHighScore")
        }
        else {
            UserDefaults.standard.set(score, forKey: "highScore")
        }
        highScoreLabel.text = String(highScore)
    }
    
    func scroll(scrollLayer: SKNode!, speedCoefficient: CGFloat) {
        /* Scroll */
        
        scrollLayer.position.x -= speedCoefficient
        
        if speedCoefficient > 0 {
            for element in scrollLayer.children as! [SKSpriteNode] {
                
                /* Get ground node position, convert node position to scene space */
                let elementPosition = scrollLayer.convert(element.position, to: self)
                
                /* Check if ground sprite has left the scene */
                if elementPosition.x <= -element.size.width / 2 {
                    
                    /* Reposition ground sprite to the second starting position */
                    let newPosition = CGPoint(x: (self.size.width / 2) + element.size.width, y: elementPosition.y)
                    
                    /* Convert new node position back to scroll layer space */
                    element.position = self.convert(newPosition, to: scrollLayer)
                }
            }
        }
        else {
            for element in scrollLayer.children as! [SKSpriteNode] {
                
                /* Get ground node position, convert node position to scene space */
                let elementPosition = scrollLayer.convert(element.position, to: self)
                
                /* Check if ground sprite has left the scene */
                if elementPosition.x >= (self.size.width / 2) + element.size.width {
                    
                    /* Reposition ground sprite to the second starting position */
                    let newPosition = CGPoint(x: -element.size.width / 2, y: elementPosition.y)
                    
                    /* Convert new node position back to scroll layer space */
                    element.position = self.convert(newPosition, to: scrollLayer)
                }
            }
        }
    }
    
    func resetHighScore() {
        //Sets the integer value for the key "highscore" to be equal to 0
        UserDefaults.standard.set(0, forKey: "highScore")
        UserDefaults.standard.set(0, forKey: "hardHighScore")
        //Synchronizes the NSUserDefaults
        UserDefaults.standard.synchronize()
        highScoreLabel.text = String(highScore)
    }
}
