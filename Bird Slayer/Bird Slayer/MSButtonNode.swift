//
//  MSButtonNode.swift
//  Make School
//
//  Created by Martin Walsh on 20/02/2016.
//  Copyright (c) 2016 Make School. All rights reserved.
//

import SpriteKit

enum MSButtonNodeState {
    case MSButtonNodeStateActive, MSButtonNodeStateSelected, MSButtonNodeStateHidden
}

class MSButtonNode: SKSpriteNode {
    
    var originalXScale: CGFloat = 1
    var originalYScale: CGFloat = 1
    var topNode: SKNode!
    var bottomNode: SKNode!
    var xDist: CGFloat = 0
    var yDist: CGFloat = 0
    var text = false
    
    /* Setup a dummy action closure */
    var selectedHandler: () -> Void = { print("No button action set") }
    
    /* Button state management */
    var state: MSButtonNodeState = .MSButtonNodeStateActive {
        didSet {
            switch state {
            case .MSButtonNodeStateActive:
                /* Enable touch */
                self.isUserInteractionEnabled = true
                
                /* Visible */
                if !text {
                    self.alpha = 1
                    self.xScale = originalXScale
                    self.yScale = originalYScale
                } else {
                    topNode.position.x = -1 * (xDist / 2.0)
                    topNode.position.y = -1 * (yDist / 2.0)
                    bottomNode.position.x = xDist
                    bottomNode.position.y = yDist
                }
                break
            case .MSButtonNodeStateSelected:
                /* Semi transparent */
                if !text {
                    self.alpha = 0.7
                    self.xScale = originalXScale * 0.9
                    self.yScale = originalYScale * 0.9
                } else {
                    topNode.position.x = xDist * (1.0 / 4.0)
                    topNode.position.y = yDist * (1.0 / 4.0)
                    bottomNode.position.x = xDist / 4.0
                    bottomNode.position.y = yDist / 4.0
                }
                break
            case .MSButtonNodeStateHidden:
                /* Disable touch */
                self.isUserInteractionEnabled = false
                
                /* Hide */
                self.alpha = 0
                break
            }
        }
    }
    
    /* Support for NSKeyedArchiver (loading objects from SK Scene Editor */
    required init?(coder aDecoder: NSCoder) {
        
        /* Call parent initializer e.g. SKSpriteNode */
        super.init(coder: aDecoder)
        
        /* Enable touch on button node */
        self.isUserInteractionEnabled = true
        
        originalXScale = self.xScale
        originalYScale = self.yScale
        if self.childNode(withName: "topNode") != nil && self.childNode(withName: "//bottomNode") != nil {
            topNode = self.childNode(withName: "topNode")
            bottomNode = topNode.childNode(withName: "bottomNode")
            xDist = bottomNode.position.x
            yDist = bottomNode.position.y
            text = true
        }
    }
    
    // MARK: - Touch handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        state = .MSButtonNodeStateSelected
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        selectedHandler()
        state = .MSButtonNodeStateActive
    }
    
}
