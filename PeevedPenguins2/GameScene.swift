//
//  GameScene.swift
//  PeevedPenguins2
//
//  Created by Cappillen on 6/22/17.
//  Copyright © 2017 Cappillen. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //Game UI Objects
    var catapultArm: SKSpriteNode!
    var cameraNode: SKCameraNode!
    //Add an optional camera target
    var cameraTarget: SKSpriteNode?
    //UI Connections
    var buttonRestart: MSButtonNode!
    var catapult: SKSpriteNode!
    var cantileverNode: SKSpriteNode!
    var touchNode: SKSpriteNode!
    //Physics helpers
    var touchJoint: SKPhysicsJointSpring?
    var penguinJoint: SKPhysicsJointPin?
    
    override func didMove(to view: SKView) {
        //Set up scene here
        
        catapultArm = childNode(withName: "catapultArm") as! SKSpriteNode
        catapult = childNode(withName: "catapult") as! SKSpriteNode
        cantileverNode = childNode(withName: "cantileverNode") as! SKSpriteNode
        touchNode = childNode(withName: "touchNode") as! SKSpriteNode
        
        //Create the new camera ndoe
        cameraNode = childNode(withName: "cameraNode") as! SKCameraNode
        self.camera = cameraNode
        
        //Set physics delegate
        physicsWorld.contactDelegate = self
        //Set reference to the UI Connections
        buttonRestart = self.childNode(withName: "//buttonRestart") as! MSButtonNode
        
        //Selected handler
        buttonRestart.selectedHandler = {
            guard let scene = GameScene.level(1) else {
                print("Level 1 is missing")
                return
            }
            
            scene.scaleMode = .aspectFill
            view.presentScene(scene)
        }
        
        setUpCatapult()
    }
    
    func setUpCatapult() {
        //Pin joint
        var pinLocation = catapultArm.position
        pinLocation.x += -10
        pinLocation.y += -70
        let catapultJoint = SKPhysicsJointPin.joint(withBodyA: catapult.physicsBody!, bodyB: catapultArm.physicsBody!, anchor: pinLocation)
        physicsWorld.add(catapultJoint)
        
        //Spring joint catapult arm and cantilever ode
        var anchorAPosition = catapultArm.position
        anchorAPosition.x += 0
        anchorAPosition.y += 50
        let catapultSpringJoint = SKPhysicsJointSpring.joint(withBodyA: catapultArm.physicsBody!, bodyB: cantileverNode.physicsBody!, anchorA: anchorAPosition, anchorB: cantileverNode.position)
        physicsWorld.add(catapultSpringJoint)
        catapultSpringJoint.frequency = 6
        catapultSpringJoint.damping = 0.5
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Called when a touch begins
        let touch = touches.first!              //Get the first touch
        let location = touch.location(in: self) //Find the location of that touch in this view
        let nodeAtPoint = atPoint(location)     //Find the node at that location
        if nodeAtPoint.name == "catapultArm" {  //If the touched node is named "catapultAr" do...
            touchNode.position = location
            touchJoint = SKPhysicsJointSpring.joint(withBodyA: touchNode.physicsBody!, bodyB: catapultArm.physicsBody!, anchorA: location, anchorB: location)
            physicsWorld.add(touchJoint!)
            
            //Creating the penguin
            let penguin = Penguin()
            addChild(penguin)
            penguin.position.x += catapultArm.position.x + 30
            penguin.position.y += catapultArm.position.y + 40
            penguin.physicsBody?.usesPreciseCollisionDetection = true
            penguinJoint = SKPhysicsJointPin.joint(withBodyA: catapultArm.physicsBody!, bodyB: penguin.physicsBody!, anchor: penguin.position)
            physicsWorld.add(penguinJoint!)
            cameraTarget = penguin
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        touchNode.position = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Check for a touch joint then remove it
        if let touchJoint = touchJoint {
            physicsWorld.remove(touchJoint)
        }
        
        //Check for a penguin joint then remove it
        if let penguinJoint = penguinJoint {
            physicsWorld.remove(penguinJoint)
        }
        
        //Check if there is a penguin assigned to the cameraTarget
        guard let penguin = cameraTarget else {
            return
        }
        
        //Generate a vector and a force based on the angle of the arm
        let force: CGFloat = 250
        let r = catapultArm.zRotation
        let dx = cos(r) * force
        let dy = sin(r) * force
        let v = CGVector(dx: dx, dy: dy)
        penguin.physicsBody?.applyImpulse(v)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        moveCamera()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        //Physics contact delegate implementaion
        //Get reference to the bodies involved in hte collision
        let contactA: SKPhysicsBody = contact.bodyA
        let contactB: SKPhysicsBody = contact.bodyB
        
        //Get reference to the bodies involved in the collsion
        let nodeA = contactA.node as! SKSpriteNode
        let nodeB = contactB.node as! SKSpriteNode
        
        //Check if either physics bodies was a seal
        if contactA.categoryBitMask ==  2 || contactB.categoryBitMask == 2 {
            
            //Was the collsion more than a gentle nudge
            if contact.collisionImpulse > 5.0 {
                //Kill the seal
                if contactA.categoryBitMask == 2 { removeSeal(node: nodeA) }
                if contactB.categoryBitMask == 2 { removeSeal(node: nodeB) }
            }
        }

    }
    
    func removeSeal(node: SKNode) {
        //Seal death
        
        //load the particle effects
        let particles = SKEmitterNode(fileNamed: "Poof")
        //Position particles at the Seal node if you moved seal to an sks, this will need to be node.convert(node.position,to: self), not node.position
        particles?.position = node.convert(node.position, to: self)
        //Add particles to scene
        addChild(particles!)
        let wait = SKAction.wait(forDuration: 5)
        let removeParticles = SKAction.removeFromParent()
        let seq = SKAction.sequence([wait, removeParticles])
        particles?.run(seq)
        
        //Create our hero death action
        let sealDeath = SKAction.run({
            //Remove seal node from scene
            node.removeFromParent()
        })
        self.run(sealDeath)
        
        //Play SFX
        let sound = SKAction.playSoundFileNamed("sfx_seal", waitForCompletion: false)
        self.run(sound)
    }
    
    //Move the camera but clamp it when it gets out of the screen
    func moveCamera() {
        guard let cameraTarget = cameraTarget else {
            return
        }
        let targetX = cameraTarget.position.x
        let x = clamp(value: targetX, lower: 0, upper: 392)
        cameraNode.position.x = x
    }
    
    //Make a class method to load levels
    class func level(_ levelNumber: Int) -> GameScene? {
        guard let scene = GameScene(fileNamed: "Level_\(levelNumber)") else {
            return nil
        }
        scene.scaleMode = .aspectFill
        return scene
    }
}

func clamp<T: Comparable>(value: T, lower: T, upper: T) -> T {
    return min(max(value, lower), upper)
}
