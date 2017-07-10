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
    case normal, smart, big
}

enum Side {
    case left, right
}

class Bird: SKSpriteNode {
    
    var type: BirdType! {
        didSet {
            switch type! {
            case .smart:
                color = UIColor(red: 1.0, green: 1.0, blue: 0.75, alpha: 1.0)
                health = 2
                pointValue = pointValue * 3
            case .big:
                xScale = 2
                yScale = 2
                health = 5
                pointValue = pointValue * 5
                birdSpeed = birdSpeed * (2/3)
            default:
                break
            }
        }
    }
    var direction: Side!
    var pooTimer = 0
    var started = false
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
