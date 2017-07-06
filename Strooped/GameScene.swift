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
    
    var tileGrid: TileGrid!
    var testLabel: SKLabelNode!
    static var gameState: GameState = .ready
    
    override func didMove(to view: SKView) {
        tileGrid = TileGrid()
        self.addChild(tileGrid)
        
        testLabel = childNode(withName: "testLabel") as! SKLabelNode
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Iterate touch through TileGrid and ColorTile child nodes */
        for node in nodes(at: touches.first!.location(in: self)) {
            node.touchesBegan(touches, with: event)
        }
        
        if GameScene.gameState != .gameOver {
            testLabel.fontColor = UIColor.white
        }
        else {
            testLabel.fontColor = UIColor.red
        }
        
        testLabel.text = ColorTile.selectedColor.rawValue
    }
      
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
