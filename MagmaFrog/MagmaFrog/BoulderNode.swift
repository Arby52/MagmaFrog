//
//  BoulderNode.swift
//  MagmaFrog
//
//  Created by RITSON, BEN on 23/11/2019.
//  Copyright © 2019 RITSON, BEN. All rights reserved.
//

import SpriteKit

class BoulderNode: SKSpriteNode {
    var movSpeed: CGFloat
    
    init(startPosition:CGPoint, movSpeed:CGFloat, direction:Direction){
        self.movSpeed = movSpeed
        
        let texture = SKTexture(imageNamed: "boulder")
        super.init(texture: texture, color: .white, size: CGSize(width: 64, height: 64))
        
        physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(30))
        physicsBody?.categoryBitMask = CollisionType.boulder.rawValue
        physicsBody?.contactTestBitMask = CollisionType.player.rawValue
        physicsBody?.collisionBitMask = 0
        physicsBody?.isDynamic = true
        name = "boulder"
        position = CGPoint(x: startPosition.x, y:startPosition.y)
        zPosition = 3
        configureMovement(direction: direction)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError(":]")
    }
    
    func configureMovement(direction: Direction){
        let path = UIBezierPath()
        path.move(to: .zero)
        
        if (direction == Direction.left){
            path.addLine(to: CGPoint(x:-10000, y: 0)) //Move in a straight line to the left.
        } else {
            path.addLine(to:CGPoint(x:10000, y: 0))
        }
        let movement = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: CGFloat(movSpeed))
        
        let sequence = SKAction.sequence([movement, .removeFromParent()]) //destroy once movement is finished
        
        run(sequence)
    }
    
}
