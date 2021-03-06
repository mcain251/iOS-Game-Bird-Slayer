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
    case normal, smart, big, rare, toxic, rapid
}

enum Side {
    case left, right
}

class Bird: SKSpriteNode {
    
    // Colors
    let smartBirdColor = UIColor(red: 1.0, green: 1.0, blue: 0.68, alpha: 1.0)
    let rareBirdColor = UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
    let toxicBirdColor = UIColor(red: 0.61, green: 1.0, blue: 0.47, alpha: 1.0)
    let rapidBirdColor = UIColor(red: 1.0, green: 0.65, blue: 0.65, alpha: 1.0)
    
    // Determines bird attributes
    var type: BirdType! {
        didSet {
            switch type! {
            case .smart:
                color = smartBirdColor
                health = 2
                pointValue = pointValue * 3
            case .big:
                xScale = 2 * xScale
                yScale = 2 * yScale
                health = 5
                pointValue = pointValue * 8
                birdSpeed = birdSpeed * CGFloat(2)/CGFloat(3)
            case .rare:
                color = rareBirdColor
                xScale = 0.75 * xScale
                yScale = 0.75 * yScale
                pointValue = pointValue * 20
                birdSpeed = birdSpeed * 1.5
            case .toxic:
                color = toxicBirdColor
                health = 2
                pointValue = pointValue * 3
            case .rapid:
                color = rapidBirdColor
                health = 3
                pointValue = pointValue * 5
                birdSpeed = birdSpeed * CGFloat(2)/CGFloat(3)
            default:
                break
            }
        }
    }
    
    // BTS variables
    var direction: Side!
    var pooTimer = 0
    var started = false
    
    // Default values (changed when type is set)
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
