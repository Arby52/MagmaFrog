//
//  GameScene.swift
//  MagmaFrog
//
//  Created by RITSON, BEN on 23/11/2019.
//  Copyright © 2019 RITSON, BEN. All rights reserved.
//

import SpriteKit


class GameScene: SKScene {
    let player = SKSpriteNode(imageNamed: "frog")
    let rockbg = SKSpriteNode(imageNamed: "rockbg")
    
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
    }
}
