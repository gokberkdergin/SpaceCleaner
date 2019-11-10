

import SpriteKit
import GameplayKit
import CoreMotion


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    var starField: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var score: Int = 0 {
        didSet {
            scoreLabel.text = " Score: \(score)"
        }
    }
    var gameTimer: Timer!
    var aliens = ["alien", "alien2", "alien3", "s1", "s2", "s3", "s4", "s5", "s6", "a1", "a2", "a3", "a4","a5", "a6","a7","a8","a9","a10"]
    
    let alienCathegory: UInt32 = 0x1 << 1
    let bulletCathegory: UInt32 = 0x1 << 0
    
    let motionManager = CMMotionManager()
    var xAccelerate: CGFloat = 0
    
    override func didMove(to view: SKView) {
        starField = SKEmitterNode(fileNamed: "Starfield")
        starField.position = CGPoint(x: 0, y: 1472)
        starField.advanceSimulationTime(10)
        self.addChild(starField)
        
        starField.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "shuttle")
       player.position = CGPoint(x: UIScreen.main.bounds.width / 2, y: 40)
        
        
        self.addChild(player)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 25
        scoreLabel.fontColor = UIColor.white
        scoreLabel.position = CGPoint(x: 75, y: 45)
        score = 0
        
        self.addChild(scoreLabel)
        
        var timeInterval = 0.75
        
        if UserDefaults.standard.bool(forKey: "hard") {
            timeInterval = 0.3
        }
        gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
    motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data:CMAccelerometerData?, error: Error!) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xAccelerate = CGFloat(acceleration.x) * 0.75 + self.xAccelerate * 0.25
            }
        }
    
    }
    override func didSimulatePhysics() {
        player.position.x += xAccelerate * 50
        
        if player.position.x < 0 {
            player.position = CGPoint(x: UIScreen.main.bounds.width  - player.size.width , y: player.position.y)
        } else if player.position.x > UIScreen.main.bounds.width {
            player.position = CGPoint(x: 20, y: player.position.y) }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var alienBody:SKPhysicsBody
        var bulletBody:SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            bulletBody = contact.bodyA
            alienBody = contact.bodyB
        } else {
            bulletBody = contact.bodyB
            alienBody = contact.bodyA
        }
        if (alienBody.categoryBitMask & alienCathegory) != 0 && (bulletBody.categoryBitMask & bulletCathegory) != 0 {
            collisionElements(bulletNode: bulletBody.node as! SKSpriteNode, alienNode: alienBody.node as! SKSpriteNode)
        }
    }
    func collisionElements(bulletNode: SKSpriteNode, alienNode: SKSpriteNode ) {
        let explosion = SKEmitterNode(fileNamed: "Vzriv")
        explosion?.position = alienNode.position
        self.addChild(explosion!)
        
        //self.run(SKAction.playSoundFileNamed("vzriv.mp3", waitForCompletion: false))
        
        bulletNode.removeFromParent()
        alienNode.removeFromParent()
        
        self.run(SKAction.wait(forDuration: 2)){
            explosion?.removeFromParent()
        }
        score += 15
    }
    
    @objc func addAlien(){
        aliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: aliens) as! [String]
        
        let alien = SKSpriteNode(imageNamed: aliens[0])
        let randomPos = GKRandomDistribution(lowestValue: 20, highestValue: Int(UIScreen.main.bounds.size.width - 20))
        let pos = CGFloat(randomPos.nextInt())
        alien.position = CGPoint(x: pos, y:UIScreen.main.bounds.size.height + alien.size.height)
        
        
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        alien.physicsBody?.isDynamic = true
        
        alien.physicsBody?.categoryBitMask = alienCathegory
        alien.physicsBody?.contactTestBitMask = bulletCathegory
        alien.physicsBody?.collisionBitMask =  0
        
        self.addChild(alien)
        
        let animDuration: TimeInterval = 6
        
        var actions = [SKAction]()
        actions.append(SKAction.move(to: CGPoint(x: pos, y: 0 - alien.size.height) , duration: animDuration))
        actions.append(SKAction.removeFromParent())
        
        alien.run(SKAction.sequence(actions))
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireBullet()
    }
    
    
    func fireBullet() {
        //self.run( SKAction.playSoundFileNamed("bullet.mp3", waitForCompletion: false))
        
        let bullet = SKSpriteNode(imageNamed: "torpedo")
        bullet.position = player.position
        bullet.position.y += 5
        
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width / 2)
        bullet.physicsBody?.isDynamic = true
       
        
        bullet.physicsBody?.categoryBitMask = bulletCathegory
        bullet.physicsBody?.contactTestBitMask =  alienCathegory
        bullet.physicsBody?.collisionBitMask =  0
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(bullet)
        
        let animDuration: TimeInterval = 0.3
        
        var actions = [SKAction]()
        actions.append(SKAction.move(to: CGPoint(x: player.position.x, y: UIScreen.main.bounds.size.height + bullet.size.height) , duration: animDuration))
        actions.append(SKAction.removeFromParent())
        
        bullet.run(SKAction.sequence(actions))
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
      
        guard let touch = touches.first else { return }
        
        var location = touch.location(in: self)
    
        
         player.position = location
    }
   
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
