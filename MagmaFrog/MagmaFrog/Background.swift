//
//  Background.swift
//  MagmaFrog
//
//  Created by RITSON, BEN on 09/12/2019.
//  Copyright © 2019 RITSON, BEN. All rights reserved.
//

import SpriteKit

class Background: SKSpriteNode {
    
    init(texName: String, objName: String){
        
        let texture = SKTexture(imageNamed: texName)
        super.init(texture: texture, color: .white, size: CGSize(width: 750, height: 64))
            
        name = objName
        size.width = frame.width
        zPosition = 0
        
        if(texName == "magmabg"){
            physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 750, height: 64))
            physicsBody?.categoryBitMask = CollisionType.magma.rawValue
            physicsBody?.contactTestBitMask = CollisionType.player.rawValue
            physicsBody?.isDynamic = false
        }
        

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError(":]")
    }

}
