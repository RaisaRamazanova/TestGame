//
//  GameScene.swift
//  Example
//
//  Created by Пользователь on 30.08.2020.
//  Copyright © 2020 Raisat Ramazanova. All rights reserved.
//


import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var backgroundNode: SKNode!
    var man: SKSpriteNode!
    var scoreLabel:SKLabelNode!
    
    var score:Int = 0 {
        didSet{
            scoreLabel.text = "Счет: \(score)"
        }
    }
    
    var gameTimer:Timer!
    var aliens = ["bird"]
    
    let alienCategory:UInt32 = 0x1 << 1
    let bulletCategory:UInt32 = 0x1 << 0
    
    override func didMove(to view: SKView) {
                
        backgroundNode = self.childNode(withName: "background")!
        man = self.childNode(withName: "man") as? SKSpriteNode
        
        let moveBackground = SKAction.move(by: CGVector(dx: -500, dy: 0), duration: 10)
        
        backgroundNode.run(moveBackground)
        
        
        self.physicsWorld.contactDelegate = self
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -1)
        self.physicsWorld.contactDelegate = self
        
        scoreLabel = SKLabelNode(text: "Счет: 0")
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = UIColor.black
        scoreLabel.position = CGPoint(x: -200, y: 130)
        score = 0
        self.addChild(scoreLabel)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var alienBody:SKPhysicsBody
        var bulletBody:SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            alienBody = contact.bodyB
            bulletBody = contact.bodyA
        }else {
            alienBody = contact.bodyA
            bulletBody = contact.bodyB
        }
        
        if (alienBody.categoryBitMask & alienCategory) != 0 && (bulletBody.categoryBitMask & bulletCategory) != 0 {
            collisionElements(bulletNode: bulletBody.node as! SKSpriteNode, alianNode: alienBody.node as! SKSpriteNode)
        }
    
    }
    
    
    func collisionElements(bulletNode:SKSpriteNode, alianNode:SKSpriteNode) {
        let explosion = SKEmitterNode(fileNamed: "Fire.sks")
        explosion?.position = alianNode.position
        self.addChild(explosion!)
        
        self.run(SKAction.playSoundFileNamed("vzryv.mp3", waitForCompletion: false))
        
        bulletNode.removeFromParent()
        alianNode.removeFromParent()
        
        self.run(SKAction.wait(forDuration: 2)) {
            explosion?.removeFromParent()
        }
        
        score += 5
    }
    
    @objc func addAlien () {
        aliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: aliens) as! [String]
        
        let alien = SKSpriteNode(imageNamed: aliens[0])
        let randomPos = GKRandomDistribution(lowestValue: 0, highestValue: 160)
        let pos = CGFloat(randomPos.nextInt())
        alien.position = CGPoint(x: 800, y: pos)
        alien.setScale(0.07)
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        alien.physicsBody?.isDynamic = true
        
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = bulletCategory
        alien.physicsBody?.collisionBitMask = 0
        
        self.addChild(alien)
        
        let animDuration:TimeInterval = 6
        
        var actions = [SKAction]()
        actions.append(SKAction.move(to: CGPoint(x: -320, y: pos), duration: animDuration))
        actions.append(SKAction.removeFromParent())
        
        alien.run(SKAction.sequence(actions))
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        man.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 0.1))
        fireBullet()
    }

    
    func fireBullet() {
        self.run(SKAction.playSoundFileNamed("vzryv.mp3", waitForCompletion: false))
        
        let bullet = SKSpriteNode(imageNamed: "2")
        bullet.position = man.position
        bullet.position.x += 100
        bullet.setScale(0.5)
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width / 2)
        bullet.physicsBody?.isDynamic = true
        
        bullet.physicsBody?.categoryBitMask = bulletCategory
        bullet.physicsBody?.contactTestBitMask = alienCategory
        bullet.physicsBody?.collisionBitMask = 0
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(bullet)
        
        let animDuration:TimeInterval = 0.3
        
        var actions = [SKAction]()
        actions.append(SKAction.move(to: CGPoint(x: 320, y: man.position.y), duration: animDuration))
        actions.append(SKAction.removeFromParent())
        
        bullet.run(SKAction.sequence(actions))

    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
