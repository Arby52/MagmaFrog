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
        var currentBlocks: Int = 0
        let neededBlocks: Int = 21
        var prevBG: BackgroundTypes = BackgroundTypes.spawn
        
        //Spawn Starting Background
        currentBlocks = SpawnStartingBG(currentBlocks: &currentBlocks)
        
        //Randomly spawn the rest of the backgrounds
        while currentBlocks <= neededBlocks{
            var bgtype: Int

            //Make sure the same area dosent spawn twice
            repeat {
                bgtype = Int.random(in: 1...3)
            } while prevBG.rawValue == bgtype
   
            switch bgtype{
            case 1:
                //spawn safe
                print("spawning safe")
                currentBlocks = SpawnSafeBG(currentBlocks: &currentBlocks)
                prevBG = BackgroundTypes.safe
                break
                
            case 2:
                //spawn magma
                print("spawning magma")
                currentBlocks = SpawnMagmaBG(currentBlocks: &currentBlocks)
                prevBG = BackgroundTypes.magma
                break
                
            case 3:
                //spawn boulder
                print("spawning boulder")
                currentBlocks = SpawnBoulderBG(currentBlocks: &currentBlocks)
                prevBG = BackgroundTypes.boulder
                break
                
            default:
                break
            }
            
        }
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
    
    func SpawnStartingBG( currentBlocks: inout Int) ->Int{
        for _ in 0...2{
            let bg = SKSpriteNode(imageNamed: "safebg")
            bg.name = "spawnbg"
            bg.position.x = 0
            bg.zPosition = 0
            bg.position.y = CGFloat((frame.minY + 32) + CGFloat(currentBlocks*64))
            addChild(bg)
            currentBlocks+=1
        }
        
        return currentBlocks
    }
    
    func SpawnSafeBG(currentBlocks: inout Int) -> Int{
        
        for _ in 0...2{
            let bg = SKSpriteNode(imageNamed: "safebg")
            bg.name = "safebg"
            bg.position.x = 0
            bg.zPosition = 0
            bg.position.y = CGFloat((frame.minY + 32) + CGFloat(currentBlocks*64))
            addChild(bg)
            currentBlocks+=1
        }
        
        return currentBlocks
    }
    
    func SpawnMagmaBG(currentBlocks: inout Int) -> Int{
        
        for _ in 0...2{
            let bg = SKSpriteNode(imageNamed: "magmabg")
            bg.name = "magmabg"
            bg.position.x = 0
            bg.zPosition = 0
            bg.position.y = CGFloat((frame.minY + 32) + CGFloat(currentBlocks*64))
            addChild(bg)
            currentBlocks+=1
        }
        
        return currentBlocks
    }
    
    func SpawnBoulderBG(currentBlocks: inout Int) ->Int{
        
        for n in 0...2{
            let bg = SKSpriteNode(imageNamed: "rockbg")
            bg.name = "rockbg"
            bg.position.x = 0
            bg.zPosition = 0
            bg.position.y = CGFloat((frame.minY + 32) + CGFloat(currentBlocks*64))
            addChild(bg)
            
            print("timer")
            print(n)
            let xOffset = Int.random(in: 0 ... 500)
            let timer = Double.random(in: 3 ... 5)
            let speed = Int.random(in: 70 ... 150)
            Timer.scheduledTimer(withTimeInterval: timer, repeats: true) {_ in
                self.SpawnBoulder(boulderStartY: Int(bg.position.y), xOffset: xOffset, speed: speed)
            }
                            
            currentBlocks+=1
        }
        
        //boulder spawn timer
        

        
        return currentBlocks
    }
    
    
    func SpawnBoulder(boulderStartY: Int, xOffset: Int, speed: Int){
        guard isPlayerAlive else {return }
        
        let boulderStartY = boulderStartY
        let boulderStartX = frame.maxX + CGFloat(xOffset)
        let boulder = BoulderNode(startPosition: CGPoint(x: CGFloat(boulderStartX), y: CGFloat( boulderStartY)), movSpeed: CGFloat(speed))
        boulder.zPosition=1
        addChild(boulder)
    }
}
