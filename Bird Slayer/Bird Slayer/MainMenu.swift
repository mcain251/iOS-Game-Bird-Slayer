//
//  MainMenu.swift
//  Bird Slayer
//
//  Created by Marshall Cain on 7/7/17.
//  Copyright © 2017 Marshall Cain. All rights reserved.
//

import SpriteKit
import AVFoundation

var autoFire: Bool! = false

var leftFixed: Bool! = false
var rightFixed: Bool! = false

var fixedLeftJoystickLocation: CGPoint = CGPoint(x: -142, y: -145)
var fixedRightJoystickLocation: CGPoint = CGPoint(x: 142, y: -145)

var newGame = false

var musicPlaying = true
var soundOn = true

class MainMenu: SKScene {
    
    let offScreen: CGPoint = CGPoint(x: -1000, y: -1000)
    let onScreen: CGPoint = CGPoint(x: 0, y: 0)
    
    var bgMusic: AVAudioPlayer?
    
    // UI
    var slayButton: MSButtonNode!
    var optionButton: MSButtonNode!
    var newGameButton: MSButtonNode!
    var continueBox: SKSpriteNode!
    var continueBackButton: MSButtonNode!
    var creditsButton: MSButtonNode!
    var creditsBox: SKSpriteNode!
    var creditsBackButton: MSButtonNode!
    var continueButton: MSButtonNode!
    var soundButton: MSButtonNode!
    var musicButton: MSButtonNode!
    var musicX: SKSpriteNode!
    var controlsButton: MSButtonNode!
    var eraseButton: MSButtonNode!
    var yesButton: MSButtonNode!
    var noButton: MSButtonNode!
    var sureBox: SKSpriteNode!
    var backButton: MSButtonNode!
    var controlsBackButton: MSButtonNode!
    var rightButton: MSButtonNode!
    var leftButton: MSButtonNode!
    var rightTick: SKSpriteNode!
    var leftTick: SKSpriteNode!
    var defaultScreen: SKNode!
    var controlsScreen: SKNode!
    var customizationScreen: SKNode!
    var customizationButton: MSButtonNode!
    var resetLocationsButton: MSButtonNode!
    var customizationBackButton: MSButtonNode!
    var leftJoystick: SKSpriteNode!
    var rightJoystick: SKSpriteNode!
    var leftTouch: UITouch!
    var rightTouch: UITouch!
    var autoFireButton: MSButtonNode!
    var autoFireTick: SKSpriteNode!
    var mainScreen: SKNode!
    
    // Setup scene
    override func didMove(to view: SKView) {
        
        // Loads saved data
        if let auto = UserDefaults().bool(forKey: "AUTOFIRE") as Bool? {
            autoFire = auto
        }
        if let leftFix = UserDefaults().bool(forKey: "LEFTFIXED") as Bool? {
            leftFixed = leftFix
        }
        if let rightFix = UserDefaults().bool(forKey: "RIGHTFIXED") as Bool? {
            rightFixed = rightFix
        }
        if let leftX = UserDefaults().integer(forKey: "LEFTX") as Int? {
            if leftX != 0 {
                fixedLeftJoystickLocation.x = CGFloat(leftX)
            }
        }
        if let leftY = UserDefaults().integer(forKey: "LEFTY") as Int? {
            if leftY != 0 {
                fixedLeftJoystickLocation.y = CGFloat(leftY)
            }
        }
        if let rightX = UserDefaults().integer(forKey: "RIGHTX") as Int? {
            if rightX != 0 {
                fixedRightJoystickLocation.x = CGFloat(rightX)
            }
        }
        if let rightY = UserDefaults().integer(forKey: "RIGHTY") as Int? {
            if rightY != 0 {
                fixedRightJoystickLocation.y = CGFloat(rightY)
            }
        }
        if let music = UserDefaults().bool(forKey: "MUSIC") as Bool? {
            musicPlaying = !music
        }
        if let sound = UserDefaults().bool(forKey: "SOUND") as Bool? {
            soundOn = !sound
        }
        
        // Set reference to objects
        slayButton = childNode(withName: "//slayButton") as! MSButtonNode
        optionButton = childNode(withName: "//optionButton") as! MSButtonNode
        continueBox = childNode(withName: "//continueBox") as! SKSpriteNode
        newGameButton = continueBox.childNode(withName: "newGameButton") as! MSButtonNode
        continueBackButton = continueBox.childNode(withName: "continueBackButton") as! MSButtonNode
        continueButton = continueBox.childNode(withName: "continueButton") as! MSButtonNode
        creditsButton = childNode(withName: "//creditsButton") as! MSButtonNode
        creditsBox = childNode(withName: "//creditsBox") as! SKSpriteNode
        creditsBackButton = creditsBox.childNode(withName: "creditsBackButton") as! MSButtonNode
        controlsButton = childNode(withName: "//controlsButton") as! MSButtonNode
        eraseButton = childNode(withName: "//eraseButton") as! MSButtonNode
        yesButton = childNode(withName: "//yesButton") as! MSButtonNode
        noButton = childNode(withName: "//noButton") as! MSButtonNode
        sureBox = childNode(withName: "sureBox") as! SKSpriteNode
        backButton = childNode(withName: "//backButton") as! MSButtonNode
        controlsBackButton = childNode(withName: "//controlsBackButton") as! MSButtonNode
        rightButton = childNode(withName: "//rightButton") as! MSButtonNode
        leftButton = childNode(withName: "//leftButton") as! MSButtonNode
        rightTick = childNode(withName: "//rightTick") as! SKSpriteNode
        if !rightFixed {
            rightTick.isHidden = true
        }
        leftTick = childNode(withName: "//leftTick") as! SKSpriteNode
        if !leftFixed {
            leftTick.isHidden = true
        }
        defaultScreen = childNode(withName: "Default")
        controlsScreen = childNode(withName: "Controls")
        customizationScreen = childNode(withName: "Customization")
        customizationButton = childNode(withName: "//customizationButton") as! MSButtonNode
        resetLocationsButton = childNode(withName: "//resetLocationsButton") as! MSButtonNode
        customizationBackButton = childNode(withName: "//customizationBackButton") as! MSButtonNode
        leftJoystick = childNode(withName: "//leftJoystick") as! SKSpriteNode
        rightJoystick = childNode(withName: "//rightJoystick") as! SKSpriteNode
        autoFireButton = childNode(withName: "//autoFireButton") as! MSButtonNode
        autoFireTick = childNode(withName: "//autoFireTick") as! SKSpriteNode
        if !autoFire {
            autoFireTick.isHidden = true
        }
        musicButton = childNode(withName: "//musicButton") as! MSButtonNode
        soundButton = childNode(withName: "//soundButton") as! MSButtonNode
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
        
        // Button functionalities
        slayButton.selectedHandler = {[unowned self] in
            var continuable = false
            if let savedScore = UserDefaults().integer(forKey: "SAVEDSCORE") as Int? {
                if savedScore > 0 {
                    continuable = true
                    self.continueBox.position = self.onScreen
                }
            }
            if !continuable {
                self.loadGame("slay")
            }
        }
        newGameButton.selectedHandler = {[unowned self] in
            newGame = true
            self.loadGame("slay")
        }
        
        continueButton.selectedHandler = {[unowned self] in
            self.loadGame("slay")
        }
        
        continueBackButton.selectedHandler = {[unowned self] in
            self.continueBox.position = self.offScreen
        }
        optionButton.selectedHandler = {[unowned self] in
            self.loadGame("option")
        }
        
        creditsBackButton.selectedHandler = {[unowned self] in
            self.creditsBox.position = self.offScreen
            self.mainScreen.position = self.onScreen
        }
        
        creditsButton.selectedHandler = {[unowned self] in
            self.creditsBox.position = self.onScreen
            self.mainScreen.position = self.offScreen
        }
        controlsButton.selectedHandler = {[unowned self] in
            self.defaultScreen.position = self.offScreen
            self.controlsScreen.position = self.onScreen
        }
        backButton.selectedHandler = {[unowned self] in
            self.loadMainMenu()
        }
        eraseButton.selectedHandler = {[unowned self] in
            self.sureBox.position = self.onScreen
        }
        yesButton.selectedHandler = {[unowned self] in
            UserDefaults.standard.set(nil, forKey: "HIGHSCORE")
            UserDefaults.standard.set(nil, forKey: "AUTOFIRE")
            UserDefaults.standard.set(nil, forKey: "LEFTFIXED")
            UserDefaults.standard.set(nil, forKey: "RIGHTFIXED")
            UserDefaults.standard.set(nil, forKey: "LEFTX")
            UserDefaults.standard.set(nil, forKey: "LEFTY")
            UserDefaults.standard.set(nil, forKey: "RIGHTX")
            UserDefaults.standard.set(nil, forKey: "RIGHTY")
            UserDefaults.standard.set(nil, forKey: "SAVEDSCORE")
            UserDefaults.standard.set(nil, forKey: "SAVEDHEALTH")
            let temp = GameScene()
            for (type, _) in temp.upgradeUIElements {
                UserDefaults.standard.set(nil, forKey: type)
            }
            self.sureBox.position = self.offScreen
            rightFixed = false
            self.rightTick.isHidden = true
            leftFixed = false
            self.leftTick.isHidden = true
            self.autoFireTick.isHidden = true
            fixedLeftJoystickLocation = CGPoint(x: -142, y: -145)
            fixedRightJoystickLocation = CGPoint(x: 142, y: -145)
            self.leftJoystick.position = fixedLeftJoystickLocation
            self.rightJoystick.position = fixedRightJoystickLocation
        }
        noButton.selectedHandler = {[unowned self] in
            self.sureBox.position = self.offScreen
        }
        controlsBackButton.selectedHandler = {[unowned self] in
            self.defaultScreen.position = self.onScreen
            self.controlsScreen.position = self.offScreen
        }
        autoFireButton.selectedHandler = {[unowned self] in
            autoFire = !autoFire
            UserDefaults.standard.set(autoFire, forKey: "AUTOFIRE")
            self.autoFireTick.isHidden = !autoFire
        }
        leftButton.selectedHandler = {[unowned self] in
            leftFixed = !leftFixed
            UserDefaults.standard.set(leftFixed, forKey: "LEFTFIXED")
            self.leftTick.isHidden = !leftFixed
        }
        rightButton.selectedHandler = {[unowned self] in
            rightFixed = !rightFixed
            UserDefaults.standard.set(rightFixed, forKey: "RIGHTFIXED")
            self.rightTick.isHidden = !rightFixed
        }
        customizationButton.selectedHandler = {[unowned self] in
            self.controlsScreen.position = self.offScreen
            self.customizationScreen.position = self.onScreen
        }
        resetLocationsButton.selectedHandler = {[unowned self] in
            UserDefaults.standard.set(nil, forKey: "LEFTX")
            UserDefaults.standard.set(nil, forKey: "LEFTY")
            UserDefaults.standard.set(nil, forKey: "RIGHTX")
            UserDefaults.standard.set(nil, forKey: "RIGHTY")
            fixedLeftJoystickLocation = CGPoint(x: -142, y: -145)
            fixedRightJoystickLocation = CGPoint(x: 142, y: -145)
            self.leftJoystick.position = fixedLeftJoystickLocation
            self.rightJoystick.position = fixedRightJoystickLocation
        }
        customizationBackButton.selectedHandler = {[unowned self] in
            self.customizationScreen.position = self.offScreen
            self.controlsScreen.position = self.onScreen
        }
        musicButton.selectedHandler = {[unowned self] in
            musicPlaying = !musicPlaying
            UserDefaults.standard.set(!musicPlaying, forKey: "MUSIC")
            if !musicPlaying {
                self.musicX.position = self.onScreen
                self.bgMusic?.pause()
            } else {
                self.musicX.position = self.offScreen
                self.startBackgroundMusic()
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
        
        if musicPlaying {
            startBackgroundMusic()
        }
        
        // Sets joystick locations
        leftJoystick.position = fixedLeftJoystickLocation
        rightJoystick.position = fixedRightJoystickLocation
        
        mainScreen = childNode(withName: "Main")
    }
    
    // Changes the scene to GameScene
    func loadGame(_ button: String) {
        
        // Set reference to SpriteKit view
        guard let skView = self.view as SKView! else {
            print("Could not get Skview")
            return
        }
        
        // Creates GameScene
        switch button {
        case "slay":
            if let scene = GameScene(fileNamed: "GameScene") {
            
                // Ensure correct aspect mode
                scene.scaleMode = .aspectFit
                skView.presentScene(scene)
            }
        case "option":
            mainScreen.position = offScreen
            defaultScreen.position = onScreen
        default:
            break
        }
    }
    
    // Starts the background music
    func startBackgroundMusic()
    {
        if let bgMusic = self.setupAudioPlayerWithFile("Menace", type:"mp3") {
            self.bgMusic = bgMusic
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if customizationScreen.position == onScreen {
            for touch in touches {
                if touch.location(in: self).x <= 0 {
                    if leftTouch == nil {
                        leftTouch = touch
                        let location = touch.location(in: self)
                        leftJoystick.position.x = clamp(value: location.x, lower: -209, upper: -75)
                        leftJoystick.position.y = clamp(value: location.y, lower: -145, upper: 145)
                    }
                } else {
                    if rightTouch == nil {
                        rightTouch = touch
                        let location = touch.location(in: self)
                        rightJoystick.position.x = clamp(value: location.x, lower: 75, upper: 209)
                        rightJoystick.position.y = clamp(value: location.y, lower: -145, upper: 145)
                    }
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if customizationScreen.position == onScreen {
            for touch in touches {
                if touch === leftTouch {
                    let location = touch.location(in: self)
                    leftJoystick.position.x = clamp(value: location.x, lower: -224, upper: -60)
                    leftJoystick.position.y = clamp(value: location.y, lower: -145, upper: 145)
                }
                if touch === rightTouch {
                    let location = touch.location(in: self)
                    rightJoystick.position.x = clamp(value: location.x, lower: 60, upper: 224)
                    rightJoystick.position.y = clamp(value: location.y, lower: -145, upper: 145)
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch === leftTouch {
                leftTouch = nil
                fixedLeftJoystickLocation = leftJoystick.position
                UserDefaults.standard.set(Int(leftJoystick.position.x), forKey: "LEFTX")
                UserDefaults.standard.set(Int(leftJoystick.position.y), forKey: "LEFTY")
            }
            if touch === rightTouch {
                rightTouch = nil
                fixedRightJoystickLocation = rightJoystick.position
                UserDefaults.standard.set(Int(rightJoystick.position.x), forKey: "RIGHTX")
                UserDefaults.standard.set(Int(rightJoystick.position.y), forKey: "RIGHTY")
            }
        }
    }
    
    // Changes the scene to GameScene
    func loadMainMenu() {
        
        defaultScreen.position = offScreen
        mainScreen.position = onScreen
    }
}
