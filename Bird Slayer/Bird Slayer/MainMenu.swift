//
//  MainMenu.swift
//  Bird Slayer
//
//  Created by Marshall Cain on 7/7/17.
//  Copyright © 2017 Marshall Cain. All rights reserved.
//

import SpriteKit

class MainMenu: SKScene {
    
    // UI
    var slayButton: MSButtonNode!
    
    // Setup scene
    override func didMove(to view: SKView) {
        
        print("1")
        
        // Set reference to play button
        slayButton = self.childNode(withName: "slayButton") as! MSButtonNode
        
        // Play button functionality
        slayButton.selectedHandler = {
            print("2")
            self.loadGame()
        }
    }
    
    // Changes the scene to GameScene
    func loadGame() {
        
        // Set reference to SpriteKit view
        guard let skView = self.view as SKView! else {
            print("Could not get Skview")
            return
        }
        
        // Creates GameScene
        if let scene = GameScene(fileNamed: "GameScene") {
        
            // Ensure correct aspect mode
            scene.scaleMode = .aspectFit
            
            skView.presentScene(scene)
        }
    }
    
}
