//
//  GameScene.swift
//  Bird Slayer
//
//  Created by Marshall Cain on 7/5/17.
//  Copyright © 2017 Marshall Cain. All rights reserved.
//

import SpriteKit

// Clamp function
func clamp<T: Comparable>(value: T, lower: T, upper: T) -> T {
    return min(max(value, lower), upper)
}

class GameScene: SKScene {
    var hero: SKSpriteNode!
    var leftTouch: UITouch?
    var leftInitialPosition: CGPoint!
    var rightTouch: UITouch?
    var rightInitialPosition: CGPoint!
    
    var heroSpeed: CGFloat = 150
    
    
    override func didMove(to view: SKView) {
        hero = self.childNode(withName: "//hero") as! SKSpriteNode
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch.location(in: self.view).x <= 284 {
                if leftTouch == nil {
                    leftTouch = touch
                    leftInitialPosition = touch.location(in: self.view)
                }
            } else {
                if rightTouch == nil {
                    rightTouch = touch
                    rightInitialPosition = touch.location(in: self.view)
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch === leftTouch {
                hero.physicsBody?.velocity.dx = (touch.location(in: self.view).x - leftInitialPosition.x) * 3
                hero.physicsBody?.velocity.dx = clamp(value: (hero.physicsBody?.velocity.dx)!, lower: -1 * heroSpeed, upper: heroSpeed)
                if (hero.position.x <= (-284 + hero.size.width / 2 + 1)) {
                    hero.position.x = max(hero.position.x, -284 + hero.size.width / 2)
                    hero.physicsBody?.velocity.dx = clamp(value: (hero.physicsBody?.velocity.dx)!, lower: 0, upper: heroSpeed)
                }
                if (hero.position.x >= (284 - (hero.size.width / 2) - 1)) {
                    hero.position.x = min(hero.position.x, 284 - (hero.size.width / 2))
                    hero.physicsBody?.velocity.dx = clamp(value: (hero.physicsBody?.velocity.dx)!, lower: -1 * heroSpeed, upper: 0)
                }
            } else if touch === rightTouch {
                print("right: \(String(describing: rightTouch?.location(in: self.view).x))")
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch === leftTouch {
                leftTouch = nil
                leftInitialPosition = nil
                hero.physicsBody?.velocity.dx = 0
            } else if touch === rightTouch {
                rightTouch = nil
                rightInitialPosition = nil
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if (hero.position.x <= (-284 + hero.size.width / 2 + 1)) {
            hero.position.x = max(hero.position.x, -284 + hero.size.width / 2)
            hero.physicsBody?.velocity.dx = clamp(value: (hero.physicsBody?.velocity.dx)!, lower: 0, upper: heroSpeed)
        }
        if (hero.position.x >= (284 - (hero.size.width / 2) - 1)) {
            hero.position.x = min(hero.position.x, 284 - (hero.size.width / 2))
            hero.physicsBody?.velocity.dx = clamp(value: (hero.physicsBody?.velocity.dx)!, lower: -1 * heroSpeed, upper: 0)
        }
    }
}
