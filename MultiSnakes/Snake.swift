//
//  Snake.swift
//  MultiSnakes
//
//  Created by Paul Balducci on 4/12/15.
//  Copyright (c) 2015 Bradley Balducci. All rights reserved.
//

import Foundation
import SpriteKit

enum Direction: Int {
    case up = 1
    case right = 2
    case down = 3
    case left = 4
}

class Snake {
    var length: Int
    var bodyParts: [Block] = []
    var head: Block
    var tail: Block
    var nextTail: Block? // when Snake grows, this Block is added to bodyParts, solidified, and colored
    var direction: Direction
    var color: String
    
    init(thisColor: String, startx: Int, starty: Int) {
        color = thisColor
        length = 2
        direction = .right
        head = Block(thisx: startx, thisy: starty)
        head.color = thisColor
        bodyParts.append(head)
        for var i = 0; i < length; i++ { //sets the Snake's parts in a straight, horizontal line
            var lastBlock = bodyParts[bodyParts.endIndex - 1]
            var thisBlock: Block = Block(thisx: lastBlock.coordinate.x-1, thisy: lastBlock.coordinate.y)
            thisBlock.isSolid = true
            thisBlock.color = thisColor
            thisBlock.sprite = SKSpriteNode(texture: SKTexture(imageNamed: "\(thisColor)"))
            bodyParts.append(thisBlock)
        }
        tail = bodyParts[bodyParts.endIndex-1]
    }
    
    func moveHead(direction: Direction) -> Point? { //called in moveBody; just call moveBody at each tick
        switch direction {
        case .left:
            return self.head.moveTo(self.head.coordinate.x-1, thisy: self.head.coordinate.y)
        case .down:
            return self.head.moveTo(self.head.coordinate.x, thisy: self.head.coordinate.y-1)
        case .right:
            return self.head.moveTo(self.head.coordinate.x+1, thisy: self.head.coordinate.y)
        case .up:
            return self.head.moveTo(self.head.coordinate.x, thisy: self.head.coordinate.y+1)
        }
    }
    
    func moveBody(direction: Direction) {
        var nextPosition: Point? = moveHead(direction)
        for var i = 1; i < bodyParts.count; i++ { //start i at one because the head (index0) has already moved
            var thisBlock: Block = bodyParts[i]
            var pointHold: Point? = bodyParts[i].moveTo(nextPosition!.x, thisy: nextPosition!.y)
            nextPosition = pointHold
            if i == bodyParts.count - 1 {
                tail = thisBlock
            }
        }
    }
    
    
    func findNextTail() -> Point {
        var nextToLast = bodyParts[bodyParts.endIndex-2]
        var last = bodyParts[bodyParts.endIndex-1]
        if nextToLast.coordinate.x == last.coordinate.x {// if the two final body parts are vertical neighbors...
            if nextToLast.coordinate.y < last.coordinate.y { //..and the tail is above the next-to-last part...
                return Point(x: last.coordinate.x, y: last.coordinate.y+1) //...the next tail goes above the tail
            } else {
                return Point(x: last.coordinate.x, y: last.coordinate.y-1)
            }
        } else if nextToLast.coordinate.y == last.coordinate.y {
            if nextToLast.coordinate.x < last.coordinate.x {
                return Point(x: last.coordinate.x+1, y: last.coordinate.y)
            } else {
                return Point(x: last.coordinate.x-1, y: last.coordinate.y)
            }
        } else {
            println("Error in findNextTail(): Snake")
            var crashWithMissingValueInDicitonary = Dictionary<Int,Int>()
            let crashInt = crashWithMissingValueInDicitonary[1]!
            return Point(x: 0, y: 0)
        }
    }
    
    func growBody() {
        var nextTailPoint = findNextTail()
        var thisNextTail = Block(thisx: nextTailPoint.x, thisy: nextTailPoint.y)
        thisNextTail.isSolid = true
        thisNextTail.color = color
        bodyParts.append(thisNextTail)
        println("Grown")
    }
    
}