//
//  MagmaFloat.swift
//  MagmaFrog
//
//  Created by RITSON, BEN on 02/12/2019.
//  Copyright © 2019 RITSON, BEN. All rights reserved.
//

import SpriteKit

class MagmaFloat: SKSpriteNode {

    var movSpeed: CGFloat
    
    init(startPosition:CGPoint, movSpeed:CGFloat, direction:Direction){
        self.movSpeed = movSpeed
        
        let texture = SKTexture(imageNamed: "magmafloat")
        super.init(texture: texture, color: .white, size: CGSize(width: 56, height: 128)) //I have no idea why i need to do switch the width and height, but i do
            
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 60, height: 128))
        physicsBody?.categoryBitMask = CollisionType.magmaFloat.rawValue //set the collision type to the enum value
        physicsBody?.contactTestBitMask = CollisionType.player.rawValue
        physicsBody?.collisionBitMask = 0
        physicsBody?.isDynamic = true
        name = "magmafloat"
        position = CGPoint(x: startPosition.x, y:startPosition.y)
        zPosition = 1

        configureMovement(direction: direction)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError(":]")
    }
    
    func configureMovement(direction:Direction){
        let path = UIBezierPath()
        path.move(to: .zero)
        
        if (direction == Direction.left){
            path.addLine(to: CGPoint(x:-10000, y: 0)) //Move in a straight line to the left. TODO: add a randomiser so it could come in from the left and go right
        } else {
            path.addLine(to:CGPoint(x:10000, y: 0))
        }
        
        let movement = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: CGFloat(movSpeed))
        
        let sequence = SKAction.sequence([movement, .removeFromParent()]) //destroy once movement is finished
        
        run(sequence)
    }
    
}
