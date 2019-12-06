//
//  Pickup.swift
//  MagmaFrog
//
//  Created by RITSON, BEN on 06/12/2019.
//  Copyright © 2019 RITSON, BEN. All rights reserved.
//

import SpriteKit

class Pickup: SKSpriteNode {
    
    init(startPosition: CGPoint){
        
        let texture = SKTexture(imageNamed: "pickup")
        super.init(texture: texture, color: .white, size: CGSize(width: 64, height: 64))
            
        physicsBody = SKPhysicsBody(circleOfRadius: 32)
        physicsBody?.categoryBitMask = CollisionType.pickup.rawValue //set the collision type to the enum value
        physicsBody?.contactTestBitMask = CollisionType.player.rawValue
        physicsBody?.collisionBitMask = 0
        name = "pickup"
        zPosition = 2
        position = startPosition

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError(":]")
    }

}
