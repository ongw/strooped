//
//  ColorTile.swift
//  Strooped
//
//  Created by Wes Ong on 2017-07-05.
//  Copyright © 2017 Wes Ong. All rights reserved.
//

import Foundation
import SpriteKit

/* Tracking enum for color values */
enum Color: String {
    case red = "red",
    blue = "blue",
    yellow = "yellow",
    green = "green",
    pink = "pink",
    orange = "orange",
    black = "black",
    purple = "purple",
    null = ""
}

class ColorTile: SKSpriteNode {
    
    var textColor: Color!
    var textValue: Color!
    
    var frontLabel: SKLabelNode = SKLabelNode()
    
    /* Bool for whether ColorTile is main */
    var isMain: Bool = false
    
    /* Static variable to track user touch input */
    static var selectedColor: Color = .null
    
    init(textColor: Color, textValue: Color, isMain: Bool = false) {
        
        /* Initialize tile texture and label */
        var texture: SKTexture
        
        /* Check if tile is main tile and set texture respectively */
        if isMain {
            texture = SKTexture(imageNamed: "mainTile")
            frontLabel.fontSize = 22
        }
        else {
            texture = SKTexture(imageNamed: "commonTile")
            frontLabel.fontSize = 22
        }
        
        /* Label font formatting */
        frontLabel.zPosition = 3
        frontLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        frontLabel.fontName = "Ge Body"

        /* Required init for implementation */
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        /* Set up Tile Values */
        self.setValue(textColor: textColor, textValue: textValue, isMain: isMain)
        
        /* Add label to tile */
        self.addChild(frontLabel)
        
        /* Set up anchor point to center of tile */
        self.anchorPoint = CGPoint(x:0.5, y:0.5)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        if !isMain {
            
        /* Update selectedColor variable */
        ColorTile.selectedColor = self.textValue
        }
        else {
            ColorTile.selectedColor = .null
        }
    }
    
    func setValue(textColor: Color, textValue: Color, isMain: Bool = false) {
        /* Initialize tile variables */
        self.textValue = textValue
        self.textColor = textColor
        self.isMain = isMain
        
        /* Set text of label */
        self.frontLabel.text = textValue.rawValue
        
        /* Check if tile is main tile */
        if isMain {
            texture = SKTexture(imageNamed: "mainTile")
            frontLabel.fontSize = 22
        }
        else {
            texture = SKTexture(imageNamed: "commonTile")
            frontLabel.fontSize = 22
        }
        
        /* Label text attributes */
        frontLabel.fontColor = ColorTile.getColor(textColor)
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    static func getColor(_ color: Color) -> UIColor{
        /* Returns UIColor for TextColor enum */
        switch color {
        case .red:
            return UIColor.red
        case .blue:
            return UIColor.blue
        case .green:
            return UIColor(red: 0.153, green: 0.427, blue: 0.212, alpha: 1)
        case .black:
            return UIColor.black
        case .pink:
            return UIColor(red: 0.9137, green: 0.5686, blue: 0.7412, alpha: 1)
        case .orange:
            return UIColor.orange
        case .purple:
            return UIColor.purple
        case .yellow:
            return UIColor(red: 0.922, green: 0.847, blue: 0.208, alpha: 1)
        default:
            return UIColor.cyan
        }
    }
}
