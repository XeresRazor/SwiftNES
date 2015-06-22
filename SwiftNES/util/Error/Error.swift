//
//  Error.swift
//  SwiftNES
//
//  Created by Articulate on 6/4/15.
//  Copyright (c) 2015 DigitalWorlds. All rights reserved.
//

import Swift

protocol Error: class {
    func Error() -> String
}

func NewError(text: String) -> Error? {
    return ErrorString(s: text)
}

class ErrorString: Error {
    var s: String
    
    init(s: String) {
        self.s = s
    }
    
    func Error() -> String {
        return self.s
    }
}

//func == (left: ErrorString, right: ErrorString) -> Bool {
//    let equal = left.s == right.s
//    return equal
//}