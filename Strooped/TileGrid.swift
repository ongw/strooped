//
//  TileGrid.swift
//  Strooped
//
//  Created by Wes Ong on 2017-07-05.
//  Copyright © 2017 Wes Ong. All rights reserved.
//

import Foundation
import SpriteKit

extension MutableCollection where Indices.Iterator.Element == Index {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            swap(&self[firstUnshuffled], &self[i])
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Iterator.Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

class TileGrid: SKSpriteNode {
    
    /* 3x3 grid of ColorTiles */
    var tileArray = [[ColorTile]]()
    
    /* Tracker for main tile */
    var mainTile: ColorTile!
    
    /* Array of colors for various function usage */
    static var color: [Color] = [.null, .red, .null, .blue, .green, .null, .yellow, .null]
    
    init() {
        /* Populate the grid with tiles */
        super.init(texture: SKTexture.init(), color: UIColor.clear, size: CGSize(width: 0, height: 0))
        
        /* Initialize text labels */
        var colorCount = 0
        
        /* Loop through columns */
        for gridX in 0..<3 {
            
            /* Initialize empty column */
            tileArray.append([])
            
            /* Loop through rows */
            for gridY in 0..<3 {
                
                /* Create a new tile at row / column array position */
                var newTile: ColorTile
                
                /* If center tile, define as main */
                if gridX == 1 && gridY == 1 {
                    newTile = ColorTile(textColor: .null, textValue: .null, isMain: true)
                    mainTile = newTile
                    changeMainTile()
                }
                else {
                    newTile = ColorTile(textColor: .black, textValue: TileGrid.color[colorCount])
                    colorCount += 1
                }
                
                /* Set tile position */
                newTile.position = CGPoint(x: Double(gridX*90) + 12.5*Double(gridX + 1) + 45, y: Double(gridY*90) + 12.5*Double(gridY + 1) + 95)
                
                /* Add new tile as child node*/
                addChild(newTile)
                
                /* Append new tile to array */
                tileArray[gridX].append(newTile)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        
        
        if ColorTile.selectedColor != .null {
        /* Check for wrong selection */
        checkTouch()
        
        /* Change main tile */
        changeMainTile()
            
        /* Change normal tiles */
        randomizeNormalTiles()
        }
    }
    
    func checkTouch(){
        /* Check if tapped node matches text color of main node */
        if ColorTile.selectedColor != .null {
            if ColorTile.selectedColor == mainTile.textColor {
                GameScene.gameState = .ready
            }
            else {
                GameScene.gameState = .gameOver
            }
        }
    }
    
    func changeMainTile() {
        /* Set up array of selections */
        var mainTileColorArray = [Color]()
        
        /* Get all current non-null colors */
        for color in TileGrid.color {
            if color != .null {
                mainTileColorArray.append(color)
            }
        }
        
        /* Randomly set color text and value */
        mainTile.setValue(textColor: mainTileColorArray[Int(arc4random_uniform(UInt32(mainTileColorArray.count)))], textValue: mainTileColorArray[Int(arc4random_uniform(UInt32(mainTileColorArray.count)))], isMain: true)
    }
    
    func randomizeNormalTiles() {
        /* Shuffle colors */
        TileGrid.color.shuffle()
        
        var colorCount = 0
        for x in 0..<3 {
            for y in 0..<3 {
               if tileArray[x][y] != mainTile {
                    tileArray[x][y].setValue(textColor: .black, textValue: TileGrid.color[colorCount])
                    colorCount += 1
                }
            }
        }
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
