//
//  Reader.swift
//  SwiftNES
//
//  Created by Articulate on 6/4/15.
//  Copyright (c) 2015 DigitalWorlds. All rights reserved.
//

import Swift

// Color type
let ctGrayscale = 0
let ctTrueColor = 2
let ctPaletted = 3
let ctGrayscaleAlpha = 4
let ctTrueColorAlpha = 6

enum CB: Int {
    case cbInvalid = 0, cbG1, cbG2, cbG4, cbG8, cbGA8, cbTC8, cbP1, cbP2, cbP4, cbP8, cbTCA8,  cbG16, cbGA16, cbTC16, cbTCA16
}

// Filter type
let ftNone = 0
let ftSub = 1
let ftUp = 2
let ftAverage = 3
let ftPaeth = 4
let nFilter = 5

// Interlace Type
let itNone: UInt8 = 0
let itAdam7: UInt8 = 1

struct InterlaceScan {
    var xFactor, yFactor, xOffset, yOffset: Int
    init(_ xFactor: Int, _ yFactor: Int, _ xOffset: Int, _ yOffset: Int) {
        self.xFactor = xFactor
        self.yFactor = yFactor
        self.xOffset = xOffset
        self.yOffset = yOffset
    }
}

let interlacing = [
    InterlaceScan(8, 8, 0, 0),
    InterlaceScan(8, 8, 4, 0),
    InterlaceScan(4, 8, 0, 4),
    InterlaceScan(4, 4, 2, 0),
    InterlaceScan(2, 4, 0, 2),
    InterlaceScan(2, 2, 1, 0),
    InterlaceScan(1, 2, 0, 1),
    
]

enum DS: Int {
    case dsStart = 0, dsSeenIHDR, dsSeenPLTE, dsSeenIDAT, dsSeenIEND
}

let pngHeader = "\u{89}PNG\r\n\u{1a}\n"


class FormatError: Error {
    var string: String
    
    init(string: String) {
        self.string = string
    }
    
    func Error() -> String {
        return "png: invalid format: " + self.string
    }
}

class UnsupportedError: Error {
    var string: String
    
    init(string: String) {
        self.string = string
    }
    
    func Error() -> String {
        return "png: unsupported feature: " + self.string
    }
}

let chunkOrderError = FormatError(string: "Chunk out of order")

struct decoder {
    var r: Reader
    var img: Image
    var crc: Hash32
    var width, height: Int
    var depth: Int
//    var palette: Palette
    var cb: CB
    var stage: DS
    var idatLength: UInt32
    var tmp = Array<UInt8>(count: 3 * 256, repeatedValue: 0)
    var interlace: Int
    
    mutating func parseIHDR(length: UInt32) -> Error? {
        if length != 13 {
            return FormatError(string: "bad IHDR length")
        }
        let (_, err) = ReadFull(self.r, self.tmp[0..<13])
        if err != nil {
            return err
        }
        self.crc.Write(self.tmp[0..<13])
        if self.tmp[10] != 0 {
            return UnsupportedError(string: "compresson method")
        }
        if self.tmp[11] != 0 {
            return UnsupportedError(string: "filter method")
        }
        if self.tmp[12] != itNone && self.tmp[12] != itAdam7 {
            return FormatError(string: "invalid interlace method")
        }
        self.interlace = Int(self.tmp[12])
        let w = Int32(bigEndian:(Int32(self.tmp[0]) | Int32(self.tmp[1] << 8) | Int32(self.tmp[2] << 16) | Int32(self.tmp[3] << 24)))
        return nil
    }
}

func min(a: Int, b: Int) -> Int {
    if a < b {
        return a
    }
    return b
}

func PNGDecode(r: Reader) -> Image?
{
    return nil
}
