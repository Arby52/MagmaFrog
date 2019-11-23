//
//  BoulderNode.swift
//  MagmaFrog
//
//  Created by RITSON, BEN on 23/11/2019.
//  Copyright © 2019 RITSON, BEN. All rights reserved.
//

import SpriteKit

class BoulderNode: SKSpriteNode {
    var movSpeed: Int
    
    init(startPosition:CGPoint, movSpeed:Int){
        self.movSpeed = movSpeed
        
        let texture = SKTexture(imageNamed: "boulder")
        super.init(texture: texture, color: .white, size: CGSize(width: 64, height: 64))
        
        physicsBody = SKPhysicsBody(texture: texture, size: texture.size())
        physicsBody?.categoryBitMask = CollisionType.rollingBoulder.rawValue
        physicsBody?.collisionBitMask = CollisionType.player.rawValue
        physicsBody?.contactTestBitMask = CollisionType.player.rawValue
        name = "rollingBoulder"
        position = CGPoint(x: startPosition.x, y:startPosition.y)
    
        configureMovement()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError(":]")
    }
    
    func configureMovement(){
        let path = UIBezierPath()
        path.move(to: .zero)
        
        path.addLine(to: CGPoint(x:-10000, y: 0)) //Move in a straight line to the left. TODO: add a randomiser so it could come in from the left and go right
        
        let movement = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: CGFloat(movSpeed))
        
        let sequence = SKAction.sequence([movement, .removeFromParent()]) //destroy once movement is finished
        
        run(sequence)
    }
    
}
