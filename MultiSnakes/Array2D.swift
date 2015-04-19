//
//  Array2D.swift
//  TwoSnakes
//
//  Created by Paul Balducci on 4/5/15.
//  Copyright (c) 2015 Bradley Balducci. All rights reserved.
//

import Foundation

class Array2D<T> { //T means array will store any type of data
    let columns: Int
    let rows: Int
    let count: Int
    
    var array: Array<T?> //this will actually store the objects for each class instance
    //optional so that we can accept objects with nil value
    
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        self.count = columns*rows
        
        //initialize array, size of row*col
        array = Array<T?>(count: rows * columns, repeatedValue: nil)
    }
    
    // allows the array[columns, row] syntax
    subscript(column: Int, row: Int) -> T? {
        get {
            return array[(row * columns) + column]
        }
        set { // allows changing values in array i.e. array[4,6] = 1
            array[(row * columns) + column] = newValue
        }
    }
}