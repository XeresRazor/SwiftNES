//
//  String+MD5.swift
//  SwiftNES
//
//  Created by David Green on 5/28/15.
//  Copyright (c) 2015 DigitalWorlds. All rights reserved.
//

import Foundation

extension String {
    func md5() -> String! {
        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = CC_LONG(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<UInt8>(malloc(digestLen))
        
        CC_MD5(UnsafePointer<Void>(str!), strLen, result)
        
        var hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        free(result)
        
        return String(hash)
    }
}