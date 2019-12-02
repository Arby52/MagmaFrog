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
    case player = 0 //The Frog
    case boulder = 1 //Rolling Boulders
    case magma = 2 //Magma
    case magmaFloat = 4
}

enum BackgroundTypes : Int{
    case spawn = 0
    case safe = 1
    case magma = 2
    case boulder = 3
}

enum Direction: Int{
    case left = 0
    case right = 1
}




class GameScene: SKScene{
    
    //Create player and variables
    let moveStep: CGFloat = 64
    var onPlatform:Bool = false
    var isPlayerAlive = true
    var score = 0
    let player = Player()
    
    //spawn starting background
    let bpositions = Array(stride(from: -384, to: 384, by: 128))
    var currentBlocks: Int = 0
    let neededBlocks: Int = 24
    var prevBG: BackgroundTypes = BackgroundTypes.safe
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0,dy: 0) //Disable gravity
        
        isUserInteractionEnabled = true
        
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler(_:)))
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler(_:)))
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler(_:)))
        
        upSwipe.direction = .up
        downSwipe.direction = .down
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        view.addGestureRecognizer(upSwipe)
        view.addGestureRecognizer(downSwipe)
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        
        player.position = CGPoint(x: 0, y: frame.minY+96)
        addChild(player)
        
        //Spawn Starting Background
        currentBlocks = SpawnStartingBG(currentBlocks: &currentBlocks)
        currentBlocks = SpawnBackgrounds(currentBlocks: &currentBlocks)
        
    }
    
    //Update and Input functions
    override func update(_ currentTime: TimeInterval) {
        /* ////////uhhhh, make it so they have to come on screen once before can be deleted :] mayB with boolean
        for child in children{ //Destroy objets off screen
            if child.frame.maxX < 0 {
                if !frame.intersects(child.frame){
                    child.removeFromParent()
                }
            }
        }
         */
    }
    
    @objc func swipeHandler(_ sender : UISwipeGestureRecognizer){
        if isPlayerAlive{
            switch(sender.direction){
                    case .up:
                        player.position.y += moveStep
                        
                        if player.position.y > 0{
                            //Move EVERY NODE down by movestep
                            for child in children{
                                child.position.y -= moveStep
                            }
                            currentBlocks -= 1
                        }
                        
                        if currentBlocks < neededBlocks{
                            currentBlocks = SpawnBackgrounds(currentBlocks: &currentBlocks)
                        }
                    
                        break
                        
                    case .left:
                        //If not at boundary, move frog
                        if !(Int(floor(player.position.x)) < -310){
                            player.position.x -= moveStep
                        }
                        break
                        
                    case .right:
                        if !(Int(floor(player.position.x)) > 310){
                            player.position.x += moveStep
                        }
                        break
                        
                    case .down:
                        if !(Int(floor(player.position.y)) < -615){
                            player.position.y -= moveStep
                        }

                        break
                        
                    default:
                        break
            }
        }
    }
    
    
   
    
    func destroy(object: SKNode){
        object.removeFromParent()
    }
    
    //Background spawning functions
    func SpawnBackgrounds(currentBlocks: inout Int) ->Int{
        //Randomly spawn the needed backgrounds
             while currentBlocks <= neededBlocks{
                 var bgtype: Int

                 //Make sure the same area dosent spawn twice
                 repeat {
                     bgtype = Int.random(in: 1...3)
                 } while prevBG.rawValue == bgtype
        
                 switch bgtype{
                 case 1:
                     //spawn safe
                     currentBlocks = SpawnSafeBG(currentBlocks: &currentBlocks)
                     prevBG = BackgroundTypes.safe
                     break
                     
                 case 2:
                     //spawn magma
                     currentBlocks = SpawnMagmaBG(currentBlocks: &currentBlocks)
                     prevBG = BackgroundTypes.magma
                     break
                     
                 case 3:
                     //spawn boulder
                     currentBlocks = SpawnBoulderBG(currentBlocks: &currentBlocks)
                     prevBG = BackgroundTypes.boulder
                     break
                     
                 default:
                     break
                 }
                
                
                 
             }
        return currentBlocks
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
        let blockAmount = Int.random(in: 2...2)
        for _ in 1...blockAmount{
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
        let blockAmount = Int.random(in: 2...4)
        for _ in 1...blockAmount{
            let bg = SKSpriteNode(imageNamed: "magmabg")
            bg.name = "magmabg"
            bg.position.x = 0
            bg.zPosition = 0
            bg.position.y = CGFloat((frame.minY + 32) + CGFloat(currentBlocks*64))
            
            bg.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 750, height: 64))
            bg.physicsBody?.categoryBitMask = CollisionType.magma.rawValue
            bg.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
            bg.physicsBody?.isDynamic = false
            
            addChild(bg)
            
            let xOffset = Int.random(in: 0 ... 250)
            let timer = Double.random(in: 2.5 ... 4)
            let speed = 100
            let dval = Int.random(in: 0...1)
            var direction:Direction
            if(dval == 0){
                direction = Direction.left
                var fillSpawnPoint = (frame.maxX + CGFloat(xOffset))
                repeat{
                    let magmaFloat = MagmaFloat(startPosition: CGPoint(x: CGFloat(fillSpawnPoint), y: CGFloat( bg.position.y)), movSpeed: CGFloat(speed), direction: direction)

                   addChild(magmaFloat)
                   fillSpawnPoint -= (CGFloat(timer) * CGFloat(speed))
                } while fillSpawnPoint >= frame.minX
            }
            else{
                direction = Direction.right
                var fillSpawnPoint = (frame.minX - CGFloat(xOffset))
                repeat{
                    let magmaFloat = MagmaFloat(startPosition: CGPoint(x: CGFloat(fillSpawnPoint), y: CGFloat( bg.position.y)), movSpeed: CGFloat(speed), direction: direction)

                   addChild(magmaFloat)
                   fillSpawnPoint += (CGFloat(timer) * CGFloat(speed))
                } while fillSpawnPoint <= frame.maxX
            }

            //spawn magmaFloats in on the screen so they're in place on spawn

            //Spawn on timer
            Timer.scheduledTimer(withTimeInterval: timer, repeats: true) {_ in
                self.SpawnMagmaFloat(floatStartY: Int(bg.position.y), xOffset: xOffset, speed: speed, direction: direction)
            }
            
            currentBlocks+=1
        }
        
        return currentBlocks
    }
    
    func SpawnBoulderBG(currentBlocks: inout Int) ->Int{
        let blockAmount = Int.random(in: 2...4)
        for _ in 1...blockAmount{
            let bg = SKSpriteNode(imageNamed: "rockbg")
            bg.name = "rockbg"
            bg.position.x = 0
            bg.zPosition = 0
            bg.position.y = CGFloat((frame.minY + 32) + CGFloat(currentBlocks*64))
            addChild(bg)
            
            let xOffset = Int.random(in: 0 ... 500)
            let timer = Double.random(in: 3 ... 5)
            let speed = Int.random(in: 70 ... 150)
            
            //spawn boulders in on the screen so they're in place on spawn
            var fillSpawnPoint = (frame.maxX + CGFloat(xOffset))
            repeat{
                let boulder = BoulderNode(startPosition: CGPoint(x: CGFloat(fillSpawnPoint), y: CGFloat( bg.position.y)), movSpeed: CGFloat(speed))
                addChild(boulder)
                fillSpawnPoint -= (CGFloat(timer) * CGFloat(speed))
            } while fillSpawnPoint >= frame.minX
            
            //Spawn on timer
            Timer.scheduledTimer(withTimeInterval: timer, repeats: true) {_ in
                self.SpawnBoulder(boulderStartY: Int(bg.position.y), xOffset: xOffset, speed: speed)
            }
                            
            currentBlocks+=1
        }
        
        return currentBlocks
    }
    
    func SpawnMagmaFloat(floatStartY: Int, xOffset: Int, speed: Int, direction: Direction){
        
        let floatStartY = floatStartY
        var floatStartX: CGFloat
        if(direction == Direction.left){
            floatStartX = frame.maxX + CGFloat(xOffset)
        } else {
            floatStartX = frame.minX - CGFloat(xOffset)
        }
        let magmaFloat = MagmaFloat(startPosition: CGPoint(x:floatStartX, y:CGFloat(floatStartY)), movSpeed: CGFloat(speed), direction: direction)
        addChild(magmaFloat)
    }
    
    func SpawnBoulder(boulderStartY: Int, xOffset: Int, speed: Int){
        
        let boulderStartY = boulderStartY
        let boulderStartX = frame.maxX + CGFloat(xOffset)
        let boulder = BoulderNode(startPosition: CGPoint(x: CGFloat(boulderStartX), y: CGFloat( boulderStartY)), movSpeed: CGFloat(speed))
        addChild(boulder)
    }
}

extension GameScene: SKPhysicsContactDelegate{
    //Collision Functions
        func didBegin(_ contact: SKPhysicsContact) {
           
           guard let nodeA = contact.bodyA.node else {return}
           guard let nodeB = contact.bodyB.node else {return}
           
           print("Collision")
           
           //Player Colliding
           if nodeA.name == "mfloat" || nodeB.name == "mfloat"{
               collisionBetween(obj1: nodeA, obj2: nodeB)
           }
           
           if nodeA.name == "player" || nodeB.name == "player"{
               collisionBetween(obj1: nodeA, obj2: nodeB)
           }
        }
        
        func collisionBetween(obj1: SKNode, obj2: SKNode){
           //With Boulder
           if (obj1.name == "player" && obj2.name == "boulder"){
               destroy(object: obj1)
               isPlayerAlive = false
           }
           
           //player and mfloat
           if (obj1.name == "player" && obj2.name == "mfloat"){
               onPlatform = true
           }
           if (obj1.name == "mfloat" && obj2.name == "player"){
               onPlatform = true
           }
           
           //player and lava
           if(!onPlatform){
               if(obj1.name == "player" && obj2.name == "magmabg"){
                   destroy(object: obj1)
                   isPlayerAlive = false
               }
               if(obj1.name == "magmabg" && obj2.name == "player"){
                   destroy(object: obj2)
                   isPlayerAlive = false
               }
           }
        }
    
    func didEnd(_ contact: SKPhysicsContact) {
            guard let nodeA = contact.bodyA.node else {return}
            guard let nodeB = contact.bodyB.node else {return}
            
            if nodeA.name == "player" || nodeB.name == "player"{
                endedCollision(obj1: nodeA, obj2: nodeB)
            }
        }
    
        func endedCollision(obj1: SKNode, obj2: SKNode){
            if (obj1.name == "player" && obj2.name == "mfloat"){
                onPlatform = false
            }
            if (obj1.name == "mfloat" && obj2.name == "player"){
                onPlatform = false
            }
        }
}
