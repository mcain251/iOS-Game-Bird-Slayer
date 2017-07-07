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

// Game state enumeration
enum GameSceneState {
    case inactive, active, gameOver
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Game objects
    var hero: SKSpriteNode!
    var gun: SKSpriteNode!
    var birdBase: Bird!
    var birds: [Bird] = []
    var bulletBase: SKSpriteNode!
    var bullets: [SKSpriteNode] = []
    var pooBase: SKSpriteNode!
    var poops: [SKSpriteNode] = []
    var healthBar: SKSpriteNode!
    var healthBarContainer: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var nextUpgradeLabel: SKLabelNode!
    var highScoreLabel: SKLabelNode!
    var tutorial: SKNode!
    var upgradeScreen: SKNode!
    var gameOverLabel: SKLabelNode!
    var pauseButton: MSButtonNode!
    var pauseLabel: SKLabelNode!
    var upgradeLabel: SKLabelNode!
    
    // Upgrade UI
    var health_1: SKSpriteNode!
    var health_2: SKSpriteNode!
    var health_3: SKSpriteNode!
    var health_plus: SKLabelNode!
    var health_button: MSButtonNode!
    var speed_1: SKSpriteNode!
    var speed_2: SKSpriteNode!
    var speed_3: SKSpriteNode!
    var speed_plus: SKLabelNode!
    var speed_button: MSButtonNode!
    var fire_rate_1: SKSpriteNode!
    var fire_rate_2: SKSpriteNode!
    var fire_rate_3: SKSpriteNode!
    var fire_rate_plus: SKLabelNode!
    var fire_rate_button: MSButtonNode!
    var bullet_speed_1: SKSpriteNode!
    var bullet_speed_2: SKSpriteNode!
    var bullet_speed_3: SKSpriteNode!
    var bullet_speed_plus: SKLabelNode!
    var bullet_speed_button: MSButtonNode!
    var healthUpgradeStatus = 1
    var speedUpgradeStatus = 1
    var fireRateUpgradeStatus = 1
    var bulletSpeedUpgradeStatus = 1
    var oldHealthUpgradeStatus = 1
    var oldSpeedUpgradeStatus = 1
    var oldFireRateUpgradeStatus = 1
    var oldBulletSpeedUpgradeStatus = 1
    
    // Controls
    var leftTouch: UITouch?
    var leftInitialPosition: CGPoint!
    var rightTouch: UITouch?
    var rightInitialPosition: CGPoint!
    var shooting = false
    var leftThumb: SKSpriteNode!
    var rightThumb: SKSpriteNode!
    var leftJoystick: SKSpriteNode!
    var rightJoystick: SKSpriteNode!
    var leftJoystickPosition: CGPoint!
    var rightJoystickPosition: CGPoint!
    
    // Gameplay variables
    var score = 0
    var highScore = UserDefaults().integer(forKey: "HIGHSCORE")
    var maxHealth = 6
    let maxMaxHealth = 12
    let minMaxHealth = 6
    var health = 6
    var heroSpeed: CGFloat = 150
    let maxHeroSpeed: CGFloat = 300
    let minHeroSpeed: CGFloat = 150
    var birdSpeed: CGFloat = 100
    var bulletSpeed: CGFloat = 200
    let maxBulletSpeed: CGFloat = 500
    let minBulletSpeed: CGFloat = 200
    // Frames until next shot ~(seconds * 60)
    var shotFrequency: Int = 1 * 60
    let maxShotFrequency: Int = 30
    let minShotFrequency: Int = 1 * 60
    // Number of upgrades per catagory
    let upgrades = 3
    var invincibilityTimer = 0
    let invincibilityTime = 3 * 60
    
    // Bird constants
    let pooSpeed: CGFloat = 150
    // Average frames until next poop ~(seconds * 60)
    let pooFrequency: Int = 2 * 60
    
    // Normal bird spawn variables
    // Average frames until next bird spawn ~(seconds * 60)
    var normalSpawnFrequency: Int = 5 * 60
    // Actual frames until next bird spawn
    var normalSpawnTime: Int!
    // Framecount for bird spawning
    var normalSpawnTimer: Int = 0
    
    // Smart bird spawn variables
    var smartSpawnFrequency: Int = 8 * 60
    var smartSpawnTime: Int!
    var smartSpawnTimer: Int = 0
    var smartIsSpawning = false
    let levelsToSmart = 2
    
    // Big bird spawn variables
    var bigSpawnFrequency: Int = 15 * 60
    var bigSpawnTime: Int!
    var bigSpawnTimer: Int = 0
    var bigIsSpawning = false
    let levelsToBig = 4
    
    // BTS variables
    // Framecount for shooting
    var shotTimer: Int = 0
    var gameState: GameSceneState = .inactive
    // List of scores that initiate upgrade screen
    var upgradeScores: [Int] = [50, 150, 300, 500, 750, 1050, 1400, 1800, 2250, 2750, 3300, 3900]
    //var upgradeScores: [Int] = [10, 20, 50, 80, 130, 200, 250, 300, 350, 400, 450, 500]
    var pause = false
    
    // Called when game begins
    override func didMove(to view: SKView) {
        normalSpawnTime = normalSpawnFrequency
        smartSpawnTime = smartSpawnFrequency
        bigSpawnTime = bigSpawnFrequency
        shotTimer = shotFrequency
        
        // Set reference to objects
        hero = self.childNode(withName: "//hero") as! SKSpriteNode
        gun = hero.childNode(withName: "gun") as! SKSpriteNode
        birdBase = self.childNode(withName: "//birdBase") as! Bird
        bulletBase = self.childNode(withName: "//bulletBase") as! SKSpriteNode
        pooBase = self.childNode(withName: "//pooBase") as! SKSpriteNode
        healthBar = self.childNode(withName: "healthBar") as! SKSpriteNode
        healthBarContainer = self.childNode(withName: "healthBarContainer") as! SKSpriteNode
        scoreLabel = self.childNode(withName: "scoreLabel") as! SKLabelNode
        highScoreLabel = self.childNode(withName: "highScoreLabel") as! SKLabelNode
        nextUpgradeLabel = self.childNode(withName: "nextUpgradeLabel") as! SKLabelNode
        tutorial = self.childNode(withName: "tutorial")
        tutorial.position = self.position
        leftThumb = self.childNode(withName: "leftThumb") as! SKSpriteNode
        rightThumb = self.childNode(withName: "rightThumb") as! SKSpriteNode
        leftJoystick = self.childNode(withName: "leftJoystick") as! SKSpriteNode
        rightJoystick = self.childNode(withName: "rightJoystick") as! SKSpriteNode
        upgradeScreen = self.childNode(withName: "upgradeScreen")
        upgradeScreen.position = self.position
        upgradeScreen.isHidden = true
        gameOverLabel = self.childNode(withName: "gameOverLabel") as! SKLabelNode
        gameOverLabel.isHidden = true
        pauseButton = self.childNode(withName: "pauseButton") as! MSButtonNode
        pauseLabel = self.childNode(withName: "pauseLabel") as! SKLabelNode
        pauseLabel.isHidden = true
        upgradeLabel = self.childNode(withName: "upgradeLabel") as! SKLabelNode
        upgradeLabel.isHidden = true
        
        // Set reference to upgrade UI objects
        health_1 = self.childNode(withName: "//health_1") as! SKSpriteNode
        health_2 = self.childNode(withName: "//health_2") as! SKSpriteNode
        health_3 = self.childNode(withName: "//health_3") as! SKSpriteNode
        health_plus = self.childNode(withName: "//health_plus") as! SKLabelNode
        health_button = self.childNode(withName: "//health_button") as! MSButtonNode
        speed_1 = self.childNode(withName: "//speed_1") as! SKSpriteNode
        speed_2 = self.childNode(withName: "//speed_2") as! SKSpriteNode
        speed_3 = self.childNode(withName: "//speed_3") as! SKSpriteNode
        speed_plus = self.childNode(withName: "//speed_plus") as! SKLabelNode
        speed_button = self.childNode(withName: "//speed_button") as! MSButtonNode
        fire_rate_1 = self.childNode(withName: "//fire_rate_1") as! SKSpriteNode
        fire_rate_2 = self.childNode(withName: "//fire_rate_2") as! SKSpriteNode
        fire_rate_3 = self.childNode(withName: "//fire_rate_3") as! SKSpriteNode
        fire_rate_plus = self.childNode(withName: "//fire_rate_plus") as! SKLabelNode
        fire_rate_button = self.childNode(withName: "//fire_rate_button") as! MSButtonNode
        bullet_speed_1 = self.childNode(withName: "//bullet_speed_1") as! SKSpriteNode
        bullet_speed_2 = self.childNode(withName: "//bullet_speed_2") as! SKSpriteNode
        bullet_speed_3 = self.childNode(withName: "//bullet_speed_3") as! SKSpriteNode
        bullet_speed_plus = self.childNode(withName: "//bullet_speed_plus") as! SKLabelNode
        bullet_speed_button = self.childNode(withName: "//bullet_speed_button") as! MSButtonNode
        health_button.selectedHandler = {
            self.healthUpgradeStatus += 1
            self.isPaused  = false
            self.upgradeScreen.isHidden = true
            self.upgradeLabel.isHidden = true
        }
        speed_button.selectedHandler = {
            self.speedUpgradeStatus += 1
            self.isPaused  = false
            self.upgradeScreen.isHidden = true
            self.upgradeLabel.isHidden = true
        }
        fire_rate_button.selectedHandler = {
            self.fireRateUpgradeStatus += 1
            self.isPaused  = false
            self.upgradeScreen.isHidden = true
            self.upgradeLabel.isHidden = true
        }
        bullet_speed_button.selectedHandler = {
            self.bulletSpeedUpgradeStatus += 1
            self.isPaused  = false
            self.upgradeScreen.isHidden = true
            self.upgradeLabel.isHidden = true
        }
        pauseButton.selectedHandler = {
            if !self.pause {
                self.isPaused = true
                self.leftTouch = nil
                self.leftInitialPosition = nil
                self.leftJoystick.isHidden = true
                self.leftThumb.isHidden = true
                self.hero.physicsBody?.velocity.dx = 0
                self.rightTouch = nil
                self.rightInitialPosition = nil
                self.gun.zRotation = 0
                self.shooting = false
                self.rightJoystick.isHidden = true
                self.rightThumb.isHidden = true
                self.isPaused = true
                self.upgradeScreen.isHidden = false
                switch self.healthUpgradeStatus {
                case 1:
                    break
                case 2:
                    self.health_1.color = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
                case 3:
                    self.health_2.color = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
                default:
                    self.health_3.color = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
                }
                switch self.speedUpgradeStatus {
                case 1:
                    break
                case 2:
                    self.speed_1.color = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
                case 3:
                    self.speed_2.color = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
                default:
                    self.speed_3.color = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
                }
                switch self.fireRateUpgradeStatus {
                case 1:
                    break
                case 2:
                    self.fire_rate_1.color = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
                case 3:
                    self.fire_rate_2.color = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
                default:
                    self.fire_rate_3.color = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
                }
                switch self.bulletSpeedUpgradeStatus {
                case 1:
                    break
                case 2:
                    self.bullet_speed_1.color = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
                case 3:
                    self.bullet_speed_2.color = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
                default:
                    self.bullet_speed_3.color = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
                }
                let offScreen: CGPoint = CGPoint(x: -1000, y: -1000)
                self.health_plus.position = offScreen
                self.health_button.position = offScreen
                self.speed_plus.position = offScreen
                self.speed_button.position = offScreen
                self.fire_rate_plus.position = offScreen
                self.fire_rate_button.position = offScreen
                self.bullet_speed_plus.position = offScreen
                self.bullet_speed_button.position = offScreen
                self.pauseLabel.isHidden = false
                self.pause = true
            } else {
                self.isPaused  = false
                self.upgradeScreen.isHidden = true
                self.pauseLabel.isHidden = true
                self.pause = false
            }
        }
        
        
        // Set physics contact delegate
        physicsWorld.contactDelegate = self
    }
    
    // Touch functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState == .inactive {
            gameState = .active
        }
        if gameState != .gameOver && !self.isPaused {
            for touch in touches {
                if touch.location(in: self.view).x <= 284 {
                    if leftTouch == nil {
                        leftTouch = touch
                        leftInitialPosition = touch.location(in: self.view)
                        leftJoystickPosition = leftInitialPosition
                        leftJoystickPosition.x -= 284
                        leftJoystickPosition.y = 160 - leftInitialPosition.y
                        leftJoystick.isHidden = false
                        leftJoystick.position = leftJoystickPosition
                        leftThumb.isHidden = false
                        leftThumb.position = leftJoystickPosition
                    }
                } else {
                    if rightTouch == nil {
                        rightTouch = touch
                        rightInitialPosition = touch.location(in: self.view)
                        rightJoystickPosition = rightInitialPosition
                        rightJoystickPosition.x -= 284
                        rightJoystickPosition.y = 160 - rightInitialPosition.y
                        shooting = true
                        rightJoystick.isHidden = false
                        rightJoystick.position = rightJoystickPosition
                        rightThumb.isHidden = false
                        rightThumb.position = rightJoystickPosition
                    }
                }
            }
        }
        if gameState == .gameOver {
            let skView = self.view as SKView!
            let scene = GameScene(fileNamed:"GameScene") as GameScene!
            scene?.scaleMode = .aspectFill
            skView?.presentScene(scene)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState != .gameOver && !self.isPaused {
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
                    leftThumb.position.x = clamp(value: touch.location(in: self).x, lower: leftJoystickPosition.x - 50, upper: leftJoystickPosition.x + 50)
                } else if touch === rightTouch {
                    gun.zRotation = (rightInitialPosition.x - touch.location(in: self.view).x) * CGFloat(Double.pi/2/50)
                    gun.zRotation = clamp(value: gun.zRotation, lower: -CGFloat(Double.pi/2), upper: CGFloat(Double.pi/2))
                    rightThumb.position.x = clamp(value: touch.location(in: self).x, lower: rightJoystickPosition.x - 50, upper: rightJoystickPosition.x + 50)
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState != .gameOver && !self.isPaused {
            for touch in touches {
                if touch === leftTouch {
                    leftTouch = nil
                    leftInitialPosition = nil
                    leftJoystick.isHidden = true
                    leftThumb.isHidden = true
                    hero.physicsBody?.velocity.dx = 0
                } else if touch === rightTouch {
                    rightTouch = nil
                    rightInitialPosition = nil
                    gun.zRotation = 0
                    shooting = false
                    rightJoystick.isHidden = true
                    rightThumb.isHidden = true
                }
            }
        }
    }
    
    // Called every frame
    override func update(_ currentTime: TimeInterval) {
        if invincibilityTimer > 0 {
            invincibilityTimer -= 1
            if invincibilityTimer % 30 > 20 {
                hero.isHidden = true
            } else {
                hero.isHidden = false
            }
        }
        if gameState != .inactive {
            // Spawns new bird if necessary, removes old birds
            birdManager()
            tutorial.isHidden = true
        }
        if gameState == .active {
            // Shoots if necessary, removes old bullets
            shotManager()
        }
        if gameState == .inactive {
            tutorial.isHidden = false
        }
        
        // Removes old poops
        pooManager()
        
        // Manages hero's health and healthbar
        healthManager()
        
        // Manages score and highscore, as well as the next upgrade label
        scoreManager()
        
        // Makes sure upgrades are applied correctly
        upgradeManager()
        
        // Clamps hero's position and velocity to inside play area
        if (hero.position.x <= (-284 + hero.size.width / 2 + 1)) {
            hero.position.x = max(hero.position.x, -284 + hero.size.width / 2)
            hero.physicsBody?.velocity.dx = clamp(value: (hero.physicsBody?.velocity.dx)!, lower: 0, upper: heroSpeed)
        }
        if (hero.position.x >= (284 - (hero.size.width / 2) - 1)) {
            hero.position.x = min(hero.position.x, 284 - (hero.size.width / 2))
            hero.physicsBody?.velocity.dx = clamp(value: (hero.physicsBody?.velocity.dx)!, lower: -1 * heroSpeed, upper: 0)
        }
    }
    
    // Called when a physics contact occurs
    func didBegin(_ contact: SKPhysicsContact) {
        
        // Get references to the bodies involved in the collision
        let contactA:SKPhysicsBody = contact.bodyA
        let contactB:SKPhysicsBody = contact.bodyB
        
        // Get references to the physics body parent SKSpriteNode
        let nodeA = contactA.node as! SKSpriteNode
        let nodeB = contactB.node as! SKSpriteNode
        
        // Check if either physics bodies was a bird, then damage the bird and remove the bullet
        if contactA.categoryBitMask == 2 || contactB.categoryBitMask == 2 {
            if let birdA = contactA.node as? Bird {
                birdA.health -= 1
                if birdA.health == 0 {
                    score += birdA.pointValue
                }
                nodeB.removeFromParent()
                nodeB.isHidden = true
            } else if let birdB = contactB.node as? Bird {
                birdB.health -= 1
                if birdB.health == 0 {
                    score += birdB.pointValue
                }
                nodeA.removeFromParent()
                nodeA.isHidden = true
            }
        }
        
        // Check if one was a bullet and one was a poop, then removes both, unless it's a big poop
        if (contactA.categoryBitMask == 4 && contactB.categoryBitMask == 8) {
            nodeA.removeFromParent()
            nodeA.isHidden = true
            if nodeB.xScale != 2 && nodeB.xScale != 2{
                nodeB.removeFromParent()
                nodeB.isHidden = true
            }
        }
        if(contactA.categoryBitMask == 8 && contactB.categoryBitMask == 4) {
            nodeB.removeFromParent()
            nodeB.isHidden = true
            if nodeA.xScale != 2 && nodeA.xScale != 2{
                nodeA.removeFromParent()
                nodeA.isHidden = true
            }
        }
        
        // Check if one was the hero, then removes poop and decrements health
        if (contactA.categoryBitMask == 1) {
            if invincibilityTimer <= 0 {
                health -= 1
                if nodeB.xScale == 2 && nodeB.yScale == 2 && health != 0{
                    health -= 1
                }
            }
            nodeB.removeFromParent()
            nodeB.isHidden = true
        }
        if (contactB.categoryBitMask == 1) {
            if invincibilityTimer <= 0 {
                health -= 1
                if nodeA.xScale == 2 && nodeA.yScale == 2 && health != 0 {
                    health -= 1
                }
            }
            nodeA.removeFromParent()
            nodeA.isHidden = true
        }
    }
    
    // Figures out if new bird should be spawned, then spawns it. Removes old birds. Makes birds poo if they are due
    func birdManager() {
        normalSpawnTimer += 1
        if normalSpawnTimer >= normalSpawnTime {
            spawnBird(.normal)
            let rand = arc4random_uniform(UInt32(normalSpawnFrequency))
            normalSpawnTime = Int(rand) + (normalSpawnFrequency/2)
            normalSpawnTimer = 0
        }
        if smartIsSpawning {
            smartSpawnTimer += 1
            if smartSpawnTimer >= smartSpawnTime {
                spawnBird(.smart)
                let rand = arc4random_uniform(UInt32(smartSpawnFrequency))
                smartSpawnTime = Int(rand) + (smartSpawnFrequency/2)
                smartSpawnTimer = 0
            }
        }
        if bigIsSpawning {
            bigSpawnTimer += 1
            if bigSpawnTimer >= bigSpawnTime {
                spawnBird(.big)
                let rand = arc4random_uniform(UInt32(bigSpawnFrequency))
                bigSpawnTime = Int(rand) + (bigSpawnFrequency/2)
                bigSpawnTimer = 0
            }
        }
        for var i in 0 ..< birds.count {
            if i >= birds.count || i < 0 {break}
            birds[i].pooTimer -= 1
            if birds[i].position.x < -350 || birds[i].position.x > 350 {
                birds[i].removeFromParent()
                birds.remove(at: i)
                if i > 0 {
                    i -= 1
                }
            } else if birds[i].health <= 0 {
                birds[i].removeFromParent()
                birds.remove(at: i)
                if i > 0 {
                    i -= 1
                }
            } else if birds[i].isHidden {
                birds[i].removeFromParent()
                birds.remove(at: i)
                if i > 0 {
                    i -= 1
                }
            } else if birds[i].pooTimer <= 0 {
                if !birds[i].started {
                    birds[i].started = true
                } else {
                    poo(birds[i])
                }
                birds[i].pooTimer = Int(arc4random_uniform(UInt32(pooFrequency))) + (pooFrequency/2)
            }
        }
    }
    
    // Figures out if bullet should be shot, then shoots it. Removes old bullets
    func shotManager() {
        if shotTimer < shotFrequency {
            shotTimer += 1
        }
        if shooting {
            if shotTimer >= shotFrequency {
                shoot()
                shotTimer = 0
            }
        }
        for var i in 0 ..< bullets.count {
            if i >= bullets.count || i < 0 {break}
            if bullets[i].position.y > 200 || bullets[i].position.x < -350 || bullets[i].position.x > 350 {
                bullets[i].removeFromParent()
                bullets.remove(at: i)
                if i > 0 {
                    i -= 1
                }
            } else if bullets[i].isHidden {
                bullets[i].removeFromParent()
                bullets.remove(at: i)
                if i > 0 {
                    i -= 1
                }
            }
        }
    }
    
    // Destroys old poops
    func pooManager() {
        for var i in 0 ..< poops.count {
            if i >= poops.count || i < 0 {break}
            if poops[i].position.y < -200 || poops[i].position.x < -350 || poops[i].position.x > 350 {
                poops[i].removeFromParent()
                poops.remove(at: i)
                if i > 0 {
                    i -= 1
                }
            } else if poops[i].isHidden {
                poops[i].removeFromParent()
                poops.remove(at: i)
                if i > 0 {
                    i -= 1
                }
            }
        }
    }
    
    // Sets healthbar and triggers game over when health reaches 0
    func healthManager() {
        let hWidth = CGFloat(90 * maxHealth/minMaxHealth)
        healthBarContainer.size.width = hWidth + 10
        let healthRatio: CGFloat = CGFloat(health)/CGFloat(maxHealth)
        healthBar.size.width = healthRatio * hWidth
        if health <= 0 && gameState != .gameOver {
            gameOver()
        }
    }
    
    // Sets the scoreLabel to the score and updates the highscore if necessary. Sets and manages the upgrade label
    func scoreManager() {
        scoreLabel.text = "\(score)"
        highScoreLabel.text = "High: \(highScore)"
        if score > highScore {
            UserDefaults.standard.set(score, forKey: "HIGHSCORE")
            highScore = UserDefaults().integer(forKey: "HIGHSCORE")
            highScoreLabel.text = "High: \(highScore)"
        }
        if upgradeScores.count > 0 {
            if score >= upgradeScores.first! {
                upgradeScores.removeFirst()
                upgrade()
            }
            if upgradeScores.count > 0 {
                nextUpgradeLabel.text = "Next Upgrade: \(upgradeScores.first!)"
            }
        } else {
            nextUpgradeLabel.text = ""
        }
    }
    
    // Makes sure multiple inputs are evened out and applies upgrades
    func upgradeManager() {
        let total = healthUpgradeStatus + speedUpgradeStatus + fireRateUpgradeStatus + bulletSpeedUpgradeStatus
        let oldTotal = oldHealthUpgradeStatus + oldSpeedUpgradeStatus + oldFireRateUpgradeStatus + oldBulletSpeedUpgradeStatus
        var index = 0
        while total - oldTotal > 1 {
            switch index % 4 {
            case 0:
                bulletSpeedUpgradeStatus = max(bulletSpeedUpgradeStatus - 1, oldBulletSpeedUpgradeStatus)
            case 1:
                fireRateUpgradeStatus = max(fireRateUpgradeStatus - 1, oldFireRateUpgradeStatus)
            case 2:
                speedUpgradeStatus = max(speedUpgradeStatus - 1, oldSpeedUpgradeStatus)
            case 3:
                healthUpgradeStatus = max(healthUpgradeStatus - 1, oldHealthUpgradeStatus)
            default:
                break
            }
            index += 1
        }
        if healthUpgradeStatus - oldHealthUpgradeStatus == 1 {
            maxHealth = (((maxMaxHealth - minMaxHealth)/upgrades) * (healthUpgradeStatus - 1)) + minMaxHealth
            health += ((maxMaxHealth - minMaxHealth)/upgrades)
        }
        if speedUpgradeStatus - oldSpeedUpgradeStatus == 1 {
            heroSpeed = (((maxHeroSpeed - minHeroSpeed)/CGFloat(upgrades)) * CGFloat((speedUpgradeStatus - 1))) + minHeroSpeed
        }
        if fireRateUpgradeStatus - oldFireRateUpgradeStatus == 1 {
            shotFrequency = minShotFrequency - (((minShotFrequency - maxShotFrequency)/upgrades) * (fireRateUpgradeStatus - 1))
        }
        if bulletSpeedUpgradeStatus - oldBulletSpeedUpgradeStatus == 1 {
            bulletSpeed = (((maxBulletSpeed - minBulletSpeed)/CGFloat(upgrades)) * CGFloat((bulletSpeedUpgradeStatus - 1))) + minBulletSpeed
        }
        
        // Toggles harder birds
        if !smartIsSpawning && total >= upgrades + levelsToSmart {
            smartIsSpawning = true
        }
        if !bigIsSpawning && total >= upgrades + levelsToBig {
            bigIsSpawning = true
        }
        
        oldHealthUpgradeStatus = healthUpgradeStatus
        oldSpeedUpgradeStatus = speedUpgradeStatus
        oldFireRateUpgradeStatus = fireRateUpgradeStatus
        oldBulletSpeedUpgradeStatus = bulletSpeedUpgradeStatus
    }
    
    // Spawns a new bird
    func spawnBird(_ type: BirdType) {
        let newBird = birdBase.copy() as! Bird
        newBird.physicsBody?.linearDamping = 0
        
        // Sets the bird's attributes based on its type
        newBird.type = type
        switch type {
        case .smart:
            newBird.color = UIColor(red: 1.0, green: 1.0, blue: 0.75, alpha: 1.0)
            newBird.health = 2
            newBird.pointValue = newBird.pointValue * 3
            newBird.birdSpeed = self.birdSpeed
        case .big:
            newBird.xScale = 2
            newBird.yScale = 2
            newBird.health = 5
            newBird.pointValue = newBird.pointValue * 5
            newBird.birdSpeed = self.birdSpeed * (2/3)
        default:
            newBird.birdSpeed = self.birdSpeed
        }
        
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
        newBird.physicsBody?.velocity.dx = -1 * newBird.birdSpeed
        if newBird.direction == .right {
            newPosition.x = -300
            newBird.physicsBody?.velocity.dx = newBird.birdSpeed
        }
        newBird.position = newPosition
        self.addChild(newBird)
        birds.append(newBird)
    }
    
    // Shoots
    func shoot() {
        if gameState == .active {
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
    
    // Poops
    func poo(_ bird: Bird) {
        let newPoo = pooBase.copy() as! SKSpriteNode
        newPoo.physicsBody?.linearDamping = 0
        newPoo.position = bird.position
        newPoo.position.y = bird.position.y - 10
        switch bird.type! {
        case .smart:
            newPoo.color = UIColor(red: 1.0, green: 1.0, blue: 0.75, alpha: 1.0)
            let xDist = hero.position.x - newPoo.position.x
            let yDist = hero.position.y - newPoo.position.y - 100
            let tDist = sqrt(xDist*xDist + yDist*yDist)
            newPoo.physicsBody?.velocity.dy = pooSpeed * (yDist/tDist)
            newPoo.physicsBody?.velocity.dx = pooSpeed * (xDist/tDist)
        case .big:
            newPoo.xScale = 2
            newPoo.yScale = 2
            newPoo.physicsBody?.velocity.dy = -0.75 * pooSpeed
        default:
            newPoo.physicsBody?.velocity.dy = -1 * pooSpeed
        }
        poops.append(newPoo)
        self.addChild(newPoo)
    }
    
    // Called when player's health reaches 0
    func gameOver() {
        leftTouch = nil
        leftInitialPosition = nil
        leftJoystick.isHidden = true
        leftThumb.isHidden = true
        hero.physicsBody?.velocity.dx = 0
        rightTouch = nil
        rightInitialPosition = nil
        gun.zRotation = 0
        shooting = false
        rightJoystick.isHidden = true
        rightThumb.isHidden = true
        
        gameState = .gameOver
        hero.removeFromParent()
        gameOverLabel.isHidden = false
    
        // Removes all bullets on screen
        for _ in bullets {
            bullets.removeFirst()
        }
    }
    
    // Brings up the upgrade screen and pauses the game
    func upgrade() {
        leftTouch = nil
        leftInitialPosition = nil
        leftJoystick.isHidden = true
        leftThumb.isHidden = true
        hero.physicsBody?.velocity.dx = 0
        rightTouch = nil
        rightInitialPosition = nil
        gun.zRotation = 0
        shooting = false
        rightJoystick.isHidden = true
        rightThumb.isHidden = true
        isPaused = true
        upgradeScreen.isHidden = false
        upgradeLabel.isHidden = false
        switch healthUpgradeStatus {
        case 1:
            health_plus.position = health_1.position
            health_button.position = health_1.position
        case 2:
            health_1.color = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
            health_plus.position = health_2.position
            health_button.position = health_2.position
        case 3:
            health_2.color = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
            health_plus.position = health_3.position
            health_button.position = health_3.position
        default:
            health_3.color = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
            health_plus.text = ""
            health_button.state = .MSButtonNodeStateHidden
        }
        switch speedUpgradeStatus {
        case 1:
            speed_plus.position = speed_1.position
            speed_button.position = speed_1.position
        case 2:
            speed_1.color = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
            speed_plus.position = speed_2.position
            speed_button.position = speed_2.position
        case 3:
            speed_2.color = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
            speed_plus.position = speed_3.position
            speed_button.position = speed_3.position
        default:
            speed_3.color = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
            speed_plus.text = ""
            speed_button.state = .MSButtonNodeStateHidden
        }
        switch fireRateUpgradeStatus {
        case 1:
            fire_rate_plus.position = fire_rate_1.position
            fire_rate_button.position = fire_rate_1.position
        case 2:
            fire_rate_1.color = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
            fire_rate_plus.position = fire_rate_2.position
            fire_rate_button.position = fire_rate_2.position
        case 3:
            fire_rate_2.color = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
            fire_rate_plus.position = fire_rate_3.position
            fire_rate_button.position = fire_rate_3.position
        default:
            fire_rate_3.color = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
            fire_rate_plus.text = ""
            fire_rate_button.state = .MSButtonNodeStateHidden
        }
        switch bulletSpeedUpgradeStatus {
        case 1:
            bullet_speed_plus.position = bullet_speed_1.position
            bullet_speed_button.position = bullet_speed_1.position
        case 2:
            bullet_speed_1.color = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
            bullet_speed_plus.position = bullet_speed_2.position
            bullet_speed_button.position = bullet_speed_2.position
        case 3:
            bullet_speed_2.color = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
            bullet_speed_plus.position = bullet_speed_3.position
            bullet_speed_button.position = bullet_speed_3.position
        default:
            bullet_speed_3.color = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
            bullet_speed_plus.text = ""
            bullet_speed_button.state = .MSButtonNodeStateHidden
        }
        
        // Increases the difficulty
        normalSpawnFrequency = Int(Double(normalSpawnFrequency) * 0.9)
        if smartIsSpawning {
            smartSpawnFrequency = Int(Double(smartSpawnFrequency) * 0.9)
        }
        if bigIsSpawning {
            bigSpawnFrequency = Int(Double(bigSpawnFrequency) * 0.9)
        }
        
        // Makes invulnerable
        invincibilityTimer = invincibilityTime
    }
}
