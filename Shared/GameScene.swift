import SpriteKit

class GameScene: SKScene {
  
  private enum State: Comparable {
    case notPlaying
    case waiting(start: TimeInterval)
    case playing(lastTime: TimeInterval, lastCreatedBallTime: TimeInterval)
    case gameOver
  }
  
  private var state: State = .notPlaying
  
  private var score: Int = 0
  private var lastLocation: CGFloat?
  private var maxPosition: CGFloat = 0
  
  private var startPostion : SKNode!
  private var endPostion : SKNode!
  private var scoreLabel : SKLabelNode!
  private var slider : SKSpriteNode!
  private var ballsTemplate : [SKNode] = []
  private var balls : [SKNode] = []
  private var emitter: SKEmitterNode?
  
  class func make() -> GameScene {
    guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
      print("Failed to load GameScene.sks")
      abort()
    }
    scene.scaleMode = .aspectFill
    scene.physicsWorld.contactDelegate = scene
    return scene
  }
  
  override func didMove(to view: SKView) {
    setUp()
  }
  
  override func update(_ currentTime: TimeInterval) {
    switch state {
      case .notPlaying:
        state = .waiting(start: currentTime)
        return
      case .waiting(let start) where currentTime - start < 1.5:
        return
      case .waiting(_):
        state = .playing(lastTime: currentTime, lastCreatedBallTime: 0)
      case .playing(let lastTime, var lastCreatedBallTime):
        let delta = currentTime - lastTime
        let offset = CGFloat(delta) * 300
        balls.forEach { $0.position.y -= offset }
        
        if currentTime - lastCreatedBallTime > 0.5 {
          lastCreatedBallTime = currentTime
          let ball = ballsTemplate[Int(arc4random_uniform(3))].copy() as! SKShapeNode
          ball.position = startPostion.position
          balls.append(ball)
          addChild(ball)
        }
        state = .playing(lastTime: currentTime, lastCreatedBallTime: lastCreatedBallTime)
      case .gameOver:
        let transition = SKTransition.doorway(withDuration: 1)
        let scene = StartScene.make()
        scene.score = score
        view?.presentScene(scene, transition: transition)
        return
    }
  }
  
  private func setUp() {
    physicsWorld.contactDelegate = self
    emitter = SKEmitterNode(fileNamed: "Particle.sks")
    emitter?.removeFromParent()
    
    balls.forEach { $0.removeFromParent() }
    balls = []
    
    state = .notPlaying
    score = 0
    
    startPostion = childNode(withName: "//startPostion")!
    endPostion = childNode(withName: "//endPostion")!
    scoreLabel = childNode(withName: "//score")! as? SKLabelNode
    scoreLabel.text = "\(score)"
    slider = childNode(withName: "//slider")! as? SKSpriteNode
    slider.children.forEach {
      $0.physicsBody?.usesPreciseCollisionDetection = true
    }
    maxPosition = slider.size.width / 2.0 - 20
    
    if ballsTemplate.isEmpty {
      func make(sprite: SKNode) -> SKShapeNode {
        let sprite = sprite as! SKSpriteNode
        sprite.removeFromParent()
        let node = SKShapeNode(circleOfRadius: 15)
        node.name = sprite.name
        node.fillColor = sprite.color
        node.strokeColor = SKColor.clear
        
        let physicsBody = SKPhysicsBody(circleOfRadius: 10)
        physicsBody.affectedByGravity = false
        physicsBody.categoryBitMask = sprite.physicsBody!.categoryBitMask
        physicsBody.usesPreciseCollisionDetection = true
        node.physicsBody = physicsBody
        return node
      }
      
      ballsTemplate = [
        make(sprite: childNode(withName: "//ballRed")!),
        make(sprite: childNode(withName: "//ballYellow")!),
        make(sprite: childNode(withName: "//ballGreen")!)
      ]
    }
  }
  
  private func updateSliderPostionBy(_ value: CGFloat) {
    let position = slider.position.x + value
    slider.position.x = max(-maxPosition, min(position, maxPosition))
  }
  
}

extension GameScene: SKPhysicsContactDelegate {
  
  func didBegin(_ contact: SKPhysicsContact) {
    guard state != .gameOver else { return }
    
    let (bodyA, bodyB) = (contact.bodyA, contact.bodyB)
    
    if bodyA.node?.parent === slider && bodyB.node?.parent === slider {
      return
    }
    
    let ball = bodyA.node as? SKShapeNode ?? bodyB.node as! SKShapeNode
    
    if bodyA.categoryBitMask == bodyB.categoryBitMask {
      ball.removeFromParent()
      score += 1
      scoreLabel.text = "\(score)"
      return
    } else {
      state = .gameOver
      slider.addChild(emitter!)
    }
  }
  
}

extension GameScene {
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard state != .gameOver else {
      setUp()
      return
    }
    lastLocation = touches.first?.location(in: self).x
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard state != .gameOver else { return }
    
    let location = touches.first!.location(in: self).x
    defer { self.lastLocation = location }
    
    guard let lastLocation = lastLocation else { return }
    updateSliderPostionBy(location - lastLocation)
  }
  
}
