//
//  MainMenu.swift
//  PeevedPenguins2
//
//  Created by Cappillen on 6/23/17.
//  Copyright © 2017 Cappillen. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenu: SKScene {
    
    //UI Connections
    var buttonPlay: MSButtonNode!
    
    override func didMove(to view: SKView) {
        //Set up scene here
        
        //Adding background music
        let song = SKAudioNode(fileNamed: "shooting")
        song.autoplayLooped = true
        addChild(song)
        
        //Set UI Connections
        buttonPlay = self.childNode(withName: "buttonPlay") as! MSButtonNode
        
        buttonPlay.selectedHandler = {
            song.autoplayLooped = false
            self.loadGame()
        }
        
        //Add a snow emmiter
        let snow = SKEmitterNode(fileNamed: "Snowy")
        snow?.position = CGPoint(x: 120, y: 280)
        let snow2 = SKEmitterNode(fileNamed: "Snowy")
        snow2?.position = CGPoint(x: 350, y: 280)
        addChild(snow!)
        addChild(snow2!)
        
    }
    
    func loadGame() {
        //Grab reference to our sprite kit view
        
        //1) grab reference to our spriteKit view
        guard let skView = self.view as SKView! else {
            print("could not get SKView")
            return
        }
        //2) Load game scene
        guard let scene = GameScene.level(1) else {
            print("Could not make GameScene, check the name is spelled correctly")
            return
        }
        //Enusre the aspect mode is correct
        scene.scaleMode = .aspectFill
        
        //Show Debug
        skView.showsPhysics = true
        skView.showsDrawCount = true
        skView.showsFPS = true
        
        //4) 
        skView.presentScene(scene)
        
    }
}
