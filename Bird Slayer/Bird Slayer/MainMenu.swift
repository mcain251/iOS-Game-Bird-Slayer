//
//  MainMenu.swift
//  Bird Slayer
//
//  Created by Marshall Cain on 7/7/17.
//  Copyright © 2017 Marshall Cain. All rights reserved.
//

import SpriteKit

var autoFire: Bool! = false

var leftFixed: Bool! = false
var rightFixed: Bool! = false

var fixedLeftJoystickLocation: CGPoint = CGPoint(x: 142, y: -145)
var fixedRightJoystickLocation: CGPoint = CGPoint(x: 426, y: -145)

var newGame = false

class MainMenu: SKScene {
    
    let offScreen: CGPoint = CGPoint(x: -1000, y: -1000)
    let onScreen: CGPoint = CGPoint(x: 0, y: 0)
    
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
    
    // Setup scene
    override func didMove(to view: SKView) {
        
        // Set reference to buttons
        slayButton = childNode(withName: "slayButton") as! MSButtonNode
        optionButton = childNode(withName: "optionButton") as! MSButtonNode
        continueBox = childNode(withName: "continueBox") as! SKSpriteNode
        newGameButton = continueBox.childNode(withName: "newGameButton") as! MSButtonNode
        continueBackButton = continueBox.childNode(withName: "continueBackButton") as! MSButtonNode
        continueButton = continueBox.childNode(withName: "continueButton") as! MSButtonNode
        creditsButton = childNode(withName: "creditsButton") as! MSButtonNode
        creditsBox = childNode(withName: "creditsBox") as! SKSpriteNode
        creditsBackButton = creditsBox.childNode(withName: "creditsBackButton") as! MSButtonNode
        
        // Play button functionality
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
        
        // Option button functionality
        optionButton.selectedHandler = {[unowned self] in
            self.loadGame("option")
        }
        
        creditsBackButton.selectedHandler = {[unowned self] in
            self.creditsBox.position = self.offScreen
        }
        
        creditsButton.selectedHandler = {[unowned self] in
            self.creditsBox.position = self.onScreen
        }
        
        
        
        // Loads saved control scheme
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
            if let scene = GameScene(fileNamed: "OptionMenu") {
                    
                // Ensure correct aspect mode
                scene.scaleMode = .aspectFit
                skView.presentScene(scene)
            }
        default:
            break
        }
    }
}
