//
//  Hash.swift
//  SwiftNES
//
//  Created by Articulate on 6/4/15.
//  Copyright (c) 2015 DigitalWorlds. All rights reserved.
//

import Swift

protocol Hash: Writer {
    func Sum(b: [UInt8]) -> [UInt8]
    func Reset()
    func Size() -> Int
    func BlockSize() -> Int
}

protocol Hash32: Hash {
    func Sum32() -> UInt32
}

protocol Hash64: Hash {
    func Sum64() -> UInt64
}
