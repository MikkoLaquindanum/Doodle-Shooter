//
//  ContentView.swift
//  scuffedAstroids v.6
//
//  Created by Mikko Laquindanum on 7/5/22.
//

import SwiftUI
import SpriteKit
import GameKit

class GameScene: SKScene, SKPhysicsContactDelegate, ObservableObject {
    
    let background = SKSpriteNode(imageNamed: "NewBackground")
    var player = SKSpriteNode()
    var playerFire = SKSpriteNode()
    var rocks = SKSpriteNode()
    
    var bossOne = SKSpriteNode()
    var bossOneFire = SKSpriteNode()
    
    @Published var gameOver = false
    private let mViewModel = MainMenuViewModel()
    
    var userScore = 0
    var scoreLabel  = SKLabelNode()
    
    var liveArray = [SKSpriteNode]()
    
    var fireTimer = Timer()
    var rockTimer = Timer()
    
    var bossOneFireTimer = Timer()
    
    var bossOneLives = 50
    
    struct CBitmask {
        static let playerShip: UInt32 = 0b1 // 1
        static let playerFire: UInt32 = 0b10 // 2
        static let incomingRocks: UInt32 = 0b100 // 4
        static let bossOne: UInt32 = 0b1000 // 8
        static let bossOneFire: UInt32 = 0b10000
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        scene?.size = CGSize(width: 750, height: 1335)
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.setScale(0.9)
        background.zPosition = 1
        background.alpha = 0.6
        addChild(background)
        
        makePlayer(playerCh: 2)
        
        fireTimer = .scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(playerFireFunction), userInfo: nil, repeats: true)
        
        rockTimer = .scheduledTimer(timeInterval: 0.65, target: self, selector: #selector(makeRocks), userInfo: nil, repeats: true)
        
        scoreLabel.text = "Score: \(userScore)"
        scoreLabel.fontName = "AmericanTypewriter"
        scoreLabel.fontSize = 50
        scoreLabel.fontColor = .black
        scoreLabel.zPosition = 10
        scoreLabel.position = CGPoint(x: size.width / 2 + 250, y: size.height / 1.15)
        addChild(scoreLabel)
        
        addLives(lives: 3)
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactA : SKPhysicsBody
        let contactB : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            contactA = contact.bodyA
            contactB = contact.bodyB
        } else {
            contactA = contact.bodyB
            contactB = contact.bodyA
        }
        
        if contactA.categoryBitMask == CBitmask.playerFire && contactB.categoryBitMask == CBitmask.incomingRocks {
            
            updateScore()
            
            playerFireHitRock(fires: contactA.node as! SKSpriteNode, anotherRock: contactB.node as! SKSpriteNode)
            
            if userScore == 69 {
                makeBossOne()
                rockTimer.invalidate()
                bossOneFireTimer = Timer.scheduledTimer(timeInterval: 0.70, target: self, selector: #selector(bossOneFireFunc), userInfo: nil, repeats: true)
            }
            
        }
        
        if contactA.categoryBitMask == CBitmask.playerShip && contactB.categoryBitMask == CBitmask.incomingRocks {
            
            player.run(SKAction.repeat(SKAction.sequence([SKAction.fadeOut(withDuration: 0.1), SKAction.fadeIn(withDuration: 0.1)]), count: 8))
            
            contactB.node?.removeFromParent()
            
            if let live1 = childNode(withName: "live1") {
                live1.removeFromParent()
            } else if let live2 = childNode(withName: "live2") {
                live2.removeFromParent()
            } else if let live3 =  childNode(withName: "live3") {
                live3.removeFromParent()
                player.removeFromParent()
                fireTimer.invalidate()
                rockTimer.invalidate()
                
                let explo = SKEmitterNode(fileNamed: "Explosions")
                explo!.particleSize = CGSize(width: 300, height: 300)
                explo?.position = player.position
                explo?.zPosition = 5
                addChild(explo!)
                
                gameOverFunc()
            }
            
        }
        
        if contactA.categoryBitMask == CBitmask.playerFire && contactB.categoryBitMask == CBitmask.bossOne {
            
            let explo = SKEmitterNode(fileNamed: "Explosions")
            explo!.particleSize = CGSize(width: 200, height: 200)
            explo?.position = contactA.node!.position
            explo?.zPosition = 5
            addChild(explo!)
            
            contactA.node?.removeFromParent()
            
            bossOneLives -= 1
            
            if bossOneLives == 0 {
                
                let explo = SKEmitterNode(fileNamed: "Explosions")
                explo!.particleSize = CGSize(width: 300, height: 300)
                explo?.position = bossOne.position
                explo?.zPosition = 5
                addChild(explo!)
                
                contactB.node?.removeFromParent()
                bossOneFireTimer.invalidate()
                rockTimer = Timer.scheduledTimer(timeInterval: 0.49, target: self, selector: #selector(makeRocks), userInfo: nil, repeats: true)
            }
            
        }
        
        if contactA.categoryBitMask == CBitmask.playerShip && contactB.categoryBitMask == CBitmask.bossOneFire {
            
            player.run(SKAction.repeat(SKAction.sequence([SKAction.fadeOut(withDuration: 0.1), SKAction.fadeIn(withDuration: 0.1)]), count: 8))
            
            contactB.node?.removeFromParent()
            
            if let live1 = childNode(withName: "live1") {
                live1.removeFromParent()
            } else if let live2 = childNode(withName: "live2") {
                live2.removeFromParent()
            } else if let live3 =  childNode(withName: "live3") {
                live3.removeFromParent()
                player.removeFromParent()
                fireTimer.invalidate()
                bossOneFireTimer.invalidate()
                
                let explo = SKEmitterNode(fileNamed: "Explosions")
                explo!.particleSize = CGSize(width: 300, height: 300)
                explo?.position = player.position
                explo?.zPosition = 5
                addChild(explo!)
                
                gameOverFunc()
                
            }
        }
        
        if contactA.categoryBitMask == CBitmask.playerShip && contactB.categoryBitMask == CBitmask.bossOne {
            
            player.run(SKAction.repeat(SKAction.sequence([SKAction.fadeOut(withDuration: 0.1), SKAction.fadeIn(withDuration: 0.1)]), count: 8))
            
            if let live1 = childNode(withName: "live1") {
                live1.removeFromParent()
            } else if let live2 = childNode(withName: "live2") {
                live2.removeFromParent()
            } else if let live3 =  childNode(withName: "live3") {
                live3.removeFromParent()
                player.removeFromParent()
                fireTimer.invalidate()
                bossOneFireTimer.invalidate()
                
                let explo = SKEmitterNode(fileNamed: "Explosions")
                explo!.particleSize = CGSize(width: 300, height: 300)
                explo?.position = player.position
                explo?.zPosition = 5
                addChild(explo!)
                
                gameOverFunc()
                
            }
        }
        
    }
    
    func playerHitRock(players: SKSpriteNode, bossLazer: SKSpriteNode) {
        players.removeFromParent()
        bossLazer.removeFromParent()
        
        fireTimer.invalidate()
        bossOneFireTimer.invalidate()
        
        let explo = SKEmitterNode(fileNamed: "Explosions")
        explo!.particleSize = CGSize(width: 300, height: 300)
        explo?.position = players.position
        explo?.zPosition = 5
        addChild(explo!)
        
    }
    
    func playerHitRock(players: SKSpriteNode, anotherRock: SKSpriteNode) {
        players.removeFromParent()
        anotherRock.removeFromParent()
        
        fireTimer.invalidate()
        rockTimer.invalidate()
        
        let explo = SKEmitterNode(fileNamed: "Explosions")
        explo!.particleSize = CGSize(width: 300, height: 300)
        explo?.position = players.position
        explo?.zPosition = 5
        addChild(explo!)
        
    }
    
    func playerFireHitRock(fires: SKSpriteNode, anotherRock: SKSpriteNode) {
        fires.removeFromParent()
        anotherRock.removeFromParent()
        
        let explo = SKEmitterNode(fileNamed: "Explosions")
        explo?.position = anotherRock.position
        explo?.zPosition = 5
        addChild(explo!)
        
    }
    
    func addLives(lives: Int) {
        for i in 1...lives {
            let live = SKSpriteNode(imageNamed: "ship")
            live.setScale(1.0)
            live.position = CGPoint(x: CGFloat(i) * live.size.width + 10, y: size.height - live.size.height - 20)
            live.zPosition = 10
            live.name = "live\(i)"
            liveArray.append(live)
            addChild(live)
            
        }
    }
    
    func makePlayer(playerCh: Int) {
        var shipName = ""
        
        switch playerCh {
        case 1:
            shipName = "ship"
            
        default:
            shipName = "BetterShip"
        }
        
        player = .init(imageNamed: shipName)
        player.size = CGSize(width: 115, height: 115)
        player.position = CGPoint(x: size.width / 2, y: 120)
        player.zPosition = 10
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = CBitmask.playerShip
        player.physicsBody?.contactTestBitMask = CBitmask.incomingRocks
        player.physicsBody?.collisionBitMask = CBitmask.incomingRocks
        addChild(player)
        
    }
    
    func makeBossOne() {
        
        bossOne = .init(imageNamed: "boss")
        bossOne.position  = CGPoint(x: size.width / 2, y: size.height + bossOne.size.height)
        bossOne.zPosition = 10
        bossOne.setScale(1.1)
        bossOne.physicsBody = SKPhysicsBody(rectangleOf: bossOne.size)
        bossOne.physicsBody?.affectedByGravity = false
        bossOne.physicsBody?.categoryBitMask = CBitmask.bossOne
        bossOne.physicsBody?.contactTestBitMask = CBitmask.playerShip | CBitmask.playerFire
        bossOne.physicsBody?.collisionBitMask = CBitmask.playerFire
        
        let move1 = SKAction.moveTo(y: size.height / 1.3, duration: 2)
        let move2 = SKAction.moveTo(x: size.width - bossOne.size.width / 2, duration: 2)
        let move3 = SKAction.moveTo(x: 0 + bossOne.size.width / 2, duration: 1)
        let move4 = SKAction.moveTo(x: size.width / 2, duration: 2)
        let move5 = SKAction.fadeOut(withDuration: 0.2)
        let move6 = SKAction.fadeIn(withDuration: 0.2)
        let move7 = SKAction.moveTo(y: 0 + bossOne.size.height / 2, duration: 0.75)
        let move8 = SKAction.moveTo(y: size.height / 1.3, duration: 2)
        
        let action  = SKAction.repeat(SKAction.sequence([move5, move6]), count: 6)
        let repeatForever = SKAction.repeatForever(SKAction.sequence([move2, move3, move4, action, move7, move8]))
        let sequence = SKAction.sequence([move1, repeatForever])
        
        bossOne.run(sequence)
        
        addChild(bossOne)
    }
    
    @objc func bossOneFireFunc() {
        
        bossOneFire = .init(imageNamed: "BossLazer")
        bossOneFire.position = bossOne.position
        bossOneFire.zPosition = 5
        bossOneFire.setScale(1.5)
        bossOneFire.physicsBody = SKPhysicsBody(rectangleOf: bossOneFire.size)
        bossOneFire.physicsBody?.affectedByGravity = false
        bossOneFire.physicsBody?.categoryBitMask = CBitmask.bossOneFire
        bossOneFire.physicsBody?.contactTestBitMask = CBitmask.playerShip
        bossOneFire.physicsBody?.collisionBitMask = CBitmask.playerShip
        
        let move1 = SKAction.moveTo(y: 0 - bossOneFire.size.height, duration: 1.5)
        let removeAction = SKAction.removeFromParent()
        
        let sequence = SKAction.sequence([move1, removeAction])
        bossOneFire.run(sequence)
        
        addChild(bossOneFire)
        
    }
    
    @objc func playerFireFunction() {
        playerFire = .init(imageNamed: "lazer")
        playerFire.size = CGSize(width: 20, height: 35)
        playerFire.position = player.position
        playerFire.zPosition = 3
        playerFire.physicsBody = SKPhysicsBody(rectangleOf: playerFire.size)
        playerFire.physicsBody?.affectedByGravity = false
        playerFire.physicsBody?.categoryBitMask = CBitmask.playerFire
        playerFire.physicsBody?.contactTestBitMask = CBitmask.incomingRocks | CBitmask.bossOne
        playerFire.physicsBody?.collisionBitMask = CBitmask.incomingRocks | CBitmask.bossOne
        
        addChild(playerFire)
        
        let moveAction = SKAction.moveTo(y: 1400, duration: 1)
        let deleteAction = SKAction.removeFromParent()
        let combine = SKAction.sequence([moveAction,deleteAction])
        
        playerFire.run(combine)
        
    }
    
    @objc func makeRocks() {
        let randomNumber = GKRandomDistribution(lowestValue: 50, highestValue: 700)
        
        rocks = .init(imageNamed: "rock2")
        rocks.size = CGSize(width: 150, height: 150)
        rocks.position = CGPoint(x: randomNumber.nextInt(), y: 1400)
        rocks.zPosition = 5
        rocks.setScale(0.7)
        rocks.physicsBody = SKPhysicsBody(rectangleOf: rocks.size)
        rocks.physicsBody?.affectedByGravity = false
        rocks.physicsBody?.categoryBitMask = CBitmask.incomingRocks
        rocks.physicsBody?.contactTestBitMask = CBitmask.playerShip | CBitmask.playerFire
        rocks.physicsBody?.collisionBitMask = CBitmask.playerShip | CBitmask.playerFire
        addChild(rocks)
        
        let moveAction = SKAction.moveTo(y: -100, duration: 2)
        let deleteAction = SKAction.removeFromParent()
        let combine = SKAction.sequence([moveAction,deleteAction])
        
        rocks.run(combine)
        
    }
    
    func updateScore() {
        userScore += 1
        
        scoreLabel.text = "Score: \(userScore)"
    }
    
    override func  touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            player.position.x = location.x
        }
    }
    
    func gameOverFunc() {
        removeAllChildren()
        gameOver = true
        
        let gameOverLabel = SKLabelNode()
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 90
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        mViewModel.compareScores(currentScore: userScore)
        
        
        addChild(gameOverLabel)
    }
}

struct ContentView: View {
    @ObservedObject var scene = GameScene()
    
    var body: some View {
        NavigationView {
            HStack {
                ZStack {
                    SpriteView(scene: scene)
                        .ignoresSafeArea()
                    
                    if scene.gameOver == true {
                        NavigationLink {
                            MainMenu().navigationBarHidden(true)
                                .navigationBarBackButtonHidden(true)
                        }  label: {
                            Text("Main Menu")
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
