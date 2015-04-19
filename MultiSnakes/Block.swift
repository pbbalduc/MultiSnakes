import Foundation
import SpriteKit

struct Point {
    var x: Int
    var y: Int
}

class Block {
    var sprite: SKSpriteNode?
    var color: String
    var isSolid: Bool
    var isFruit: Bool
    var coordinate: Point //relative to game board (not pixels)
    var lastPosition: Point? // coordinates of the Block's previous position if it is a moving Block (part of the Snake)
    
    init(thisx: Int, thisy: Int) {
        isSolid = false
        isFruit = false
        coordinate = Point(x: thisx, y: thisy)
        color = "yellow"
        //sprite = SKSpriteNode(texture: atlas.textureNamed("yellow"))
    }
    
    func moveTo(thisx: Int, thisy: Int) -> Point? { //returns the previous cordinates of the block so its trailing Block (in the Snake) can occupy that space
        lastPosition = coordinate
        coordinate.x = thisx
        coordinate.y = thisy
        
        return lastPosition
    }
}