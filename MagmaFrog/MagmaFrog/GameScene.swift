//
//  GameScene.swift
//  MagmaFrog
//
//  Created by RITSON, BEN on 23/11/2019.
//  Copyright © 2019 RITSON, BEN. All rights reserved.
//

import SpriteKit

//Types of collisions in the game
enum CollisionType: UInt32{
    case player = 1 //The Frog
    case playerWeapon = 2 //Frog Tonuge
    case rollingBoulder = 4 //Rolling Boulders
    case magma = 8 //Magma
    case obstacleBoulder = 16 //Stationary Obstacle Boulders
}

class GameScene: SKScene {
    let player = SKSpriteNode(imageNamed: "frog")
    let rockbg = SKSpriteNode(imageNamed: "rockbg")
    
    var isPlayerAlive = true
    var score = 0
    
    let bpositions = Array(stride(from: -384, to: 384, by: 128))
    
    override func didMove(to view: SKView) {
        
        rockbg.name = "rockbg"
        rockbg.position.x = 0
        rockbg.zPosition = 0
        rockbg.position.y = 0
        addChild(rockbg)
        
        player.name = "player"
        player.position.x = 0  //frame.minX to get left side
        player.zPosition = 1
        player.position.y = 0
        addChild(player)
        
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 64))
        player.physicsBody?.categoryBitMask = CollisionType.player.rawValue //set the collision type to the enum value
        player.physicsBody?.collisionBitMask = CollisionType.rollingBoulder.rawValue | CollisionType.obstacleBoulder.rawValue //What can the player collide with? The | adds the two values from the enum together
        player.physicsBody?.contactTestBitMask = CollisionType.rollingBoulder.rawValue | CollisionType.obstacleBoulder.rawValue //sends a message when collisions happen
        player.physicsBody?.isDynamic = false //remove gravity
    }
}
