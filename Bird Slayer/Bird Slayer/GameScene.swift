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
    
    // Upgrade UI and relevant values
    var upgradeUIElements: [String: (squares: [SKSpriteNode?], _plus: SKLabelNode?, _button: MSButtonNode?, upgradeStatus: Int, oldUpgradeStatus: Int)] = ["health": ([nil, nil, nil], nil, nil, 1, 1), "speed": ([nil, nil, nil], nil, nil, 1, 1), "fire_rate": ([nil, nil, nil], nil, nil, 1, 1), "bullet_speed": ([nil, nil, nil], nil, nil, 1, 1)]
    // Total of the upgrade statuses
    var total = 0
    var oldTotal = 0
    let offScreen: CGPoint = CGPoint(x: -1000, y: -1000)
    // Number of upgrades per catagory (set later)
    var upgrades = 0
    // Number of categories (set later)
    var upgradeTypes = 0
    
    // Controls
    var leftTouch: UITouch?
    var leftInitialPosition: CGPoint!
    var rightTouch: UITouch?
    var rightInitialPosition: CGPoint!
    var leftThumb: SKSpriteNode!
    var rightThumb: SKSpriteNode!
    var leftJoystick: SKSpriteNode!
    var rightJoystick: SKSpriteNode!
    var leftJoystickPosition: CGPoint!
    var rightJoystickPosition: CGPoint!
    var shooting = false
    // Delays the first shot to persuade the user to hold down the fire button
    var delay = false
    
    // Gameplay constants
    let maxMaxHealth = 12
    let minMaxHealth = 6
    let maxHeroSpeed: CGFloat = 300
    let minHeroSpeed: CGFloat = 150
    let maxBulletSpeed: CGFloat = 500
    let minBulletSpeed: CGFloat = 200
    // Frames until next shot ~(seconds * 60)
    let maxShotFrequency: Int = 30
    let minShotFrequency: Int = 1 * 60
    // Average frames until next bird spawn ~(seconds * 60)
    let minSpawnFrequency = 5 * 60
    let maxSpawnFrequency = 1 * 60
    // Frames until post-upgrade invincibility runs out ~(seconds * 60)
    let invincibilityTime = 3 * 60
    let birdSpeed: CGFloat = 100
    let pooSpeed: CGFloat = 150
    // Average frames until next poop ~(seconds * 60)
    let pooFrequency: Int = 2 * 60
    
    // Colors
    let upgradedColor: UIColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
    let smartPooColor: UIColor = UIColor(red: 1.0, green: 1.0, blue: 0.75, alpha: 1.0)
    
    // All bird variables assigned to each type:
    // spawnRatio = relative spawn ratio (100 = same rate as normal bird)
    // spawnTime = actual frames until next bird spawn (set later)
    // spawnTimer = framecount for bird spawning
    // levelsTo = how many times the player must upgrade for the bird to start spawning
    // isSpawning = if the bird type is spawning or not
    var birdVariables: [BirdType: (spawnRatio: Int, spawnTime: Int, spawnTimer: Int, levelsTo: Int, isSpawning: Bool)] = [.normal: (100, 0, 0, 0, true), .smart: (50, 0, 0, 2, false), .big: (25, 0, 0, 4, false), .rare: (2, 0, 0, 6, false)]
    
    // BTS variables
    var score = 0
    var highScore = UserDefaults().integer(forKey: "HIGHSCORE")
    var health = 0
    var maxHealth = 0
    var heroSpeed: CGFloat = 0
    var bulletSpeed: CGFloat = 0
    var shotFrequency: Int = 0
    var spawnFrequency = 0
    // Framecounts for invincibility and shooting
    var invincibilityTimer = 0
    var shotTimer: Int = 0
    var gameState: GameSceneState = .inactive
    // List of scores that initiate upgrade screen
    //var upgradeScores: [Int] = [50, 150, 300, 500, 750, 1050, 1400, 1800, 2250, 2750, 3300, 3900]
    var upgradeScores: [Int] = [10, 20, 50, 80, 130, 200, 250, 300, 350, 400, 450, 500]
    var pause = false
    
    // Called when game begins
    override func didMove(to view: SKView) {
        
        // Set dependent values
        upgrades = (upgradeUIElements["health"]?.squares.count)!
        upgradeTypes = upgradeUIElements.count
        maxHealth = minMaxHealth
        health = maxHealth
        heroSpeed = minHeroSpeed
        bulletSpeed = minBulletSpeed
        shotFrequency = minShotFrequency
        spawnFrequency = minSpawnFrequency
        
        // Set the inital timers
        shotTimer = shotFrequency
        for (type, _) in birdVariables {
            birdVariables[type]?.spawnTime = spawnFrequency
        }
        
        // Set reference to objects, screens, and UI and sets their initial states
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
        gameOverLabel = self.childNode(withName: "gameOverLabel") as! SKLabelNode
        gameOverLabel.isHidden = true
        upgradeLabel = self.childNode(withName: "upgradeLabel") as! SKLabelNode
        upgradeLabel.isHidden = true
        pauseLabel = self.childNode(withName: "pauseLabel") as! SKLabelNode
        pauseLabel.isHidden = true
        tutorial = self.childNode(withName: "tutorial")
        tutorial.position = self.position
        upgradeScreen = self.childNode(withName: "upgradeScreen")
        upgradeScreen.position = self.position
        upgradeScreen.isHidden = true
        leftThumb = self.childNode(withName: "leftThumb") as! SKSpriteNode
        rightThumb = self.childNode(withName: "rightThumb") as! SKSpriteNode
        leftJoystick = self.childNode(withName: "leftJoystick") as! SKSpriteNode
        rightJoystick = self.childNode(withName: "rightJoystick") as! SKSpriteNode
        pauseButton = self.childNode(withName: "pauseButton") as! MSButtonNode
        
        // Set reference to upgrade UI objects
        for (type, elements) in upgradeUIElements {
            for i in 0 ..< elements.squares.count {
                upgradeUIElements[type]?.squares[i] = self.childNode(withName: "//\(type)_\(i+1)") as? SKSpriteNode
            }
            upgradeUIElements[type]?._plus = self.childNode(withName: "//\(type)_plus") as? SKLabelNode
            upgradeUIElements[type]?._button = self.childNode(withName: "//\(type)_button") as? MSButtonNode
            upgradeUIElements[type]?._button?.selectedHandler = {
                self.upgradeUIElements[type]?.upgradeStatus += 1
                self.isPaused = false
                self.upgradeScreen.isHidden = true
                self.upgradeLabel.isHidden = true
                self.pauseButton.isHidden = false
                self.pauseButton.state = .MSButtonNodeStateActive
            }
        }
        
        // Pause button functionality (pauses and presents paused upgrade screen/ unpauses and hides pause screen)
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
                for (type, elements) in self.upgradeUIElements {
                    if (elements.upgradeStatus - 2) >= 0 && (elements.upgradeStatus - 2) < elements.squares.count {
                        self.upgradeUIElements[type]?.squares[elements.upgradeStatus - 2]?.color = self.upgradedColor
                    }
                    self.upgradeUIElements[type]?._button?.position = self.offScreen
                    self.upgradeUIElements[type]?._plus?.position = self.offScreen
                }
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
                    gun.zRotation = (rightInitialPosition.x - touch.location(in: self.view).x) * CGFloat(Double.pi/4/50)
                    gun.zRotation = clamp(value: gun.zRotation, lower: -CGFloat(Double.pi/4), upper: CGFloat(Double.pi/4))
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
        
        // Check if one was the ground, then acts accordingly based on the type of poop
        if (contactA.categoryBitMask == 16 || contactB.categoryBitMask == 16) {
            
        }
    }
    
    // Figures out if new bird should be spawned, then spawns it. Removes old birds. Makes birds poo if they are due
    func birdManager() {
        
        // Checks if birds are due to spawn. Spawns if true
        for (type, variables) in birdVariables {
            if variables.isSpawning {
                birdVariables[type]?.spawnTimer += 1
                if variables.spawnTimer >= variables.spawnTime {
                    spawnBird(type)
                    let spawnRate = Int(Double(spawnFrequency) * (ratioTotal()/Double(variables.spawnRatio)))
                    let rand = arc4random_uniform(UInt32(spawnRate))
                    birdVariables[type]?.spawnTime = Int(rand) + (spawnRate/2)
                    birdVariables[type]?.spawnTimer = 0
                }
            }
        }
        for var i in 0 ..< birds.count {
            if i >= birds.count || i < 0 {break}
            birds[i].pooTimer -= 1
            
            // Checks if the birds are offscreen. Removes if true
            if birds[i].position.x < -284 - (birds[i].size.width/2 + 1) || birds[i].position.x > 350 + (birds[i].size.width/2 + 1) {
                birds[i].removeFromParent()
                birds.remove(at: i)
                if i > 0 {
                    i -= 1
                }
            
            // Checks if birds are dead. Removes if true
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
                
            // Checks if birds are due to poo. Poops if true
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
        calculateTotals()
        while total - oldTotal > 1 {
            for (type, elements) in upgradeUIElements {
                if total - oldTotal > 1 {
                    upgradeUIElements[type]?.upgradeStatus = max(elements.upgradeStatus - 1, elements.oldUpgradeStatus)
                }
                calculateTotals()
            }
        }
        for (type, elements) in upgradeUIElements {
            if elements.upgradeStatus - elements.oldUpgradeStatus == 1 {
                switch type {
                case "health":
                    maxHealth = (((maxMaxHealth - minMaxHealth)/upgrades) * (elements.upgradeStatus - 1)) + minMaxHealth
                    health += ((maxMaxHealth - minMaxHealth)/upgrades)
                case "speed":
                    heroSpeed = (((maxHeroSpeed - minHeroSpeed)/CGFloat(upgrades)) * CGFloat((elements.upgradeStatus - 1))) + minHeroSpeed
                case "fire_rate":
                    shotFrequency = minShotFrequency - (((minShotFrequency - maxShotFrequency)/upgrades) * (elements.upgradeStatus - 1))
                case "bullet_speed":
                    bulletSpeed = (((maxBulletSpeed - minBulletSpeed)/CGFloat(upgrades)) * CGFloat((elements.upgradeStatus - 1))) + minBulletSpeed
                default:
                    break
                }
            }
        }
        
        // Toggles harder birds
        for (type, variables) in birdVariables {
            if !variables.isSpawning && total >= upgradeTypes + variables.levelsTo {
                birdVariables[type]?.isSpawning = true
            }
        }
        
        // Updates old status values
        for (type, elements) in upgradeUIElements {
            upgradeUIElements[type]?.oldUpgradeStatus = elements.upgradeStatus
        }
    }
    
    // Spawns a new bird
    func spawnBird(_ type: BirdType) {
        let newBird = birdBase.copy() as! Bird
        newBird.physicsBody?.linearDamping = 0
        
        // Sets the bird's type
        newBird.birdSpeed = self.birdSpeed
        newBird.type = type
        
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
        var newPosition = CGPoint(x: 284 + Int(newBird.size.width/2 + 1),y: Int(rand))
        newBird.physicsBody?.velocity.dx = -1 * newBird.birdSpeed
        if newBird.direction == .right {
            newPosition.x = -284 - (newBird.size.width/2 + 1)
            newBird.physicsBody?.velocity.dx = newBird.birdSpeed
        }
        newBird.position = newPosition
        self.addChild(newBird)
        birds.append(newBird)
    }
    
    // Shoots
    func shoot() {
        if gameState == .active {
            if delay {
                let newBullet = bulletBase.copy() as! SKSpriteNode
                newBullet.physicsBody?.linearDamping = 0
                newBullet.position = hero.position
                newBullet.position.x -= gun.size.height * sin(gun.zRotation)
                newBullet.position.y += gun.size.height * cos(gun.zRotation) - 160 + hero.size.height
                newBullet.physicsBody?.velocity.dx = -bulletSpeed * sin(gun.zRotation)
                newBullet.physicsBody?.velocity.dy = bulletSpeed * cos(gun.zRotation)
                bullets.append(newBullet)
                self.addChild(newBullet)
            } else {
                delay = true
            }
        }
    }
    
    // Poops
    func poo(_ bird: Bird) {
        var isPooping = true
        let newPoo = pooBase.copy() as! SKSpriteNode
        newPoo.physicsBody?.linearDamping = 0
        newPoo.position = bird.position
        newPoo.position.y = bird.position.y - 10
        switch bird.type! {
        case .smart:
            newPoo.color = smartPooColor
            var xDist = hero.position.x - newPoo.position.x
            let yDist = hero.position.y - newPoo.position.y - 100
            if xDist > abs(yDist) {
                xDist = abs(yDist)
            }
            if xDist < yDist {
                xDist = yDist
            }
            let tDist = sqrt(xDist*xDist + yDist*yDist)
            newPoo.physicsBody?.velocity.dy = pooSpeed * (yDist/tDist)
            newPoo.physicsBody?.velocity.dx = pooSpeed * (xDist/tDist)
        case .big:
            newPoo.xScale = 2
            newPoo.yScale = 2
            newPoo.physicsBody?.velocity.dy = -0.75 * pooSpeed
        case .rare:
            isPooping = false
        default:
            newPoo.physicsBody?.velocity.dy = -1 * pooSpeed
        }
        if isPooping {
            poops.append(newPoo)
            self.addChild(newPoo)
        }
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
        
        // Pauses game and removes UI
        pauseButton.isHidden = true
        pauseButton.state = .MSButtonNodeStateHidden
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
        
        // Presents upgrade screen
        upgradeScreen.isHidden = false
        upgradeLabel.isHidden = false
        for (type, elements) in upgradeUIElements {
            if (elements.upgradeStatus - 2) >= 0 && (elements.upgradeStatus - 2) < elements.squares.count {
                self.upgradeUIElements[type]?.squares[elements.upgradeStatus - 2]?.color = self.upgradedColor
            }
            if (elements.upgradeStatus - 1) < elements.squares.count {
                upgradeUIElements[type]?._button?.position = (elements.squares[elements.upgradeStatus - 1]?.position)!
                upgradeUIElements[type]?._plus?.position = (elements.squares[elements.upgradeStatus - 1]?.position)!
            } else {
                upgradeUIElements[type]?._button?.state = .MSButtonNodeStateHidden
                upgradeUIElements[type]?._plus?.text = ""
            }
        }
        
        // Increases the spawn rate
        calculateTotals()
        spawnFrequency = minSpawnFrequency - (((minSpawnFrequency - maxSpawnFrequency)/(upgrades * upgradeTypes)) * (total - upgradeTypes))
        
        // Makes invulnerable
        invincibilityTimer = invincibilityTime
    }
    
    // Calculates the new and old totals of the upgrade statuses
    func calculateTotals() {
        total = 0
        oldTotal = 0
        for (_, elements) in upgradeUIElements {
            total += elements.upgradeStatus
            oldTotal += elements.oldUpgradeStatus
        }
    }
    
    // Calculates and returns the total of the relevant bird spawn ratios. Used to calculate individual spawn rates
    func ratioTotal() -> Double {
        var ratioTotal: Double = 0.0
        for (_, variables) in birdVariables {
            if variables.isSpawning {
                ratioTotal += Double(variables.spawnRatio)
            }
        }
        return ratioTotal
    }
}
