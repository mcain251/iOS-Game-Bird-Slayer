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
    var rightLeg: SKSpriteNode!
    var leftLeg: SKSpriteNode!
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
    var unpauseButton: MSButtonNode!
    let unpauseButtonPosition: CGPoint = CGPoint(x: 241.5, y: 122.5)
    var menuButton: MSButtonNode!
    let menuButtonPosition: CGPoint = CGPoint(x: -226.5, y: 122.5)
    var pauseLabel: SKLabelNode!
    var upgradeLabel: SKLabelNode!
    var shield: SKSpriteNode!
    var ground: SKSpriteNode!
    var powerupBar: SKSpriteNode!
    var powerupBarContainer: SKSpriteNode!
    var zoomPoint: SKNode!
    
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
    let originalMaxHeroSpeed: CGFloat = 300
    let originalMinHeroSpeed: CGFloat = 150
    let originalMaxBulletSpeed: CGFloat = 500
    let originalMinBulletSpeed: CGFloat = 200
    // Frames until next shot ~(seconds * 60)
    let maxShotFrequency: Int = 30
    let minShotFrequency: Int = 1 * 60
    // Average frames until next bird spawn ~(seconds * 60)
    let minSpawnFrequency = 3 * 60
    let maxSpawnFrequency = Int(0.75 * 60.0)
    let originalMinSpawnHeight = 50
    let maxSpawnHeight = 160
    // Frames until post-upgrade invincibility runs out ~(seconds * 60)
    let invincibilityTime = 3 * 60
    let originalBirdSpeed: CGFloat = 100
    let originalPooSpeed: CGFloat = 150
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
    let originalPowerupSpeed: CGFloat = 75
    let spreadShotSpread: CGFloat = CGFloat(Double.pi/12)
    // Minimum size of objects on screen after zoom-out
    let minScale = 0.6
    // Tracks the original size of scalable objects for scaling
    var originalObjectSizes: [String: (x: CGFloat, y: CGFloat)] = [:]
    // Max angle of hero's legs
    let legAngle = CGFloat.pi * (CGFloat(45)/CGFloat(180))
    // Max angular delta of hero's legs (angle of change per frame)
    let maxLegSpeed = CGFloat.pi * (CGFloat(5)/CGFloat(180))
    
    // powerups (color, status, spawn ratio)
    var powerupStatuses: [String: (UIColor?, Bool, Int)] = ["health": (nil, false, 1), "shield": (nil, false, 1), "spreadShot": (nil, false, 1)]
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
    var maxHeroSpeed: CGFloat = 0
    var minHeroSpeed: CGFloat = 0
    var maxBulletSpeed: CGFloat = 0
    var minBulletSpeed: CGFloat = 0
    var birdSpeed: CGFloat = 0
    var pooSpeed: CGFloat = 0
    var powerupSpeed: CGFloat = 0
    var scaleChanged = false
    var minSpawnHeight = 0
    var right = true
    var legsMovingForward = true
    
    // Called when game begins
    override func didMove(to view: SKView) {
        
        // Set dependent values
        upgrades = (upgradeUIElements["health"]?.squares.count)!
        upgradeTypes = upgradeUIElements.count
        maxHeroSpeed = originalMaxHeroSpeed
        minHeroSpeed = originalMinHeroSpeed
        maxBulletSpeed = originalMaxBulletSpeed
        minBulletSpeed = originalMinHeroSpeed
        birdSpeed = originalBirdSpeed
        pooSpeed = originalPooSpeed
        powerupSpeed = originalPowerupSpeed
        minSpawnHeight = originalMinSpawnHeight
        maxHealth = minMaxHealth
        health = maxHealth
        heroSpeed = minHeroSpeed
        bulletSpeed = minBulletSpeed
        shotFrequency = minShotFrequency
        spawnFrequency = minSpawnFrequency
        powerupStatuses["health"]?.0 = healthPowerupColor
        powerupStatuses["shield"]?.0 = shieldPowerupColor
        powerupStatuses["spreadShot"]?.0 = spreadShotPowerupColor
        
        powerupTimer = nextPowerupTime
        
        // Set the inital timers
        shotTimer = shotFrequency
        for (type, _) in birdVariables {
            birdVariables[type]?.spawnTime = spawnFrequency
        }
        
        // Set reference to objects, screens, and UI and sets their initial states
        hero = childNode(withName: "//hero") as! SKSpriteNode
        gun = hero.childNode(withName: "gun") as! SKSpriteNode
        rightLeg = hero.childNode(withName: "rightLeg") as! SKSpriteNode
        leftLeg = hero.childNode(withName: "leftLeg") as! SKSpriteNode
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
        ground = childNode(withName: "ground") as! SKSpriteNode
        unpauseButton = childNode(withName: "unpauseButton") as! MSButtonNode
        unpauseButton.position = unpauseButtonPosition
        unpauseButton.isHidden = true
        unpauseButton.state = .MSButtonNodeStateHidden
        menuButton = childNode(withName: "menuButton") as! MSButtonNode
        menuButton.position = menuButtonPosition
        menuButton.isHidden = true
        menuButton.state = .MSButtonNodeStateHidden
        powerupBar = childNode(withName: "//powerupBar") as! SKSpriteNode
        powerupBarContainer = childNode(withName: "powerupBarContainer") as! SKSpriteNode
        zoomPoint = childNode(withName: "zoomPoint")

        
        // Set reference to upgrade UI objects
        for (type, elements) in upgradeUIElements {
            for i in 0 ..< elements.squares.count {
                upgradeUIElements[type]?.squares[i] = childNode(withName: "//\(type)_\(i+1)") as? SKSpriteNode
            }
            upgradeUIElements[type]?._plus = childNode(withName: "//\(type)_plus") as? SKLabelNode
            upgradeUIElements[type]?._button = childNode(withName: "//\(type)_button") as? MSButtonNode
            upgradeUIElements[type]?._button?.selectedHandler = {[unowned self] in
                self.upgradeUIElements[type]?.upgradeStatus += 1
                self.isPaused = false
                self.gameState = .active
                self.upgradeScreen.isHidden = true
                self.upgradeLabel.isHidden = true
                self.pauseButton.isHidden = false
                self.pauseButton.state = .MSButtonNodeStateActive
                // Changes scale
                self.scaleChanged = true
            }
        }
        
        // Pause button functionalities (pauses and presents paused upgrade screen/ unpauses and hides pause screen)
        pauseButton.selectedHandler = {[unowned self] in
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
                    for i in 0 ... elements.upgradeStatus - 2 {
                        self.upgradeUIElements[type]?.squares[i]?.color = self.upgradedColor
                    }
                }
                self.upgradeUIElements[type]?._button?.position = self.offScreen
                self.upgradeUIElements[type]?._plus?.position = self.offScreen
            }
            self.pauseLabel.isHidden = false
            self.pause = true
            self.unpauseButton.isHidden = false
            self.unpauseButton.state = .MSButtonNodeStateActive
            self.menuButton.isHidden = false
            self.menuButton.state = .MSButtonNodeStateActive
        }
        unpauseButton.selectedHandler = {[unowned self] in
            self.isPaused  = false
            self.gameState = .active
            self.upgradeScreen.isHidden = true
            self.pauseLabel.isHidden = true
            self.pause = false
            self.unpauseButton.isHidden = true
            self.unpauseButton.state = .MSButtonNodeStateHidden
            self.menuButton.isHidden = true
            self.menuButton.state = .MSButtonNodeStateHidden
        }
        menuButton.selectedHandler = {[unowned self] in
            // Set reference to SpriteKit view
            guard let skView = self.view as SKView! else {
                print("Could not get Skview")
                return
            }
            
            // Creates GameScene
            if let scene = GameScene(fileNamed: "MainMenu") {
                
                // Ensure correct aspect mode
                scene.scaleMode = .aspectFit
                skView.presentScene(scene)
            }
        }
        
        // Set physics contact delegate
        physicsWorld.contactDelegate = self
        
        // Loads saved progress if necessary
        if !newGame {
            for (type, _) in upgradeUIElements {
                if let savedUpgradeStatus = UserDefaults().integer(forKey: type) as Int? {
                    if savedUpgradeStatus > 0 {
                        upgradeUIElements[type]?.upgradeStatus = savedUpgradeStatus
                        upgradeUIElements[type]?.oldUpgradeStatus = savedUpgradeStatus
                    }
                }
            }
            if let savedScore = UserDefaults().integer(forKey: "SAVEDSCORE") as Int? {
                score = savedScore
            }
            if let savedHealth = UserDefaults().integer(forKey: "SAVEDHEALTH") as Int? {
                if savedHealth > 0 {
                    health = savedHealth
                }
            }
            while upgradeScores.count >= 1 && score >= upgradeScores.first! {
                upgradeScores.removeFirst()
            }
            calculateTotals()
            spawnFrequency = Int(Double(minSpawnFrequency) * pow(pow((Double(maxSpawnFrequency)/Double(minSpawnFrequency)), (1.0/Double(upgrades * upgradeTypes))), Double(total - upgradeTypes + 1)))
            maxHealth = (((maxMaxHealth - minMaxHealth)/upgrades) * ((upgradeUIElements["health"]?.upgradeStatus)! - 1)) + minMaxHealth
            heroSpeed = (((maxHeroSpeed - minHeroSpeed)/CGFloat(upgrades)) * CGFloat(((upgradeUIElements["speed"]?.upgradeStatus)! - 1))) + minHeroSpeed
            shotFrequency = Int(Double(minShotFrequency) * pow(pow((Double(maxShotFrequency)/Double(minShotFrequency)), (1.0/Double(upgrades))), Double((upgradeUIElements["fire_rate"]?.upgradeStatus)! - 1)))
            bulletSpeed = (((maxBulletSpeed - minBulletSpeed)/CGFloat(upgrades)) * CGFloat(((upgradeUIElements["bullet_speed"]?
                .upgradeStatus)! - 1))) + minBulletSpeed
        } else {
            newGame = false
        }
        
        // Save original object sizes
        originalObjectSizes["birdBase"] = (birdBase.size.width, birdBase.size.height)
        originalObjectSizes["pooBase"] = (pooBase.size.width, pooBase.size.height)
        originalObjectSizes["bulletBase"] = (bulletBase.size.width, bulletBase.size.height)
        originalObjectSizes["hero"] = (hero.size.width, hero.size.height)
        originalObjectSizes["gun"] = (gun.size.width, gun.size.height)
        originalObjectSizes["toxicHazardBase"] = (toxicHazardBase.size.width, toxicHazardBase.size.height)
        originalObjectSizes["shield"] = (shield.size.width, shield.size.height)
        originalObjectSizes["powerupBase"] = (powerupBase.size.width, powerupBase.size.height)
        
        scaleManager()
        hero.position.y = -120 + ground.size.height + hero.size.height/2.0
        
        if autoFire {
            gun.zRotation = CGFloat.pi
        }
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
                    for i in 0 ... elements.upgradeStatus - 2 {
                        self.upgradeUIElements[type]?.squares[i]?.color = self.upgradedColor
                    }
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
                        if !leftFixed {
                            leftInitialPosition = touch.location(in: self.view)
                            leftJoystickPosition = leftInitialPosition
                            leftJoystickPosition.x -= 284
                            leftJoystickPosition.y = 160 - leftInitialPosition.y
                            leftJoystick.position = leftJoystickPosition
                            leftThumb.position = leftJoystickPosition
                        } else {
                            leftInitialPosition = fixedLeftJoystickLocation
                            leftJoystickPosition = leftInitialPosition
                            leftJoystickPosition.x -= 284
                            leftJoystick.position = leftJoystickPosition
                            leftThumb.position = leftJoystickPosition
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
                        }
                        leftJoystick.isHidden = false
                        leftThumb.isHidden = false
                    }
                } else {
                    if rightTouch == nil {
                        rightTouch = touch
                        if !rightFixed {
                            rightInitialPosition = touch.location(in: self.view)
                            rightJoystickPosition = rightInitialPosition
                            rightJoystickPosition.x -= 284
                            rightJoystickPosition.y = 160 - rightInitialPosition.y
                            rightJoystick.position = rightJoystickPosition
                            rightThumb.position = rightJoystickPosition
                            gun.zRotation = CGFloat.pi
                        } else {
                            rightInitialPosition = fixedRightJoystickLocation
                            rightJoystickPosition = rightInitialPosition
                            rightJoystickPosition.x -= 284
                            rightJoystick.position = rightJoystickPosition
                            rightThumb.position = rightJoystickPosition
                            gun.zRotation = (rightInitialPosition.x - touch.location(in: self.view).x) * CGFloat(Double.pi/4/50) + CGFloat.pi
                            gun.zRotation = clamp(value: gun.zRotation, lower: -CGFloat(Double.pi/4) + CGFloat.pi, upper: CGFloat(Double.pi/4) + CGFloat.pi)
                            rightThumb.position.x = clamp(value: touch.location(in: self).x, lower: rightJoystickPosition.x - 50, upper: rightJoystickPosition.x + 50)
                        }
                        shooting = true
                        rightJoystick.isHidden = false
                        rightThumb.isHidden = false
                        if hero.xScale == -1 {
                            gun.zRotation = -gun.zRotation
                        }
                    }
                }
            }
        }
        
        // Restarts the game
        if gameState == .gameOver {
            
            // Resets saved values
            for (type, _) in upgradeUIElements {
                UserDefaults.standard.set(1, forKey: type)
            }
            
            UserDefaults.standard.set(0, forKey: "SAVEDSCORE")
            UserDefaults.standard.set(minMaxHealth, forKey: "SAVEDHEALTH")
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
                    gun.zRotation = (rightInitialPosition.x - touch.location(in: self.view).x) * CGFloat(Double.pi/4/50) + CGFloat.pi
                    gun.zRotation = clamp(value: gun.zRotation, lower: -CGFloat(Double.pi/4) + CGFloat.pi, upper: CGFloat(Double.pi/4) + CGFloat.pi)
                    rightThumb.position.x = clamp(value: touch.location(in: self).x, lower: rightJoystickPosition.x - 50, upper: rightJoystickPosition.x + 50)
                    if hero.xScale == -1 {
                        gun.zRotation = -gun.zRotation
                    }
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
                    if autoFire {
                        gun.zRotation = CGFloat.pi
                    } else {
                        gun.zRotation = 0
                    }
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
            if invincibilityTimer % 20 > 13 {
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
        
        // Saves progress
        saveElements()
        
        // Makes sure the scale of scalable variables is correct
        scaleManager()
        
        // Manages walking animation
        legManager()
        
        // Clamps hero's position and velocity to inside play area
        if (hero.position.x <= (-284 + hero.size.width / 2 + 1)) {
            hero.position.x = max(hero.position.x, -284 + hero.size.width / 2)
            hero.physicsBody?.velocity.dx = clamp(value: (hero.physicsBody?.velocity.dx)!, lower: 0, upper: heroSpeed)
        }
        if (hero.position.x >= (284 - (hero.size.width / 2) - 1)) {
            hero.position.x = min(hero.position.x, 284 - (hero.size.width / 2))
            hero.physicsBody?.velocity.dx = clamp(value: (hero.physicsBody?.velocity.dx)!, lower: -1 * heroSpeed, upper: 0)
        }
        
        if (hero.physicsBody?.velocity.dx)! < CGFloat(0) {
            hero.xScale = -1
            if right {
                gun.zRotation = -gun.zRotation
            }
            right = false
        }
        if (hero.physicsBody?.velocity.dx)! > CGFloat(0) {
            hero.xScale = 1
            if !right {
                gun.zRotation = -gun.zRotation
            }
            right = true
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
                invincibilityTimer = invincibilityTime
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
                invincibilityTimer = invincibilityTime
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
            invincibilityTimer = invincibilityTime
            nodeA.removeFromParent()
            nodeA.isHidden = true
        }
        if (contactB.categoryBitMask == 32) {
            if invincibilityTimer <= 0 {
                health -= 1
            }
            invincibilityTimer = invincibilityTime
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
                if String(describing: nodeA.color) == String(describing: attributes.0!) {
                    powerupStatuses[powerup]?.1 = true
                }
            }
            nodeA.removeFromParent()
            nodeA.isHidden = true
        }
        if (contactB.categoryBitMask == 64 && contactA.categoryBitMask == 1) {
            for (powerup, attributes) in powerupStatuses {
                if String(describing: nodeB.color) == String(describing: attributes.0!) {
                    powerupStatuses[powerup]?.1 = true
                }
            }
            nodeB.removeFromParent()
            nodeB.isHidden = true
        }
    }
    
    // Figures out if new bird should be spawned, then spawns it. Removes old birds. Makes birds poo if they are due. Spawns powerups if due
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
            if birds[i].position.x < -284 - (birds[i].size.width/2 + 2) || birds[i].position.x > 350 + (birds[i].size.width/2 + 2) {
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
        if shooting || autoFire {
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
            if type == "health" && elements.upgradeStatus - elements.oldUpgradeStatus == 1 {
                    maxHealth = (((maxMaxHealth - minMaxHealth)/upgrades) * (elements.upgradeStatus - 1)) + minMaxHealth
                    health += ((maxMaxHealth - minMaxHealth)/upgrades)
            }
            switch type{
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
        var rand = arc4random_uniform(UInt32(CGFloat(maxSpawnHeight - minSpawnHeight) - (2 * newBird.size.height)))
        rand += UInt32(newBird.size.height) + UInt32(minSpawnHeight)
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
            if delay || autoFire {
                var rotation = gun.zRotation + CGFloat.pi
                if hero.xScale == -1 {
                    rotation = CGFloat.pi - gun.zRotation
                }
                let newBullet = bulletBase.copy() as! SKSpriteNode
                newBullet.physicsBody?.linearDamping = 0
                newBullet.position = hero.position
                newBullet.position.x -= gun.size.height * sin(rotation)
                newBullet.position.y = gun.size.height * cos(rotation) - 160 + ground.size.height + (hero.size.height/2) + gun.position.y
                newBullet.physicsBody?.velocity.dx = -bulletSpeed * sin(rotation)
                newBullet.physicsBody?.velocity.dy = bulletSpeed * cos(rotation)
                newBullet.zRotation = rotation
                bullets.append(newBullet)
                self.addChild(newBullet)
                newBullet.zPosition = 2
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
                var rotation = gun.zRotation + CGFloat.pi
                if hero.xScale == -1 {
                    rotation = CGFloat.pi - gun.zRotation
                }
                newBullet.position.x -= gun.size.height * sin(rotation)
                newBullet.position.y = gun.size.height * cos(rotation) - 160 + ground.size.height + (hero.size.height/2) + gun.position.y
                if i == 2 {
                    rotation += spreadShotSpread
                } else if i == 3 {
                    rotation -= spreadShotSpread
                }
                newBullet.physicsBody?.velocity.dx = -bulletSpeed * sin(rotation)
                newBullet.physicsBody?.velocity.dy = bulletSpeed * cos(rotation)
                newBullet.zRotation = rotation
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
        newHazard.position.y = ground.position.y + ground.size.height/2 - toxicHazardBase.size.height/2
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
                    shield.position.y = ground.size.height + (hero.size.height/2) - 160
                    if !poweredup {
                        powerupTimer = powerupTime
                    }
                    powerupBar.color = shieldPowerupColor
                case "spreadShot":
                    if !poweredup {
                        powerupTimer = powerupTime
                    }
                    powerupBar.color = spreadShotPowerupColor
                    powerupBar.alpha = 0.75
                default:
                    break
                }
                poweredup = true
            }
        }
        
        if powerupTimer > 0 {
            if gameState == .active {
                powerupTimer -= 1
            }
            if poweredup {
                powerupBarContainer.position = hero.position
                powerupBarContainer.position.y = ground.size.height - powerupBarContainer.size.height/2 - 160
                powerupBarContainer.position.x -= powerupBarContainer.size.width/2
                powerupBar.size.width = (CGFloat(powerupTimer)/CGFloat(powerupTime)) * (powerupBarContainer.size.width - 5)
            }
        } else if poweredup {
            for (powerup, _) in powerupStatuses {
                powerupStatuses[powerup]?.1 = false
                shield.position = offScreen
            }
            poweredup = false
            powerupTimer = nextPowerupTime
            powerupBarContainer.position = offScreen
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
        var rtotal = 0
        for (_, attributes) in powerupStatuses {
            rtotal += attributes.2
        }
        var rand = Int(arc4random_uniform(UInt32(rtotal))) + 1
        for (_, attributes) in powerupStatuses {
            rand -= attributes.2
            if rand <= 0 {
                newPowerup.color = attributes.0!
                break
            }
        }
        newPowerup.physicsBody?.velocity.dy = -1 * powerupSpeed
        addChild(newPowerup)
        currentPowerup = (newPowerup, false, powerupIdleTime)
    }
    
    // Saves progress to be picked up when the user returns
    func saveElements() {
        for (type, elements) in upgradeUIElements {
            UserDefaults.standard.set(elements.upgradeStatus, forKey: type)
        }
        UserDefaults.standard.set(score, forKey: "SAVEDSCORE")
        UserDefaults.standard.set(health, forKey: "SAVEDHEALTH")
    }
    
    // Scales the scaling elements on the screen down to simulate zooming out
    func scaleManager() {
        calculateTotals()
        let smallScale = CGFloat(pow(Double(minScale), (1.0/Double(upgrades * upgradeTypes))))
        let scale = CGFloat(pow(Double(smallScale), Double(total - upgradeTypes)))
        minSpawnHeight = Int((CGFloat(originalMinSpawnHeight) - zoomPoint.position.y) * scale + zoomPoint.position.y)
        maxHeroSpeed = originalMaxHeroSpeed * scale
        minHeroSpeed = originalMinHeroSpeed * scale
        maxBulletSpeed = originalMaxBulletSpeed * scale
        minBulletSpeed = originalMinBulletSpeed * scale
        birdSpeed = originalBirdSpeed * scale
        pooSpeed = originalPooSpeed * scale
        powerupSpeed = originalPowerupSpeed * scale
        birdBase.size = CGSize(width: (originalObjectSizes["birdBase"]?.x)! * scale, height: (originalObjectSizes["birdBase"]?.y)! * scale)
        pooBase.size = CGSize(width: (originalObjectSizes["pooBase"]?.x)! * scale, height: (originalObjectSizes["pooBase"]?.y)! * scale)
        bulletBase.size = CGSize(width: (originalObjectSizes["bulletBase"]?.x)! * scale, height: (originalObjectSizes["bulletBase"]?.y)! * scale)
        toxicHazardBase.size = CGSize(width: (originalObjectSizes["toxicHazardBase"]?.x)! * scale, height: (originalObjectSizes["toxicHazardBase"]?.y)! * scale)
        hero.size = CGSize(width: (originalObjectSizes["hero"]?.x)! * scale, height: (originalObjectSizes["hero"]?.y)! * scale)
        shield.size = CGSize(width: (originalObjectSizes["shield"]?.x)! * scale, height: (originalObjectSizes["shield"]?.y)! * scale)
        gun.size = CGSize(width: (originalObjectSizes["gun"]?.x)! * scale, height: (originalObjectSizes["gun"]?.y)! * scale)
        powerupBase.size = CGSize(width: (originalObjectSizes["powerupBase"]?.x)! * scale, height: (originalObjectSizes["powerupBase"]?.y)! * scale)
        if currentPowerup != nil {
            currentPowerup.0.size = powerupBase.size
            if scaleChanged {
                currentPowerup.0.position.x = currentPowerup.0.position.x
                currentPowerup.0.position.y = ((currentPowerup.0.position.y - zoomPoint.position.y) * scale) + zoomPoint.position.y
                currentPowerup.0.physicsBody?.velocity.dy = (currentPowerup.0.physicsBody?.velocity.dy)! * scale
            }
        }
        for bird in birds {
            if scaleChanged {
                bird.size = CGSize(width: bird.size.width * smallScale, height: bird.size.height * smallScale)
                bird.position.x = bird.position.x * scale
                bird.position.y = ((bird.position.y - zoomPoint.position.y) * scale) + zoomPoint.position.y
                bird.physicsBody?.velocity.dx = (bird.physicsBody?.velocity.dx)! * scale
            }
        }
        for bullet in bullets {
            bullet.size = bulletBase.size
            if scaleChanged {
                bullet.position.x = bullet.position.x * scale
                bullet.position.y = ((bullet.position.y - zoomPoint.position.y) * scale) + zoomPoint.position.y
                bullet.physicsBody?.velocity.dy = (bullet.physicsBody?.velocity.dy)! * scale
                bullet.physicsBody?.velocity.dx = (bullet.physicsBody?.velocity.dx)! * scale
            }
        }
        for hazard in hazards {
            hazard.0.size = toxicHazardBase.size
            if scaleChanged {
                hazard.0.position.x = hazard.0.position.x * scale
                hazard.0.position.y = ((hazard.0.position.y - zoomPoint.position.y) * scale) + zoomPoint.position.y
            }
        }
        for poo in poops {
            if scaleChanged {
                poo.size = CGSize(width: poo.size.width * smallScale, height: poo.size.height * smallScale)
                poo.position.x = poo.position.x * scale
                poo.position.y = ((poo.position.y - zoomPoint.position.y) * scale) + zoomPoint.position.y
                poo.physicsBody?.velocity.dy = (poo.physicsBody?.velocity.dy)! * scale
            }
        }
        if scaleChanged {
            hero.position.x = hero.position.x * scale
            hero.position.y = -120 + ground.size.height + hero.size.height/2.0
            scaleChanged = false
        }
    }
    
    // Makes the hero's legs move
    func legManager() {
        let legSpeed = abs((hero.physicsBody?.velocity.dx)!/heroSpeed * maxLegSpeed)
        if rightLeg.zRotation >= legAngle {
            legsMovingForward = false
        } else if leftLeg.zRotation >= legAngle {
            legsMovingForward = true
        }
        if legsMovingForward && legSpeed > 0{
            rightLeg.zRotation = rightLeg.zRotation + legSpeed
            leftLeg.zRotation = rightLeg.zRotation * -1
        } else if legSpeed > 0 {
            rightLeg.zRotation = rightLeg.zRotation - legSpeed
            leftLeg.zRotation = rightLeg.zRotation * -1
        }
        if legSpeed == CGFloat(0) {
            legsMovingForward = true
            rightLeg.zRotation = rightLeg.zRotation / 2
            leftLeg.zRotation = leftLeg.zRotation / 2
        }
    }
}
