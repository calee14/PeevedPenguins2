//
//  Penguin.swift
//  PeevedPenguins2
//
//  Created by Cappillen on 6/23/17.
//  Copyright © 2017 Cappillen. All rights reserved.
//

import Foundation
import SpriteKit

class Penguin: SKSpriteNode {
    
    init() {
        
        //make the penguin texture, color, and size
        let texture = SKTexture(imageNamed: "flyingpenguin")
        let color = UIColor.clear
        let size = texture.size()
        
        //Called the designated initializer
        super.init(texture: texture, color: color, size: size)
        
        //Set the physical properties
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        physicsBody?.categoryBitMask = 1
        physicsBody?.friction = 0.6
        physicsBody?.mass = 0.5
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
