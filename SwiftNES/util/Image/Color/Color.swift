//
//  Color.swift
//  SwiftNES
//
//  Created by Articulate on 6/2/15.
//  Copyright (c) 2015 DigitalWorlds. All rights reserved.
//

import Swift

//  color implements a basic color library.

// Color can convert itself to alpha-premultiplied 16-bits per channel RGBA.
// The conversion may be lossy.

protocol Color {
    // RGBA returns the alpha-premultiplied red, green, blue and alpha values
    // for the color. Each value ranges within [0, 0xFFFF], but is represented
    // by a uint32 so that multiplying by a blend factor up to 0xFFFF will not
    // overflow.
    func RGBA() -> (r: UInt32, g: UInt32, b: UInt32, a: UInt32)
}

protocol Model {
    func Convert(c: Color) -> Color
}

// RGBA represents a traditional 32-bit alpha-premultiplied color,
// having 8 bits for each of red, green, blue and alpha.
struct RGBAColor: Color {
    var R, G, B, A: UInt8
    
    init() {
        self.init(0, 0, 0, 0)
    }
    
    init(_ r: UInt8, _ g: UInt8, _ b: UInt8, _ a: UInt8) {
        self.R = r
        self.G = g
        self.B = b
        self.A = a
    }
    
    func RGBA() -> (r: UInt32, g: UInt32, b: UInt32, a: UInt32) {
        var r = UInt32(self.R)
        r |= r << 8
        var g = UInt32(self.G)
        g |= g << 8
        var b = UInt32(self.B)
        b |= b << 8
        var a = UInt32(self.A)
        a |= a << 8
        return (r, g, b, a)
    }
}

struct RGBA16Color: Color {
    var R, G, B, A: UInt16
    
    init() {
        self.init(0, 0, 0, 0)
    }
    
    init(_ r: UInt16, _ g: UInt16, _ b: UInt16, _ a: UInt16) {
        self.R = r
        self.G = g
        self.B = b
        self.A = a
    }
    
    func RGBA() -> (r: UInt32, g: UInt32, b: UInt32, a: UInt32) {
        let r = UInt32(self.R)
        let g = UInt32(self.G)
        let b = UInt32(self.B)
        let a = UInt32(self.A)
        return (r, g, b, a)
    }
}

struct AlphaColor: Color {
    var A: UInt8
    
    init() {
        self.init(0)
    }
    
    init(_ a: UInt8) {
        self.A = a
    }
    
    func RGBA() -> (r: UInt32, g: UInt32, b: UInt32, a: UInt32) {
        var a = UInt32(self.A)
        a |= a << 8
        return (a, a, a, a)
    }
}

struct Alpha16Color: Color {
    var A: UInt16
    
    init() {
        self.init(0)
    }
    
    init(_ a: UInt16) {
        self.A = a
    }
    
    func RGBA() -> (r: UInt32, g: UInt32, b: UInt32, a: UInt32) {
        var a = UInt32(self.A)
        return (a, a, a, a)
    }
}

func ModelFunc(f: (Color) -> Color) -> Model {
    return modelFunc(f: f)
}

struct modelFunc: Model {
    let f: (Color) -> Color
    
    func Convert(c: Color) -> Color {
        return self.f(c)
    }
}

let RGBAModel = ModelFunc(rgbaModel)
let RGBA16Model = ModelFunc(rgba16Model)
let AlphaModel = ModelFunc(alphaModel)
let Alpha16Model = ModelFunc(alpha16Model)

func rgbaModel(c: Color) -> Color {
    if let _ = c as? RGBAColor {
        return c
    }
    
    let (r, g, b, a) = c.RGBA()
    return RGBAColor(UInt8(r >> 8), UInt8(g >> 8), UInt8(b >> 8), UInt8(a >> 8))
}

func rgba16Model(c: Color) -> Color {
    if let _ = c as? RGBA16Color {
        return c
    }
    
    let (r, g, b, a) = c.RGBA()
    return RGBA16Color(UInt16(r), UInt16(g), UInt16(b), UInt16(a))
}

func alphaModel(c: Color) -> Color {
    if let _ = c as? AlphaColor {
        return c
    }
    
    let (_, _, _, a) = c.RGBA()
    return AlphaColor(UInt8(a >> 8))
}

func alpha16Model(c: Color) -> Color {
    if let _ = c as? Alpha16Color {
        return c
    }
    
    let (_, _, _, a) = c.RGBA()
    return Alpha16Color(UInt16(a))
}

//  Standard colors
let BlackColor = RGBA16Color(0, 0, 0, 0xffff)
let WhiteColor = RGBA16Color(0xffff, 0xffff, 0xffff, 0xffff)
let TransparentColor = Alpha16Color(0)
let OpaqueColor = Alpha16Color(0xffff)
