//
//  GameScene.swift
//  MagmaFrog
//
//  Created by RITSON, BEN on 23/11/2019.
//  Copyright © 2019 RITSON, BEN. All rights reserved.
//

import SpriteKit
import CoreMotion

//Types of collisions in the game
enum CollisionType: UInt32{
    case player = 0 //The Frog
    case boulder = 1 //Rolling Boulders
    case magmaFloat = 2//MagmaFloat
    case magma = 4 //Magma
    case pickup = 8 //Shockwave Pickup
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
    
    //Create player and various variables
    let moveStep: CGFloat = 64
    var onPlatform:Bool = false
    var onLava:Bool = false
    var floatDirection: Direction = Direction.left
    var isPlayerAlive = true
    var currentPlatform:SKNode? = nil
    let player = Player()
    
    var shockwaveBool = false

    
    //Motion Manager
    let motionManager = CMMotionManager()
    
    
    var scoreLabel: SKLabelNode!
    var score = 0{
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var shockwaveLabel: SKLabelNode!
    var remainingShockwaves = 3{
        didSet{
            shockwaveLabel.text = "Shockwaves: \(remainingShockwaves)"
        }
    }
    
    //spawn starting background
    let bpositions = Array(stride(from: -384, to: 384, by: 128))
    var currentBlocks: Int = 0
    let neededBlocks: Int = 24
    var prevBG: BackgroundTypes = BackgroundTypes.safe
    
    
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0,dy: 0) //Disable gravity
        
        
        isUserInteractionEnabled = true
                
        //Initializing swipe gestures
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
        
        //Motion Manager
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.016
            motionManager.startDeviceMotionUpdates(to: .main) {
                [weak self] (data, error) in
                
                guard let data = data, error == nil else{
                    return
                }
                if (data.userAcceleration.z < -2.5 && self!.remainingShockwaves > 0 && !(self!.shockwaveBool)){
                    self!.Shockwave()
                    self!.shockwaveBool = true
                }
                if(data.userAcceleration.z > -2 && self!.shockwaveBool){
                    self!.shockwaveBool = false
                }
            }
        }
        
        
        
        //Spawn Objects
        player.position = CGPoint(x: 0, y: frame.minY+96)
        addChild(player)
        
        //Spawn Starting Background
        currentBlocks = SpawnStartingBG(currentBlocks: &currentBlocks)
        currentBlocks = SpawnBackgrounds(currentBlocks: &currentBlocks)
        
        //score aligning
        scoreLabel = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x:frame.minX + 50, y:frame.maxY - 50)
        scoreLabel.fontSize = 40
        scoreLabel.zPosition = 10
        addChild(scoreLabel)
        
        //Shockwave aligning
        shockwaveLabel = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        shockwaveLabel.text = "Shockwaves: 3"
        shockwaveLabel.horizontalAlignmentMode = .right
        shockwaveLabel.position = CGPoint(x:frame.maxX - 50, y:frame.maxY - 50)
        shockwaveLabel.fontSize = 40
        shockwaveLabel.zPosition = 10
        addChild(shockwaveLabel)
    }
      
    func HandleShaking(){
        
    }
        
    //Update and Input functions
    override func update(_ currentTime: TimeInterval) {
        if(onPlatform && currentPlatform != nil){
            player.position.x = (currentPlatform?.position.x)!
        }
        
        
        if(onLava && !onPlatform && (currentPlatform == nil)){
            player.removeFromParent()
            isPlayerAlive = false
        }
        
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
                            scoreLabel.position.y += moveStep
                            shockwaveLabel.position.y += moveStep
                            currentBlocks -= 1
                            score += 1
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
    
    func Shockwave(){
        for child in children{
            if child.name == "boulder"{
                child.removeFromParent()
            }
        }
        remainingShockwaves -= 1
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
            SpawnPickup(yPos: Int(bg.position.y))
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
            
            SpawnPickup(yPos: Int(bg.position.y))
            
            //Spawning Magma Floats
            let xOffset = Int.random(in: 0 ... 250)
            let timer = Double.random(in: 2.5 ... 4)
            let speed = 100

            //spawn magmaFloats in on the screen so they're in place on spawn
            if(floatDirection == Direction.left){
                var fillSpawnPoint = (frame.maxX + CGFloat(xOffset))
                repeat{
                    let magmaFloat = MagmaFloat(startPosition: CGPoint(x: CGFloat(fillSpawnPoint), y: CGFloat( bg.position.y)), movSpeed: CGFloat(speed), direction: floatDirection)

                   addChild(magmaFloat)
                   fillSpawnPoint -= (CGFloat(timer) * CGFloat(speed))
                } while fillSpawnPoint >= frame.minX
            }
            else{
                var fillSpawnPoint = (frame.minX - CGFloat(xOffset))
                repeat{
                    let magmaFloat = MagmaFloat(startPosition: CGPoint(x: CGFloat(fillSpawnPoint), y: CGFloat( bg.position.y)), movSpeed: CGFloat(speed), direction: floatDirection)

                   addChild(magmaFloat)
                   fillSpawnPoint += (CGFloat(timer) * CGFloat(speed))
                } while fillSpawnPoint <= frame.maxX
            }

            let tempDirection = floatDirection
            
            //Spawn on timer
            Timer.scheduledTimer(withTimeInterval: timer, repeats: true) {_ in
                self.SpawnMagmaFloat(floatStartY: Int(bg.position.y), xOffset: xOffset, speed: speed, direction: tempDirection)
            }
            if(floatDirection == Direction.left){
                floatDirection = Direction.right
            } else {
                floatDirection = Direction.left
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
            
            SpawnPickup(yPos: Int(bg.position.y))
            
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
    
    func SpawnPickup(yPos: Int){
        let rand = Int.random(in: 0 ... 25) //1 in 25 chance for a pickup every block
        if(rand == 0){
            let possibleXPoints = Array(stride(from: -320, to: 320, by: 64)) //possible x spawn points
            let xRand = Int.random(in: 0 ... 9) //random x position
            let xPos = possibleXPoints[xRand] //randomly choose a point from the array
            let pickup = Pickup(startPosition: CGPoint(x: xPos, y: yPos))
            addChild(pickup)
        }
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
    
    func OnLava(){
        onLava = true
         print("magma \(onLava)")
    }
    
    func OnPlatform(Obj: SKNode){
        onPlatform = true
        currentPlatform = Obj
        print("platform \(onPlatform)")
    }
}


//Collisions
//I dont know how to force magmafloat to always go before magma, since they "overlap" at the same time
extension GameScene: SKPhysicsContactDelegate{
    //Collision Functions
    //On Enter
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else {return}
        guard let nodeB = contact.bodyB.node else {return}
        
        if nodeA.name == "player"{
            collisionBetween(Player: nodeA, Obj: nodeB)
        }
        if nodeB.name == "player"{
            collisionBetween(Player: nodeB, Obj: nodeA)
        }
 
    }
    
    func collisionBetween(Player: SKNode, Obj: SKNode){

        if (Obj.name == "boulder"){
           destroy(object: Player)
           isPlayerAlive = false
        }

        //player and mfloat
        if (Obj.name == "magmafloat"){
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03){
                self.OnPlatform(Obj: Obj)
            }
        }

        //player and lava
        if(Obj.name == "magmabg"){
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05){
                self.OnLava()
            }
        }
        
        //Player and Shockwave Pickup
        if(Obj.name == "pickup"){
            print("pickup collide")
            remainingShockwaves += 1
            destroy(object: Obj)
        }
    }
    
    //On Exit
    func didEnd(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else {return}
        guard let nodeB = contact.bodyB.node else {return}
        
        if nodeA.name == "player" {
            endedCollision(Player: nodeA, Obj: nodeB)
        }
        if nodeB.name == "player" {
            endedCollision(Player: nodeB, Obj: nodeA)
        }
    }

    func endedCollision(Player: SKNode, Obj: SKNode){
        if(Obj.name == "magmabg"){
            onLava = false
            print("magma \(onLava)")
        }
        
        if (Obj.name == "magmafloat"){
            onPlatform = false
            currentPlatform = nil
            print("platform \(onPlatform)")
        }
    }
    
    func destroy(object: SKNode){
        object.removeFromParent()
    }
    
}
