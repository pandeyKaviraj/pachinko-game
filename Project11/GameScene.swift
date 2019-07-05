import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var numberOfBalls = 5
    var allBalls = ["ballBlue", "ballGreen", "ballCyan", "ballRed", "ballYellow", "ballPurple", "ballGrey"]
    
    var scoreLabel: SKLabelNode!
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    //Edit or done properties
    var editLabel: SKLabelNode!
    
    var editingMode: Bool = false {
        
      didSet {
            if editingMode {
                editLabel.text = "Done"
            }
            else {
                editLabel.text = "Edit"
            }
        }
    }
    
    
    override func didMove(to view: SKView) {
        
        //create a sprite node
        let background = SKSpriteNode(imageNamed: "background")
        //place it to the middle
        background.position = CGPoint(x: 512, y: 384)
        //draws faster
        background.blendMode = .replace
        //put it to behind
        background.zPosition = -1
        //add it to the game scene
        addChild(background)
        //This adds physics body to whole screen
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        //this below code means this class notified when two physics body come in contact
        physicsWorld.contactDelegate = self
    
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        
        //slotBase add
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        //score label add
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        //Edit and done add
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //touch on screen with 1,2 or 3 fingers
        guard let touch = touches.first else { return }
        //get location of touch
        let location = touch.location(in: self)
        //code for edit/done touch or ball create observer
        let objects = nodes(at: location)
        if objects.contains(editLabel) {
            editingMode.toggle()
        }
        else {
            if editingMode {
                //create a box
                //we create a size with a height of 16 and a width between 16 and 128
                let size = CGSize(width: Int.random(in: 16...128), height: 16)
                //create an SKSpriteNode with the random size we made along with a random color
                let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                //then give the new box a random rotation and place it at the location that was tapped on the screen.
                box.zRotation = CGFloat.random(in: 0...3)
                box.position = location
                box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                box.physicsBody?.isDynamic = false
                addChild(box)
            } else
            {
                if numberOfBalls == 0
                {
                    exit(0)
                }
                //created a ball
                //part of challenge to generate random color ball
                let ball = SKSpriteNode(imageNamed: allBalls[Int.random(in: 0...6)])
                ////give the box a physics body of box size,  add circular physics to this ball
                ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                // we're giving the ball's physics body a restitution (bounciness) level of 0.4, where values are from 0 to 1.
                ball.physicsBody!.restitution = 0.4
                
                //We want to know every collision of ball
                ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
                //ball position is touch location
                //below code is challenge 2 and
                ball.position = CGPoint(x: location.x, y: 768)
                //giving ball node a name
                ball.name = "ball"
                addChild(ball)
            }
        }
    }
    
    func makeBouncer(at position: CGPoint) {
        //Bouncing image for bounce add to game
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        //"centered horizontally on the bottom edge of the scene."
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    //Identical of makebouncer method and isGood is for to put good or bad slot
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        }
            
        else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            //slotbase is a action or collision part and want to know that part so need below code
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        //Adding physics for slotbase
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        //slot base needs to be non - dynamic
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    //********MARK: Ball collision with slotBase*********//
    
    //when a ball collides with something else
    func collisionBetween(ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball: ball)
            score += 1
        }
        else if object.name == "bad" {
            destroy(ball: ball)
            score -= 1
        }
    }
    
    
    //when we're finished with the ball and want to get rid of it.
    func destroy(ball: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.particlePosition = ball.position
            addChild(fireParticles)
        }
        //removes a node from your game
        ball.removeFromParent()
    }
    
    
    //We'll get told which two bodies collided, and the contact method needs to determine which one is the ball so that it can call collisionBetween() with the correct parameters.Note: ball collides with good or bad
    func didBegin(_ contact: SKPhysicsContact) {
        //we’ll use guard to ensure both bodyA and bodyB have nodes attached
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        if nodeA.name == "ball" {
            collisionBetween(ball: nodeA, object: nodeB)
        }
        else if nodeB.name == "ball" {
            collisionBetween(ball: nodeB, object: nodeA)
        }
    }
}
