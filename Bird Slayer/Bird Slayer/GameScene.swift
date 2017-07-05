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
    
    // Game objects
    var hero: SKSpriteNode!
    var gun: SKSpriteNode!
    var birdBase: Bird!
    var birds: [Bird] = []
    var bulletBase: SKSpriteNode!
    var bullets: [SKSpriteNode] = []
    var pooBase: SKSpriteNode!
    
    // Controls
    var leftTouch: UITouch?
    var leftInitialPosition: CGPoint!
    var rightTouch: UITouch?
    var rightInitialPosition: CGPoint!
    var shooting = false
    
    // Gameplay variables
    var heroSpeed: CGFloat = 150
    var birdSpeed: CGFloat = 100
    var bulletSpeed: CGFloat = 200
    // Average frames until next bird spawn ~(seconds * 60)
    var spawnFrequency: Int = 5 * 60
    // Frames until next shot
    var shotFrequency: Int = 1 * 60
    
    // BTS variables
    // Actual frames until next bird spawn
    var spawnTime: Int!
    // Framecount for bird spawning
    var spawnTimer: Int = 0
    // Framecount for shooting
    var shotTimer: Int = 0
    
    
    override func didMove(to view: SKView) {
        spawnTime = spawnFrequency
        
        // Set reference to objects
        hero = self.childNode(withName: "//hero") as! SKSpriteNode
        gun = hero.childNode(withName: "gun") as! SKSpriteNode
        birdBase = self.childNode(withName: "//birdBase") as! Bird
        bulletBase = self.childNode(withName: "//bulletBase") as! SKSpriteNode
        pooBase = self.childNode(withName: "//pooBase") as! SKSpriteNode
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
                    shooting = true
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch === leftTouch {
                hero.physicsBody?.velocity.dx = (touch.location(in: self.view).x - leftInitialPosition.x) * (heroSpeed/50)
                hero.physicsBody?.velocity.dx = clamp(value: (hero.physicsBody?.velocity.dx)!, lower: -1 * heroSpeed, upper: heroSpeed)
                if (hero.position.x <= (-284 + hero.size.width / 2 + 1)) {
                    hero.position.x = max(hero.position.x, -284 + hero.size.width / 2)
                    hero.physicsBody?.velocity.dx = clamp(value: (hero.physicsBody?.velocity.dx)!, lower: 0, upper: heroSpeed)
                }
                if (hero.position.x >= (284 - (hero.size.width / 2) - 1)) {
                    hero.position.x = min(hero.position.x, 284 - hero.size.width / 2)
                    hero.physicsBody?.velocity.dx = clamp(value: (hero.physicsBody?.velocity.dx)!, lower: -1 * heroSpeed, upper: 0)
                }
            } else if touch === rightTouch {
                gun.zRotation = (rightInitialPosition.x - touch.location(in: self.view).x) * CGFloat(Double.pi/2/50)
                gun.zRotation = clamp(value: gun.zRotation, lower: -CGFloat(Double.pi/2), upper: CGFloat(Double.pi/2))
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
                gun.zRotation = 0
                shooting = false
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        // Spawns new bird if necessary, removes old birds
        birdManager()
        
        // Shoots if necessary, removes old bullets
        shotManager()
        
        // clamps hero's position and velocity to inside play area
        if (hero.position.x <= (-284 + hero.size.width / 2 + 1)) {
            hero.position.x = max(hero.position.x, -284 + hero.size.width / 2)
            hero.physicsBody?.velocity.dx = clamp(value: (hero.physicsBody?.velocity.dx)!, lower: 0, upper: heroSpeed)
        }
        if (hero.position.x >= (284 - (hero.size.width / 2) - 1)) {
            hero.position.x = min(hero.position.x, 284 - (hero.size.width / 2))
            hero.physicsBody?.velocity.dx = clamp(value: (hero.physicsBody?.velocity.dx)!, lower: -1 * heroSpeed, upper: 0)
        }
    }
    
    // Figures out if new bird should be spawned, then spawns it. Removes old birds
    func birdManager() {
        spawnTimer += 1
        if spawnTimer >= spawnTime {
            spawnBird()
            let rand = arc4random_uniform(UInt32(spawnFrequency))
            spawnTime = spawnFrequency + Int(rand) - (spawnFrequency/2)
            spawnTimer = 0
        }
        for var i in 0 ..< birds.count {
            if i >= birds.count || i < 0 {break}
            if birds[i].position.y < -200 || birds[i].position.x < -350 || birds[i].position.x > 350 {
                birds.remove(at: i)
                i -= 1
            }
        }
    }
    
    // Figures out if bullet should be shot, then shoots it. Removes old bullets
    func shotManager() {
        if shooting {
            shotTimer += 1
            if shotTimer > shotFrequency {
                shoot()
                shotTimer = 0
            }
        } else {
            shotTimer = 0
        }
        for var i in 0 ..< bullets.count {
            if i >= bullets.count || i < 0 {break}
            if bullets[i].position.y > 200 || bullets[i].position.x < -350 || bullets[i].position.x > 350 {
                bullets.remove(at: i)
                i -= 1
            }
        }
    }
    
    // Spawns a new bird
    func spawnBird() {
        let newBird = birdBase.copy() as! Bird
        newBird.physicsBody?.linearDamping = 0
        
        // Chooses type of bird
        newBird.type = .normal
        
        // Chooses the side the bird spawns on
        let rand1 = arc4random_uniform(UInt32(2))
        if Int(rand1) < 1 {
            newBird.direction = .right
        } else {
            newBird.direction = .left
        }
        
        // Determines and sets its inital position
        var rand = arc4random_uniform(UInt32(160 - (2 * newBird.size.height)))
        rand += UInt32(newBird.size.height)
        var newPosition = CGPoint(x: 300,y: Int(rand))
        newBird.physicsBody?.velocity.dx = -1 * birdSpeed
        if newBird.direction == .right {
            newPosition.x = -300
            newBird.physicsBody?.velocity.dx = birdSpeed
        }
        newBird.position = newPosition
        self.addChild(newBird)
        birds.append(newBird)
    }
    
    // Shoots
    func shoot() {
        let newBullet = bulletBase.copy() as! SKSpriteNode
        newBullet.physicsBody?.linearDamping = 0
        newBullet.position = hero.position
        newBullet.position.x -= gun.size.height * sin(gun.zRotation)
        newBullet.position.y += gun.size.height * cos(gun.zRotation) - 160 + hero.size.height
        newBullet.physicsBody?.velocity.dx = -bulletSpeed * sin(gun.zRotation)
        newBullet.physicsBody?.velocity.dy = bulletSpeed * cos(gun.zRotation)
        bullets.append(newBullet)
        self.addChild(newBullet)
    }
}
