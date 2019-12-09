
import SpriteKit

class ResetButton: SKNode {
    var defaultButton: SKSpriteNode
    var activeButton: SKSpriteNode
    var action: () -> Void
    init (defaultButtonImage: String, activeButtonImage: String, buttonAction: @escaping () -> Void){
        defaultButton = SKSpriteNode(imageNamed: defaultButtonImage)
        activeButton = SKSpriteNode(imageNamed: activeButtonImage)
        activeButton.isHidden = true
        action = buttonAction
        
        super.init()
        
        isUserInteractionEnabled = true
        addChild(defaultButton)
        addChild(activeButton)
    }
    
    required init (coder aDecoder: NSCoder){
        fatalError(":]")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeButton.isHidden = false
        defaultButton.isHidden = true
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        let touch: UITouch = touches.first!
        let location: CGPoint = touch.location(in: self)
        
        if(defaultButton.contains(location)){
            activeButton.isHidden = false
            defaultButton.isHidden = true
        } else {
            activeButton.isHidden = true
            defaultButton.isHidden = false
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch = touches.first!
        let location: CGPoint = touch.location(in: self)
        
        if(defaultButton.contains(location)){
            action()
        }
        
        activeButton.isHidden = true
        defaultButton.isHidden = false
    }
}
