//
//  GameScene.swift
//  Bird Slayer
//
//  Created by Marshall Cain on 7/5/17.
//  Copyright © 2017 Marshall Cain. All rights reserved.
//

import SpriteKit
import AVFoundation

// Clamp function
func clamp<T: Comparable>(value: T, lower: T, upper: T) -> T {
    return min(max(value, lower), upper)
}

// Game state enumeration
enum GameSceneState {
    case inactive, active, gameOver, paused, upgrading
}

class GameScene: SKScene, SKPhysicsContactDelegate {

    let onScreen = CGPoint(x: 0, y: 0)
    let offScreen = CGPoint(x: -1000, y: -1000)
    
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
    let unpauseButtonPosition = CGPoint(x: 246.5, y: 122.5)
    var menuButton: MSButtonNode!
    let menuButtonPosition = CGPoint(x: -224, y: 122.5)
    var soundButton: MSButtonNode!
    let soundButtonPosition = CGPoint(x: 116.5, y: 122.5)
    var musicButton: MSButtonNode!
    let musicButtonPosition = CGPoint(x: 176.5, y: 122.5)
    var musicX: SKSpriteNode!
    var pauseLabel: SKLabelNode!
    var upgradeLabel: SKLabelNode!
    var shield: SKSpriteNode!
    var shield_2: SKSpriteNode!
    var ground: SKSpriteNode!
    var powerupBar: SKSpriteNode!
    var powerupBarContainer: SKSpriteNode!
    var zoomPoint: SKNode!
    var background: SKSpriteNode!
    var scoreTextBase: SKLabelNode!
    var healthTextBase: SKLabelNode!
    var featherBase: SKSpriteNode!
    
    // Music player
    var bgMusic: AVAudioPlayer?
    
    // Upgrade UI and relevant values
    var upgradeUIElements: [String: (squares: [SKSpriteNode?], _plus: SKLabelNode?, _button: MSButtonNode?, upgradeStatus: Int, oldUpgradeStatus: Int)] = ["health": ([nil, nil, nil], nil, nil, 1, 1), "speed": ([nil, nil, nil], nil, nil, 1, 1), "fire_rate": ([nil, nil, nil], nil, nil, 1, 1), "bullet_speed": ([nil, nil, nil], nil, nil, 1, 1)]
    // Total of the upgrade statuses
    var total = 0
    var oldTotal = 0
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
    let maxMaxHealth = 6
    let minMaxHealth = 3
    let originalMaxHeroSpeed: CGFloat = 200
    let originalMinHeroSpeed: CGFloat = 85
    let originalMaxBulletSpeed: CGFloat = 350
    let originalMinBulletSpeed: CGFloat = 160
    // Frames until next shot ~(seconds * 60)
    let maxShotFrequency: Int = 30
    let minShotFrequency: Int = 1 * 60
    // Average frames until next bird spawn ~(seconds * 60)
    let minSpawnFrequency = 3 * 60
    let maxSpawnFrequency = 1 * 60
    let originalMinSpawnHeight = 50
    let maxSpawnHeight = 160
    // Frames until post-upgrade invincibility runs out ~(seconds * 60)
    let invincibilityTime = 3 * 60
    let originalBirdSpeed: CGFloat = 100
    let originalPooSpeed: CGFloat = 150
    // Average frames until next poop ~(seconds * 60)
    let pooFrequency: Int = 2 * 60
    // Frames until hazards disappear ~(seconds * 60)
    let hazardTime: Int = Int(1 * 60.0)
    // Frames until next powerup ~(seconds * 60)
    let nextPowerupTime: Int = 25 * 60
    // Frames until powerup runs out ~(seconds * 60)
    let powerupTime: Int = 15 * 60
    // Frames until powerup disappears on ground ~(seconds * 60)
    let powerupIdleTime: Int = 5 * 60
    let originalPowerupSpeed: CGFloat = 75
    let spreadShotSpread: CGFloat = CGFloat(Double.pi/12)
    // Minimum size of objects on screen after zoom-out
    let minScale = 0.6
    // Max angle of hero's legs
    let legAngle = CGFloat.pi * (CGFloat(45)/CGFloat(180))
    // Max angular delta of hero's legs (angle of change per frame)
    let maxLegSpeed = CGFloat.pi * (CGFloat(5)/CGFloat(180))
    // Frames until next rapid poo ~(seconds * 60)
    let rapidPooTime = Int(0.5 * 60.0)
    
    // powerups (texture, status, spawn ratio, color)
    var powerupStatuses: [String: (UIImage?, Bool, Int, UIColor?)] = ["health": (nil, false, 2, nil), "shield": (nil, false, 1, nil), "spreadShot": (nil, false, 1, nil)]
    var currentPowerup: (SKSpriteNode, Bool, Int)!
    var powerupTimer = 0
    var powerupWillAppear = false
    var poweredup = false
    
    // Colors
    let upgradedColor: UIColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
    let smartPooColor: UIColor = UIColor(red: 1.0, green: 1.0, blue: 0.75, alpha: 1.0)
    let toxicPooColor: UIColor = UIColor(red: 0.72, green: 1.0, blue: 0.46, alpha: 1.0)
    let bigPooColor: UIColor = UIColor(red: 1.0, green: 1.0, blue: 0.99, alpha: 1.0)
    let healthPowerupColor: UIColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    let shieldPowerupColor: UIColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
    let spreadShotPowerupColor: UIColor = UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
    
    // All bird variables assigned to each type:
    // spawnRatio = relative spawn ratio (100 = same rate as normal bird)
    // spawnTime = actual frames until next bird spawn (set later)
    // spawnTimer = framecount for bird spawning
    // levelsTo = how many times the player must upgrade for the bird to start spawning
    // isSpawning = if the bird type is spawning or not
    var birdVariables: [BirdType: (spawnRatio: Int, spawnTime: Int, spawnTimer: Int, levelsTo: Int, isSpawning: Bool)] = [.normal: (100, 0, 0, 0, true), .smart: (30, 0, 0, 2, false), .toxic: (30, 0, 0, 4, false), .big: (15, 0, 0, 6, false), .rapid: (10, 0, 0, 8, false), .rare: (1, 0, 0, 10, false)]
    
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
    //var upgradeScores: [Int] = [10, 20, 50, 80, 130, 180, 360, 440, 640, 840, 1040, 1240]
    //var upgradeScores: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10]
    //var upgradeScores: [Int] = [1, 2, 3, 4, 5, 6, 20, 30, 40, 50, 60, 70]
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
    var birdShot = false
    
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
        powerupStatuses["health"]?.0 = #imageLiteral(resourceName: "Health_Powerup_2")
        powerupStatuses["health"]?.3 = healthPowerupColor
        powerupStatuses["shield"]?.0 = #imageLiteral(resourceName: "Shield_Powerup_2")
        powerupStatuses["shield"]?.3 = shieldPowerupColor
        powerupStatuses["spreadShot"]?.0 = #imageLiteral(resourceName: "Spread_Powerup_2")
        powerupStatuses["spreadShot"]?.3 = spreadShotPowerupColor
        
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
        shield = hero.childNode(withName: "shield") as! SKSpriteNode
        shield.position = offScreen
        shield_2 = shield.childNode(withName: "shield_2") as! SKSpriteNode
        ground = childNode(withName: "ground") as! SKSpriteNode
        unpauseButton = childNode(withName: "unpauseButton") as! MSButtonNode
        unpauseButton.position = unpauseButtonPosition
        unpauseButton.isHidden = true
        unpauseButton.state = .MSButtonNodeStateHidden
        menuButton = childNode(withName: "menuButton") as! MSButtonNode
        menuButton.position = menuButtonPosition
        menuButton.isHidden = true
        menuButton.state = .MSButtonNodeStateHidden
        soundButton = childNode(withName: "soundButton") as! MSButtonNode
        soundButton.position = soundButtonPosition
        soundButton.isHidden = true
        soundButton.state = .MSButtonNodeStateHidden
        musicButton = childNode(withName: "musicButton") as! MSButtonNode
        musicButton.position = musicButtonPosition
        musicButton.isHidden = true
        musicButton.state = .MSButtonNodeStateHidden
        musicX = musicButton.childNode(withName: "musicX") as! SKSpriteNode
        if !musicPlaying {
            musicX.position = onScreen
        } else {
            musicX.position = offScreen
        }
        if soundOn {
            soundButton.texture = SKTexture(imageNamed: "Sound_On")
        } else {
            soundButton.texture = SKTexture(imageNamed: "Sound_Off")
        }
        powerupBar = childNode(withName: "//powerupBar") as! SKSpriteNode
        powerupBarContainer = childNode(withName: "powerupBarContainer") as! SKSpriteNode
        zoomPoint = childNode(withName: "zoomPoint")
        background = childNode(withName: "background") as! SKSpriteNode
        scoreTextBase = childNode(withName: "scoreTextBase") as! SKLabelNode
        healthTextBase = childNode(withName: "healthTextBase") as! SKLabelNode
        featherBase = childNode(withName: "featherBase") as! SKSpriteNode
        
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
            self.soundButton.isHidden = false
            self.soundButton.state = .MSButtonNodeStateActive
            self.musicButton.isHidden = false
            self.musicButton.state = .MSButtonNodeStateActive
            if self.bgMusic != nil && musicPlaying {
                self.bgMusic!.pause()
            }
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
            self.soundButton.isHidden = true
            self.soundButton.state = .MSButtonNodeStateHidden
            self.musicButton.isHidden = true
            self.musicButton.state = .MSButtonNodeStateHidden
            if self.bgMusic != nil && musicPlaying {
                self.bgMusic!.play()
                self.bgMusic?.numberOfLoops = -1
            }
            else if self.bgMusic == nil && musicPlaying {
                self.startBackgroundMusic()
            }
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
        musicButton.selectedHandler = {[unowned self] in
            musicPlaying = !musicPlaying
            UserDefaults.standard.set(!musicPlaying, forKey: "MUSIC")
            if !musicPlaying {
                self.musicX.position = self.onScreen
                self.bgMusic?.pause()
            } else {
                self.musicX.position = self.offScreen
            }
        }
        soundButton.selectedHandler = {[unowned self] in
            soundOn = !soundOn
            UserDefaults.standard.set(!soundOn, forKey: "SOUND")
            if soundOn {
                self.soundButton.texture = SKTexture(imageNamed: "Sound_On")
            } else {
                self.soundButton.texture = SKTexture(imageNamed: "Sound_Off")
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
                } else {
                    score = 0
                    for (type, _) in upgradeUIElements {
                        UserDefaults.standard.set(1, forKey: type)
                    }
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
        if score == 0 {
            health = maxHealth
        } else {
            birdShot = true
        }
        
        calculateTotals()
        var tempTotal = total
        while tempTotal - upgradeTypes >= 1 {
            scaleChanged = true
            scaleManager()
            tempTotal -= 1
        }
        
        if autoFire {
            gun.zRotation = CGFloat.pi
        }
        if leftFixed {
            leftInitialPosition = fixedLeftJoystickLocation
            leftJoystickPosition = leftInitialPosition
            leftJoystick.position = leftJoystickPosition
            leftThumb.position = leftJoystickPosition
            leftJoystick.isHidden = false
            leftThumb.isHidden = false
        }
        if rightFixed {
            rightInitialPosition = fixedRightJoystickLocation
            rightJoystickPosition = rightInitialPosition
            rightJoystick.position = rightJoystickPosition
            rightThumb.position = rightJoystickPosition
            rightJoystick.isHidden = false
            rightThumb.isHidden = false
        }
        
        if musicPlaying {
            startBackgroundMusic()
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
                if touch.location(in: self).x <= 0 {
                    if leftTouch == nil {
                        leftTouch = touch
                        if !leftFixed {
                            leftInitialPosition = touch.location(in: self)
                            leftJoystickPosition = leftInitialPosition
                            leftJoystick.position = leftJoystickPosition
                            leftThumb.position = leftJoystickPosition
                        } else {
                            leftInitialPosition = fixedLeftJoystickLocation
                            leftJoystickPosition = leftInitialPosition
                            leftJoystick.position = leftJoystickPosition
                            leftThumb.position = leftJoystickPosition
                            hero.physicsBody?.velocity.dx = (touch.location(in: self).x - leftInitialPosition.x) * (heroSpeed/50)
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
                            rightInitialPosition = touch.location(in: self)
                            rightJoystickPosition = rightInitialPosition
                            rightJoystick.position = rightJoystickPosition
                            rightThumb.position = rightJoystickPosition
                            gun.zRotation = CGFloat.pi
                        } else {
                            rightInitialPosition = fixedRightJoystickLocation
                            rightJoystickPosition = rightInitialPosition
                            rightJoystick.position = rightJoystickPosition
                            rightThumb.position = rightJoystickPosition
                            gun.zRotation = (rightInitialPosition.x - touch.location(in: self).x) * CGFloat(Double.pi/4/50) + CGFloat.pi
                            gun.zRotation = clamp(value: gun.zRotation, lower: -CGFloat(Double.pi/4) + CGFloat.pi, upper: CGFloat(Double.pi/4) + CGFloat.pi)
                            rightThumb.position.x = clamp(value: touch.location(in: self).x, lower: rightJoystickPosition.x - 50, upper: rightJoystickPosition.x + 50)
                        }
                        shooting = true
                        rightJoystick.isHidden = false
                        rightThumb.isHidden = false
                        if hero.xScale < 0 {
                            gun.zRotation = -gun.zRotation
                        }
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
                    hero.physicsBody?.velocity.dx = (touch.location(in: self).x - leftInitialPosition.x) * (heroSpeed/50)
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
                    gun.zRotation = (rightInitialPosition.x - touch.location(in: self).x) * CGFloat(Double.pi/4/50) + CGFloat.pi
                    gun.zRotation = clamp(value: gun.zRotation, lower: -CGFloat(Double.pi/4) + CGFloat.pi, upper: CGFloat(Double.pi/4) + CGFloat.pi)
                    rightThumb.position.x = clamp(value: touch.location(in: self).x, lower: rightJoystickPosition.x - 50, upper: rightJoystickPosition.x + 50)
                    if hero.xScale < 0 {
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
                    leftThumb.position = leftJoystick.position
                    if !leftFixed {
                        leftJoystick.isHidden = true
                        leftThumb.isHidden = true
                    }
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
                    rightThumb.position = rightJoystick.position
                    if !rightFixed {
                        rightJoystick.isHidden = true
                        rightThumb.isHidden = true
                    }
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
            hero.xScale = -1 * abs(hero.xScale)
            if right {
                gun.zRotation = -gun.zRotation
            }
            right = false
        }
        if (hero.physicsBody?.velocity.dx)! > CGFloat(0) {
            hero.xScale = abs(hero.xScale)
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
                    let scoreText = scoreTextBase.copy() as! SKLabelNode
                    scoreText.position = birdA.position
                    scoreText.text = "+\(birdA.pointValue)"
                    addChild(scoreText)
                    let fade = SKAction(named: "textFade")!
                    let remove = SKAction.removeFromParent()
                    let sequence = SKAction.sequence([fade, remove])
                    scoreText.run(sequence)
                    explodeInFeathers(birdA)
                }
                nodeB.removeFromParent()
                nodeB.isHidden = true
            } else if let birdB = contactB.node as? Bird {
                birdB.health -= 1
                if birdB.health == 0 {
                    score += birdB.pointValue
                    let scoreText = scoreTextBase.copy() as! SKLabelNode
                    scoreText.position = birdB.position
                    scoreText.text = "+\(birdB.pointValue)"
                    addChild(scoreText)
                    let fade = SKAction(named: "textFade")!
                    let remove = SKAction.removeFromParent()
                    let sequence = SKAction.sequence([fade, remove])
                    scoreText.run(sequence)
                    explodeInFeathers(birdB)
                }
                nodeA.removeFromParent()
                nodeA.isHidden = true
            }
        }
        
        // Check if one was a bullet and one was a poop, then removes both, unless it's a big poop
        if (contactA.categoryBitMask == 4 && contactB.categoryBitMask == 8) {
            nodeA.removeFromParent()
            nodeA.isHidden = true
            if String(describing: nodeB.color) != String(describing: bigPooColor) {
                nodeB.removeFromParent()
                nodeB.isHidden = true
            }
        }
        if (contactA.categoryBitMask == 8 && contactB.categoryBitMask == 4) {
            nodeB.removeFromParent()
            nodeB.isHidden = true
            if String(describing: nodeA.color) != String(describing: bigPooColor) {
                nodeA.removeFromParent()
                nodeA.isHidden = true
            }
        }
        
        // Check if one was the hero and the other was poop, then removes poop and decrements health, if necessary
        if (contactA.categoryBitMask == 1 && contactB.categoryBitMask == 8) {
            if invincibilityTimer <= 0 && !(powerupStatuses["shield"]?.1)! {
                health -= 1
                playSound("ugh")
                if String(describing: nodeB.color) == String(describing: bigPooColor) && health != 0{
                    health -= 1
                    let healthText = healthTextBase.copy() as! SKLabelNode
                    healthText.position = hero.position
                    healthText.position.y = healthText.position.y - 39.5 + (hero.size.height / 2)
                    healthText.text = "-2"
                    addChild(healthText)
                    let fade = SKAction(named: "textFade")!
                    let remove = SKAction.removeFromParent()
                    let sequence = SKAction.sequence([fade, remove])
                    healthText.run(sequence)
                } else {
                    let healthText = healthTextBase.copy() as! SKLabelNode
                    healthText.position = hero.position
                    healthText.position.y = healthText.position.y - 39.5 + (hero.size.height / 2)
                    healthText.text = "-1"
                    addChild(healthText)
                    let fade = SKAction(named: "textFade")!
                    let remove = SKAction.removeFromParent()
                    let sequence = SKAction.sequence([fade, remove])
                    healthText.run(sequence)
                }
                invincibilityTimer = invincibilityTime
            }
            nodeB.removeFromParent()
            nodeB.isHidden = true
            playSound("splat")
        }
        if (contactB.categoryBitMask == 1 && contactA.categoryBitMask == 8) {
            if invincibilityTimer <= 0 && !(powerupStatuses["shield"]?.1)! {
                health -= 1
                playSound("ugh")
                if String(describing: nodeA.color) == String(describing: bigPooColor) && health != 0 {
                    health -= 1
                    let healthText = healthTextBase.copy() as! SKLabelNode
                    healthText.position = hero.position
                    healthText.text = "-2"
                    addChild(healthText)
                    let fade = SKAction(named: "textFade")!
                    let remove = SKAction.removeFromParent()
                    let sequence = SKAction.sequence([fade, remove])
                    healthText.run(sequence)
                } else {
                    let healthText = healthTextBase.copy() as! SKLabelNode
                    healthText.position = hero.position
                    healthText.text = "-1"
                    addChild(healthText)
                    let fade = SKAction(named: "textFade")!
                    let remove = SKAction.removeFromParent()
                    let sequence = SKAction.sequence([fade, remove])
                    healthText.run(sequence)
                }
                invincibilityTimer = invincibilityTime
            }
            nodeA.removeFromParent()
            nodeA.isHidden = true
            playSound("splat")
        }
        
        // Check if one was the ground, then acts accordingly based on the type of poop
        if (contactA.categoryBitMask == 16) {
            if String(describing: nodeB.color) == String(describing: toxicPooColor){
                createHazard(nodeB)
                playSound("splat")
            }
            if contactB.categoryBitMask == 8 {
                nodeB.removeFromParent()
                nodeB.isHidden = true
            }
        }
        if (contactB.categoryBitMask == 16) {
            if String(describing: nodeB.color) == String(describing: toxicPooColor) {
                createHazard(nodeA)
                playSound("splat")
            }
            if contactA.categoryBitMask == 8 {
                nodeA.removeFromParent()
                nodeA.isHidden = true
            }
        }
        
        // Check if one was a hazard, then removes hazard and decrements health
        if (contactA.categoryBitMask == 32) {
            if invincibilityTimer <= 0 && !(powerupStatuses["shield"]?.1)! {
                playSound("ugh")
                health -= 1
                let healthText = healthTextBase.copy() as! SKLabelNode
                healthText.position = hero.position
                healthText.position.y = healthText.position.y - 39.5 + (hero.size.height / 2)
                healthText.text = "-1"
                addChild(healthText)
                let fade = SKAction(named: "textFade")!
                let remove = SKAction.removeFromParent()
                let sequence = SKAction.sequence([fade, remove])
                healthText.run(sequence)
            }
            invincibilityTimer = invincibilityTime
            nodeA.removeFromParent()
            nodeA.isHidden = true
            playSound("splat")
        }
        if (contactB.categoryBitMask == 32) {
            if invincibilityTimer <= 0 && !(powerupStatuses["shield"]?.1)! {
                health -= 1
                playSound("ugh")
                let healthText = healthTextBase.copy() as! SKLabelNode
                healthText.position = hero.position
                healthText.position.y = healthText.position.y - 39.5 + (hero.size.height / 2)
                healthText.text = "-1"
                addChild(healthText)
                let fade = SKAction(named: "textFade")!
                let remove = SKAction.removeFromParent()
                let sequence = SKAction.sequence([fade, remove])
                healthText.run(sequence)
            }
            invincibilityTimer = invincibilityTime
            nodeB.removeFromParent()
            nodeB.isHidden = true
            playSound("splat")
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
                if String(describing: nodeA.color) == String(describing: attributes.3!) {
                    powerupStatuses[powerup]?.1 = true
                }
            }
            nodeA.removeFromParent()
            nodeA.isHidden = true
        }
        if (contactB.categoryBitMask == 64 && contactA.categoryBitMask == 1) {
            for (powerup, attributes) in powerupStatuses {
                if String(describing: nodeB.color) == String(describing: attributes.3!) {
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
                playSound("birdDeath")
                if musicPlaying && !birdShot {
                    birdShot = true
                    startBackgroundMusic()
                }
                birdShot = true
                if i > 0 {
                    i -= 1
                }
            } else if birds[i].isHidden {
                birds[i].removeFromParent()
                birds.remove(at: i)
                if i > 0 {
                    i -= 1
                }
                
            // Checks if birds are due to poo. Poos if true
            } else if birds[i].pooTimer <= 0 {
                if !birds[i].started {
                    birds[i].started = true
                } else {
                    poo(birds[i])
                }
                birds[i].pooTimer = Int(arc4random_uniform(UInt32(pooFrequency))) + (pooFrequency/2)
                if birds[i].type == .rapid {
                    birds[i].pooTimer = rapidPooTime
                }
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
                let maxShotsPerSecond = 60.0/Double(maxShotFrequency)
                let minShotsPerSecond = 60.0/Double(minShotFrequency)
                let deltaSPS = (maxShotsPerSecond - minShotsPerSecond) / Double(upgrades)
                let specificDSPS = deltaSPS * Double(elements.upgradeStatus - 1)
                let shotsPerSecond = specificDSPS + minShotsPerSecond
                shotFrequency = Int(60.0 / shotsPerSecond)
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
                    let fadeOut = SKAction(named: "fadeOut")!
                    let removeFromScene = SKAction.removeFromParent()
                    let sequence = SKAction.sequence([fadeOut,removeFromScene])
                    hazards[i].0.run(sequence)
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
            newBird.xScale = -1 * newBird.xScale
        } else {
            newBird.direction = .left
        }
        
        // Determines and sets its inital position
        var rand = arc4random_uniform(UInt32(CGFloat(maxSpawnHeight - minSpawnHeight) - newBird.size.height))
        rand += UInt32(newBird.size.height / 2) + UInt32(minSpawnHeight)
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
                if hero.xScale < 0 {
                    rotation = CGFloat.pi - gun.zRotation
                }
                let newBullet = bulletBase.copy() as! SKSpriteNode
                newBullet.physicsBody?.linearDamping = 0
                newBullet.position = hero.position
                newBullet.position.x -= gun.size.height * sin(rotation)
                newBullet.position.y = gun.size.height * cos(rotation) + (ground.position.y + ground.size.height / 2.0) + (hero.size.height/2) + gun.position.y
                newBullet.physicsBody?.velocity.dx = -bulletSpeed * sin(rotation)
                newBullet.physicsBody?.velocity.dy = bulletSpeed * cos(rotation)
                newBullet.zRotation = rotation
                bullets.append(newBullet)
                self.addChild(newBullet)
                newBullet.zPosition = 2
                playSound("shot")
            } else {
                delay = true
                shotTimer = shotFrequency / 2
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
                if hero.xScale < 0 {
                    rotation = CGFloat.pi - gun.zRotation
                }
                newBullet.position.x -= gun.size.height * sin(rotation)
                newBullet.position.y = gun.size.height * cos(rotation) + (ground.position.y + ground.size.height / 2.0) + (hero.size.height/2) + gun.position.y
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
                newBullet.zPosition = 2
                playSound("shot")
            }
        }
    }
    
    // Poops
    func poo(_ bird: Bird) {
        var isPooping = true
        let newPoo = pooBase.copy() as! SKSpriteNode
        newPoo.physicsBody?.linearDamping = 0
        newPoo.position = bird.position
        newPoo.position.y = bird.position.y
        switch bird.type! {
        case .smart:
            newPoo.color = smartPooColor
            var xDist = hero.position.x - newPoo.position.x
            let yDist = hero.position.y - newPoo.position.y - 100
            if xDist > ((7 * abs(yDist)) / 9) {
                xDist = ((7 * abs(yDist)) / 9)
            }
            if xDist < ((7 * yDist) / 9) {
                xDist = ((7 * yDist) / 9)
            }
            let tDist = sqrt(xDist*xDist + yDist*yDist)
            newPoo.physicsBody?.velocity.dy = pooSpeed * (yDist/tDist)
            newPoo.physicsBody?.velocity.dx = pooSpeed * (xDist/tDist)
            newPoo.zRotation = -atan(xDist/yDist) * 0.75
        case .big:
            newPoo.color = bigPooColor
            newPoo.xScale = 2 * newPoo.xScale
            newPoo.yScale = 2 * newPoo.yScale
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
        
        // Resets saved values
        for (type, _) in upgradeUIElements {
            UserDefaults.standard.set(1, forKey: type)
        }
        
        UserDefaults.standard.set(0, forKey: "SAVEDSCORE")
        UserDefaults.standard.set(minMaxHealth, forKey: "SAVEDHEALTH")
        
        newGame = true
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
            let maxBirdsPerSecond = 60.0/Double(maxSpawnFrequency)
            let minBirdsPerSecond = 60.0/Double(minSpawnFrequency)
            let deltaBPS = (maxBirdsPerSecond - minBirdsPerSecond) / Double(upgrades * upgradeTypes)
            let specificDBPS = deltaBPS * Double((total + 1) - upgradeTypes)
            let birdsPerSecond = specificDBPS + minBirdsPerSecond
            spawnFrequency = Int(60.0 / birdsPerSecond)
            
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
                        let healthText = scoreTextBase.copy() as! SKLabelNode
                        healthText.position = hero.position
                        healthText.position.y = healthText.position.y - 39.5 + (hero.size.height / 2)
                        healthText.text = "+1"
                        addChild(healthText)
                        let fade = SKAction(named: "textFade")!
                        let remove = SKAction.removeFromParent()
                        let sequence = SKAction.sequence([fade, remove])
                        healthText.run(sequence)
                    }
                case "shield":
                    shield.position = onScreen
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
                powerupBarContainer.position.y = (ground.position.y + ground.size.height / 2.0) - powerupBarContainer.size.height * 1.5
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
                if currentPowerup.2 < Int(Double(powerupIdleTime) * 0.4) {
                    if currentPowerup.2 % 30 > 15 {
                        currentPowerup.0.alpha = 0
                    } else {
                        currentPowerup.0.alpha = 1
                    }
                }
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
        newPowerup.zPosition = 2
        newPowerup.physicsBody?.linearDamping = 0
        var rtotal = 0
        for (_, attributes) in powerupStatuses {
            rtotal += attributes.2
        }
        var rand = Int(arc4random_uniform(UInt32(rtotal))) + 1
        for (_, attributes) in powerupStatuses {
            rand -= attributes.2
            if rand <= 0 {
                newPowerup.color = attributes.3!
                newPowerup.texture = SKTexture(image: attributes.0!)
                newPowerup.size = powerupBase.size
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
    
    // Scales the given object to the given scale and resets physicsBody
    func scale(_ node: SKSpriteNode, by thisMuch: CGFloat) {
        var body = false
        var dynamic = false
        var allowsRotation = false
        var pinned = false
        var affectedByGravity = false
        var friction: CGFloat = 0.0
        var restitution: CGFloat = 0.0
        var linearDamping: CGFloat = 0.0
        var angularDamping: CGFloat = 0.0
        var mass: CGFloat =
        0.0
        var categoryMask: UInt32 = 0
        var collisionMask: UInt32 = 0
        var fieldMask: UInt32 = 0
        var contactMask: UInt32 = 0
        var velocitydx: CGFloat = 0
        var velocitydy: CGFloat = 0
        
        if node.physicsBody != nil {
            body = true
            dynamic = (node.physicsBody?.isDynamic)!
            allowsRotation = (node.physicsBody?.allowsRotation)!
            pinned = (node.physicsBody?.pinned)!
            affectedByGravity = (node.physicsBody?.affectedByGravity)!
            friction = (node.physicsBody?.friction)!
            restitution = (node.physicsBody?.restitution)!
            linearDamping = (node.physicsBody?.linearDamping)!
            angularDamping = (node.physicsBody?.angularDamping)!
            mass = (node.physicsBody?.mass)!
            categoryMask = (node.physicsBody?.categoryBitMask)!
            collisionMask = (node.physicsBody?.collisionBitMask)!
            fieldMask = (node.physicsBody?.collisionBitMask)!
            contactMask = (node.physicsBody?.contactTestBitMask)!
            velocitydx = (node.physicsBody?.velocity.dx)!
            velocitydy = (node.physicsBody?.velocity.dy)!
        }
        node.setScale(thisMuch)
        if body {
            node.physicsBody? = SKPhysicsBody(rectangleOf: node.size)
            node.physicsBody?.isDynamic = dynamic
            node.physicsBody?.allowsRotation = allowsRotation
            node.physicsBody?.pinned = pinned
            node.physicsBody?.affectedByGravity = affectedByGravity
            node.physicsBody?.friction = friction
            node.physicsBody?.restitution = restitution
            node.physicsBody?.linearDamping = linearDamping
            node.physicsBody?.angularDamping = angularDamping
            node.physicsBody?.mass = mass
            node.physicsBody?.categoryBitMask = categoryMask
            node.physicsBody?.collisionBitMask = collisionMask
            node.physicsBody?.fieldBitMask = fieldMask
            node.physicsBody?.contactTestBitMask = contactMask
            node.physicsBody?.velocity.dx = velocitydx
            node.physicsBody?.velocity.dy = velocitydy
        }
    }
    
    // Scales the scaling elements on the screen down to simulate zooming out
    func scaleManager() {
        calculateTotals()
        let stepScale = CGFloat(pow(Double(minScale), (1.0/Double(upgrades * upgradeTypes))))
        let fullScale = CGFloat(pow(Double(stepScale), Double(total - upgradeTypes)))
        minSpawnHeight = Int((CGFloat(originalMinSpawnHeight) - zoomPoint.position.y) * stepScale + zoomPoint.position.y)
        maxHeroSpeed = originalMaxHeroSpeed * fullScale
        minHeroSpeed = originalMinHeroSpeed * fullScale
        maxBulletSpeed = originalMaxBulletSpeed * fullScale
        minBulletSpeed = originalMinBulletSpeed * fullScale
        birdSpeed = originalBirdSpeed * fullScale
        pooSpeed = originalPooSpeed * fullScale
        powerupSpeed = originalPowerupSpeed * fullScale
        if scaleChanged {
            scale(birdBase, by: fullScale)
            scale(pooBase, by: fullScale)
            scale(bulletBase, by: fullScale)
            scale(toxicHazardBase, by: fullScale)
            scale(hero, by: fullScale)
            hero.position.x = hero.position.x * stepScale
            hero.position.y = 39.5 + (ground.position.y + ground.size.height / 2.0) + hero.size.height/2.0
            scale(powerupBase, by: fullScale)
            scale(shield, by: fullScale)
            scale(background, by: fullScale)
            scale(ground, by: fullScale)
            scale(featherBase, by: fullScale)
            ground.position.y = zoomPoint.position.y - (ground.size.height / 2.0)
            if currentPowerup != nil {
                scale(currentPowerup.0, by: fullScale)
                currentPowerup.0.position.x = currentPowerup.0.position.x * stepScale
                currentPowerup.0.position.y = ((currentPowerup.0.position.y - zoomPoint.position.y) * stepScale) + zoomPoint.position.y
                currentPowerup.0.physicsBody?.velocity.dy = (currentPowerup.0.physicsBody?.velocity.dy)! * stepScale
            }
            for bird in birds {
                scale(bird, by: fullScale)
                if bird.direction == .right {
                    bird.xScale = -1 * bird.xScale
                }
                if bird.type == .big {
                    bird.xScale = 2 * bird.xScale
                    bird.yScale = 2 * bird.yScale
                }
                bird.position.x = bird.position.x * stepScale
                bird.position.y = ((bird.position.y - zoomPoint.position.y) * stepScale) + zoomPoint.position.y
                bird.physicsBody?.velocity.dx = (bird.physicsBody?.velocity.dx)! * stepScale
            }
            for bullet in bullets {
                scale(bullet, by: fullScale)
                bullet.position.x = bullet.position.x * stepScale
                bullet.position.y = ((bullet.position.y - zoomPoint.position.y) * stepScale) + zoomPoint.position.y
                bullet.physicsBody?.velocity.dy = (bullet.physicsBody?.velocity.dy)! * stepScale
                bullet.physicsBody?.velocity.dx = (bullet.physicsBody?.velocity.dx)! * stepScale
            }
            for hazard in hazards {
                scale(hazard.0, by: fullScale)
                hazard.0.position.x = hazard.0.position.x * stepScale
                hazard.0.position.y = ((hazard.0.position.y - zoomPoint.position.y) * stepScale) + zoomPoint.position.y
            }
            for poo in poops {
                let big = String(describing: poo.color) == String(describing: bigPooColor)
                scale(poo, by: fullScale)
                if big {
                    poo.xScale = 2 * poo.xScale
                    poo.yScale = 2 * poo.yScale
                }
                poo.position.x = poo.position.x * stepScale
                poo.position.y = ((poo.position.y - zoomPoint.position.y) * stepScale) + zoomPoint.position.y
                poo.physicsBody?.velocity.dy = (poo.physicsBody?.velocity.dy)! * stepScale
            }
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
    
    // Spawns feathers at the birds location
    func explodeInFeathers(_ bird: Bird) {
        let location = bird.position
        for _ in 0 ... 20 {
            var rand = CGFloat(Int(arc4random_uniform(50)) - 25)
            var rand2 = CGFloat(Int(arc4random_uniform(50)) - 25)
            if bird.type == .big {
                rand = rand * 2
                rand2 = rand2 * 2
            }
            let rand3 = CGFloat(Int(arc4random_uniform(20)) - 10)
            let move = SKAction.moveBy(x: rand, y: rand2, duration: 0.5)
            let fade = SKAction.fadeOut(withDuration: 0.5)
            let rotate = SKAction.rotate(byAngle: rand3, duration: 0.5)
            let remove = SKAction.removeFromParent()
            let group = SKAction.group([move, rotate, fade])
            let sequence = SKAction.sequence([group, remove])
            let feather = featherBase.copy() as! SKSpriteNode
            addChild(feather)
            feather.position = location
            feather.color = bird.color
            if bird.type == .big {
                feather.xScale = feather.xScale * 2
                feather.yScale = feather.yScale * 2
            }
            feather.run(sequence)
        }
    }
    
    // Starts the background music
    func startBackgroundMusic() {
        if birdShot {
            if let bgMusic = self.setupAudioPlayerWithFile("megasong_edit_8", type:"mp3") {
                self.bgMusic = bgMusic
            }
        } else {
            if let bgMusic = self.setupAudioPlayerWithFile("Birds_2", type:"wav") {
                self.bgMusic = bgMusic
            }
        }
        self.bgMusic!.play()
        self.bgMusic?.numberOfLoops = -1
    }
    
    // Calls for audio player
    func setupAudioPlayerWithFile(_ file:NSString, type:NSString) -> AVAudioPlayer?  {
        
        let soundFilePath = Bundle.main.path(forResource: file as String, ofType: type as String)
        let soundFileURL = URL(fileURLWithPath: soundFilePath!)
        
        var audioPlayer: AVAudioPlayer?
        
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: soundFileURL)
        } catch {
            print("Player not available")
        }
        return audioPlayer
    }
    
    // Plays sound
    func playSound(_ sound: String) {
        if soundOn {
            switch sound {
            case "shot":
                run(SKAction.playSoundFileNamed("Gunshot_2.wav", waitForCompletion: false))
            case "birdDeath":
                run(SKAction.playSoundFileNamed("Bird_Death_2.wav", waitForCompletion: false))
            case "splat":
                run(SKAction.playSoundFileNamed("Splat_1.wav", waitForCompletion: false))
            case "ugh":
                run(SKAction.playSoundFileNamed("Ugh_1.wav", waitForCompletion: false))
            default:
                break
            }
        }
    }
}
