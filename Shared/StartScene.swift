import SpriteKit

class StartScene: SKScene {
  
  var score: Int? = nil
  
  class func make() -> StartScene {
    guard let scene = SKScene(fileNamed: "StartScene") as? StartScene else {
      print("Failed to load GameScene.sks")
      abort()
    }
    scene.scaleMode = .aspectFill
    return scene
  }
  
  override func didMove(to view: SKView) {
    guard let score = score else {
      return
    }
    
    let gameOverLabel = self.childNode(withName: "//gameOver") as? SKLabelNode
    gameOverLabel?.text = "GAME OVER"
    
    let scoreLabel = self.childNode(withName: "//score") as? SKLabelNode
    scoreLabel?.text = "Score: \(score)"
  }
}

extension StartScene {
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let location = touches.first?.location(in: self) {
      if nodes(at: location).first?.name == .some("start") {
        let transition = SKTransition.doorway(withDuration: 1)
        transition.pausesOutgoingScene = true
        let gameScene = GameScene.make()
        view?.presentScene(gameScene, transition: transition)
      }
    }
  }
}
