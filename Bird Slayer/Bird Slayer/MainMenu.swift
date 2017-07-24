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
    
    // UI
    var slayButton: MSButtonNode!
    var optionButton: MSButtonNode!
    var newGameButton: MSButtonNode!
    
    // Setup scene
    override func didMove(to view: SKView) {
        
        // Set reference to buttons
        slayButton = childNode(withName: "slayButton") as! MSButtonNode
        optionButton = childNode(withName: "optionButton") as! MSButtonNode
        newGameButton = childNode(withName: "newGameButton") as! MSButtonNode
        
        // Play button functionality
        slayButton.selectedHandler = {[unowned self] in
            self.loadGame("slay")
        }
        
        newGameButton.selectedHandler = {[unowned self] in
            newGame = true
            self.loadGame("slay")
        }
        
        // Option button functionality
        optionButton.selectedHandler = {[unowned self] in
            self.loadGame("option")
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
