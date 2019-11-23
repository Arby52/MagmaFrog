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

enum BackgroundTypes : Int{
    case spawn = 0
    case safe = 1
    case magma = 2
    case boulder = 3
}

class GameScene: SKScene {
    let player = SKSpriteNode(imageNamed: "frog")
        
    var isPlayerAlive = true
    var score = 0
    
    let bpositions = Array(stride(from: -384, to: 384, by: 128))
    
    override func didMove(to view: SKView) {
        
        player.name = "player"
        player.position.x = 0  //frame.minX to get left side
        player.zPosition = 1
        player.position.y = frame.minY + 96
        addChild(player)
        
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 64))
        player.physicsBody?.categoryBitMask = CollisionType.player.rawValue //set the collision type to the enum value
        player.physicsBody?.collisionBitMask = CollisionType.rollingBoulder.rawValue | CollisionType.obstacleBoulder.rawValue //What can the player collide with? The | adds the two values from the enum together
        player.physicsBody?.contactTestBitMask = CollisionType.rollingBoulder.rawValue | CollisionType.obstacleBoulder.rawValue //sends a message when collisions happen
        player.physicsBody?.isDynamic = false //remove gravity
        
        
        //spawn starting background
        let currentBlocks: Int = 0
        let neededBlocks: Int = 21
        let prevBg: BackgroundTypes
        
        //starting area
        for n in 0...2{
            let bg = SKSpriteNode(imageNamed: "rockbg")
            bg.name = "rockbg"
            bg.position.x = 0
            bg.zPosition = 0
            bg.position.y = CGFloat((frame.minY + 32) + CGFloat(n*64))
            addChild(bg)
        }
        
        while currentBlocks < neededBlocks{
            let bgtype = Int.random(in: 1...3)
            switch bgtype{
            case 1:
                
                break
                
            case 2:
                
                break
                
            case 3:
                
                break
            }
            
        }
        
        //boulder spawn timer
        var boulderSpawnTimer: Timer?
        boulderSpawnTimer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(SpawnBoulder), userInfo: nil, repeats: true)
              
    }
    
    override func update(_ currentTime: TimeInterval) {
        for child in children{ //Destroy objets off screen
            if child.frame.maxX < 0 {
                if !frame.intersects(child.frame){
                    child.removeFromParent()
                }
            }
        }
    }
    
    @objc func SpawnBoulder(){
        guard isPlayerAlive else {return }
        
        let boulderStartY = 0
        let boulder = BoulderNode(startPosition: CGPoint(x:frame.maxX , y: CGFloat( boulderStartY)), movSpeed: 100)
        addChild(boulder)
    }
}
