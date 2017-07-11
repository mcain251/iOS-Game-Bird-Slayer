//
//  Bird.swift
//  Bird Slayer
//
//  Created by Marshall Cain on 7/5/17.
//  Copyright © 2017 Marshall Cain. All rights reserved.
//

import SpriteKit

// specifies the type of bird
enum BirdType {
    case normal, smart, big, rare
}

enum Side {
    case left, right
}

class Bird: SKSpriteNode {
    
    // Colors
    let smartBirdColor = UIColor(red: 1.0, green: 1.0, blue: 0.75, alpha: 1.0)
    let rareBirdColor = UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
    
    // Determines bird attributes
    var type: BirdType! {
        didSet {
            switch type! {
            case .smart:
                color = smartBirdColor
                health = 2
                pointValue = pointValue * 3
            case .big:
                xScale = 2
                yScale = 2
                health = 5
                pointValue = pointValue * 5
                birdSpeed = birdSpeed * (2/3)
            case .rare:
                color = rareBirdColor
                xScale = 0.75
                yScale = 0.75
                pointValue = pointValue * 20
                birdSpeed = birdSpeed * 1.5
            default:
                break
            }
        }
    }
    
    // BTS variables
    var direction: Side!
    var pooTimer = 0
    var started = false
    
    // Default values (changed when type is set
    var pointValue = 10
    var health = 1
    var birdSpeed: CGFloat!
    
    // Initializer
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }

    // Required to inherit SKSpriteNode
    required init?(coder aDecoder: NSCoder) {
        type = .normal
        super.init(coder: aDecoder)
    }
}
