//
//  Names.swift
//  SwiftNES
//
//  Created by David Green on 6/2/15.
//  Copyright (c) 2015 DigitalWorlds. All rights reserved.
//

import Swift

class UniformImage: Image, Color, Model {
    var C: Color
    
    init(c: Color) {
        self.C = c
    }
    
    func RGBA() -> (r: UInt32, g: UInt32, b: UInt32, a: UInt32) {
        return self.C.RGBA()
    }
    
    func ColorModel() -> Model {
        return self
    }
    
    func Convert(c: Color) -> Color {
        return self.C
    }
    
    func Bounds() -> Rectangle {
        return Rectangle(-1000000000, -1000000000, 1000000000, 1000000000)
    }
    
    func At(x: Int, _ y: Int) -> Color {
        return self.C
    }
    
    func Set(x: Int, _ y: Int, c: Color) {
        // Do nothing
    }
    
    func Opaque() -> Bool {
        let (_, _, _, a) = self.C.RGBA()
        return a == 0xffff
    }
}
