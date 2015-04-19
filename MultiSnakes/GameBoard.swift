//
//  GameBoard.swift
//  MultiSnakes
//
//  Created by Paul Balducci on 4/12/15.
//  Copyright (c) 2015 Bradley Balducci. All rights reserved.
//

import Foundation
import SpriteKit

let numRows = 25
let numCols = 18

enum Color: Int {
    case blue = 0
    case orange = 1
    case purple = 2
    case red = 3
    case teal = 4
    case yellow = 5
}

let NumberOfColors = 6

class GameBoard {

    var blocks = Array2D<Block>(columns: numCols, rows: numRows)
    var fruitPoint: Point?
    
    init() {
        createInitialBlocks()
    }
    
    func blockAtPoint(column: Int, row: Int) -> Block? {
        assert(column >= 0 && column < numCols, "Column assert failed")
        assert(row >= 0 && row < numRows, "Row assert failed")
        return blocks[column, row]
    }

    func createInitialBlocks() {
        for row in 0..<numRows {
            for column in 0..<numCols {
                blocks[column, row] = Block(thisx: column, thisy: row)
            }
        }
        placeWalls()
        placeSnakes(mySnake, snake2: theirSnake)
        placeFruit()
    }

    func getAllBlocks() -> Array2D<Block> {
        return blocks
    }
    
    func placeSnakes(snake1: Snake, snake2: Snake) {
        for block in snake1.bodyParts {
            var thisX = block.coordinate.x
            var thisY = block.coordinate.y
            blocks[thisX, thisY] = block
        }
        
        for block in snake2.bodyParts {
            var thisX = block.coordinate.x
            var thisY = block.coordinate.y
            blocks[thisX, thisY] = block
        }
    }
    
    func placeWalls() {
        for var i = 0; i < numRows; i++ {
            blocks[0, i]?.color = "purple"
            blocks[0, i]?.isSolid = true
            
            blocks[numCols-1, i]?.color = "purple"
            blocks[numCols-1, i]?.isSolid = true
        }
        
        for var j = 0; j < numCols; j++ {
            blocks[j, 0]?.color = "purple"
            blocks[j, 0]?.isSolid = true
            
            blocks[j, numRows-1]?.color = "purple"
            blocks[j, numRows-1]?.isSolid = true
        }
    }
    
    func placeFruit() {
        var x = Int(arc4random_uniform(UInt32(numCols-1))+1)
        var y = Int(arc4random_uniform(UInt32(numRows-1))+1)
        //can't place fruit at a solid Block or at either Snake's head (which is not solid)
        while blocks[x,y]?.isSolid == true && (x != mySnake.head.coordinate.x && y != mySnake.head.coordinate.y) && (x != theirSnake.head.coordinate.x && y != theirSnake.head.coordinate.y) {
            x = Int(arc4random_uniform(UInt32(numCols-1))+1)
            y = Int(arc4random_uniform(UInt32(numRows-1))+1)
        }
        blocks[x,y]?.isFruit = true
        blocks[x,y]?.color = "teal"
        fruitPoint = Point(x: x, y: y)
    }

    func moveSnake(snake: Snake, direction: Direction) {
        snake.moveBody(direction)
        var i = 0
        for block in snake.bodyParts {
            var thisX = block.coordinate.x
            var thisY = block.coordinate.y
            blocks[thisX, thisY] = block
            blocks[thisX, thisY]?.color = snake.color
            if i == snake.bodyParts.endIndex-1 { //if this is the snake's tail, make its previous position a blank Block (this does not yet work)
                blocks[block.lastPosition!.x, block.lastPosition!.y]?.color = "yellow"
                blocks[block.lastPosition!.x, block.lastPosition!.y]?.isSolid = false
                blocks[block.lastPosition!.x, block.lastPosition!.y]?.isFruit = false
            }
            i++
        }
    }
    
    func checkForDeath(snake: Snake) {
        var shouldDie: Bool = false
        if snake.direction == .right {
            if blocks[snake.head.coordinate.x+1, snake.head.coordinate.y]?.isSolid == true {
                shouldDie = true
            }
        }
        if snake.direction == .left {
            if blocks[snake.head.coordinate.x-1, snake.head.coordinate.y]?.isSolid == true{
                shouldDie = true          }
        }
        if snake.direction == .up {
            if blocks[snake.head.coordinate.x, snake.head.coordinate.y+1]?.isSolid == true {
                shouldDie = true           }
        }
        if snake.direction == .down {
            if blocks[snake.head.coordinate.x, snake.head.coordinate.y-1]?.isSolid == true {
                shouldDie = true           }
        }
        if shouldDie {
            gameOver()
        }
    }
    
    //Send end of game signal via this method.  If you need to call in a GameViewController, use:
    //
    //      let scene = GameScene(named: "GameScene")
    //      scene.gameOver()
    //
    // or we can add a delegate protocol to communicate between the GameBoard and the VC
    func gameOver() {
        println("Death")
    }
    
    func checkForFruit(snake: Snake) {
        var shouldGrow: Bool = false
        if snake.direction == .right {
            if blocks[snake.head.coordinate.x+1, snake.head.coordinate.y]?.isFruit == true {
                shouldGrow = true
            }
        }
        if snake.direction == .left {
            if blocks[snake.head.coordinate.x-1, snake.head.coordinate.y]?.isFruit == true{
                shouldGrow = true
            }
        }
        if snake.direction == .up {
            if blocks[snake.head.coordinate.x, snake.head.coordinate.y+1]?.isFruit == true {
                shouldGrow = true
            }
        }
        if snake.direction == .down {
            if blocks[snake.head.coordinate.x, snake.head.coordinate.y-1]?.isFruit == true {
                shouldGrow = true
            }
        }
        if shouldGrow {
            growSnake(snake)
            //Snake grows correctly, but still working on deleting/replacing the fruit once eaten
            blocks[fruitPoint!.x, fruitPoint!.y]?.color = "yellow"
            blocks[fruitPoint!.x, fruitPoint!.y]?.isFruit = false
        }
    }
    
    func growSnake(snake: Snake) {
        snake.growBody()
    }
    
    //just used for opponent's snake right now, won't go in final game
    func rotateDirection(snake: Snake) {
        var value: Int = 0
        var currentDirection = snake.direction
        value = currentDirection.rawValue+1
        if value > Direction.left.rawValue {
            value = Direction.up.rawValue
        }
        snake.direction = Direction(rawValue: value)!
    }
    
    func changeDirection(snake: Snake, swipe: String) {
        var currentDirection: Direction = snake.direction
        var value: Int = 0
        if swipe == "right" {
            if currentDirection.rawValue == Direction.left.rawValue {
                value = Direction.up.rawValue
            } else {
                value = Direction.right.rawValue
            }
        } else if swipe == "left" {
            if currentDirection.rawValue == Direction.right.rawValue {
                value = Direction.up.rawValue
            } else {
                value = Direction.left.rawValue
            }
        }  else if swipe == "up" {
            if currentDirection.rawValue == Direction.down.rawValue {
                value = Direction.left.rawValue
            } else {
                value = Direction.up.rawValue
            }
        } else if swipe == "down" {
            if currentDirection.rawValue == Direction.up.rawValue {
                value = Direction.left.rawValue
            } else {
                value = Direction.down.rawValue
            }
        } else {
            assert(true, "Swipe control error in changeDirection()")
        }
        snake.direction = Direction(rawValue: value)!
    }
}