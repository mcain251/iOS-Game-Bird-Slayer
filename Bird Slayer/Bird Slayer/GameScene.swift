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
    case inactive, active, gameOver, paused, upgrading
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
    var toxicHazardBase: SKSpriteNode!
    var hazards: [(SKSpriteNode, Int)] = []
    var powerupBase: SKSpriteNode!
    var healthBar: SKSpriteNode!
    var healthBarContainer: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var nextUpgradeLabel: SKLabelNode!
    var highScoreLabel: SKLabelNode!
    var tutorial: SKNode!
    var upgradeScreen: SKNode!
    var gameOverLabel: SKLabelNode!
    var levelUpLabel: SKLabelNode!
    var pauseButton: MSButtonNode!
    var pauseLabel: SKLabelNode!
    var upgradeLabel: SKLabelNode!
    var shield: SKSpriteNode!
    
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
    let minSpawnFrequency = 3 * 60
    let maxSpawnFrequency = Int(0.75 * 60.0)
    // Frames until post-upgrade invincibility runs out ~(seconds * 60)
    let invincibilityTime = 3 * 60
    let birdSpeed: CGFloat = 100
    let pooSpeed: CGFloat = 150
    // Average frames until next poop ~(seconds * 60)
    let pooFrequency: Int = 2 * 60
    // Frames until hazards disappear ~(seconds * 60)
    let hazardTime: Int = 2 * 60
    // Frames until next powerup ~(seconds * 60)
    let nextPowerupTime: Int = 45 * 60
    // Frames until powerup runs out ~(seconds * 60)
    let powerupTime: Int = 15 * 60
    // Frames until powerup disappears on ground ~(seconds * 60)
    let powerupIdleTime: Int = 5 * 60
    let powerupSpeed: CGFloat = 75
    let spreadShotSpread: CGFloat = CGFloat(Double.pi/12)
    
    // powerups
    var powerupStatuses: [String: (UIColor, Bool)] = [:]
    var currentPowerup: (SKSpriteNode, Bool, Int)!
    var powerupTimer = 0
    var powerupWillAppear = false
    var poweredup = false
    
    // Colors
    let upgradedColor: UIColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
    let smartPooColor: UIColor = UIColor(red: 1.0, green: 1.0, blue: 0.75, alpha: 1.0)
    let toxicPooColor: UIColor = UIColor(red: 0.72, green: 1.0, blue: 0.46, alpha: 1.0)
    let healthPowerupColor: UIColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    let shieldPowerupColor: UIColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
    let spreadShotPowerupColor: UIColor = UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
    
    // All bird variables assigned to each type:
    // spawnRatio = relative spawn ratio (100 = same rate as normal bird)
    // spawnTime = actual frames until next bird spawn (set later)
    // spawnTimer = framecount for bird spawning
    // levelsTo = how many times the player must upgrade for the bird to start spawning
    // isSpawning = if the bird type is spawning or not
    var birdVariables: [BirdType: (spawnRatio: Int, spawnTime: Int, spawnTimer: Int, levelsTo: Int, isSpawning: Bool)] = [.normal: (100, 0, 0, 0, true), .smart: (30, 0, 0, 2, false), .toxic: (30, 0, 0, 4, false), .big: (10, 0, 0, 6, false), .rare: (1, 0, 0, 8, false)]
    
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
    var upgradeScores: [Int] = [50, 150, 300, 500, 750, 1050, 1400, 1800, 2250, 2750, 3300, 3900]
    //var upgradeScores: [Int] = [10, 20, 50, 80, 110, 140, 220, 300, 500, 700, 900, 1100]
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
        powerupStatuses = ["health": (healthPowerupColor, false), "shield": (shieldPowerupColor, false), "spreadShot": (spreadShotPowerupColor, false)]
        powerupTimer = nextPowerupTime
        
        // Set the inital timers
        shotTimer = shotFrequency
        for (type, _) in birdVariables {
            birdVariables[type]?.spawnTime = spawnFrequency
        }
        
        // Set reference to objects, screens, and UI and sets their initial states
        hero = childNode(withName: "//hero") as! SKSpriteNode
        gun = hero.childNode(withName: "gun") as! SKSpriteNode
        birdBase = childNode(withName: "//birdBase") as! Bird
        bulletBase = childNode(withName: "//bulletBase") as! SKSpriteNode
        pooBase = childNode(withName: "//pooBase") as! SKSpriteNode
        toxicHazardBase = childNode(withName: "toxicHazardBase") as! SKSpriteNode
        powerupBase = childNode(withName: "powerupBase") as! SKSpriteNode
        healthBar = childNode(withName: "healthBar") as! SKSpriteNode
        healthBarContainer = childNode(withName: "healthBarContainer") as! SKSpriteNode
        scoreLabel = childNode(withName: "scoreLabel") as! SKLabelNode
        highScoreLabel = childNode(withName: "highScoreLabel") as! SKLabelNode
        nextUpgradeLabel = childNode(withName: "nextUpgradeLabel") as! SKLabelNode
        gameOverLabel = childNode(withName: "gameOverLabel") as! SKLabelNode
        gameOverLabel.isHidden = true
        levelUpLabel = childNode(withName: "levelUpLabel") as! SKLabelNode
        levelUpLabel.isHidden = true
        upgradeLabel = childNode(withName: "upgradeLabel") as! SKLabelNode
        upgradeLabel.isHidden = true
        pauseLabel = childNode(withName: "pauseLabel") as! SKLabelNode
        pauseLabel.isHidden = true
        tutorial = childNode(withName: "tutorial")
        tutorial.position = self.position
        upgradeScreen = childNode(withName: "upgradeScreen")
        upgradeScreen.position = self.position
        upgradeScreen.isHidden = true
        leftThumb = childNode(withName: "leftThumb") as! SKSpriteNode
        rightThumb = childNode(withName: "rightThumb") as! SKSpriteNode
        leftJoystick = childNode(withName: "leftJoystick") as! SKSpriteNode
        rightJoystick = childNode(withName: "rightJoystick") as! SKSpriteNode
        pauseButton = childNode(withName: "pauseButton") as! MSButtonNode
        shield = childNode(withName: "shield") as! SKSpriteNode
        
        // Set reference to upgrade UI objects
        for (type, elements) in upgradeUIElements {
            for i in 0 ..< elements.squares.count {
                upgradeUIElements[type]?.squares[i] = childNode(withName: "//\(type)_\(i+1)") as? SKSpriteNode
            }
            upgradeUIElements[type]?._plus = childNode(withName: "//\(type)_plus") as? SKLabelNode
            upgradeUIElements[type]?._button = childNode(withName: "//\(type)_button") as? MSButtonNode
            upgradeUIElements[type]?._button?.selectedHandler = {
                self.upgradeUIElements[type]?.upgradeStatus += 1
                self.isPaused = false
                self.gameState = .active
                self.upgradeScreen.isHidden = true
                self.upgradeLabel.isHidden = true
                self.pauseButton.isHidden = false
                self.pauseButton.state = .MSButtonNodeStateActive
            }
        }
        
        // Pause button functionality (pauses and presents paused upgrade screen/ unpauses and hides pause screen)
        pauseButton.selectedHandler = {
            if !self.pause {
                self.gameState = .paused
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
                self.gameState = .active
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
        
        // Starts the game
        if gameState == .inactive {
            gameState = .active
            pauseButton.isHidden = false
        }
        
        // Failsafe if you die and pause on the same frame
        if isPaused && !gameOverLabel.isHidden {
            isPaused  = false
            gameState = .gameOver
            upgradeScreen.isHidden = true
            pauseLabel.isHidden = true
            pause = false
        }
        
        // Reveals the upgrade menu
        if gameState == .upgrading && !levelUpLabel.isHidden {
            levelUpLabel.isHidden = true
            upgradeScreen.isHidden = false
            upgradeLabel.isHidden = false
            for (type, elements) in upgradeUIElements {
                if (elements.upgradeStatus - 2) >= 0 && (elements.upgradeStatus - 2) < elements.squares.count {
                    upgradeUIElements[type]?.squares[elements.upgradeStatus - 2]?.color = upgradedColor
                }
                if (elements.upgradeStatus - 1) < elements.squares.count {
                    upgradeUIElements[type]?._button?.position = (elements.squares[elements.upgradeStatus - 1]?.position)!
                    upgradeUIElements[type]?._plus?.position = (elements.squares[elements.upgradeStatus - 1]?.position)!
                } else {
                    upgradeUIElements[type]?._button?.state = .MSButtonNodeStateHidden
                    upgradeUIElements[type]?._plus?.text = ""
                }
            }
        }
        
        // Allows the player to control the hero if the game is playing
        if gameState != .gameOver && !isPaused {
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
        
        // Restarts the game
        if gameState == .gameOver {
            let skView = self.view as SKView!
            let scene = GameScene(fileNamed:"GameScene") as GameScene!
            scene?.scaleMode = .aspectFill
            skView?.presentScene(scene)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState != .gameOver && !isPaused {
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
        if gameState != .gameOver && !isPaused {
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
            pauseButton.isHidden = true
        }
        if gameState == .paused || gameState == .upgrading {
            isPaused = true
        }
        if gameState == .gameOver {
            pauseButton.isHidden = true
        }
        
        // Removes old poops
        pooManager()
        
        // Manages hero's health and healthbar
        healthManager()
        
        // Manages score and highscore, as well as the next upgrade label
        scoreManager()
        
        // Makes sure upgrades are applied correctly
        upgradeManager()
        
        // Removes old hazards
        hazardManager()
        
        // Applies current powerup and removes old powerups
        powerupManager()
        
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
        
        // Check if either physics bodies was a bird, then damage the bird and remove the bullet.
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
        
        // Check if one was the hero and the other was poop, then removes poop and decrements health, if necessary
        if (contactA.categoryBitMask == 1 && contactB.categoryBitMask == 8) {
            if invincibilityTimer <= 0 && !(powerupStatuses["shield"]?.1)! {
                health -= 1
                if nodeB.xScale == 2 && nodeB.yScale == 2 && health != 0{
                    health -= 1
                }
            }
            nodeB.removeFromParent()
            nodeB.isHidden = true
        }
        if (contactB.categoryBitMask == 1 && contactA.categoryBitMask == 8) {
            if invincibilityTimer <= 0 && !(powerupStatuses["shield"]?.1)! {
                health -= 1
                if nodeA.xScale == 2 && nodeA.yScale == 2 && health != 0 {
                    health -= 1
                }
            }
            nodeA.removeFromParent()
            nodeA.isHidden = true
        }
        
        // Check if one was the ground, then acts accordingly based on the type of poop
        if (contactA.categoryBitMask == 16) {
            if String(describing: nodeB.color) == String(describing: toxicPooColor){
                createHazard(nodeB)
                nodeB.removeFromParent()
                nodeB.isHidden = true
            }
        }
        if (contactB.categoryBitMask == 16) {
            if String(describing: nodeB.color) == String(describing: toxicPooColor) {
                createHazard(nodeA)
                nodeA.removeFromParent()
                nodeA.isHidden = true
            }
        }
        
        // Check if one was a hazard, then removes hazard and decrements health
        if (contactA.categoryBitMask == 32) {
            if invincibilityTimer <= 0 {
                health -= 1
            }
            nodeA.removeFromParent()
            nodeA.isHidden = true
        }
        if (contactB.categoryBitMask == 32) {
            if invincibilityTimer <= 0 {
                health -= 1
            }
            nodeB.removeFromParent()
            nodeB.isHidden = true
        }
        
        // Check if one was a powerup and the other was the ground, then stops the powerup and starts the timer
        if (contactA.categoryBitMask == 64 && contactB.categoryBitMask == 16) {
            nodeA.physicsBody?.velocity.dy = 0
            if nodeA === currentPowerup.0 {
                currentPowerup.1 = true
            }
        }
        if (contactB.categoryBitMask == 64 && contactA.categoryBitMask == 16) {
            nodeB.physicsBody?.velocity.dy = 0
            if nodeB === currentPowerup.0 {
                currentPowerup.1 = true
            }
        }
        
        // Check if one was a powerup and the other was the player, then removes the powerup and toggles the powerup
        if (contactA.categoryBitMask == 64 && contactB.categoryBitMask == 1) {
            for (powerup, attributes) in powerupStatuses {
                if String(describing: nodeA.color) == String(describing: attributes.0) {
                    powerupStatuses[powerup]?.1 = true
                }
            }
            nodeA.removeFromParent()
            nodeA.isHidden = true
        }
        if (contactB.categoryBitMask == 64 && contactA.categoryBitMask == 1) {
            for (powerup, attributes) in powerupStatuses {
                if String(describing: nodeB.color) == String(describing: attributes.0) {
                    powerupStatuses[powerup]?.1 = true
                }
            }
            nodeB.removeFromParent()
            nodeB.isHidden = true
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
            
            // Checks if birds are dead. Removes if true. Spawns powerup if powerup is due
            } else if birds[i].health <= 0 {
                if powerupWillAppear {
                    spawnPowerup(birds[i].position)
                    powerupWillAppear = false
                }
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
                if (powerupStatuses["spreadShot"]?.1)! {
                    spreadShoot()
                } else {
                    shoot()
                }
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
                    shotFrequency = Int(Double(minShotFrequency) * pow(pow((Double(maxShotFrequency)/Double(minShotFrequency)), (1.0/Double(upgrades))), Double(elements.upgradeStatus - 1)))
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
    
    // Removes hazards if their timer has reached hazardTime
    func hazardManager() {
        for i in 0 ..< hazards.count {
            if i < hazards.count {
                hazards[i].1 += 1
                if hazards[i].1 >= hazardTime {
                    hazards[i].0.removeFromParent()
                    hazards.remove(at: i)
                } else if hazards[i].0.isHidden {
                    hazards[i].0.removeFromParent()
                    hazards.remove(at: i)
                }
            }
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
    
    // Shoots in a spread patten
    func spreadShoot() {
        if gameState == .active {
            for i in 1 ... 3 {
                let newBullet = bulletBase.copy() as! SKSpriteNode
                newBullet.physicsBody?.linearDamping = 0
                newBullet.position = hero.position
                newBullet.position.x -= gun.size.height * sin(gun.zRotation)
                newBullet.position.y += gun.size.height * cos(gun.zRotation) - 160 + hero.size.height
                var rotation = gun.zRotation
                if i == 2 {
                    rotation += spreadShotSpread
                } else if i == 3 {
                    rotation -= spreadShotSpread
                }
                newBullet.physicsBody?.velocity.dx = -bulletSpeed * sin(rotation)
                newBullet.physicsBody?.velocity.dy = bulletSpeed * cos(rotation)
                bullets.append(newBullet)
                self.addChild(newBullet)
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
        case .toxic:
            newPoo.color = toxicPooColor
            newPoo.physicsBody?.velocity.dy = -1 * pooSpeed
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
            bullets.first?.removeFromParent()
            bullets.removeFirst()
        }
    }
    
    // Brings up the upgrade screen and pauses the game
    func upgrade() {
        
        if gameState != .gameOver {
            // Pauses game and removes UI
            gameState = .upgrading
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
            
            // Presents level up label
            levelUpLabel.isHidden = false
            
            // Increases the spawn rate
            calculateTotals()
            spawnFrequency = Int(Double(minSpawnFrequency) * pow(pow((Double(maxSpawnFrequency)/Double(minSpawnFrequency)), (1.0/Double(upgrades * upgradeTypes))), Double(total - upgradeTypes + 1)))
            
            // Makes invulnerable
            invincibilityTimer = invincibilityTime
        }
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
    
    // Creates a hazard at the location of the node
    func createHazard(_ node: SKNode) {
        let newHazard = toxicHazardBase.copy() as! SKSpriteNode
        newHazard.position.x = node.position.x
        newHazard.position.y = -130 - newHazard.size.height/2
        hazards.append((newHazard, 0))
        self.addChild(newHazard)
    }
    
    // Applies current powerup and removes old powerups. Also adds new powerups if they are due.
    func powerupManager() {
        for (powerup, attributes) in powerupStatuses {
            if attributes.1 {
                switch powerup {
                case "health":
                    if health < maxHealth {
                        health += 1
                    }
                case "shield":
                    shield.position = hero.position
                    shield.position.y -= 100
                    if !poweredup {
                        powerupTimer = powerupTime
                    }
                case "spreadShot":
                    if !poweredup {
                        powerupTimer = powerupTime
                    }
                default:
                    break
                }
                poweredup = true
            }
        }
        
        print("\(powerupTimer), \(poweredup)")
        
        if powerupTimer > 0 {
            if gameState == .active {
                powerupTimer -= 1
            }
        } else if poweredup {
            for (powerup, _) in powerupStatuses {
                powerupStatuses[powerup]?.1 = false
                shield.position = offScreen
            }
            poweredup = false
            powerupTimer = nextPowerupTime
        } else if !poweredup && powerupTimer > -100 {
            powerupWillAppear = true
            powerupTimer = -100
        }
    
        if currentPowerup != nil {
            if currentPowerup.1 {
                currentPowerup.2 -= 1
            }
            if currentPowerup.2 <= 0 {
                currentPowerup.0.removeFromParent()
                currentPowerup = nil
                powerupTimer = nextPowerupTime
            } else if currentPowerup.0.isHidden {
                currentPowerup.0.removeFromParent()
                currentPowerup = nil
            }
        }
    }
    
    // Spawns a powerup at the given position
    func spawnPowerup(_ pos: CGPoint) {
        let newPowerup = powerupBase.copy() as! SKSpriteNode
        newPowerup.position = pos
        newPowerup.physicsBody?.linearDamping = 0
        let rand = Int(arc4random_uniform(UInt32(powerupStatuses.count)))
        newPowerup.color = Array(powerupStatuses.values)[rand].0
        newPowerup.physicsBody?.velocity.dy = -1 * powerupSpeed
        addChild(newPowerup)
        currentPowerup = (newPowerup, false, powerupIdleTime)
    }
}
