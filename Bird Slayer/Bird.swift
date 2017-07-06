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
    
    var type: BirdType!
    var direction: Side!
    var pooTimer = 0
    var started = false
    var pointValue = 10
    
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
