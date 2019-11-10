

import SpriteKit

class MainMenu: SKScene {

    var starField:SKEmitterNode!
    
    var newGameButtonNode: SKSpriteNode!
    var levelButtonNode: SKSpriteNode!
    var labelLevelNode: SKLabelNode!
    
    
    override func didMove(to view: SKView) {
        
        starField = self.childNode(withName: "starfield") as! SKEmitterNode
        starField.advanceSimulationTime(10)
        
        newGameButtonNode = self.childNode(withName: "newGameButton") as! SKSpriteNode
        levelButtonNode = self.childNode(withName: "LevelButton") as! SKSpriteNode
        labelLevelNode = self.childNode(withName: "labelLevelButton") as! SKLabelNode
       
        let userLever = UserDefaults.standard
        
        if userLever.bool(forKey: "hard") {
            labelLevelNode.text = "Hard"
        } else {
            labelLevelNode.text = "Easy"
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            
            if nodesArray.first?.name == "newGameButton" {
                let transition = SKTransition.flipVertical(withDuration: 0.5)
                let gameScene = GameScene(size: UIScreen.main.bounds.size)
                self.view?.presentScene(gameScene, transition: transition)
            } else if nodesArray.first?.name == "LevelButton"{
                changeLevel()
                
            }
        }
    }
    func changeLevel() {
        let userLevel = UserDefaults.standard
        
        if labelLevelNode.text == "Easy" {
            labelLevelNode.text = "Hard"
            userLevel.set(true, forKey: "hard")
        } else {
            labelLevelNode.text = "Easy"
            userLevel.set(false, forKey: "hard")
        }
        userLevel.synchronize()
    }
}
