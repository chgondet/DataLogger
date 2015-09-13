//: Playground - noun: a place where people can play

import UIKit
import CoreGraphics


class clDataLogger {
    var values : [CGFloat] = []
    
    init(){
        

    for i in 0...100 {
        values.append((CGFloat)(i))
    }
    }
    
}

var str = "Hello, playground"
var myInstance = clDataLogger ()

print( myInstance.values)

