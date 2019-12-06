//
//  Player.swift
//  MagmaFrog
//
//  Created by RITSON, BEN on 02/12/2019.
//  Copyright © 2019 RITSON, BEN. All rights reserved.
//

import SpriteKit



class Player: SKSpriteNode {
    
    init(){
        
        let texture = SKTexture(imageNamed: "frog")
        super.init(texture: texture, color: .white, size: CGSize(width: 64, height: 64))
            
        physicsBody = SKPhysicsBody(circleOfRadius: 30)
        physicsBody?.categoryBitMask = CollisionType.player.rawValue //set the collision type to the enum value
        physicsBody?.contactTestBitMask = CollisionType.boulder.rawValue | CollisionType.magmaFloat.rawValue | CollisionType.magma.rawValue | CollisionType.pickup.rawValue//sends a message when collisions happen
        physicsBody?.collisionBitMask = 0
        name = "player"
        zPosition = 2

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError(":]")
    }

}
