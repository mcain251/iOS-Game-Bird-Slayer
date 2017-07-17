//
//  OptionMenu.swift
//  Bird Slayer
//
//  Created by Marshall Cain on 7/13/17.
//  Copyright © 2017 Marshall Cain. All rights reserved.
//

import SpriteKit

class OptionMenu: SKScene {
    
    let offScreen: CGPoint = CGPoint(x: -1000, y: -1000)
    let onScreen: CGPoint = CGPoint(x: 0, y: 0)
    
    // UI
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
    
    override func didMove(to view: SKView) {
        
        // Set reference to buttons
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
        
        // Button functionalities
        controlsButton.selectedHandler = {
            self.defaultScreen.position = self.offScreen
            self.controlsScreen.position = self.onScreen
        }
        backButton.selectedHandler = {
            self.loadMainMenu()
        }
        eraseButton.selectedHandler = {
            self.sureBox.position = self.onScreen
        }
        yesButton.selectedHandler = {
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
            fixedLeftJoystickLocation = CGPoint(x: 142, y: -145)
            fixedRightJoystickLocation = CGPoint(x: 426, y: -145)
            self.leftJoystick.position = fixedLeftJoystickLocation
            self.leftJoystick.position.x -= 284
            self.rightJoystick.position = fixedRightJoystickLocation
            self.rightJoystick.position.x -= 284
        }
        noButton.selectedHandler = {
            self.sureBox.position = self.offScreen
        }
        controlsBackButton.selectedHandler = {
            self.defaultScreen.position = self.onScreen
            self.controlsScreen.position = self.offScreen
        }
        autoFireButton.selectedHandler = {
            autoFire = !autoFire
            UserDefaults.standard.set(autoFire, forKey: "AUTOFIRE")
            self.autoFireTick.isHidden = !autoFire
        }
        leftButton.selectedHandler = {
            leftFixed = !leftFixed
            UserDefaults.standard.set(leftFixed, forKey: "LEFTFIXED")
            self.leftTick.isHidden = !leftFixed
        }
        rightButton.selectedHandler = {
            rightFixed = !rightFixed
            UserDefaults.standard.set(rightFixed, forKey: "RIGHTFIXED")
            self.rightTick.isHidden = !rightFixed
        }
        customizationButton.selectedHandler = {
            self.controlsScreen.position = self.offScreen
            self.customizationScreen.position = self.onScreen
        }
        resetLocationsButton.selectedHandler = {
            UserDefaults.standard.set(nil, forKey: "LEFTX")
            UserDefaults.standard.set(nil, forKey: "LEFTY")
            UserDefaults.standard.set(nil, forKey: "RIGHTX")
            UserDefaults.standard.set(nil, forKey: "RIGHTY")
            fixedLeftJoystickLocation = CGPoint(x: 142, y: -145)
            fixedRightJoystickLocation = CGPoint(x: 426, y: -145)
            self.leftJoystick.position = fixedLeftJoystickLocation
            self.leftJoystick.position.x -= 284
            self.rightJoystick.position = fixedRightJoystickLocation
            self.rightJoystick.position.x -= 284
        }
        customizationBackButton.selectedHandler = {
            self.customizationScreen.position = self.offScreen
            self.controlsScreen.position = self.onScreen
        }
        
        // Sets joystick locations
        leftJoystick.position = fixedLeftJoystickLocation
        self.leftJoystick.position.x -= 284
        rightJoystick.position = fixedRightJoystickLocation
        self.rightJoystick.position.x -= 284
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if customizationScreen.position == onScreen {
            for touch in touches {
                if touch.location(in: self.view).x <= 284 {
                    if leftTouch == nil {
                        leftTouch = touch
                        var location = touch.location(in: view)
                        location.y = 160 - location.y
                        location.x -= 284
                        leftJoystick.position.x = clamp(value: location.x, lower: -209, upper: -75)
                        leftJoystick.position.y = clamp(value: location.y, lower: -145, upper: 145)
                    }
                } else {
                    if rightTouch == nil {
                        rightTouch = touch
                        var location = touch.location(in: view)
                        location.y = 160 - location.y
                        location.x -= 284
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
                    var location = touch.location(in: view)
                    location.y = 160 - location.y
                    location.x -= 284
                    leftJoystick.position.x = clamp(value: location.x, lower: -224, upper: -60)
                    leftJoystick.position.y = clamp(value: location.y, lower: -145, upper: 145)
                }
                if touch === rightTouch {
                    var location = touch.location(in: view)
                    location.y = 160 - location.y
                    location.x -= 284
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
                UserDefaults.standard.set(Int(leftJoystick.position.x) + 284, forKey: "LEFTX")
                UserDefaults.standard.set(Int(leftJoystick.position.y), forKey: "LEFTY")
            }
            if touch === rightTouch {
                rightTouch = nil
                fixedRightJoystickLocation = rightJoystick.position
                UserDefaults.standard.set(Int(rightJoystick.position.x) + 284, forKey: "RIGHTX")
                UserDefaults.standard.set(Int(rightJoystick.position.y), forKey: "RIGHTY")
            }
        }
    }
    
    // Changes the scene to GameScene
    func loadMainMenu() {
        
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
}
