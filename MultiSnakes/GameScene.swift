
/*
   Feel free to ask about anything; there's still a few problems: there are blank blocks at the Snakes' starting position, I can't get the fruit to
move once eaten (just started on this so might not be a big deal), and if the two Snakes' heads collide, it will not register as a death (don't
worry about fixing that though, not a big deal since the very next tick will register a collision).  I somewhat fixed the Snake's growing problem,
but I need to do some more testing to double check.
   It seems like there's some little problem somewhere that is causing the board not to update properly (see redrawBoard() in this file).  To get
the Snakes' coordinates: mySnake.bodyParts[index].coordinate.x
*/

import SpriteKit

let BlockSize: CGFloat = 20.0 //pixels of each sprite
let tickLengthMillis = NSTimeInterval(600) //60% of a second
var lastTick: NSDate? // used for game clock; set to nil when you wanna pause the game
var board: GameBoard = GameBoard()
var index: Int = 0 // just used for automated theirSnake's movement; not for final game
var mySnake: Snake = Snake(thisColor: "red", startx: 10, starty: 10) //your snake is always red
var theirSnake: Snake = Snake(thisColor: "blue", startx: 10, starty: 20) //theirs is blue (each players is controlling a red snake from their perspective)
let atlas: SKTextureAtlas = SKTextureAtlas(named: "Sprites.atlas") //preloading the textures

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        self.scaleMode = .ResizeFill //scene should fill entire screen; for the final game we should add sprites to a gamelayer: SKNode (currently only an iphone 6 can see the whole grid/board)
        self.anchorPoint = CGPoint(x: 0, y: 0)
        
        //detect any swipes that occur on the scene (whole screen)
        let swipeRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("swipedRight:"))
        swipeRight.direction = .Right //NOT our custom Direction struct's "right"
        view.addGestureRecognizer(swipeRight)
        
        let swipeLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("swipedLeft:"))
        swipeLeft.direction = .Left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeUp: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("swipedUp:"))
        swipeUp.direction = .Up
        view.addGestureRecognizer(swipeUp)
        
        let swipeDown: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("swipedDown:"))
        swipeDown.direction = .Down
        view.addGestureRecognizer(swipeDown)
        
        addSpritesToBlocks(board.blocks)
        
        lastTick = NSDate() //start the game clock
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
       
    }
   
    override func update(currentTime: CFTimeInterval) {
        if lastTick == nil { // if game is paused
            return
        }
        
        //to make game move faster, change tickLengthMillis above the scene class declaration
        var timePassed = lastTick!.timeIntervalSinceNow * -1000.0
        if timePassed > tickLengthMillis {
            lastTick = NSDate()
            board.checkForDeath(mySnake)
            board.checkForFruit(mySnake)
 
            if index%4 == 0 { // simulating opponent's movement; just for testing
                board.rotateDirection(theirSnake)
            }

            board.moveSnake(mySnake, direction: mySnake.direction)
            board.moveSnake(theirSnake, direction: theirSnake.direction)
            
            index++ //testing stuff

            redrawBoard(board.blocks)
        }
    }
    
    func startTicking() {
        lastTick = NSDate()
    }
    
    func stopTicking() {
        lastTick = nil
    }
    
    func removeBlocks() {
        self.removeAllChildren()
    }
    // place sprites in the scene depending on each Block's color and x/y coordinates
    func addSpritesToBlocks(blocks: Array2D<Block>) {
        
        for var i = 0; i < numCols; i++ {
            for var j = 0; j < numRows; j++ {
                let theblock: Block = blocks[i, j]!
                let sprite = SKSpriteNode(texture: atlas.textureNamed(theblock.color))
                sprite.position = pointForColumn(theblock.coordinate.x, row: theblock.coordinate.y)
                self.addChild(sprite)
                blocks[i,j]!.sprite = sprite
            }
        }
    }
    //used to convert a Block's x and y coordinates to pixels
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        return CGPoint(x: CGFloat(column)*BlockSize + BlockSize/2, y: CGFloat(row)*BlockSize + BlockSize/2)
    }
    
    //NEED HELP HERE
    //This method should check each Block's color, and give the sprite the appropriate texture,
    //so we should be able to change a Block's color variable in GameBoard and have it update in
    //our scene via this method; that does not happen without updating the position and zPosition
    //of the sprite and I have no clue why.  You can see through the debug info on the simulator
    //screen that the number of nodes never goes up so I can't understand why increasing the
    //zPosition matters if the sprite is being covered by another sprite
    func redrawBoard(thisBoard: Array2D<Block>) {
        for var i = 0; i < numCols; i++ {
            for var j = 0; j <  numRows; j++ {
                thisBoard[i,j]!.sprite?.texture = atlas.textureNamed(thisBoard[i,j]!.color)
                thisBoard[i,j]!.sprite?.position = pointForColumn(thisBoard[i,j]!.coordinate.x, row: thisBoard[i,j]!.coordinate.y)
                thisBoard[i,j]!.sprite?.zPosition = thisBoard[i,j]!.sprite!.zPosition+1
            }
        }
    }
    
    func swipedRight(sender: UISwipeGestureRecognizer) {
        board.changeDirection(mySnake, swipe: "right")
    }
    
    func swipedLeft(sender: UISwipeGestureRecognizer) {
        board.changeDirection(mySnake, swipe: "left")
    }
    
    func swipedUp(sender: UISwipeGestureRecognizer) {
        board.changeDirection(mySnake, swipe: "up")
    }
    
    func swipedDown(sender: UISwipeGestureRecognizer) {
        board.changeDirection(mySnake, swipe: "down")
    }
}
