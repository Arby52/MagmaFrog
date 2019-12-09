//
//  GameScene.swift
//  MagmaFrog
//
//  Created by RITSON, BEN on 23/11/2019.
//  Copyright © 2019 RITSON, BEN. All rights reserved.
//

import SpriteKit
import CoreMotion
import AudioToolbox

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
    var invalidateTimers = false
    
    //Motion Manager
    let motionManager = CMMotionManager()
    
    //Userdefaults saving
    let defaults = UserDefaults.standard
    
    //Labels
    var scoreLabel: SKLabelNode!
    var score: Int = 0{
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
    
    var highscoreLabel: SKLabelNode!
    var highscore: Int = 0{
        didSet{
            highscoreLabel.text = "Highscore: \(highscore)"
        }
    }
    
    var resetButton: ResetButton? = nil
    
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
                if (data.userAcceleration.z < -2 && self!.remainingShockwaves > 0 && !(self!.shockwaveBool)){
                    self!.Shockwave()
                    self!.shockwaveBool = true //Bool used to make sure only the first value is used
                }
            
                if(data.userAcceleration.z > -1.5 && self!.shockwaveBool){
                    self!.shockwaveBool = false //Bool reset once userAcceleration normailsies again
                }
            }
        }
                
        SpawnEverything()
    }
        
    //Update and Input functions
    override func update(_ currentTime: TimeInterval) {
        if(onPlatform && currentPlatform != nil){
            player.position.x = (currentPlatform?.position.x)!
        }
        
        //go off left screen
        if(player.position.x - player.size.width/2 < frame.minX){
            player.removeFromParent()
            isPlayerAlive = false
            GameOver()
        }
        //go off right screen
        if(player.position.x + player.size.width/2 > frame.maxX){
            player.removeFromParent()
            isPlayerAlive = false
            GameOver()
        }
        
        if(onLava && !onPlatform && (currentPlatform == nil) && isPlayerAlive){
            player.removeFromParent()
            isPlayerAlive = false
            GameOver()
        }
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
                        if !(Int(floor(player.position.x - player.size.width/2) - moveStep) < Int(frame.minX)){
                            player.position.x -= moveStep
                        }
                        break
                        
                    case .right:
                        if !(Int(floor(player.position.x + player.size.width/2) + moveStep) > Int(frame.maxX)){
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
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    func GameOver(){
        scoreLabel.removeFromParent()
        shockwaveLabel.removeFromParent()
        
        //If current score is bigger than saved score, replace saved score
        if(score > defaults.integer(forKey: "Score")){ //If Score has not been added yet, it returns 0.
            defaults.set(score, forKey: "Score")
        }
        
        //Create highscore label
        highscoreLabel = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        highscoreLabel.text = "Highscore: \(defaults.integer(forKey: "Score"))"
        highscoreLabel.horizontalAlignmentMode = .center
        highscoreLabel.position = CGPoint(x:0, y:150)
        highscoreLabel.fontSize = 60
        highscoreLabel.zPosition = 10
        addChild(highscoreLabel)
        
        //Create reset button
        resetButton = ResetButton(defaultButtonImage: "resetButton", activeButtonImage: "resetButtonDown", buttonAction: restartGame)
        
        resetButton!.position = CGPoint(x:0, y:0)
        resetButton!.zPosition = 10
        addChild(resetButton!)
    }
    
    func restartGame(){
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
        }
    }
    
    func SpawnEverything(){
        //Spawn Objects
        player.position = CGPoint(x: 0, y: frame.minY+96)
        addChild(player)
        
        //Spawn Starting Background
        currentBlocks = 0
        invalidateTimers = false
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
            let bg = Background(texName: "safebg", objName: "spawnbg")
            bg.position = CGPoint(x:0, y: CGFloat((frame.minY + 32) + CGFloat(currentBlocks*64)))
            addChild(bg)
            currentBlocks+=1
        }
        
        return currentBlocks
    }
    
    func SpawnSafeBG(currentBlocks: inout Int) -> Int{
        let blockAmount = Int.random(in: 2...2)
        for _ in 1...blockAmount{
            let bg = Background(texName: "safebg", objName: "safebg")
            bg.position = CGPoint(x:0, y: CGFloat((frame.minY + 32) + CGFloat(currentBlocks*64)))
            addChild(bg)
            SpawnPickup(yPos: Int(bg.position.y))
            currentBlocks+=1
        }
        
        return currentBlocks
    }
    
    func SpawnMagmaBG(currentBlocks: inout Int) -> Int{
        let blockAmount = Int.random(in: 2...4)
        for _ in 1...blockAmount{
            let bg = Background(texName: "magmabg", objName: "magmabg")
            bg.position = CGPoint(x:0, y: CGFloat((frame.minY + 32) + CGFloat(currentBlocks*64)))
            addChild(bg)
            
            SpawnPickup(yPos: Int(bg.position.y))
            
            //Spawning Magma Floats
            let xOffset = Int.random(in: 0 ... 250)
            let timer = Double.random(in: 2.5 ... 4)
            let speed = Int.random(in: 65 ... 200)

            //spawn magmaFloats in on the screen so they're in place on spawn. Randomise direction.
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
            Timer.scheduledTimer(withTimeInterval: timer, repeats: true) {timer in
                if (self.invalidateTimers){
                    timer.invalidate()
                } else {
                    self.SpawnMagmaFloat(floatStartY: Int(bg.position.y), xOffset: xOffset, speed: speed, direction: tempDirection)
                }
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
            let bg = Background(texName: "rockbg", objName: "rockbg")
            bg.position = CGPoint(x:0, y: CGFloat((frame.minY + 32) + CGFloat(currentBlocks*64)))
            addChild(bg)
            
            SpawnPickup(yPos: Int(bg.position.y))
            
            let xOffset = Int.random(in: 0 ... 500)
            let timer = Double.random(in: 1.5 ... 4)
            let speed = Int.random(in: 50 ... 350)
            let dirInt = Int.random(in: 1 ... 2) //do not change
            var direction: Direction
            if (dirInt == 1){
                direction = Direction.left
            } else {
                direction = Direction.right
            }
            
            //spawn boulders in on the screen so they're in place on spawn
            if(floatDirection == Direction.left){
                var fillSpawnPoint = (frame.maxX + CGFloat(xOffset))
                repeat{
                    let boulder = BoulderNode(startPosition: CGPoint(x: CGFloat(fillSpawnPoint), y: CGFloat( bg.position.y)), movSpeed: CGFloat(speed), direction: direction)
                    addChild(boulder)
                    fillSpawnPoint -= (CGFloat(timer) * CGFloat(speed))
                } while fillSpawnPoint >= frame.minX
            }
            else{
                var fillSpawnPoint = (frame.minX - CGFloat(xOffset))
                repeat{
                    let boulder = BoulderNode(startPosition: CGPoint(x: CGFloat(fillSpawnPoint), y: CGFloat( bg.position.y)), movSpeed: CGFloat(speed), direction: direction)
                    addChild(boulder)
                   fillSpawnPoint += (CGFloat(timer) * CGFloat(speed))
                } while fillSpawnPoint <= frame.maxX
            }
             
            //Spawn on timer
            Timer.scheduledTimer(withTimeInterval: timer, repeats: true) {timer in
                if (self.invalidateTimers){
                    timer.invalidate()
                } else {
                    self.SpawnBoulder(boulderStartY: Int(bg.position.y), xOffset: xOffset, speed: speed, direction: direction)
                }
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
    
    func SpawnBoulder(boulderStartY: Int, xOffset: Int, speed: Int, direction: Direction){
        
        let boulderStartY = boulderStartY
        var boulderStartX = frame.maxX + CGFloat(xOffset)
        if (direction == Direction.left){
            boulderStartX = frame.maxX + CGFloat(xOffset)
        } else {
            boulderStartX = frame.minX - CGFloat(xOffset)
        }
        
        let boulder = BoulderNode(startPosition: CGPoint(x: CGFloat(boulderStartX), y: CGFloat( boulderStartY)), movSpeed: CGFloat(speed), direction: direction)
        addChild(boulder)
    }
    
    func OnLava(){
        onLava = true
    }
    
    func OnPlatform(Obj: SKNode){
        onPlatform = true
        currentPlatform = Obj
    }
}


//Collisions
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
            //Delay on entering platform so the player can leave the previous one first. This needs to go before entering lava.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03){
                self.OnPlatform(Obj: Obj)
            }
        }

        //player and lava
        if(Obj.name == "magmabg"){
            //Delay entering lava so the player can enter a new float first.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05){
                self.OnLava()
            }
        }
        
        //Player and Shockwave Pickup
        if(Obj.name == "pickup"){
            if(remainingShockwaves <= 2){ //cap at 3
                remainingShockwaves += 1
            }
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
        }
        
        if (Obj.name == "magmafloat"){
            onPlatform = false
            currentPlatform = nil
        }
    }
    
    func destroy(object: SKNode){
        if(object.name == "player"){
            GameOver()
        }
        object.removeFromParent()
    }
    
}
