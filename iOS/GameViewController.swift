import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let scene = StartScene.make()
    let skView = self.view as! SKView
    skView.presentScene(scene)
    skView.ignoresSiblingOrder = true
    skView.showsFPS = false
    skView.showsNodeCount = false
  }
  
  override var shouldAutorotate: Bool {
    return true
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    if UIDevice.current.userInterfaceIdiom == .phone {
      return .allButUpsideDown
    } else {
      return .all
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
}
